# It's required to provide directory of kvm-unit-test

dir_kvm_unit_test := /home/works/crosvm_kvm/kvm_unit_test-crosvm/kvm-unit-tests

grub_cfg := src/grub.cfg
elf_files := $(wildcard $(dir_kvm_unit_test)/x86/*.elf)
iso_files := $(patsubst %.elf,%.iso,$(elf_files))
all_in_one_iso := all.iso
list_elf := build/list-elf.log

.PHONY: all clean run iso

all: iso all-in-one-iso

clean:
	rm -rf build/isofiles
	rm -rf $(dir_kvm_unit_test)/x86/*.iso

run:
	@rm -rf /tmp/crosvm.sock
	crosvm run \
		--disable-sandbox \
		--socket=/tmp/crosvm.sock \
		--cpus 1 --mem 1024 \
		--rwdisk=$(dir_kvm_unit_test)/x86/$(TEST) \
		--bios=./OVMF_CROSVM.fd
elfs:
	touch $(list_elf)

all-in-one-iso:
	@echo "Creating All in one ISO"
	@rm -rf build/isofiles
	@mkdir -p build/isofiles/boot/grub
	@cp $(dir_kvm_unit_test)/x86/*.elf build/isofiles/boot/
	@./src/creat-all-in-one.sh > /tmp/grub.cfg
	@cp /tmp/grub.cfg build/isofiles/boot/grub/
	@grub-mkrescue --sparc-boot -o $(dir_kvm_unit_test)/x86/$(all_in_one_iso) build/isofiles 2> /dev/null


iso: $(iso_files)
	ln -fs $(dir_kvm_unit_test) kvm-unit-tests
	echo "All ISO created successfully!"

%.iso : %.elf elfs
	@echo "Creating ISO for case: $(notdir $<)"
	@rm -rf build/isofiles
	@mkdir -p build/isofiles/boot/grub
	@cp $< build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub/
	@grub-mkrescue --sparc-boot -o $@ build/isofiles 2> /dev/null
	@echo $(notdir $<) >> $(list_elf)


