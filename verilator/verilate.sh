verilator \
-cc -exe --public --trace --savable \
--compiler msvc +define+SIMULATION=1 \
-O3 --x-assign fast --x-initial fast --noassert \
--converge-limit 6000 \
-Wno-UNOPTFLAT \
--top-module top suite_sim.v \
../rtl/suite.v \
../rtl/rom.v \
../rtl/pll.v \
../rtl/pll/pll_0002.v