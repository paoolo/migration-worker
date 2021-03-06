#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ] || [ $# -eq 1 ]
then
    echo "Bad script params."
    exit 1
fi

mkdir -p ${__dir}/logs
. ~/.creds
. $2

: ${OS_TENANT_NAME:?"Need to set OS_TENANT_NAME non-empty"}
: ${OS_USERNAME:?"Need to set OS_USERNAME non-empty"}
: ${OS_PASSWORD:?"Need to set OS_PASSWORD non-empty"}
: ${OS_AUTH_URL:?"Need to set OS_AUTH_URL non-empty"}

command -v glance > /dev/null 2>&1 || { echo "No 'glance'" >&2; exit 1; }

command -v sudo > /dev/null 2>&1 || { echo "No 'sudo'" >&2; exit 1; }
command -v qemu-img > /dev/null 2>&1 || { echo "No 'qemu-img'" >&2; exit 1; }

image_uuid=$1

image_list=$(glance image-list) &>> ${__dir}/logs/o2a-c.log
echo "$(date) [Result for glance image-list]: ${image_list}" &>> ${__dir}/logs/o2a-c.log

check_local=$(echo "${image_list}" | grep ${image_uuid} | wc -l) &>> ${__dir}/logs/o2a-c.log
echo "$(date) [Result for looking for ${image_uuid} in image_list]: ${check_local}" &>> ${__dir}/logs/o2a-c.log

if [ ${check_local} -eq 1 ]
then
    if [ ! -f /tmp/${image_uuid}.raw ]
    then
        __output=$(sudo qemu-img convert -f qcow2 -O raw /var/lib/glance/images/${image_uuid} /tmp/${image_uuid}.raw) &>> ${__dir}/logs/o2a-c.log
        echo "$(date) [Result for qemu-img convert]: ${__output}" &>> ${__dir}/logs/o2a-c.log
    fi

    echo "Image converted"
    exit 0
else
    echo "Requested image not exist."
    exit 1
fi
