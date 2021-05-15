# It's required to provide directory of kvm-unit-test

dir_kvm_unit_test := /home/works/crosvm_kvm/kvm_unit_test-crosvm/kvm-unit-tests

grub_cfg := src/grub.cfg
elf_files := $(wildcard $(dir_kvm_unit_test)/x86/*.elf)
iso_files := $(patsubst %.elf,%.iso,$(elf_files))

.PHONY: all clean run iso

clean:
	rm -rf build/isofiles
	rm -rf $(dir_kvm_unit_test)/x86/*.iso

run: iso
	@rm -rf /tmp/crosvm.sock
	crosvm run \
		--disable-sandbox \
		--socket=/tmp/crosvm.sock \
		--cpus 1 --mem 1024 \
		--rwdisk=$(dir_kvm_unit_test)/x86/$(TEST) \
		--bios=./OVMF_CROSVM.fd

iso: $(iso_files)
	echo "All ISO created successfully!"

%.iso : %.elf 
	@echo "Creating ISO for case: $(notdir $<)"
	@rm -rf build/isofiles
	@mkdir -p build/isofiles/boot/grub
	@cp $< build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	@grub-mkrescue --sparc-boot -o $@ build/isofiles 2> /dev/null


