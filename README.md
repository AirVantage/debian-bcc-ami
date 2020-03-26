# Debian BCC AMI

![AutoUpdate](https://github.com/AirVantage/debian-bcc-ami/workflows/AutoUpdate/badge.svg)
[![Find AMI](https://img.shields.io/badge/AWS-AMI-yellow)](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?#Images:visibility=public-images;search=debian-bcc;sort=name)

This is a modification of the official [Debian](https://wiki.debian.org/Cloud/AmazonEC2Image) 10 Buster AMI with [BCC](https://github.com/iovisor/bcc)
and kernel headers pre-installed. It simplifies and speeds up the deployment of eBPF programs, like
[SBULB](https://github.com/AirVantage/sbulb) for instance ;)

Thanks to a Github Action, we track new Debian AMI releases and publish updated images automatically.

### Features

 - installed packages: jq, linux-headers, python3-bpfcc. This saves at least 30s of boot time.
 - kernel updates are disabled so that your BPF scripts can still run after a security update
 - the motd displays the list of failed systemd units when you connect via SSH (similar to CoreOS)
 - the images are optimized for ENA and SR-IOV (high performance networking)

## Availability

So far the AMIs are only published on 2 zones: eu-west-1 and us-west-2. Only x86_64 is supported.

The images are named like this: `debian-bcc-10-amd64-hvm-ebs-20200210-166`.

You can find the latest release with this command:

```
aws ec2 describe-images --owners 018471812555 --region eu-west-1 \
  --filters Name=name,Values=debian-bcc-* \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' \
  --output text
```