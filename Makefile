SHELL 				:= /bin/bash

current_dir 		:= ${CURDIR}
TOP 				:= top
SOURCES		 		:= ${current_dir}/build/${TOP}.v

TESTBENCH 			:= volladdierer_tb

XDC 				:= ${current_dir}/src/arty_35.xdc

BUILDDIR 			:= ${current_dir}/build
BOARD_BUILDDIR 		:= ${BUILDDIR}/${TARGET}

DEVICE 				:= xc7a50t_test
BITSTREAM_DEVICE 	:= artix7
PARTNAME 			:= xc7a35tcsg324-1
OFL_BOARD 			:= arty_a7_35t

XDC_CMD				:= -x ${XDC}

simulate ${BOARD_BUILDDIR}/simulation.vcd: ${BOARD_BUILDDIR}
	ghdl -i --workdir=$(BOARD_BUILDDIR) ${current_dir}/src/*.vhdl
	ghdl -m --workdir=$(BOARD_BUILDDIR) $(TOP)
	ghdl -r --workdir=$(BOARD_BUILDDIR) $(TESTBENCH) --vcd=$(BOARD_BUILDDIR)/simulation.vcd

visualize:
	gtkwave $(BOARD_BUILDDIR)/simulation.vcd

translate ${BOARD_BUILDDIR}/$(TOP).v: ${BOARD_BUILDDIR}
	ghdl -i --workdir=$(BOARD_BUILDDIR) ${current_dir}/src/*.vhdl
	ghdl -m --workdir=$(BOARD_BUILDDIR) $(TOP) 
	ghdl synth --workdir=$(BOARD_BUILDDIR)  --out=verilog $(TOP) > $(BUILDDIR)/${TOP}.v

docker:
	docker run -it -v "${CURDIR}:/rtl/" -w "/rtl" --platform linux/amd64 gcr.io/hdl-containers/conda/f4pga/xc7/a50t

build: ${BOARD_BUILDDIR}/${TOP}.bit

program: ${BOARD_BUILDDIR}/${TOP}.bit
	openFPGALoader -b ${OFL_BOARD} ${BOARD_BUILDDIR}/${TOP}.bit

flash: ${BOARD_BUILDDIR}/${TOP}.bit
	openFPGALoader -f -b ${OFL_BOARD} ${BOARD_BUILDDIR}/${TOP}.bit

clean:
	rm -rf ${BUILDDIR}

${BOARD_BUILDDIR}:
	mkdir -p ${BOARD_BUILDDIR}

${BOARD_BUILDDIR}/${TOP}.eblif: ${SOURCES} ${XDC} ${SDC} ${PCF} | ${BOARD_BUILDDIR}
	cd ${BOARD_BUILDDIR} && symbiflow_synth -t ${TOP} ${SURELOG_OPT} -v ${SOURCES} -d ${BITSTREAM_DEVICE} -p ${PARTNAME} ${XDC_CMD}

${BOARD_BUILDDIR}/${TOP}.net: ${BOARD_BUILDDIR}/${TOP}.eblif
	cd ${BOARD_BUILDDIR} && symbiflow_pack -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.place: ${BOARD_BUILDDIR}/${TOP}.net
	cd ${BOARD_BUILDDIR} && symbiflow_place -e ${TOP}.eblif -d ${DEVICE} ${PCF_CMD} -n ${TOP}.net -P ${PARTNAME} ${SDC_CMD} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.route: ${BOARD_BUILDDIR}/${TOP}.place
	cd ${BOARD_BUILDDIR} && symbiflow_route -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.fasm: ${BOARD_BUILDDIR}/${TOP}.route
	cd ${BOARD_BUILDDIR} && symbiflow_write_fasm -e ${TOP}.eblif -d ${DEVICE}

${BOARD_BUILDDIR}/${TOP}.bit: ${BOARD_BUILDDIR}/${TOP}.fasm
	cd ${BOARD_BUILDDIR} && symbiflow_write_bitstream -d ${BITSTREAM_DEVICE} -f ${TOP}.fasm -p ${PARTNAME} -b ${TOP}.bit