{
  description = "dpcs flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "dpcs";
        version = "0.0.1";

        src = ./.;

        buildInputs = [ 
          pkgs.bash
          pkgs.fzf
          pkgs.bat
          pkgs.git
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp dpcs $out/bin/
          chmod +x $out/bin/dpcs
        '';

        meta = with pkgs.lib; {
          description = "dpcs - dependency check search";
          maintainers = [ maintainers.danihek ];
        };
      };

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/dpcs";
      };
    };
}
