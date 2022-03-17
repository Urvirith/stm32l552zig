# ARM GCC COMPILER CALL

# Toolchain To Use
TOOLCHAIN	:= arm-none-eabi-
CC		    := $(TOOLCHAIN)gcc		# c compiler
AS			:= $(TOOLCHAIN)as		# assembler
LD 			:= $(TOOLCHAIN)ld 		# linker
OBJ 		:= $(TOOLCHAIN)objcopy	# Object Copy
READELF     := $(TOOLCHAIN)readelf  # Read Elf

# -Os				Optimize for Size
# -mcpu=cortex-m4	Compile for the ARM M4 Processor
# mthumb			Target the MTHUMB Instruction Set
# -ftlo				Set Linker Time Optimisations
ARCH 		:= m33
TARGET_ARCH := -mcpu=cortex-$(ARCH)
THUMB		:= -mthumb
LINKTIME	:= -flto
ASFLAGS		:= $(TARGET_ARCH) $(THUMB)
LDFLAGS 	:= -T 
OBJFLAGS	:= -O binary

SRC_DIR   := ./src
START_DIR := $(SRC_DIR)/startup
LINK_DIR  := $(SRC_DIR)/linker
BIN_DIR	  := ./bin
BLD_DIR	  := ./build

#ONLY ONE
STARTUP		:= stm_ARMCM33.s

#ONLY ONE
LINKER		:= stm_arm.ld

#	EXAMPLE OF AUTOMATIC VARIABLES
#	%.o: %.c %.h common.h
#		$(CC) $(CFLAGS) -c $<
#
#	$@ Looks at the target
#	(Target)
#	%.o: 			%.c %.h common.h
#	
#	$< Looks at the first source
#			(First Source)
#	%.o: 	%.c 					%.h common.h
#		$(CC) $(CFLAGS) -c $<
#	$^ Looks at the first source
#			(All Source)
#	%.o: 	%.c %.h common.h
#		$(CC) $(CFLAGS) -c $^
release: $(BIN_DIR)/main.bin

# Build An ELF 
$(BIN_DIR)/main.bin: $(BIN_DIR)/main.elf
	$(OBJ) $(OBJFLAGS) $^ $@

# Build An ELF 
$(BIN_DIR)/main.elf: $(LINK_DIR)/$(LINKER) $(BIN_DIR)/main.o $(BIN_DIR)/startup.o
	$(LD) -Os -s $(LDFLAGS) $^ -o $@

# Build Dependances
$(BIN_DIR)/startup.o: $(START_DIR)/$(STARTUP)
	$(AS) $< $(ASFLAGS) -o $@

$(BIN_DIR)/main.o:
	zig build-obj $(SRC_DIR)/main.zig -O ReleaseSmall -target thumb-freestanding-none -mcpu cortex_m33 --strip
	mv main.o ./bin

zig:
	zig build

clean:
	rm -f $(BIN_DIR)/*.o
	rm -f $(BIN_DIR)/*.elf
	rm -f $(BIN_DIR)/*.bin
	rm -r $(SRC_DIR)/zig-cache

cleanzig:	
	rm -f $(BLD_DIR)/*.o
	rm -f $(BLD_DIR)/*.elf
	rm -f $(BLD_DIR)/*.bin
	rm -r ./zig-cache
	rm -r ./zig-out

flash:
	STM32_Programmer_CLI -c port=SWD -w $(BIN_DIR)/main.bin 0x08000000

flashzig:
	STM32_Programmer_CLI -c port=SWD -w $(BLD_DIR)/main.elf 0x08000000

info:
	STM32_Programmer_CLI -c port=SWD

reset:
	STM32_Programmer_CLI -c port=SWD -rst

hard_reset:
	STM32_Programmer_CLI -c port=SWD -hardRst

setup:
	mkdir build
	mkdir bin

read:
	$(READELF) $(BIN_DIR)/main.elf -a

# To Move The Rules
#sudo cp ./rules/*.rules /etc/udev/rules.d/