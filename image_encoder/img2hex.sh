#!/bin/bash
ffmpeg -vcodec png -i image.png -vcodec rawvideo -f rawvideo -pix_fmt rgb8 image.bin
srec_cat image.bin -binary -o image.hex -intel

