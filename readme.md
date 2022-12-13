# F4PGA VHDL Demo
## Description
This is a demo building the bitstream for a simple full adder for the digilent Arty A7 35T evalboard using the F4GPA open source toolchain.

## Usage
### Requirements
The demo expects a local installation of
- **Docker** to run the container containing the F4PGA toolchain
- **GHDL** (with synthesis capabilities) for simulation and synthesis of VHDL to Verilog
- **GTKWave** to view the VCD output of the simulation
- **make** in order to run the Makefile
- **openFPGAloader** in order to write the bitstream to the device

### Running the demo
Running the simulation
```bash
make simulate
```

Viewing the resulting waveforms
```bash
make visualize
```

Translating the VHDL design to Verilog
```bash
make translate
```

Starting the docker container in interactive mode in the workdir, building the design in the docker container and exiting the container when finished
```bash
make docker
make build
exit
```

Programming the bitstream into SRAM
```bash
make program
```

Programming the bitstream into FLASH
```bash
make flash
```