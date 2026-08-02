connect -url tcp:127.0.0.1:3121
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 88723523034EA"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 88723523034EA"} -index 0
dow D:/embedded/how_are_you/sdk/fftc/Debug/fftc.elf
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "RealDigital Boo 88723523034EA"} -index 0
con
