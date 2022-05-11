# 240p Test Suite for MiSTer

This project's goal is to provide calibration and testing tools for setups using the MiSTer without the constraints of a console's capabilities.
Right now the core is on it's first steps, but some of the tests are available for public use and testing.

The core outputs 320x240p, 4:3 DAR, 1:1 PAR. This means that your CRT will show 240 lines and 320 dots per line,
with a proper 4:3 aspect ratio and square "pixels", which is important for proper CRT video signal calibration.

### PAL USERS

the current core doesn't support PAL video signals or anything other than **15Khz 60hz NTSC**. PAL support is planned.

## Available tests

### Monoscope (designed by @khmr33)

This is a proper 320x240p monoscope, you can use it for many things:

- Setting the visible area for your CRT
- Setting the visible underscan for your CRT
- Use the red square and a ruler/calipers to fine tune H/V size such that the square width is equal to the height. this will set the proper aspect ratio for your CRT
- Use the pattern to fine tune convergence. You can cycle from 0-100 IRE by pressing the "B" button

# Verilator development flow

### Windows

- Install WSL2 with Ubuntu
- Install Visual Studio 2022 (Community edition is fine) with the C++ workload

### WSL (verilator)

This project has been built with Verilator v4.204. Any change to the verilator version will require changes to allow the project to build, so it is advised to stick with 4.204. To install this version, run the following commands from a temporary directory:

```
# Prerequisites:
sudo apt-get install git perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2
sudo apt-get install libfl-dev
sudo apt-get install zlibc zlib1g zlib1g-dev

git clone https://github.com/verilator/verilator

unset VERILATOR_ROOT
cd verilator
git pull
git checkout v4.204
autoconf
./configure
make -j `nproc`
sudo make install
```

### Building and running the simulation

Run `verilate.sh` after changes to any HDL code. Visual Studio will then automatically re-build on the next run.

> IMPORTANT: Run the simulation project in Release mode or your framerate will be very disappointing!
