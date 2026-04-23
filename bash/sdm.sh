# SDM setup functions
# TODO use rpiboot for CM eMMC drives

#usrname=$(logname)
#defdatadir="/data"

#init_sdm()
#{
#	declare -gA arrSDMconf # Array for configuration settings
# 	export instdir="/usr/local/sdm" # Default installation directory (target for custom.conf)
#	if [[ $(command -v sdm) ]]
# 	then
# 		read_sdm_config  		
#	fi
#}

install_sdm_server()
{
	apt-get -y install rpiboot # For Compute module eMMC drives
    # Default setup - install to /usr/local/sdm
	curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
  	# Create directories for images
	defdir="${arrconf[imgdirectory]}" # /data/current
	defimgdir="$defdir/sdm/images"
  	read -rp "Path to image directory (press enter for default = $defimgdir): " userdir
	imgdir=${userdir:="$defimgdir"}
  	mkdir -p $imgdir/current
  	mkdir -p $imgdir/latest
   	mkdir -p $imgdir/archive
	chown -R $usrname:$usrname $imgdir/..
    echo "imgdirectory=$imgdir" >> /boot/firmware/custom.conf
	read -p "SDM Server install done, press enter to continue"
}

install_sdm_client()
{
	defdir="${arrconf[imgdirectory]}" # /data/current
	defimgdir="$defdir/sdm/images"
  	read -rp "Path to image directory (press enter for default = $defimgdir): " userdir
	imgdir=${userdir:="$defimgdir"}
	echo "imgdirectory=$imgdir" >> /boot/firmware/custom.conf
	read -p "SDM Client install done, press enter to continue"
}

show_sdm_config()
{
	#read_sdm_config
	printf "SDM Config\n----------\n\
Image directory: ${arrconf[imgdirectory]}\n\
WiFi Country: ${arrconf[wificountry]}\n\
WiFi SSID: ${arrconf[wifissid]}\n\
WiFi Password: ${arrconf[wifipassword]}\n"
read -p "Press enter to continue"
}

edit_sdm_config()
{
	read -p "Function not yet available, press enter to continue"
}

download_latest_os_images()
{
	imgdir=${arrconf[imgdirectory]}
	# Latest images - TODO - check releaseDate/releaseDate is in url
	verlatest=$(curl -s https://downloads.raspberrypi.org/operating-systems-categories.json | grep "releaseDate" | head -n 1 | cut -d '"' -f 4)
	verdownload=$verlatest
	url64lite=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-$verlatest/$verdownload-raspios-trixie-arm64-lite.img.xz
	url64desk=https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-$verlatest/$verdownload-raspios-trixie-arm64.img.xz
	# Replace uncustomized latest images
 	# TODO - check if new versions available
  	rm -rf $imgdir/latest/*.img
	read -p "Dir = $imgdir/latest/"
	# Download latest images and extract
 	printf "Downloading latest images\n"
	wget -P $imgdir/latest $url64lite
 	wget -P $imgdir/latest $url64desk
    printf "Downloads done, extracting images\n"
	unxz $imgdir/latest/*.xz
	chown $usrname:$usrname $imgdir/latest/*.img
	read -p "Downloads for $verlatest to $imgdir/latest complete, press enter to continue" input
}

modify_sdm_image()
{
	imgdir=${arrconf[imgdirectory]}
	# Select latest or current directory
	read -p "Use Latest or Current image? (L/C): " userdir
	if [[ ${userdir,} = "l" ]]; then dirlist="latest" # copy to current		
	elif [[ ${userdir,} = "c" ]]; then dirlist="current" # Modify a current image  		
	else
 		read -p "Invalid option, press any key to continue"
 		return
	fi
	# Image list for selection/modification
	imgsel=$(list_selection "image" f "$imgdir/$dirlist")
	read -p "Modify image: $imgsel" inp
	
	if [[ ${dirlist} = "latest" ]]; then # Copy to /current for modification and rename
		imginp=$imgsel
		read -p "Add identifier to image name: " imgid
		imgnew="${imgsel//".img"/"-$imgid.img"}"
		#imgnew=$(sed "s/.img/-$imgid.img/ $imgsel")
		read -p "New image: $imgnew" inp
		printf "copying image $imginp to $imgnew\n"
		imgmod=$imgdir/current/$imgnew
		curl -o $imgmod FILE://$imgdir/latest/$imginp
		chown $usrname:$usrname $imgmod
		chmod 777 $imgmod
		read -p "Image to mod#ify = $imgmod"
		# Set username/password
		read -p "Password for $usrname: " usrpass
		read -p "Use WiFi or Ethernet? (W/E): " usrcon
		if [[ ${usrcon,} = "w" ]]; then
			read -p "Wifi selected, press enter to continue"
			sdm --customize --plugin user:"adduser=$usrname|password=$usrpass" --plugin user:"deluser=pi" --plugin L10n:host --plugin disables:piwiz --plugin network:"ifname=wlan0|ctype=wifi|wifi-ssid=${arrSDMconf[wifissid]}|wifi-password=${arrSDMconf[wifipassword]}|wificountry=${arrSDMconf[wificountry]}|noipv6" --extend --expand-root --regen-ssh-host-keys --restart $imgmod
		elif [[ ${usrcon,} = "e" ]]; then
			read -p "ethernet selected, press enter to continue"
			sdm --customize --plugin user:"adduser=$usrname|password=$usrpass" --plugin user:"deluser=pi" --plugin L10n:host --plugin disables:piwiz --plugin network:"ifname=eth0|noipv6" --extend --expand-root --regen-ssh-host-keys --restart $imgmod
		else
			read -p "Invalid option, press enter to continue"
		fi
	elif [[ ${dirlist} = "current" ]]; then
		imgmod=$imgdir/current/$imgsel
		read -p "Image to mod#ify = $imgmod"
		sdm --explore $imgmod
	else
		read -p "Invalid option, press enter to continue"
	fi
}

explore_sdm_image()
{
	imgdir=${arrconf[imgdirectory]}
	# Select image from current
	imgsel=$(list_selection "image" f "$imgdir/current")
	read -p "$imgsel selected - Continue (Y/N)" inp
	if [[ ${inp,} = "y" ]]; then
		imgmod=$imgdir/current/$imgsel
		sdm --explore $imgmod
		read -p "Changes applied - press enter to continue"
	fi
}

burn_sdm_image()
{
	imgdir=${arrconf[imgdirectory]}
	# Select image from current
	imgsel=$(list_selection "image" f "$imgdir/current")
 	#imgsel=$(select_list "$imgdir/current" "Image" | awk -F "/" '{print $NF}')
	#imgsel=$dirlist
	read -p "$imgsel selected - Continue (Y/N)" inp
	# Select drive
	if [[ ${inp,} = "y" ]]; then
		imgburn=$imgdir/current/$imgsel
		# Check if rpiboot needed (for Compute Module mmcblk drive)
		read -p "Run rpiboot for Compute Module? (Y/N): " inp
		if [[ ${inp,} = "y" ]]; then # Try to flash CM MMC drive with timeout
			piboot=$(timeout 30 rpiboot | tail -n 1) # TODO modify timeout + loopt to max 
			if [[ $piboot = "Second stage boot server done" ]]; then
				udevadm control --reload-rules && udevadm trigger
				bootres="Drive available"
			else
				bootres="No drive available"
			fi
			read -p "Outcome: $bootres, press any key to continue"
		fi
		udevadm control --reload-rules && udevadm trigger
		drvsel=$(list_selection "drive" b)
		read -p "$drvsel selected - Continue (Y/N)" inp
		if [[ ${inp,} = "y" ]]; then
			read -p "Hostname: " inphost
			read -p "Burn $imgburn to $drvsel with hostname $inphost? (Y/N)"
			if [[ ${inp,} = "y" ]]; then
				# burn
				sdm --burn /dev/$drvsel --hostname $inphost --expand-root $imgburn
				read -p "Burn $imgburn to $drvsel with hostname $inphost complete - press enter to continue"
			fi
		fi
	fi
}

list_selection()
{
	# Args
	# 1 - Prompt
	# 2 - List Type (a/d/f/z)
	#		- Array
	#		- Directories
	#		- Files
	#		- Zpools
	# 3	- List root (for file/dir) or array

	# Populate list
	arrlist=()
	if [ $2 = "a" ]; then # Array
		arrin=$3[@]
		arrlist=("${!arrin}")
	elif [ $2 = "b" ]; then # Block device - TODO filter
		cmd="lsblk -A -d"
		while read item
		do
			arrlist+=( $(echo "$item" | cut -d ' ' -f 1) )			
		done < <($cmd)
		unset -v "arrlist[0]" # Remove first item = column titles
	elif [ $2 = "d" ]; then # Directories
		basedir=${3%/}
		cmd="find $basedir -maxdepth 1 -type d"
		while read item
		do
			arrlist+=( "$item" )			
		done < <($cmd)
		unset -v "arrlist[0]" # Remove first item = basedir
	elif [ $2 = "f" ]; then # Files
		basedir=${3%/}
		cmd="find $basedir -maxdepth 1 -type f"
		while read item
		do
			fname="$(basename -- $item)"
			arrlist+=( $fname )			
		done < <($cmd)
	elif [ $2 = "x" ]; then # Zpools - import
		zlist=$(zpool import | grep "pool:" | cut -d ":" -f 2 | tr -d '[:blank:]')
		arrlist+=( "$zlist" )
	elif [ $2 = "z" ]; then # Zpools - list Works for imported pools
		zlist=$(zpool list | tail -n +2 | cut -d " " -f 1)
		arrlist+=( "$zlist" )
	else
		read -p "Invalid type, press any key to continue"
		return 0
	fi
	arrlist+=( "Back" )
	last_element=${arrlist[-1]}
	COLUMNS=1
	PS3="Select $1: "
	select item in ${arrlist[@]}
	do
		if [[ $item = $last_element ]] || [[ ${REPLY,} = "b" ]] || [[ ${REPLY,} = "q" ]]; then # Last menu item/Q/q/B/b
			break
		else
			if ! [[ $item = "" ]]; then
				echo "$item"
				break			
			fi
		fi
	done
}
