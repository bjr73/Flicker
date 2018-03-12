######################################################################
# WAVES

DEPTH ?= 1

ifeq ($(WAVES),1)
	WAVE_ARGS = "-define WAVES_EN -define WAVE_DEPTH=$(DEPTH)"
endif

######################################################################
# WIDTH PARAMETERS

FRONT_WIDTH ?= 4

FRONT_ARGS = "-define FRONT_END_WIDTH=$(FRONT_WIDTH)"

ISSUE_SIZE ?= 4

ISSUE_ARGS = "-define ISSUE_QUEUE_SIZE=$(ISSUE_SIZE)"

ALU_WIDTH ?= 3

ALU_ARGS = "-define SIMPLE_ALU_WIDTH=$(ALU_WIDTH)"

WIDTH_ARGS = $(FRONT_ARGS) $(ISSUE_ARGS) $(ALU_ARGS)

######################################################################
# SIMULATION OPTIONS

SIM_COUNT ?= 400000

SIM_ARGS = "-define SIMULATION_LENGTH=$(SIM_COUNT)"

######################################################################
# PRINT OPTIONS

ifeq ($(PRINT),1)
	PRINT_ARGS = "-define PRINT"
endif


######################################################################
FLICKER_ARGS = $(WIDTH_ARGS) $(WAVE_ARGS) $(SIM_ARGS) $(PRINT_ARGS)
