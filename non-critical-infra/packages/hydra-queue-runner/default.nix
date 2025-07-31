{
  rustPackages,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  protobuf,
  lib,
  makeWrapper,
  nix,
}:
rustPackages.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hydra-queue-builder";
  version = "unstable-2025-07-31";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "helsinki-systems";
    repo = "hydra-queue-runner";
    rev = "71f5293fcf152b16f21b1fca3c65d3b140da8f8e";
    hash = "sha256-N15GfzMyuCoL6D5sJEFJs6dgGX0NtMhB45SmY0muRVc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FEY2f7y41GctE/esFTmZc4Tl+rquCByM3ine80isC9w=";

  nativeBuildInputs = [
    pkg-config
    protobuf
    makeWrapper
  ];
  buildInputs = [
    openssl
    zlib
    protobuf
  ];

  cargoBuildFlags = [
    "-p"
    "builder"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  postInstall = ''
    wrapProgram $out/bin/builder --prefix PATH : ${lib.makeBinPath [ nix ]}
  '';

  meta = {
    mainProgram = "builder";
    description = "Hydra Queue-Runner implemented in rust";
    homepage = "https://github.com/helsinki-systems/hydra-queue-runner";
    license = [ lib.licenses.gpl3 ];
    maintainers = [ lib.maintainers.conni2461 ];
    platforms = lib.platforms.all;
  };
})
