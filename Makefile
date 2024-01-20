# Makefile for building bootloader, kernel, and creating ISO

AS=nasm
CC=i686-elf-gcc
LD=i686-elf-ld
OBJCOPY=i686-elf-objcopy
GENISOIMAGE=genisoimage

# Compiler and linker flags
CFLAGS=-m32 -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Werror
LDFLAGS=-melf_i386

# Directories
SRC_DIR=.
OBJ_DIR=obj
ISO_DIR=iso

# Files
BOOTLOADER_SRC=$(wildcard $(SRC_DIR)/bootloader/*.asm)
KERNEL_SRC=$(wildcard $(SRC_DIR)/kernel/*.c)

BOOTLOADER_OBJ=$(patsubst $(SRC_DIR)/bootloader/%.asm, $(OBJ_DIR)/%.o, $(BOOTLOADER_SRC))
KERNEL_OBJ=$(patsubst $(SRC_DIR)/kernel/%.c, $(OBJ_DIR)/%.o, $(KERNEL_SRC))

all: iso

$(OBJ_DIR)/bootloader/%.o: $(SRC_DIR)/bootloader/%.asm
	@mkdir -p $(@D)
	$(AS) -f bin $< -o $@

$(OBJ_DIR)/kernel/%.o: $(SRC_DIR)/kernel/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/kernel/kernel.bin: $(KERNEL_OBJ)
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) -T $(SRC_DIR)/kernel/linker.ld -o $@ $^

$(ISO_DIR)/bootable.iso: $(OBJ_DIR)/bootloader/boot.asm $(OBJ_DIR)/kernel/kernel.bin
	@mkdir -p $(ISO_DIR)
	cp $^ $(ISO_DIR)/
	$(GENISOIMAGE) -o $@ -b boot.asm -no-emul-boot -boot-load-size 4 -input-charset utf8 -J -R -V "BOOTABLE" $(ISO_DIR)

iso: $(ISO_DIR)/bootable.iso

clean:
	rm -rf $(OBJ_DIR) $(ISO_DIR)

.PHONY: all iso clean
