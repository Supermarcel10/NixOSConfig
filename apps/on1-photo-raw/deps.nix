{ pkgs }:

{
  winMetadata = pkgs.fetchurl {
    url = "https://archive.org/download/win-metadata/WinMetadata.zip";
    sha256 = "182lm5aaa4y1wnncizgmqjh47rlp2jgcysspnr45arqjdf4w5r82";
  };

  # Visual C++ Redistributable 2022 (14.40.33810)
  vcrun2022_x64 = pkgs.fetchurl {
    url = "https://aka.ms/vs/17/release/vc_redist.x64.exe";
    sha256 = "0fvidc4p4h0qm52y9s6npnjfpgpm5grsw3rhws51ixf33pmz03yc";
  };

  vcrun2022_x86 = pkgs.fetchurl {
    url = "https://aka.ms/vs/17/release/vc_redist.x86.exe";
    sha256 = "0r7damfb5q4p1xlw6qvr8kk4gq8i3k2jbx0drs210i302rhz428c";
  };
}
