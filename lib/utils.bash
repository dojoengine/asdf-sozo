#!/usr/bin/env bash

set -euo pipefail

# This is the correct GitHub homepage where releases can be downloaded for sozo.
GH_REPO="https://github.com/dojoengine/dojo"
TOOL_NAME="sozo"
TOOL_TEST="sozo --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if sozo is not hosted on GitHub releases.
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
		sed -n 's|^sozo/v||p' # Only match sozo/v* tags (new format)
}

list_legacy_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed -n 's|^v||p' # Only match v* tags (old format, <=1.8.0)
}

list_all_versions() {
	{
		list_legacy_tags
		list_github_tags
	} | grep -vE "(nightly|alpha|rc|^0\.)"
}

is_new_format() {
	local version="$1"
	local major minor patch
	IFS='.' read -r major minor patch <<<"$version"
	# Versions > 1.8.0 use the new sozo/v* tag and sozo_v* asset format
	if [ "$major" -gt 1 ]; then
		return 0
	elif [ "$major" -eq 1 ]; then
		if [ "$minor" -gt 8 ]; then
			return 0
		elif [ "$minor" -eq 8 ] && [ "${patch:-0}" -ge 1 ]; then
			return 0
		fi
	fi
	return 1
}

download_release() {
	local version filename url tag
	version="$1"
	filename="$2"

	if is_new_format "$version"; then
		tag="sozo/v${version}"
	else
		tag="v${version}"
	fi

	url="$GH_REPO/releases/download/${tag}/${filename}"

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
		cp -r "$ASDF_DOWNLOAD_PATH"/"$TOOL_NAME" "$install_path"

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

	if is_new_format "$version"; then
		# i.e. sozo_v1.8.6_darwin_arm64.tar.gz
		echo "sozo_v${version}_${PLATFORM}_${ARCH}.${EXT}"
	else
		# i.e. dojo_v1.6.2_darwin_arm64.tar.gz
		echo "dojo_v${version}_${PLATFORM}_${ARCH}.${EXT}"
	fi
}
