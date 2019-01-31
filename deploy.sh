#!/bin/bash

set -e
set -x

IMAGE_NAME=ecs-portus-$TRAVIS_BRANCH-$TRAVIS_BUILD_NUMBER
./packer build packer.json
openstack image save $IMAGE_NAME --file $IMAGE_NAME.qcow2
qemu-img convert -f qcow2 -O vmdk $IMAGE_NAME.qcow2 automium-dummy.vmdk
docker run --rm -it -v $(pwd):/root moander/ovftool ovftool /root/dummy.vmx /root/$IMAGE_NAME.ova
sudo chmod o+r $IMAGE_NAME.ova
mkdir vsphere
mv $IMAGE_NAME.ova vsphere/$IMAGE_NAME.ova
openstack container create automium-catalog-images
swift post automium-catalog-images --read-acl ".r:*,.rlistings"
openstack object create automium-catalog-images vsphere/$IMAGE_NAME.ova
