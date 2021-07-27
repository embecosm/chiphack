# Taken from https://github.com/im-tomu/fomu-workshop/tree/master/hdl
# Apache License
# Version 2.0, January 2004
# http://www.apache.org/licenses/ 

CONTAINER_ENGINE ?= docker

PWD = $(shell pwd)
CONTAINER_ARGS = run \
	--rm \
	-v /$(PWD)/../../..://wrk \
	-w //wrk/hdl/$(notdir $(shell dirname $(PWD)))/$(notdir $(PWD))

GHDL    = $(CONTAINER_ENGINE) $(CONTAINER_ARGS) hdlc/ghdl:yosys ghdl
YOSYS   = $(CONTAINER_ENGINE) $(CONTAINER_ARGS) hdlc/ghdl:yosys yosys
NEXTPNR = $(CONTAINER_ENGINE) $(CONTAINER_ARGS) hdlc/nextpnr:ice40 nextpnr-ice40
ICEPACK = $(CONTAINER_ENGINE) $(CONTAINER_ARGS) hdlc/icestorm icepack
 