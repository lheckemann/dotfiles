#!/usr/bin/env bash
set -ex
url="$1"
branch="${2:-master}"
[[ "$url" =~ ^https://github.com/[a-z0-9_-]*/[a-z0-9_-]* ]]
path="${url#https://github.com/}"
owner="${path%%/*}"
repo="${path#*/}"
sha256=$(nix-prefetch-url --unpack https://github.com/$owner/$repo/archive/$branch.tar.gz)
rev=$(git ls-remote https://github.com/$owner/$repo $branch | cut -d$'\t' -f 1)

cat <<EOF
fetchFromGitHub {
  owner = "$owner";
  repo = "$repo";
  rev = "$rev";
  sha256 = "$sha256";
}
EOF
