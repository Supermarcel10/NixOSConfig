{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [
      "moondream"
      "qwen3-vl:8b"
      "gemma3:27b-it-qat"
      "qwen3-vl:32b"
    ];
  };
}
