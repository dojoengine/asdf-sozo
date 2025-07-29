#!/usr/bin/env bash

set -euo pipefail

# This is the correct GitHub homepage where releases can be downloaded for katana.
GH_REPO="https://github.com/dojoengine/katana"
TOOL_NAME="katana"
TOOL_TEST="katana --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if katana is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# We filter out nightly, alpha, rc, and 0.x versions
	list_github_tags | grep -vE "(nightly|alpha|rc|^0\.)"
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$GH_REPO/releases/download/v${version}/${filename}"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$ASDF_DOWNLOAD_PATH/$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

# Cribbed from https://github.com/dojoengine/dojo/blob/main/dojoup/dojoup
detect_platform_arch() {
	local platform arch ext

	platform="$(uname -s)"
	arch="$(uname -m)"
	ext="tar.gz" # Default to tar.gz for Linux and macOS

	case $platform in
	Linux)
		platform="linux"
		;;
	Darwin)
		platform="darwin"
		;;
	MINGW* | MSYS* | CYGWIN*)
		ext="zip"
		platform="win32"
		;;
	*)
		fail "unsupported platform: $platform"
		;;
	esac

	if [ "${arch}" = "x86_64" ]; then
		# On macOS, check if Rosetta
		if [ "$platform" = "darwin" ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = "1" ]; then
			arch="arm64" # Rosetta
		else
			arch="amd64" # Intel/AMD64
		fi
	elif [ "${arch}" = "arm64" ] || [ "${arch}" = "aarch64" ]; then
		arch="arm64" # ARM
	else
		arch="amd64" # Default to AMD64
	fi

	echo "$platform $ext $arch"
}

get_binary_name() {
	local version="$1"

	# Get platform and architecture information to determine file extension
	read -r PLATFORM EXT ARCH <<<"$(detect_platform_arch)"

	# Determine if we should use native build (defaults to non-native for compatibility)
	BUILD=""
	if [ "${ASDF_NATIVE_BUILD:-false}" = "true" ]; then
		BUILD="_native"
	fi

	# i.e. katana_v1.6.3_darwin_arm64_native.tar.gz
	echo "${TOOL_NAME}_v${version}_${PLATFORM}_${ARCH}${BUILD}.${EXT}"
}
