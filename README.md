autopilot
=========

Scripts for Raspberry Pi

Install with:

    wget -O - https://raw.github.com/ochafik/autopilot/master/install.sh > install.sh && chmod +x install.sh
    sudo ./install.sh

Flash image on mac with:

# Misc

## Trim a Raspbian distro

```bash
dpkg-query -Wf '${Installed-Size}\t${Package}\t${Priority}\n' | egrep '\s(optional|extra)' | cut -f 1,2 | sort -nr | less

sudo apt-get --purge remove -y scratch nuscratch minecraft-pi sonic-pi dillo gpicview openjdk-7-jre oracle-java7-jdk libreoffice* wolfram-engine

# Drop X11
sudo apt-get --purge remove -y "x11-*" libxtst6 desktop-base xkb-data

sudo apt-get --purge autoremove -y
sudo apt-get clean

# Update
sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get --purge autoremove -y
sudo apt-get install -y vim
sudo apt-get --purge autoremove -y

# Setup auto-updates upgrades
sudo apt-get install unattended-upgrades
# vi /etc/apt/apt.conf.d/50unattended-upgrades
```

Edit `/boot/config.txt`:

```
hdmi_blanking=2
disable_splash=1

# Disable the ACT LED on the Pi Zero.
dtparam=act_led_trigger=none
dtparam=act_led_activelow=on

## Disable the ACT LED on the Pi 1/2/3
#dtparam=act_led_trigger=none
#dtparam=act_led_activelow=off
## Disable the PWR LED on the Pi 1/2/3.
#dtparam=pwr_led_trigger=none
#dtparam=pwr_led_activelow=off
```

## Setup pubkey auth for ssh

```bash
cat ~/.sshd/id_rsa.pub | ssh pi@raspberrypi.local -C "mkdir ~/.ssh && chmod 700 ~/.sshd && cat >> ~/.ssh/authorized_keys && chmod 0600 ~/.sshd/authorized_keys"
```

## Install node.js

```bash
sudo apt-get install -y npm
sudo npm i -g n
sudo n latest
echo 'PATH=${PATH}:/usr/local/bin' >> ~/.profile 
```
