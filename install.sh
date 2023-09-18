#!/bin/bash

# Run as root
[[ "$(whoami)" != "root" ]] && {
    echo -e "\033[1;33m[\033[1;31mErro\033[1;33m] \033[1;37m- \033[1;33myou need to run as root\033[0m"
    rm /home/ubuntu/install.sh &>/dev/null
    exit 0
}

#=== setup ===
cd 
rm -rf /root/udp
mkdir -p /root/udp
rm -rf /etc/UDPCustom
mkdir -p /etc/UDPCustom
sudo touch /etc/UDPCustom/udp-custom
udp_dir='/etc/UDPCustom'
udp_file='/etc/UDPCustom/udp-custom'

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y wget
sudo apt install -y curl
sudo apt install -y dos2unix
sudo apt install -y neofetch

source <(curl -sSL 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/module')

time_reboot() {
  print_center -ama "${a92:-System/Server Reboot In} $1 ${a93:-Seconds}"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  rm /home/ubuntu/install.sh &>/dev/null
  rm /root/install.sh &>/dev/null
  echo -e "\033[01;31m\033[1;33m More Updates, Follow Us On \033[1;31m(\033[1;36mTelegram\033[1;31m): \033[1;37m@voltssh\033[0m"
  reboot
}

# Check Ubuntu version
if [ "$(lsb_release -rs)" = "8*|9*|10*|11*|16.04*|18.04*" ]; then
  clear
  print_center -ama -e "\e[1m\e[31m=====================================================\e[0m"
  print_center -ama -e "\e[1m\e[33m${a94:-this script is not compatible with your operating system}\e[0m"
  print_center -ama -e "\e[1m\e[33m ${a95:-Use Ubuntu 20 or higher}\e[0m"
  print_center -ama -e "\e[1m\e[31m=====================================================\e[0m"
  rm /home/ubuntu/install.sh
  exit 1
else
  clear
  echo ""
  print_center -ama "A Compatible OS/Environment Found"
  print_center -ama " ⇢ Installation begins...! <"
  sleep 3

    # [change timezone to UTC +0]
  echo ""
  echo " ⇢ Change timezone to UTC +0"
  echo " ⇢ for Africa/Accra [GH] GMT +00:00"
  ln -fs /usr/share/zoneinfo/Africa/Accra /etc/localtime
  sleep 3

  # [+clean up+]
  rm -rf $udp_file &>/dev/null
  rm -rf /etc/UDPCustom/udp-custom &>/dev/null
  # rm -rf /usr/bin/udp-request &>/dev/null
  rm -rf /etc/limiter.sh &>/dev/null
  rm -rf /etc/UDPCustom/limiter.sh &>/dev/null
  rm -rf /etc/UDPCustom/module &>/dev/null
  rm -rf /usr/bin/udp &>/dev/null
  rm -rf /etc/UDPCustom/udpgw.service &>/dev/null
  rm -rf /etc/udpgw.service &>/dev/null
  systemctl stop udpgw &>/dev/null
  systemctl stop udp-custom &>/dev/null
  # systemctl stop udp-request &>/dev/null

 # [+get files ⇣⇣⇣+]
  source <(curl -sSL 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/module') &>/dev/null
  wget -O /etc/UDPCustom/module 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/module' &>/dev/null
  chmod +x /etc/UDPCustom/module

  wget "https://raw.githubusercontent.com/thefather12/UDP-PRO/main/bin/udp-custom-linux-amd64" -O /root/udp/udp-custom &>/dev/null
  # wget "https://raw.githubusercontent.com/prjkt-nv404/UDP-Custom-Installer-Manager/main/bin/udp-request-linux-amd64" -O /usr/bin/udp-request &>/dev/null
  chmod +x /root/udp/udp-custom
  # chmod +x /usr/bin/udp-request

  wget -O /etc/limiter.sh 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/limiter.sh'
  cp /etc/limiter.sh /etc/UDPCustom
  chmod +x /etc/limiter.sh
  chmod +x /etc/UDPCustom
  
  # [+udpgw+]
  wget -O /etc/udpgw 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/udpgw'
  mv /etc/udpgw /bin
  chmod +x /bin/udpgw

  # [+service+]
  wget -O /etc/udpgw.service 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/config/udpgw.service'
  wget -O /etc/udp-custom.service 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/config/udp-custom.service'
  
  mv /etc/udpgw.service /etc/systemd/system
  mv /etc/udp-custom.service /etc/systemd/system

  chmod 640 /etc/systemd/system/udpgw.service
  chmod 640 /etc/systemd/system/udp-custom.service
  
  systemctl daemon-reload &>/dev/null
  systemctl enable udpgw &>/dev/null
  systemctl start udpgw &>/dev/null
  systemctl enable udp-custom &>/dev/null
  systemctl start udp-custom &>/dev/null

  # [+config+]
  wget "https://raw.githubusercontent.com/thefather12/UDP-PRO/main/config/config.json" -O /root/udp/config.json &>/dev/null
  chmod +x /root/udp/config.json

  # [+menu+]
  wget -O /usr/bin/udp 'https://raw.githubusercontent.com/thefather12/UDP-PRO/main/module/udp' 
  chmod +x /usr/bin/udp
  ufw disable &>/dev/null
  sudo apt-get remove --purge ufw firewalld -y
  apt remove netfilter-persistent -y
  clear
  echo ""
  echo ""
  print_center -ama "${a103:-setting up, please wait...}"
  sleep 6
  title "${a102:-Installation Successful}"
  print_center -ama "${a103:-  To show menu type: \nudp\n}"
  echo -ne "\n\033[1;31mENTER \033[1;33mpara entrar al \033[1;32mMENU!\033[0m"; read
   udp
  
fi
