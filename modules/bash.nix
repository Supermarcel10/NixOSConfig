{ ... }:

{
  programs.bash.interactiveShellInit = ''
    export HISTCONTROL=ignoreboth
  '';
}
