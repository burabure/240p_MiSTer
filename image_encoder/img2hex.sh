#!/bin/bash

ffmpeg -vcodec png -i "$1.png" -vcodec rawvideo -f rawvideo -pix_fmt rgb8 "$1.bin"
hexdump -v -e '1/1 "%02X" "\n"' "$1.bin" > "../rtl/$1.hex"

