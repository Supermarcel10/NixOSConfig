#!/usr/bin/env bash
# Install NixOS to a disk for Raspberry Pi.

set -euo pipefail

# ─── Colour helpers ──────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
    RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
    RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; RESET=''
fi

info()    { printf "${CYAN}  → %s${RESET}\n" "$*"; }
success() { printf "${GREEN}  ✓ %s${RESET}\n" "$*"; }
warn()    { printf "${YELLOW}  ⚠ %s${RESET}\n" "$*" >&2; }
section() { printf "\n${BOLD}%s${RESET}\n" "$*"; }

die() {
    printf "${RED}Error: %s${RESET}\n" "$*" >&2
    exit 1
}

# ─── Usage ───────────────────────────────────────────────────────────────────

usage() {
    cat <<EOF
Usage: sudo $0 [OPTIONS]

Partition a disk and install NixOS for Raspberry Pi, or install onto an
already-partitioned disk.

Required arguments:
  --flake <flake-ref>       Flake reference, e.g. .#rpi5 or .#nixosConfigurations.rpi5

Partitioning mode (default):
  --disk <device>           Whole disk to partition and install to (e.g. /dev/nvme0n1)

Pre-partitioned mode:
  --skip-partitioning       Skip partitioning; use existing partitions
  --root <device>           Root (ext4) partition  (e.g. /dev/sda2)
  --firmware <device>       Firmware (FAT32) partition  (e.g. /dev/sda1)

Optional:
  --firmware-size <size>    Size of firmware partition in parted format (default: 512MiB)
  --generations <n>         Number of boot generations to keep in firmware (default: 1)
  --age-identity <path>     Path to age secret key for decrypting secrets (e.g. ~/.age/keys)
  --secrets-dir <path>      Path to directory containing .age secret files
  --help, -h                Show this help

Examples:
  # Partition /dev/sda and install with key pre-seeding
  sudo $0 --disk /dev/sda --flake .#calisto \\
          --age-identity ~/.age/keys --secrets-dir ./secrets

  # Use existing partitions, no key pre-seeding
  sudo $0 --skip-partitioning --root /dev/sda2 --firmware /dev/sda1 --flake .#calisto
EOF
    exit 0
}

# ─── Argument parsing ─────────────────────────────────────────────────────────

DISK=""
ROOT_DEVICE=""
FIRMWARE_DEVICE=""
FLAKE_REF=""
SKIP_PARTITIONING=false
FIRMWARE_SIZE="512MiB"
NUM_GENERATIONS="1"
AGE_IDENTITY=""
SECRETS_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --disk)              [[ $# -ge 2 ]] || die "Missing value for --disk";             DISK="$2";              shift 2 ;;
        --root)              [[ $# -ge 2 ]] || die "Missing value for --root";             ROOT_DEVICE="$2";       shift 2 ;;
        --firmware)          [[ $# -ge 2 ]] || die "Missing value for --firmware";         FIRMWARE_DEVICE="$2";   shift 2 ;;
        --flake)             [[ $# -ge 2 ]] || die "Missing value for --flake";            FLAKE_REF="$2";         shift 2 ;;
        --firmware-size)     [[ $# -ge 2 ]] || die "Missing value for --firmware-size";    FIRMWARE_SIZE="$2";     shift 2 ;;
        --generations)       [[ $# -ge 2 ]] || die "Missing value for --generations";      NUM_GENERATIONS="$2";   shift 2 ;;
        --age-identity)      [[ $# -ge 2 ]] || die "Missing value for --age-identity";     AGE_IDENTITY="$2";      shift 2 ;;
        --secrets-dir)       [[ $# -ge 2 ]] || die "Missing value for --secrets-dir";      SECRETS_DIR="$2";       shift 2 ;;
        --skip-partitioning) SKIP_PARTITIONING=true; shift ;;
        --help|-h) usage ;;
        *) die "Unknown argument: $1" ;;
    esac
done

# ─── Validation ───────────────────────────────────────────────────────────────

[[ -n "$FLAKE_REF" ]] || die "--flake is required"
[[ "$NUM_GENERATIONS" =~ ^[0-9]+$ ]] || die "--generations must be a non-negative integer"
[[ $EUID -eq 0 ]] || die "This script must be run as root (use sudo)"

if "$SKIP_PARTITIONING"; then
    [[ -n "$ROOT_DEVICE" && -n "$FIRMWARE_DEVICE" ]] \
        || die "--skip-partitioning requires both --root and --firmware"
    [[ -z "$DISK" ]] \
        || die "--disk cannot be used together with --skip-partitioning"
else
    [[ -n "$DISK" ]] || die "Either --disk or --skip-partitioning + --root + --firmware is required"
    [[ -z "$ROOT_DEVICE" && -z "$FIRMWARE_DEVICE" ]] \
        || die "--root and --firmware cannot be used in partitioning mode; use --disk instead"
fi

# Validate age arguments - both must be provided together or not at all
if [[ -n "$AGE_IDENTITY" && -z "$SECRETS_DIR" ]]; then
    die "--age-identity requires --secrets-dir to also be set"
fi
if [[ -n "$SECRETS_DIR" && -z "$AGE_IDENTITY" ]]; then
    die "--secrets-dir requires --age-identity to also be set"
fi

require_block_device() {
    local path=$1 label=$2
    [[ -b "$path" ]] || die "$label '$path' does not exist or is not a block device"
}

# ─── Flake ref normalisation ──────────────────────────────────────────────────

normalize_flake_ref() {
    local ref=$1

    # Split on '#' into path and attr parts
    local path="${ref%%#*}"
    local attr="${ref##*#}"

    # Bare absolute paths like /home/nixos/nixos are not valid flake refs
    # without a URI scheme. Rewrite them as path: so nix eval can find them.
    # Leave relative paths (.) and already-schemed refs untouched.
    if [[ "$path" == /* && "$path" != path:* && "$path" != git+* ]]; then
        path="path:${path}"
    fi

    # If the attr already contains nixosConfigurations, leave it as-is.
    if [[ "$attr" == *"nixosConfigurations"* ]]; then
        printf '%s#%s\n' "$path" "$attr"
    else
        printf '%s#nixosConfigurations.%s\n' "$path" "$attr"
    fi
}

FLAKE_REF=$(normalize_flake_ref "$FLAKE_REF")
NIXOS_INSTALL_FLAKE="${FLAKE_REF/\#nixosConfigurations./\#}"

# ─── Derive hostname from flake ref ──────────────────────────────────────────
# Extracts the host name from the flake attribute, e.g.
#   .#nixosConfigurations.calisto  →  calisto

HOSTNAME="${FLAKE_REF##*.}"
info "Derived hostname: ${HOSTNAME}"

# ─── Partition-name helper ────────────────────────────────────────────────────
# Appends a partition suffix that works for both /dev/sdX and /dev/nvme0nX style
# devices (the latter need a 'p' before the number).

partition_name() {
    local disk=$1 num=$2
    if [[ "$disk" =~ (nvme|mmcblk|loop)[0-9] ]]; then
        printf '%sp%s\n' "$disk" "$num"
    else
        printf '%s%s\n' "$disk" "$num"
    fi
}

# ─── Destructive-operation confirmation ──────────────────────────────────────

confirm_destructive() {
    local disk=$1

    section "WARNING - DESTRUCTIVE OPERATION"
    printf "\n"
    warn "ALL DATA on ${BOLD}${disk}${RESET}${YELLOW} will be permanently destroyed."
    warn "This cannot be undone."
    printf "\n"

    # Show current partition table
    if command -v lsblk &>/dev/null; then
        info "Current layout of ${disk}:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "$disk" 2>/dev/null || true
        printf "\n"
    fi

    printf "${BOLD}Type the full device path to confirm you want to wipe it: ${RESET}"
    local answer
    read -r answer

    if [[ "$answer" != "$disk" ]]; then
        printf "\nConfirmation did not match. Aborting.\n"
        exit 1
    fi

    # Second, softer confirmation
    printf "${YELLOW}Are you absolutely sure? (yes/no): ${RESET}"
    read -r answer
    if [[ "$answer" != "yes" ]]; then
        printf "\nAborted.\n"
        exit 1
    fi
}

# ─── Unmount helper ───────────────────────────────────────────────────────────

unmount_if_mounted() {
    local path=$1 recursive=${2:-false}

    mountpoint -q "$path" 2>/dev/null || return 0

    if [[ "$recursive" == true ]]; then
        info "Unmounting ${path} (recursive)..."
        # Try a clean unmount first; fall back to --lazy only if that fails
        umount --recursive "$path" 2>/dev/null \
            || { warn "Clean unmount failed, retrying lazily..."; umount --lazy --recursive "$path"; }
    else
        info "Unmounting ${path}..."
        umount "$path" 2>/dev/null \
            || { warn "Clean unmount failed, retrying lazily..."; umount --lazy "$path"; }
    fi
}

# ─── Partitioning ─────────────────────────────────────────────────────────────

partition_disk() {
    local disk=$1

    require_block_device "$disk" "Disk"

    # Unmount anything already mounted from this disk
    local existing_mounts
    existing_mounts=$(lsblk -lno MOUNTPOINT "$disk" 2>/dev/null | grep -v '^$' || true)
    if [[ -n "$existing_mounts" ]]; then
        warn "The following mount points will be unmounted: $existing_mounts"
    fi
    # Walk partitions in reverse mount-depth order
    while IFS= read -r mp; do
        [[ -n "$mp" ]] && umount --lazy "$mp" 2>/dev/null || true
    done < <(lsblk -lno MOUNTPOINT "$disk" 2>/dev/null | grep -v '^$' | sort -r)

    section "Partitioning ${disk}..."
    info "Creating GPT partition table"
    parted --script "$disk" mklabel gpt

    info "Creating firmware partition (FAT32, ${FIRMWARE_SIZE}, label FIRMWARE)"
    parted --script "$disk" mkpart FIRMWARE fat32 1MiB "$FIRMWARE_SIZE"
    parted --script "$disk" set 1 boot on

    info "Creating root partition (ext4, remainder, label NIXOS_SD)"
    parted --script "$disk" mkpart NIXOS_SD ext4 "$FIRMWARE_SIZE" 100%

    # Re-read partition table
    partprobe "$disk" 2>/dev/null || true
    sleep 1   # Give the kernel a moment to create the new device nodes

    FIRMWARE_DEVICE=$(partition_name "$disk" 1)
    ROOT_DEVICE=$(partition_name "$disk" 2)

    info "Formatting ${FIRMWARE_DEVICE} as FAT32..."
    mkfs.fat -F 32 -n FIRMWARE "$FIRMWARE_DEVICE"

    info "Formatting ${ROOT_DEVICE} as ext4..."
    mkfs.ext4 -L NIXOS_SD "$ROOT_DEVICE"

    success "Partitioning complete"
    lsblk -o NAME,SIZE,FSTYPE,LABEL "$disk"
}

# ─── Temp dir & cleanup ───────────────────────────────────────────────────────

# Nix walks every path component from / down to the work directory and rejects
# anything world-writable - including /tmp itself (which is 1777).
# Using mktemp -d or any path under /tmp will not work.
#
# /run is owned by root (755) and is only writable by root, so the full path
# /run/nixos-install-<random> satisfies Nix's security checks. It also lives on
# a tmpfs so it won't leave debris on disk if the script is interrupted.
#
# umask 022 is applied so every subdirectory created inherits 755.
WORK_DIR=$(umask 022 && mktemp -d /run/nixos-install-XXXXXXXXXX)
chmod 755 "$WORK_DIR"
ROOT_MOUNT="$WORK_DIR/files"
FIRMWARE_MOUNT="$WORK_DIR/firmware"
(umask 022 && mkdir -p "$ROOT_MOUNT" "$FIRMWARE_MOUNT")

# Verify the full path is clean before going any further.
for _dir in /run "$WORK_DIR" "$ROOT_MOUNT" "$FIRMWARE_MOUNT"; do
    _perms=$(stat -c '%a' "$_dir")
    _world_write=$(( 8#$_perms & 8#002 ))
    if [[ "$_world_write" -ne 0 ]]; then
        die "Directory $_dir is world-writable ($_perms). Nix will refuse to build here."
    fi
    _other_exec=$(( 8#$_perms & 8#001 ))
    if [[ "$_other_exec" -eq 0 ]]; then
        die "Directory $_dir is not world-executable ($_perms). nixbld users cannot traverse it."
    fi
done
unset _dir _perms _world_write _other_exec

cleanup() {
    section "Cleaning up..."
    # Unmount firmware bind-mount inside root tree first
    unmount_if_mounted "$ROOT_MOUNT/boot/firmware"
    unmount_if_mounted "$FIRMWARE_MOUNT"
    unmount_if_mounted "$ROOT_MOUNT" true
    # Remove dirs only if empty - rmdir is safe here
    rmdir "$ROOT_MOUNT/boot/firmware" 2>/dev/null || true
    rmdir "$ROOT_MOUNT/boot"          2>/dev/null || true
    rmdir "$ROOT_MOUNT"               2>/dev/null || true
    rmdir "$FIRMWARE_MOUNT"           2>/dev/null || true
    rmdir "$WORK_DIR"                 2>/dev/null || true
}

trap cleanup EXIT

# ─── Evaluate and run a flake populate command ────────────────────────────────
# Runs nix eval to get the shell commands, then executes them with bash.
# The working directory is set to WORK_DIR so relative paths (e.g. ./files,
# ./firmware) in the populate commands resolve correctly.

run_populate_cmd() {
    local attr=$1
    local raw_cmd

    info "Evaluating ${attr}..."
    raw_cmd=$(nix eval "${FLAKE_REF}.${attr}" --raw) \
        || die "Failed to evaluate ${attr}"

    if [[ -z "$raw_cmd" ]]; then
        warn "${attr} produced an empty command - skipping"
        return
    fi

    info "Running populate commands from ${attr}..."
    (
        set -euo pipefail
        cd "$WORK_DIR"
        bash -c "$raw_cmd"
    ) || die "Populate command from ${attr} failed"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

printf "${BOLD}NixOS Raspberry Pi Installer${RESET}\n"
printf "  Flake:       %s\n" "$FLAKE_REF"
printf "  Hostname:    %s\n" "$HOSTNAME"

if "$SKIP_PARTITIONING"; then
    printf "  Mode:        pre-partitioned\n"
    printf "  Root:        %s\n" "$ROOT_DEVICE"
    printf "  Firmware:    %s\n" "$FIRMWARE_DEVICE"
    require_block_device "$ROOT_DEVICE"     "Root device"
    require_block_device "$FIRMWARE_DEVICE" "Firmware device"
else
    printf "  Mode:        partition + install\n"
    printf "  Disk:        %s\n" "$DISK"
    printf "  Firmware sz: %s\n" "$FIRMWARE_SIZE"
    confirm_destructive "$DISK"
    partition_disk "$DISK"
    printf "  Root:        %s\n" "$ROOT_DEVICE"
    printf "  Firmware:    %s\n" "$FIRMWARE_DEVICE"
fi

section "Mounting root partition ${ROOT_DEVICE}..."
mount "$ROOT_DEVICE" "$ROOT_MOUNT"

# Bind-mount the firmware partition inside the root tree so nixos-install
# and the populate commands both see /boot/firmware in the right place.
section "Mounting firmware partition ${FIRMWARE_DEVICE}..."
mount "$FIRMWARE_DEVICE" "$FIRMWARE_MOUNT"
mkdir -p "$ROOT_MOUNT/boot/firmware"
mount --bind "$FIRMWARE_MOUNT" "$ROOT_MOUNT/boot/firmware"

section "Checking flake configuration..."

# Warn if the flake mounts the firmware partition at /boot instead of
# /boot/firmware. nixos-raspberrypi expects /boot/firmware - mounting at /boot
# means config.txt and DTBs land in the wrong place and the Pi won't boot.
FIRMWARE_MOUNT_POINT=$(nix eval "${FLAKE_REF}.config.boot.loader.raspberry-pi.firmwarePath" --raw 2>/dev/null || true)
if [[ -n "$FIRMWARE_MOUNT_POINT" ]]; then
    info "firmwarePath is set to: ${FIRMWARE_MOUNT_POINT}"
    if nix eval "${FLAKE_REF}.config.fileSystems./boot" --json &>/dev/null \
        && ! nix eval "${FLAKE_REF}.config.fileSystems./boot/firmware" --json &>/dev/null; then
        warn "Your flake mounts the firmware partition at /boot, but firmwarePath is"
        warn "set to '${FIRMWARE_MOUNT_POINT}'. These are inconsistent."
        warn ""
        warn "In your configuration.nix, change:"
        warn '  fileSystems."/boot" -> fileSystems."/boot/firmware"'
        warn ""
        warn "Continuing anyway, but the Pi may not boot correctly."
    fi
fi

section "Building system configuration..."
TOPLEVEL=$(nix build "${FLAKE_REF}.config.system.build.toplevel" \
    --no-link --print-out-paths \
    --system aarch64-linux) \
    || die "nix build failed"
success "System toplevel: ${TOPLEVEL}"

section "Running nixos-install..."
nixos-install \
    --flake "$NIXOS_INSTALL_FLAKE" \
    --root  "$ROOT_MOUNT" \
    --no-bootloader \
    --no-root-password \
    --system "$TOPLEVEL" \
    || die "nixos-install failed"

# On aarch64 the system will activate on first boot.

section "Populating firmware partition..."

# nixos-raspberrypi manages /boot/firmware through
# config.system.build.installBootLoader - the same script the bootloader
# activation runs on every generation switch. This evaluates the path and run it
# against the built toplevel, rewriting two things:
#
#   1. The generation count (-g N) to avoid the bootloader script walking the
#      host's /nix/var/nix/profiles/system-*-link entries and copying the host's
#      own generations onto the Pi's firmware partition.
#
#   2. The firmware path (-f /path) to point at the mounted partition rather
#      than the live system path.
INSTALL_BOOT_LOADER=$(nix eval "${FLAKE_REF}.config.system.build.installBootLoader" --raw 2>/dev/null) \
    || die "Could not evaluate config.system.build.installBootLoader from flake"

info "installBootLoader: ${INSTALL_BOOT_LOADER}"

FIRMWARE_PATH=$(nix eval "${FLAKE_REF}.config.boot.loader.raspberry-pi.firmwarePath" --raw 2>/dev/null || printf '/boot/firmware')
info "firmwarePath configured as: ${FIRMWARE_PATH}"

if [[ ! -d "${ROOT_MOUNT}${FIRMWARE_PATH}" ]]; then
    die "Firmware mount point ${ROOT_MOUNT}${FIRMWARE_PATH} does not exist. Check your fileSystems config."
fi

# Apply generation count override first, then rewrite the firmware path.
INSTALL_CMD=$(printf '%s' "$INSTALL_BOOT_LOADER" \
    | sed -E "s|-g[[:space:]]+[0-9]+|-g ${NUM_GENERATIONS}|g")
INSTALL_CMD=$(printf '%s' "$INSTALL_CMD" \
    | sed -E "s|-f[[:space:]]+[^[:space:]]+|-f ${ROOT_MOUNT}${FIRMWARE_PATH}|g")

info "Running: ${INSTALL_CMD} ${TOPLEVEL}"
bash -c "${INSTALL_CMD} $(printf '%q' "$TOPLEVEL")" \
    || die "installBootLoader failed"

success "Firmware partition populated by installBootLoader"

# ─── Seed system clock for first boot ────────────────────────────────────────
# On hardware without a battery-backed RTC, the clock resets to epoch on power loss.
# If the date is too far off, TLS certificate validation fails before NTP can correct
# it - breaking the very DNS/NTP connections needed to fix the time.
#
# systemd-timesyncd reads /var/lib/systemd/timesync/clock on boot and uses it
# as a lower bound for the system clock, ensuring time only moves forward.
# Writing the installer host's current time here gives the Pi a sane starting
# point so NTP can resync cleanly on first boot.

section "Seeding system clock for first boot..."

TIMESYNC_DIR="$ROOT_MOUNT/var/lib/systemd/timesync"
TIMESYNC_CLOCK="$TIMESYNC_DIR/clock"

mkdir -p "$TIMESYNC_DIR"
touch "$TIMESYNC_CLOCK"
touch -t "$(date '+%Y%m%d%H%M.%S')" "$TIMESYNC_CLOCK"
chmod 644 "$TIMESYNC_CLOCK"
chown root:root "$TIMESYNC_CLOCK" 2>/dev/null || true

success "Clock seeded to $(date '+%Y-%m-%d %H:%M:%S %Z')"
info "systemd-timesyncd will use this as a lower bound on first boot"

# ─── Pre-seed age and host keys ───────────────────────────────────────────────
# The SSH host key and the age identity are pre-seeded from the secrets directory
# so the Pi can decrypt its own agenix secrets autonomously from the very first
# activation, without any manual intervention.

if [[ -n "$AGE_IDENTITY" && -n "$SECRETS_DIR" ]]; then
    section "Pre-seeding SSH host key and age identity for ${HOSTNAME}..."

    HOST_KEY_SECRET="${SECRETS_DIR}/${HOSTNAME}-host-key.age"
    AGE_KEY_SECRET="${SECRETS_DIR}/${HOSTNAME}-age-key.age"

    [[ -f "$HOST_KEY_SECRET" ]] || die "Host key secret not found: ${HOST_KEY_SECRET}"
    [[ -f "$AGE_KEY_SECRET"  ]] || die "Age key secret not found: ${AGE_KEY_SECRET}"
    [[ -f "$AGE_IDENTITY"    ]] || die "Age identity file not found: ${AGE_IDENTITY}"

    # Pre-seed SSH host key
    info "Decrypting and placing SSH host key..."
    mkdir -p "$ROOT_MOUNT/etc/ssh"
    chmod 755 "$ROOT_MOUNT/etc/ssh"
    age --decrypt -i "$AGE_IDENTITY" "$HOST_KEY_SECRET" \
        | install -m 600 -o root /dev/stdin "$ROOT_MOUNT/etc/ssh/ssh_host_ed25519_key" \
        || die "Failed to decrypt host key"
    chmod 600 "$ROOT_MOUNT/etc/ssh/ssh_host_ed25519_key"
    chown root:root "$ROOT_MOUNT/etc/ssh/ssh_host_ed25519_key" 2>/dev/null || true
    success "SSH host key placed at /etc/ssh/ssh_host_ed25519_key"

    # Pre-seed age identity
    info "Decrypting and placing age identity..."
    mkdir -p "$ROOT_MOUNT/etc/age"
    chmod 755 "$ROOT_MOUNT/etc/age"
    age --decrypt -i "$AGE_IDENTITY" "$AGE_KEY_SECRET" \
        | install -m 600 -o root /dev/stdin "$ROOT_MOUNT/etc/age/key.txt" \
        || die "Failed to decrypt age identity"
    success "Age identity placed at /etc/age/key.txt"

else
    warn "Skipping key pre-seeding (--age-identity and --secrets-dir not provided)"
    warn "The Pi will not be able to decrypt agenix secrets on first boot."
    warn "Re-run with --age-identity and --secrets-dir to enable this."
fi

# ─── Verify installation ──────────────────────────────────────────────────────

section "Verifying installation..."
info "Root partition contents:"
ls -la "$ROOT_MOUNT/"

info "Firmware partition contents:"
ls -la "$FIRMWARE_MOUNT/"

# Verify the firmware partition has the bare minimum the Pi needs to boot
MISSING=()
[[ -f "$FIRMWARE_MOUNT/config.txt" ]] || MISSING+=("config.txt")
[[ -f "$FIRMWARE_MOUNT/bootcode.bin" ]] \
    || [[ -f "$FIRMWARE_MOUNT/start4.elf" ]] \
    || [[ -n "$(ls "$FIRMWARE_MOUNT"/*.dtb 2>/dev/null)" ]] \
    || MISSING+=("firmware blobs (*.elf / *.dtb)")

if [[ ${#MISSING[@]} -gt 0 ]]; then
    warn "Expected firmware files not found: ${MISSING[*]}"
    warn "The Pi may not boot. Check populateFirmwareCommands output."
else
    success "Firmware partition looks good"
fi

printf "\n"
success "Installation complete! You can now boot from ${ROOT_DEVICE%[0-9]*}."
printf "  The disk will be unmounted automatically as this script exits.\n"
