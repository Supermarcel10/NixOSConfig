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

    # VSCode IDE
    vscode

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
    pnpm
    nodejs_22

    # Elm
    elmPackages.elm

    # Arduino
    arduino-ide

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
