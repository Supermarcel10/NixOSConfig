{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # JetBrains IDEs
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.rider
    jetbrains.pycharm-professional
    jetbrains.idea-ultimate
    jetbrains.clion

    # Development Tools & Programming Languages
    git
    docker
    docker-client
    openjdk21
    python311
    rustc
    cargo
    gcc
    clang
    cmake
    dotnet-sdk
    nodejs
    yarn
    nodejs_22
    
    # Haskell
    ghc
    haskell-language-server
    cabal-install
  ];

  environment.variables = {
    PYTHON = "${pkgs.python311}/bin/python";
  };

  programs.java = {
    enable = true;
    package = pkgs.openjdk21;
  };
}
