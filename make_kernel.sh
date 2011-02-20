#!/bin/sh

WORK=`pwd`

if [ ! -f "$1" ]; then
	echo "specifiy an existing zImage!"
	exit 1
fi

if [ ! -d ../fascinate_initramfs ]; then
	cd ..
	git clone git://github.com/jt1134/fascinate_initramfs.git
	cd $WORK
fi
rm -rf ../fascinate_initramfs/.git

if [ "$2" = "V" ]; then
	cd ..
	if [ ! -d lagfix ]; then
		git clone git://github.com/project-voodoo/lagfix.git
	fi

	if [ ! -f lagfix/stages_builder/stages/stage1.tar ] || \
	[ ! -f lagfix/stages_builder/stages/stage2.tar.lzma ] || \
	[ ! -f lagfix/stages_builder/stages/stage3-sound.tar.lzma ]; then
		cd lagfix/stages_builder
		rm -f stages/stage*
		./scripts/download_precompiled_stages.sh
		cd ../../
	fi

	rm -rf voodoo
	./lagfix/voodoo_injector/generate_voodoo_initramfs.sh \
		-s fascinate_initramfs \
		-d voodoo \
		-p lagfix/voodoo_initramfs_parts \
		-x lagfix/extensions \
		-t lagfix/stages_builder/stages \
		-l -w

	cd $WORK
	rm -f "$1"-new
	./repacker.sh -s "$1" \
		-d "$1"-voodoo \
		-r ../voodoo/full-lzma-loader.cpio.gz \
		-c ""
	mv "$1"-voodoo . 
else
	rm -f "$1"-voodoo
	./repacker.sh -s "$1" \
		-d "$1"-new \
		-r ../fascinate_initramfs \
		-c lzma
	mv "$1"-new . 
fi
