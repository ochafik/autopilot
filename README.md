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

sudo apt-get --purge remove -y idle3 smartsim scratch nuscratch minecraft-pi python-minecraftpi python3-minecraftpi sonic-pi dillo gpicview openjdk-7-jre oracle-java7-jdk libreoffice* wolfram-engine

# Drop X11
sudo apt-get --purge remove -y "x11-*" libxtst6 desktop-base xkb-data

sudo apt-get --purge autoremove -y
sudo apt-get clean

# Update
sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get --purge autoremove -y
sudo apt-get install -y vim
sudo apt-get --purge autoremove -y
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

## Security

See [Securing your Raspberry Pi](https://www.raspberrypi.org/documentation/configuration/security.md)

On the Pi:
- change your password, 
- `sudo apt-get update && sudo apt-get upgrade && sudo apt-get install screen vim`
- change the hostname,
- enable SSH

On your desktop:
```bash
# Setup pubkey auth for ssh:
cat ~/.ssh/id_rsa.pub | ssh pi@raspberrypi.local -C "install -d -m 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys"
```

On the Pi:
```bash
# Setup unattended upgrades:
sudo apt-get install unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "true";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

# Setup a firewall:
sudo apt-get install ufw
sudo ufw allow ssh
yes | sudo ufw enable

# Setup IP banning for serial offenders:
sudo apt-get install fail2ban
cat /etc/fail2ban/jail.conf | \
  sed -E 's/^(maxretry *=).*/\1 3/g' | \
  sed -E 's/^(bantime *=).*/\1 -1/g' | \
  sudo tee /etc/fail2ban/jail.local
```

## Install node.js

```bash
sudo apt-get install -y npm
sudo npm i -g n
sudo n latest
echo 'PATH=${PATH}:/usr/local/bin' >> ~/.profile 
```

## Install Tensorflow

```
sudo apt-get install -y libatlas-base-dev libhdf5-dev
pip install tensorflow

# Note: this runs it as an x86_64 image, which doesn't make any sense from a performance standpoint.
docker pull tensorflow/tensorflow
docker run -it -p 8888:8888 tensorflow/tensorflow
```

## Install docker

Method 1:
```
sudo apt-get install docker.io
```

Method 2 [source](https://www.freecodecamp.org/news/the-easy-way-to-set-up-docker-on-a-raspberry-pi-7d24ced073ef/):
```
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
```

## Install QEMU-x86 to run x86_64 docker images

```
sudo apt-get install -y --no-install-recommends qemu-system-x86 qemu-user-static binfmt-support
sudo update-binfmts --enable qemu-x86_64
sudo update-binfmts --display qemu-x86_64
```

## Install VS Code

```
sudo apt-get install code
```

Alternative method
```
wget https://code.headmelted.com/installers/apt.sh
# Inspect script
./apt.sh
```
