#!/bin/sh
if [ $# -eq 0 ] ; then
  ./install.sh holo base steam end
  exit
fi
END=0
sudo pacman -Syu --noconfirm
case $1 in
  "holo")
    # add additional-pacman.conf

    cat "./additional-pacman.conf" | sudo tee -a /etc/pacman.conf
    # add holo-keyring => gpg fail
    wget https://steamdeck-packages.steamos.cloud/archlinux-mirror/holo/os/x86_64/holo-keyring-20220203-4-any.pkg.tar.zst
    sudo pacman -U --noconfirm holo-keyring-20220203-4-any.pkg.tar.zst
    sudo pacman-key --populate holo
    sudo pacman-key --refresh
    rm holo-keyring-20220203-4-any.pkg.tar.zst
    sudo pacman -Syyu --noconfirm
    yes | sudo pacman -S linux-firmware-neptune
    sudo pacman -S --noconfirm jupiter-hw-support jupiter-fan-control jupiter/xorg-xwayland-jupiter --overwrite '*'
    yes | sudo pacman -S steamdeck-kde-presets sddm-wayland mangohud lib32-mangohud --overwrite '*'
    ;;
  "base")
    sudo systemctl enable -sz-now bluetooth
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon   p7zip
    yay -S --noconfirm proton-ge-custom-bin gamescope-session-git
    ;;
  "switch-scripts")
    sudo mkdir /usr/share/steamos-custom
    sudo cp ./stopgamescope /usr/share/steamos-custom/
    sudo cp ./stopsddm /usr/share/steamos-custom/
    # gamescope commands
    echo "$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/systemctl stop sddm.service, /usr/bin/systemctl stop gamescope@$USER.service" | sudo tee /etc/sudoers.d/99-steamos-custom
    # shortcuts
    sudo cp ./switchtodesktop.desktop /usr/share/applications/
    sudo cp ./switchtogamepadui.desktop /usr/share/applications/
    sudo cp ./switchtogamepadui.desktop ~/Desktop/
    ;;
  "steam")
    # Somehow this command is super buggy
    sudo pacman -S --noconfirm steam
    steam
    steam -steamos3 -gamepadui -steamdeck -steampal
    steam -steamos3 -gamepadui -steamdeck -steampal
    steam -steamos3 -gamepadui -steamdeck -steampal
    ;;
  "kvm")
    # VFIO is WIP...
    # Basic VMs thing work fine though
    sudo pacman -S --noconfirm virt-manager dnsmasq libvirt qemu edk2-ovmf socat gnu-netcat
    sudo systemctl enable --now libvirtd
    sudo virsh net-autostart default
    sudo virsh net-start default
    sudo cp ./lsiommu /usr/bin/
    sudo usermod -aG libvirt "$(logname)" # doesn't work but is not needed?
    ;;
  "end")
    END=1
    ;;
esac
if [ $END -eq 1 ]; then
  shift 1
  ./install.sh "$@"
fi

