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
