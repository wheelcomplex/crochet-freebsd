TARGET_ARCH=amd64
KERNCONF=GENERIC
IMAGE_SIZE=$((2000 * 1000 * 1000))

generic_amd64_partition_image ( ) { 
# TODO: create UEFI disk
        # basic setup
        disk_partition_mbr
        disk_ufs_create

        disk_ufs_label 1 bsdrootfs || exit 1

        # boot loader	
		echo "Installing bootblocks($TARGET_ARCH)"

	# TODO: This is broken; should use 'make install' to copy
	# bootfiles to workdir, then install to disk image from there.
        BOOTFILES=${FREEBSD_OBJDIR}/sys/boot/i386
        echo "Boot files are at: "${BOOTFILES} 
        gpart bootcode -b ${BOOTFILES}/mbr/mbr ${DISK_MD} || exit 1
        gpart set -a active -i 1 ${DISK_MD} || exit 1
		echo "befor bsdlabel"
        gpart show ${DISK_MD}
		gpart show ${NEW_UFS_SLICE}
        bsdlabel -w -B -b ${BOOTFILES}/boot2/boot `disk_ufs_partition` || exit 1

        #show the disk
		echo "Installing bootblocks($TARGET_ARCH) done, bsdlabel to `disk_ufs_partition`"
        gpart show ${DISK_MD}
		gpart show ${NEW_UFS_SLICE}
}

strategy_add $PHASE_PARTITION_LWW generic_amd64_partition_image 

# Kernel installs in UFS partition
strategy_add $PHASE_FREEBSD_BOARD_INSTALL board_default_installkernel .
