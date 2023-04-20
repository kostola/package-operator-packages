#!/bin/bash

set -e

cd "$( dirname "$0" )" || ( echo "Can't cd to source" && exit )

pkg_list_file="$( realpath )/package-list"
pkg_temp_file="__package-temp.tar.gz"

while IFS= read -r row
do
  pkg_dir=$( echo -n "$row" | cut -d '|' -f 1 )
  pkg_tag=$( echo -n "$row" | cut -d '|' -f 2 )

  echo "===== Processing dir='$pkg_dir' tag='$pkg_tag'"
  rm -f "$pkg_temp_file"

  echo "----- Building image..."
  kubectl package build -t "$pkg_tag" -o "$pkg_temp_file" "$pkg_dir"

  echo "----- Loading image..."
  podman image load -i "$pkg_temp_file"

  echo "----- Pushing image..."
  podman push "$pkg_tag"

  rm -f "$pkg_temp_file"
  echo "----- Done"
  echo ""
done < "$pkg_list_file"
