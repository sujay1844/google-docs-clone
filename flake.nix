{
  description = "Google docs clone backend";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ elixir erlang elixir-ls inotify-tools ];

        shellHook = ''
          ${pkgs.elixir_ls}/bin/elixir-ls > /tmp/elixir-ls.log 2>&1 &
        '';
      };
    };
}
