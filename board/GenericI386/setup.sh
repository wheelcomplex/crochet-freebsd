TARGET_ARCH=i386
KERNCONF=GENERIC
IMAGE_SIZE=$((2000 * 1000 * 1000))

generic_i386_partition_image ( ) { 
        # basic setup
        disk_partition_mbr
        disk_ufs_create

        disk_ufs_label 1 bsdrootfs || exit 1

        # boot loader	
        echo "Installing bootblocks"

	# TODO: This is broken; should use 'make install' to copy
	# bootfiles to workdir, then install to disk image from there.
        BOOTFILES=${FREEBSD_OBJDIR}/sys/boot/i386
        echo "Boot files are at: "${BOOTFILES} 
        gpart bootcode -b ${BOOTFILES}/mbr/mbr ${DISK_MD} || exit 1
        gpart set -a active -i 1 ${DISK_MD} || exit 1
        bsdlabel -w -B -b ${BOOTFILES}/boot2/boot `disk_ufs_partition` || exit 1

        #show the disk
        gpart show ${DISK_MD}
}

strategy_add $PHASE_PARTITION_LWW generic_i386_partition_image

# Kernel installs in UFS partition
strategy_add $PHASE_FREEBSD_BOARD_INSTALL board_default_installkernel .
