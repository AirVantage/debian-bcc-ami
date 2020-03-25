#!/bin/bash
set -euxo pipefail

AMI_NAME=debian-bcc-10
REGIONS=eu-west-1,us-west-2
SOURCE_AMI_NAME=debian-10
BUILD_INSTANCE=t3.small
BUILD_REGION=${AWS_REGION:-eu-west-1}
OWNER_ID=018471812555
OWNER_ID_DEBIAN=136693071363

get_latest_debian_ami() {
  local owner=$1 region=$2 name=$3
  aws ec2 describe-images \
    --owners $owner \
    --region $region \
    --filters \
      Name=architecture,Values=x86_64 \
      Name=name,Values=$name* \
      Name=root-device-type,Values=ebs \
      Name=virtualization-type,Values=hvm \
    --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name]'
}

# Functions to parse the output of get_latest_debian_ami()
get_image_id() { jq -r .[0]; }
get_image_version() { jq -r .[1] | egrep -o '[0-9]+-[0-9]+$'; }

#
# M a i n
#

# Load AWS environment
[ ! -f .env ] || source .env

# Check dependencies
type aws jq packer >/dev/null || source deps.sh

# Get the latest official Debian release.
debian=$(get_latest_debian_ami $OWNER_ID_DEBIAN $BUILD_REGION $SOURCE_AMI_NAME)
debian_version=$(get_image_version <<<$debian)

# Get the latest debian-bcc release.
debbcc=$(get_latest_debian_ami $OWNER_ID $BUILD_REGION $AMI_NAME)
debbcc_version=$(get_image_version <<<$debbcc)

if [ "$debian_version" = "$debbcc_version" ]; then
  echo "No new release to build."
  exit 0
fi

packer build \
  -color=false \
  -var ami_name=$AMI_NAME-amd64-hvm-ebs-$debbcc_version \
  -var source_ami=$(get_image_id <<<$debian) \
  -var build_instance=$BUILD_INSTANCE \
  -var build_region=$BUILD_REGION \
  -var target_regions=$REGIONS \
  -var manifest=manifest-$debbcc_version.json \
  ami.json