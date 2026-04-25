# Bash functions

source_bash()
{
	# Source setup shell scripts in same directory
	bashdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	for file in $(find $bashdir -type f -name "*.sh" ! -name $(basename "$0"));
	do
  		source $file;
	done
}

read_config()
{
	input="/boot/firmware/custom.conf"
	while IFS= read -r line
	do
		[ "${line:0:1}" = "#" ] || [ "${line:0:1}" = "" ] && continue # Ignore comment and empty lines works
		key=$(echo $line | cut -d "=" -f1)
		value=$(echo $line | cut -d "=" -f2)
		arrconf+=([$key]="$value")
	done < "$input"
}

check_pi_model()
{
	pimodel=$(cat /sys/firmware/devicetree/base/model | cut -d " " -f3- | tr -d "\0")
	pimodeltype=$(echo $pimodel | cut -d " " -f1)
	if [[ "$pimodeltype" =~ ^[0-9]+$ ]]; then # Integer so Pi series 1 - 5
		echo "Pi$pimodeltype"
	elif  [ $pimodeltype = "Compute" ]; then
		compnum=$(echo $pimodel | cut -d " " -f3)
		echo "CM$compnum"
	elif  [ $pimodeltype = "Zero" ]; then
		compnum=$(echo $pimodel | cut -d " " -f2)
		echo "Zero$compnum"
	fi
}

get_subnet_cidr()
{
	wired="$(nmcli -t connection show --active | grep ethernet | cut -f 4 -d ":")"
	wifi="$(nmcli -t connection show --active | grep wireless | cut -f 4 -d ":")"
 	if [[ $wifi ]] && [[ $wired ]]; then # Multiple connections
		read -p "Use ethernet or wifi for setup? (e/w): " inp
		if [[ ${inp,} = "e" ]]; then
			dev=$wired
		elif [[ ${inp,} = "w" ]]; then
			dev=$wifi
		else
			printf "invalid option"
		fi
	else # Single connection
		dev="$wifi$wired" 
	fi
 	export localnet=$(nmcli -t device show $dev | grep "ROUTE\[1\]" | cut -f 2 -d "=" | tr -d '[:blank:]' | sed "s/,nh//")
}
	
# SSH functions
#--------------
create_user_ssh_keys()
{
	# Create keys for user
	runuser -l  $usrname -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -P \"\"" # Works including creates .ssh directory
	echo "HostKey $usrpath/.ssh/id_ed25519" >> /etc/ssh/sshd_config
	service sshd restart # Works
 	read -p "Server keys generated for $usrname, press enter to return to menu" inp
}

copy_user_ssh_keys()
{
	read -p "Remote node: " remnode
	sudo -u $usrname ssh-copy-id -i $usrpath/.ssh/id_ed25519 $usrname@$remnode
}
delete_node_from_known_hosts()
{
	read -p "Remote node: " remnode
	sudo -u $usrname ssh-keygen -f "$usrpath/.ssh/known_hosts" -R $remnode
}

# NFS setup functions
#--------------------
install_nfs_server()
{
	# TODO - Firewall rule not added if called from add_nfs_local
	# Messages from install_nfs_server option are
	# 	nfs-kernel-server install done, press enter to continue
	# 	Device = eth0 | localnet = 192.168.0.0/24
	# 	Rule added

 	#statnfs=$(check_package_status nfs-kernel-server y) # Check installed + install if not
	statnfs="d"
	if [[ $statnfs = "d" ]]; then # Setup server
		apt-get -y install nfs-kernel-server
	 	# Enforce NFSv4
		echo "RPCMOUNTDOPTS=\"--manage-gids -N 2 -N 3\"" >> /etc/default/nfs-kernel-server
		echo "RPCNFSDOPTS=\"-N 2 -N 3\"" >> /etc/default/nfs-kernel-server
		get_subnet_cidr
    	yes | sudo ufw allow from $localnet to any port nfs
		read -p "NFS Server setup done, press any key to continue"
	else
		read -p "NFS Server already installed, press any key to continue"
	fi
}

# Add local export
add_nfs_local()
{
	get_subnet_cidr
	install_nfs_server
   	# Check mount type
    read -p "System mount (default $arrconf[defsysdir]) or Data share? (s/d) " inp
    if [[ ${inp,} = "s" ]]; then # System mount
    	read -p "Path of directory to be shared (press enter for default = $arrconf[defsysdir]): " userdir
		nfsdir=${userdir:="$arrconf[defsysdir]"}
		# Check mount exists
		if grep -F "$nfsdir" "/etc/exports"
		then
			read -p "export  exists"
		else
			echo "$nfsdir $localnet(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
			exportfs -ra
			read -p "export $nfsdir created"
		fi
	elif [[ ${inp,} = "d" ]]
	then # Data mount (default /data/subdirectory)    	
		read -p "Path to directory for export (press enter for default = $defdatadir): " userdir
		basedir=${userdir:="$defdatadir"}
 		# Data share path/name (default /data/share name)
   		nfsbase=$(list_selection "directory" d $basedir)
		nfsdir=$nfsbase
		# Check mount exists
		if grep -F "$nfsdir" "/etc/exports"
		then
			read -p "export  exists"
		else
			echo "$nfsdir $localnet(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
			exportfs -ra
			read -p "export $nfsdir created"
			create_data_structure $nfsdir
		fi
		mount -a
 		#read -p "NFS export added, press any key to return to menu" input
    else
    	read -p "invalid input"
    fi
}

# Add remote mount
add_nfs_remote()
{
	read -p "Remote node: " remnode
	# Check mount type
    	read -p "System mount (default $defsysdir) or Data share? (s/d): " inp
    	if [[ ${inp,} = "s" ]]
    	then # System mount
     		read -p "Full path to remote directory (press enter for default = $defsysdir): " userdir
       		mntdir=${userdir:="$defsysdir"}
	 	echo "$remnode:$mntdir $mntdir    nfs4 rw,relatime,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none 0 0" >> /etc/fstab
   		ldconfig
	elif [[ ${inp,} = "d" ]]
	then # Data mount (default /data/subdirectory)
		read -p "Path to remote directory (press enter for default = $defdatadir): " userdir
		basedir=${userdir:="$defdatadir"}
 		# Data share path/name (default /data/share name)
   		mntdir=$(list_selection "directory" d $basedir)
		echo "$remnode:$mntdir $mntdir    nfs4 rw,relatime,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none 0 0" >> /etc/fstab
		systemctl daemon-reload  		
	fi
	mount -a
	read -p "NFS remote mount done, press enter to return to menu"
}
