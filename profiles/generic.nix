{ config, pkgs, agenix, ... }:

let
        lock-false = {
                Value = false;
                Status = "locked";
        };
        lock-true = {
                Value = true;
                Status = "locked";
        };
in
{
  # TODO: Separate browser and create configurations
        # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
  programs.firefox = {
                enable = true;
                package = pkgs.firefox-wayland;

                /* ---- POLICIES ---- */
    # Check about:policies#documentation for options.
                policies = {
                        DisableTelemetry = true;
                        DisableFirefoxStudies = true;
                        EnableTrackingProtection = {
                                Value = true;
                                Locked = true;
                                Cryptomining = true;
                                Fingerprinting = true;
      };
      DisablePocket = true;
                        DisableFirefoxScreenshots = true;
                        DontCheckDefaultBrowser = true;
                        DisplayBookmarksToolbar = "always";

                        /* ---- PREFERENCES ---- */
      # Check about:config for options.
                        Preferences = {
                                "extensions.pocket.enabled" = lock-false;
                                "extensions.screenshots.disabled" = lock-true;
                                "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
                                "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
                                "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
                                "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
                                "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
                                "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
                                "browser.newtabpage.activity-stream.showSponsored" = lock-false;
                                "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
                                "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
                                "browser.tabs.groups.enabled" = lock-true;
                        };
                };
        };

	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		# BASICS
		unixtools.whereis
		fastfetch
		neovim
		killall
		niv
		age
		agenix.packages.${system}.default
		qrencode
		flameshot
		onlyoffice-bin_latest
		wget
		btop
		tree
		lm_sensors
		fanctl

		# GENERAL APPS
		obsidian
		vesktop # Discord without broken screenshare
		teams-for-linux
		zoom-us
		ferdium
		tidal-hifi
		filezilla
		vlc
	];
}
