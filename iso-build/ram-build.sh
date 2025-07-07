#!/bin/bash
# Если каки-то команды не србаотают использовать sudo
# Подготовка среды
sudo apt update && sudo apt install -y \
    squashfs-tools xorriso isolinux unzip wget rsync \
    p7zip-full genisoimage fdisk exfatprogs git \
    dosfstools mtools

# Создание рабочих директорий
mkdir -p ~/custom-iso/{extract-cd,squashfs-root}
cd ~/custom-iso

# Скачиваем оригинальный образ
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso

# Распаковать ISO
# Проверить не создалась ли директория extract-cd/ubuntu, если да, то нужно удалить
mount -o loop ubuntu-20.04.6-live-server-amd64.iso mnt-iso
rsync -a mnt-iso/ extract-cd/
umount mnt-iso; rmdir mnt-iso


# Проверка размера системы
stat -c %s extract-cd/casper/filesystem.squashfs
# Извлекаем корневую ФС
unsquashfs -d squashfs-root extract-cd/casper/filesystem.squashfs

# добавление в распакованную ОС интернет конфига
sudo cp /etc/resolv.conf squashfs-root/etc/resolv.conf

# Добавление собственныз скриптов и тд
mkdir squashfs-root/{you sk}
cp /you/save/sk ~/custom-iso/squashfs-root/{you sk}
# Монтируем системные каталоги
sudo mount --bind /dev squashfs-root/dev 
sudo mount --bind /proc squashfs-root/proc
sudo mount --bind /sys squashfs-root/sys 
sudo mount --bind /run squashfs-root/run

# Chroot и установка нужного
sudo chroot squashfs-root /bin/bash << 'EOC'
set -e
export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y casper overlayroot 
apt install -y \
  software-properties-common \
  wget curl git make gnupg lsb-release ca-certificates build-essential \
  linux-image-generic initramfs-tools sudo locales netplan.io \
  grub-pc grub-common systemd-sysv rsync

  # Добавление репозитория NVIDIA вручную
mkdir -p /etc/apt/keyrings
curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub \
    | gpg --dearmor -o /etc/apt/keyrings/nvidia.gpg

echo "deb [signed-by=/etc/apt/keyrings/nvidia.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64 /" \
    > /etc/apt/sources.list.d/nvidia.list

apt update
# Устанавливаем пакеты NVIDIA 
apt install -y \
  nvidia-driver-570-server \
  nvidia-dkms-570-server \
  nvidia-utils-570-server \
  nvidia-fabricmanager-570 \
  datacenter-gpu-manager \
  libibumad3 \
  infiniband-diags 

# Устанавливаем дополнительные утилиты
apt install -y \
   bpytop iperf3 stress-ng mc docker.io \
  nvidia-container-toolkit ipmitool ethtool
apt install -y git make gcc g++ build-essential linux-headers-generic
# Устанавливаем GPU Burn с исправлениями
git clone https://github.com/Syllo/nvtop.git

# Уставнока nvtop
mkdir -p nvtop/build && cd nvtop/build
cmake .. -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON -DINTEL_SUPPORT=ON
make
sudo make install
cd /

# Уставнока btop
wget https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz
tar xvf btop-x86_64-linux-musl.tbz
cd btop
sudo make install
cd /

# Устанавливаем GPU Burn с исправлениями
git clone https://github.com/wilicc/gpu-burn

# Устанавливаем DCGM
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/datacenter-gpu-manager-4-core_4.2.2_amd64.deb
dpkg -i datacenter-gpu-manager-4-core_4.2.2_amd64.deb || apt -f install -y
rm datacenter-gpu-manager-4-core_4.2.2_amd64.deb

# Overlay + RAM
echo 'overlayroot="tmpfs"' > /etc/overlayroot.conf
echo 'TORAM="yes"' >> /etc/casper.conf
echo 'OVERLAYFS="tmpfs"' >> /etc/casper.conf

# Локаль и часовой пояс
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone

update-initramfs -u
EOC

# Отмонтируем
sudo umount squashfs-root/dev
sudo umount squashfs-root/proc
sudo umount squashfs-root/sys
sudo umount squashfs-root/run

# Пересоздание squashfs
sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs squashfs-root extract-cd/casper/filesystem.squashfs -e boot

# Обновить manifest
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop

# Встраиваем user-data/meta-data есть два метода
# 1.Через папку
mkdir -p extract-cd/nocloud
cp user-data meta-data extract-cd/nocloud/
# 2.Через образ, убедитесь что файлы user-data meta-data лежат рядом
genisoimage -output cidata.iso -volid cidata -joliet -rock user-data meta-data

# Проверка образа после изменения
#Если размер > 4 294 967 295 — без -iso-level 3 это вызовет ошибку.
xorriso -indev custom-ram.iso -ls /casper/filesystem.squashfs

# Обноваление файла grub.cfg и loopback.cfg
rm extract-cd/boot/grub/grub.cfg extract-cd/boot/grub/loopback.cfg
cp /youway/grub.cfg extract-cd/boot/grub/grub.cfg
cp /youway/loopback.cfg extract-cd/boot/grub/loopback.cfg

# Пересобрать ISO
sudo xorriso -as mkisofs \
  -r -V Custom-RAM \
  -o custom-ram.iso \
  -J -l -iso-level 3 -cache-inodes \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot -isohybrid-gpt-basdat \
  extract-cd