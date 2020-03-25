#!/bin/sh -eux

apt-get update
apt-get -qq install --no-install-recommends awscli jq unzip wget

# Install a recent version of packer.
ver=1.5.4
wget -nv https://releases.hashicorp.com/packer/$ver/packer_${ver}_linux_amd64.zip
echo "c7277f64d217c7d9ccfd936373fe352ea935454837363293f8668f9e42d8d99d  packer_${ver}_linux_amd64.zip" | sha256sum -c
unzip packer_${ver}_linux_amd64.zip
mv packer /usr/local/bin
