#!/bin/bash

ffmpeg -vcodec png -i "$1.png" -vcodec rawvideo -f rawvideo -pix_fmt rgb24 "$1.bin"
hexdump -v -e '1/1 "%02X" "\n"' "$1.bin" > "$1.hex"
