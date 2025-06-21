# The architecture of the running shell
# Also used to determine the build target architecture
_arch="$(/usr/bin/uname -m)"
_rust_target="x86_64-apple-darwin"
if [[ $_arch == "arm64" ]]; then
  _rust_target="aarch64-apple-darwin"
fi

# Check if we're in a Nix environment by looking for ninja in PATH
if command -v ninja >/dev/null 2>&1 && [[ "$(which ninja)" == /nix/store/* ]]; then
  export NINJA="ninja"
  # Set DEVELOPER_DIR for xcrun to work properly
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
  # Use system clang++ to avoid Nix libcxx compatibility issues
  export CXX="/usr/bin/clang++"
  # Ensure C++ standard library headers are found
  export CXXFLAGS="-isysroot $(xcrun --show-sdk-path) ${CXXFLAGS:-}"
  # Ensure proper linking with system C++ library - use explicit library path
  SDK_PATH=$(xcrun --show-sdk-path)
  export LDFLAGS="-L${SDK_PATH}/usr/lib -lc++ ${LDFLAGS:-}"
  # Keep existing LDFLAGS, CPPFLAGS, and LIBRARY_PATH if they're already set by Nix
  # Don't override them with Homebrew paths
else
  # Fall back to Homebrew paths
  echo "Using Homebrew build tools"
  _x86_64_homebrew_path="/usr/local/opt"
  _arm64_homebrew_path="/opt/homebrew/opt"
  _homebrew_path="$_x86_64_homebrew_path"
  if [[ $_arch == "arm64" ]]; then
    _homebrew_path="$_arm64_homebrew_path"
  fi
  _clangxx_path="$_homebrew_path/llvm/bin"
  _ninja_path="$_homebrew_path/ninja/bin"
  _python_path="$_homebrew_path/python3/bin"

  export PATH="$_clangxx_path:$_ninja_path:$_python_path:$PATH"
  export NINJA="$_ninja_path/ninja"
  export LDFLAGS="-L$_homebrew_path/llvm/lib"
  export CPPFLAGS="-I$_homebrew_path/llvm/include"
fi

# Some path variables
_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache"
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/helium-chromium"
_subs_cache="$_root_dir/build/subs.tar"
_namesubs_cache="$_root_dir/build/namesubs.tar"
