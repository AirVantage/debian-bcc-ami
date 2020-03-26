#!/bin/sh -eu

export DEBIAN_FRONTEND=noninteractive

# Prevent kernel updates.
apt-mark hold linux-*

# Install kernel headers and BCC.
apt-get update
apt-get -qq install --no-install-recommends jq linux-headers-$(uname -r) python3-bpfcc

# Fix Debian's ugly motd.
(
  . /etc/os-release
  echo $PRETTY_NAME >/etc/motd
)

# Display failed systemd units when the user logs in.
cat >/etc/profile.d/failed-units.sh <<__
case \$- in *i*)
  units=`systemctl list-units --no-legend --failed`
  if [ \${#units} -gt 0 ]; then
    echo
    echo " * Failed Units:"
    echo "\$units" | awk '{print "   - " \$1}'
    echo
  fi
  ;;
esac
__

# Reset cloud-init.
cloud-init clean --logs
