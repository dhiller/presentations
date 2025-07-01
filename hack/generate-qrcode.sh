#!/usr/bin/env bash

set -euo pipefail

if ! command -V qrcode; then
    echo "qrcode binary missing, install from https://github.com/skip2/go-qrcode"
    exit 1
fi

input_dir="$(pwd)/$1"
if [ ! -d "${input_dir}" ]; then
    echo "$input_dir does not exist"
    exit 1
fi

output_file="/tmp/$1-qrcode.png"

qrcode -d "https://raw.githubusercontent.com/dhiller/presentations/master/$1/slides.pdf" > "${output_file}"

echo "qrcode written to ${output_file}"
