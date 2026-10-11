#!/usr/bin/env bash
# Prints the tool versions a build uses, including the system C compiler and
# SDK, which come from the host rather than mise. CI logs it so a runner image
# change shows up next to the failure it causes.
set -euo pipefail
mise ls --current
rustc --version
case "$(uname -s)" in
  Darwin)
    xcodebuild -version 2> /dev/null || echo "Xcode: none, developer dir $(xcode-select -p)"
    cc --version | head -n 1
    ;;
  MINGW* | MSYS* | CYGWIN*)
    vswhere="/c/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
    vs=$("$vswhere" -latest -products '*' -property installationPath)
    echo "Visual Studio: $("$vswhere" -latest -products '*' -property catalog_productDisplayVersion)"
    echo "MSVC tools: $(cat "$(cygpath "$vs")/VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt")"
    ;;
  *)
    cc --version | head -n 1
    ;;
esac
