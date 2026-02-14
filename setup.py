# Python setup - firstrun
# Imports
import sys, os

# Setup variables
hstname = str(os.uname()[1])
usrname = os.getlogin() # Gives user with/without sudo
arrconf = {}

def read_config():
	conf = "/boot/firmware/custom.conf"
	if os.path.exists(conf):
		with open(conf) as f:
			for line in f:
				key = line.split('=')[0]
				val = line.split('=')[1]
				arrconf[key] = val

def set_default_shell():
	os.system("dpkg-divert --remove --no-rename /usr/share/man/man1/sh.1.gz")
	os.system("dpkg-divert --remove --no-rename /bin/sh")
	os.system("ln -sf bash.1.gz /usr/share/man/man1/sh.1.gz")
	os.system("ln -sf bash /bin/sh")
	os.system("dpkg-divert --add --local --no-rename /usr/share/man/man1/sh.1.gz")
	os.system("dpkg-divert --add --local --no-rename /bin/sh")
	#os.system("exec $SHELL;exit")
	input("Default shell set to Bash, press enter to continue")

def create_users():
	os.system("groupadd -r -g 983 munge")
	os.system("useradd -r -g munge -u 983 -d /var/lib/munge -s /sbin/nologin munge")
	os.system("groupadd -r -g 984 slurm")
	os.system("useradd -r -m -c 'SLURM workload manager' -d /var/lib/slurm -u 984 -g slurm -s /bin/bash slurm")
	input("Create users done, press enter to continue")

def update_system():
	os.system("apt-get -y update")
	os.system("apt-get -y full-upgrade")
	os.system("apt-get -y install python3-dev gcc g++ libdtovl0 libomp-dev git build-essential cmake pkg-config make nfs-common screen htop stress-ng zip bzip2 fail2ban ufw ntpsec-ntpdate pkgconf openssl python3-setuptools libgpiod-dev mmc-utils smartmontools munge cgroup-tools libcgroup-dev autoconf libtool curl libcurl4-openssl-dev systemd-dev swig")
	input("System update done, press enter to continue")

def setup_slurm_dirs():
	os.makedirs("/var/spool/slurm")
	os.makedirs("/var/log/slurm")
	os.system("chown -R slurm:slurm /var/spool/slurm")
	os.system("chown -R slurm:slurm /var/log/slurm")
	input("Slurm directories created, press enter to continue")

def setup_nfs_client():
	os.system("sed -i 's/NEED_STATD=/NEED_STATD=no/g' /etc/default/nfs-common")
	os.system("sed -i 's/NEED_IDMAPD=/NEED_IDMAPD=yes/g' /etc/default/nfs-common")

def setup_firewall():
	usropt = input("Allow remote ssh acces (y/n): ").lower()
	if usropt == "y":
		os.system("yes | sudo ufw allow ssh")
	else:
		os.system("yes | sudo ufw allow from " + arrconf['subnet'] + " to any port ssh")
	os.system("sudo ufw logging on")
	os.system("yes | sudo ufw enable")
	input("Firewall setup done, press enter to continue")

def setup_git():
	strdir = arrconf["gitlocaldir"] + "/" +  arrconf["gitrepo"].strip()
	gitdir = "".join(strdir.splitlines())
	os.makedirs(gitdir)
	strurl = "https://github.com/" +  arrconf["gituser"] + "/" +  arrconf["gitrepo"] + ".git".strip()
	giturl = "".join(strurl.splitlines())
	cmd = "git clone " + giturl + " " + gitdir
	os.system(cmd)
	input("Git setup done, press enter to continue")

def update_bashrc():
	strfile = "/home/" + usrname + "/.bashrc"
	strdir = arrconf["gitlocaldir"] + "/" +  arrconf["gitrepo"].strip()
	gitdir = "".join(strdir.splitlines())
	with open(strfile, "a") as f:
		f.write("alias spo='sudo poweroff'\n")
		f.write("alias spr='sudo reboot'\n")
		f.write("alias lsb='sudo udevadm trigger; lsblk'\n")
		f.write("alias mps='sudo python " + gitdir + "/main.py'\n")
		input("bashrc update done, press enter to continue")

def main():
	read_config()
	#set_default_shell()
	#create_users()
	#setup_slurm_dirs()
	#update_system()
	# Modify new + existing installs
	#os.system("sed -i 's/rootwait/rootwait cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=0 ipv6.disable=1/g' /boot/firmware/cmdline.txt")
	#os.system("sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config")
	#os.system("sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config")
	#os.system("sed -i 's/#FallbackNTP/FallbackNTP/g' /etc/systemd/timesyncd.conf")
	#os.system("sed -i 's/default/latest/g' /etc/default/rpi-eeprom-update")
	#os.system("touch /etc/cloud/cloud-init.disabled")
	os.system("source " + arrconf["gitlocaldir"] + "/bash/functions.sh; update_hosts")
	#setup_nfs_client()
	#setup_git()
	#update_bashrc()
	#setup_firewall()
	os.system("chown -R " + usrname + ":" + usrname + " /data/*")
	input("Setup done, press enter to continue (reboot recommended)")

#def main():
#	os.system("source /data/current/src/git/rpi-home-pycluster/bash/bash_functions.sh; update_hosts")
#	os.system("source /data/current/src/git/rpi-home-pycluster/bash/bash_functions.sh; setup_fail2ban")
#	os.system("source /data/current/src/git/rpi-home-pycluster/bash/bash_functions.sh; create_venv")

if __name__ == "__main__":
	main()
