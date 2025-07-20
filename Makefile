# SPDX-License-Identifier: CC0-1.0
#
# SPDX-FileContributor: Antonio Niño Díaz, 2023

ifeq ($(OS),Windows_NT)
BLOCKSDS            ?= C:/msys64/opt/wonderful/thirdparty/blocksds/core
BLOCKSDSEXT         ?= C:/msys64/opt/wonderful/thirdparty/blocksds/external
WONDERFUL_TOOLCHAIN ?= C:/msys64/opt/wonderful
else
BLOCKSDS            ?= /opt/blocksds/core
BLOCKSDSEXT			?= /opt/blocksds/external
endif

# User config
# ===========

NAME			:= nds_test_app
GAME_TITLE		:= NDS Test App
GAME_SUBTITLE	:= For Developers
GAME_AUTHOR		:= Charm Quirk
GAME_ICON		:= icon.bmp

include $(BLOCKSDS)/sys/default_makefiles/rom_arm9arm7/Makefile

# DLDI and internal SD slot of DSi
# --------------------------------

# Root folder of the SD image
SDROOT		:= sdroot
# Name of the generated image it "DSi-1.sd" for no$gba in DSi mode
SDIMAGE		:= image.bin

# Source code paths
# -----------------

# INCLUDES  := -I$(BLOCKSDS)/libnds/include -I$(BLOCKSDS)/include

# List of folders to combine into the root of NitroFS:
NITROFSDIR	:= #nitrofs

# # Libraries

# LIBS		:= -lnds9 -lmm9
# LIBDIRS		:= $(BLOCKSDS)/libs/maxmod

# include $(BLOCKSDS)/sys/default_makefiles/rom_combined/Makefile

# Tools
# -----

MAKE		:= make
RM		:= rm -rf

# Verbose flag
# ------------

ifeq ($(VERBOSE),1)
V		:=
else
V		:= @
endif

# Directories
# -----------

ARM9DIR		:= arm9
ARM7DIR		:= arm7

# Build artfacts
# --------------

ROM		:= $(NAME).nds

# Targets
# -------

.PHONY: all clean arm9 arm7 dldipatch sdimage

all: $(ROM)

clean:
	@echo "  CLEAN"
	$(V)$(MAKE) -f Makefile.arm9 clean --no-print-directory
	$(V)$(MAKE) -f Makefile.arm7 clean --no-print-directory
	$(V)$(RM) $(ROM) build $(SDIMAGE)

arm9:
	$(V)+$(MAKE) -f Makefile.arm9 --no-print-directory

arm7:
	$(V)+$(MAKE) -f Makefile.arm7 --no-print-directory

ifneq ($(strip $(NITROFSDIR)),)
# Additional arguments for ndstool
NDSTOOL_ARGS	:= -d $(NITROFSDIR)

# Make the NDS ROM depend on the filesystem only if it is needed
$(ROM): $(NITROFSDIR)
endif

# Combine the title strings
ifeq ($(strip $(GAME_SUBTITLE)),)
    GAME_FULL_TITLE := $(GAME_TITLE);$(GAME_AUTHOR)
else
    GAME_FULL_TITLE := $(GAME_TITLE);$(GAME_SUBTITLE);$(GAME_AUTHOR)
endif

$(ROM): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-7 build/arm7.elf -9 build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_ARGS)

sdimage:
	@echo "  MKFATIMG $(SDIMAGE) $(SDROOT)"
	$(V)$(BLOCKSDS)/tools/mkfatimg/mkfatimg -t $(SDROOT) $(SDIMAGE)

dldipatch: $(ROM)
	@echo "  DLDIPATCH $(ROM)"
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch \
		$(BLOCKSDS)/sys/dldi_r4/r4tf.dldi $(ROM)