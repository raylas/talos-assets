talos_arch := "amd64"
talos_version := "1.7.5"

[private]
default:
  @just --list --unsorted

[private]
clean:
  rm -rf _out
  mkdir _out

build: clean
  #! /usr/bin/env bash
  export DOCKER_DEFAULT_PLATFORM=linux/{{talos_arch}}

  docker run --rm -t \
    -v $PWD/_out:/out \
    ghcr.io/siderolabs/imager:v{{talos_version}} installer \
    --system-extension-image ghcr.io/siderolabs/amd-ucode:20240513 \
    --system-extension-image ghcr.io/siderolabs/zfs:2.2.4-v1.7.5 \
    --system-extension-image ghcr.io/siderolabs/nonfree-kmod-nvidia:535.129.03-v1.7.5 \
    --system-extension-image ghcr.io/siderolabs/nvidia-container-toolkit:535.129.03-v1.14.6 \
    --system-extension-image ghcr.io/siderolabs/gvisor:20240325.0 \
    --system-extension-image ghcr.io/siderolabs/tailscale:1.68.1

publish:
  #! /usr/bin/env bash
  ls -l _out
  docker load < _out/*.tar
  docker tag ghcr.io/siderolabs/installer:v{{talos_version}} ghcr.io/raylas/talos-assets/installer:{{talos_version}}
  docker push ghcr.io/raylas/talos-assets/installer:{{talos_version}}
