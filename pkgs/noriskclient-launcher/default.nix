{
  addDriverRunpath,
  alsa-lib,
  callPackage,
  glfw3-minecraft,
  lib,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXrandr,
  libXrender,
  libXxf86vm,
  libjack2,
  libpulseaudio,
  mesa-demos,
  openal,
  pciutils,
  pipewire,
  stdenv,
  symlinkJoin,
  udev,
  vulkan-loader,
  makeWrapper,
  xrandr,

  additionalLibs ? [ ],
  additionalPrograms ? [ ],
}:

let
  noriskclient-launcher' = callPackage ../noriskclient-launcher-unwrapped { };
in
symlinkJoin {
  name = "noriskclient-launcher-${noriskclient-launcher'.version}";

  paths = [ noriskclient-launcher' ];

  postPatch =
    let # i did not shamelessly copy this from the prismlauncher package declaration idk what you're talking about
      runtimeLibs = [
        glfw3-minecraft
        openal

        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        libGL
        libX11
        libXcursor
        libXext
        libXrandr
        libXrender
        libXxf86vm

        udev

        vulkan-loader
      ] ++ additionalLibs;

      runtimePrograms = [
        mesa-demos
        pciutils
        xrandr
      ] ++ additionalPrograms;
    in
    (noriskclient-launcher'.postPatch or "") + ''
      wrapProgram $out/bin/noriskclient-launcher-v3 --set PATH ${lib.makeBinPath runtimePrograms} --set LD_LIBRARY_PATH ${lib.makeLibraryPath runtimeLibs}
    '';

  meta = {
    description = "Launcher for the NoRiskClient PvP client for Minecraft";
    branch = "v3";
    homepage = "https://norisk.gg/";
    downloadPage = "https://github.com/";
    maintainers = [
      inputs.jux-is-a-nix-maintainer-apparently.maintainers-list.JuxGD
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "noriskclient-launcher-v3";
    broken = true; # set as broken since it can't actually launch Minecraft
  };
})
