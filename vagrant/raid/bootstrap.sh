#!/bin/bash

#https://raid.wiki.kernel.org/index.php/RAID_setup

#source /vagrant/bootstrap.sh

install_mdadm() {
    sudo apt-get -y install mdadm
}

configure_raid5() {
    sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=5 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf
}

configure_raid5_with_spare() {
    sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde --spare-devices=1 /dev/sdf
}

configure_raid10() {
    sudo mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde --spare-devices=1 /dev/sdf
}

check_raid() {
    sudo cat /proc/mdstat
}

save_raid() {
    sudo bash -c "mdadm --detail --scan >> /etc/mdadm/mdadm.conf"
    sudo update-initramfs -u
}

create_fs() {
    sudo mkfs.ext4 /dev/md0
    sudo mkdir -p /mnt/raid
    sudo chmod 777 /mnt/raid
    sudo bash -c "echo /dev/md0 /mnt/raid ext4  rw,user,exec 0 0 >> /etc/fstab"
    sudo bash -c "echo chmod 777 /mnt/raid >> /etc/rc.local"
    sudo mount /mnt/raid
    sudo chmod 777 /mnt/raid
}

#https://romanrm.net/dd-benchmark
bechmark() {
    sync; dd if=/dev/zero of=bf bs=8k count=500000 conv=fdatasync; rm bf
}

detail_raid() {
    sudo mdadm --detail /dev/md0
}

#https://www.thomas-krenn.com/en/wiki/Mdadm_recovery_and_resync
replace_faulty() {
    sudo mdadm --manage --set-faulty /dev/md0 /dev/sde
    sudo mdadm --manage /dev/md0 -r /dev/sde
    sudo mdadm --manage /dev/md0 -a /dev/sde
}

remove_raid() {
    sudo mdadm --stop /dev/md0
    sudo mdadm --zero-superblock /dev/sdb
    sudo mdadm --zero-superblock /dev/sdc
    sudo mdadm --zero-superblock /dev/sdd
    sudo mdadm --zero-superblock /dev/sde
    sudo mdadm --zero-superblock /dev/sdf
    echo "please remove it from /etc/mdadm/mdadm.conf and update-initramfs -u"
    echo "please remove it from /etc/fstab"
}