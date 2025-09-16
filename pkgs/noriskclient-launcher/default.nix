{
  lib,
  stdenv,
  rustPlatform,
  fetchYarnDeps,
  cargo-tauri,
  jq,
  moreutils,
  glib-networking,
  nodejs,
  yarnConfigHook,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook,
  fetchFromGitHub,
  temurin-bin,
  temurin-bin-8,
  temurin-bin-17
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noriskclient-launcher";
  version = "0.6.8";
  src = fetchFromGitHub {
    owner = "NoRiskClient";
    repo = "noriskclient-launcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T33y9I6FXmrleLDBxTVMIQK35fZAgDgrKcb02ABAt+E=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-0vVN2vJW+hrjQeTEw3L8JKa4/C83sCtxNJEaTkwwbT8=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-MEdT/1jPtt9PIMGzBaiji67UUqwDi+vF//w9cAvtOBk=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    nodejs
    yarnConfigHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook ];

  buildInputs = [
    temurin-bin
    temurin-bin-8
    temurin-bin-17
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  postPatch = ''
    jq \
      '.plugins.updater.endpoints = [ ]
      | .bundle.createUpdaterArtifacts = false' \
      src-tauri/tauri.conf.json \
      | sponge src-tauri/tauri.conf.json
  ''; # thank you donovanglover your code in that pull request you made to nixpkgs was very useful

  meta = with lib; {
    description = "Launcher for the NoRiskClient PvP client for Minecraft";
    homepage = "https://norisk.gg/";
    license = lib.licenses.gpl3Only;
    platforms = platforms.unix;
  };
})
