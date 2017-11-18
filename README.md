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

sudo apt-get remove --purge scratch nuscratch minecraft-pi sonic-pi dillo gpicview penguinspuzzle openjdk-7-jre oracle-java7-jdk libreoffice* wolfram-engine
sudo apt-get clean
sudo apt-get autoremove
```
