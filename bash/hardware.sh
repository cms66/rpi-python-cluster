# Bash hardware functions

setup_pcie()
{
	# Enable Gen 3 - Check for Pi 5/CM5
	if [ $(check_pi_model) = "Pi5" ] || [ $(check_pi_model) = "CM5" ]; then # PCIe available
		if [[ -z $(cat /boot/firmware/config.txt | grep  "dtparam=pciex1_gen=3") ]]; then # Gen 3 not set
			echo "dtparam=pciex1" >> /boot/firmware/config.txt
			echo "dtparam=pciex1_gen=3" >> /boot/firmware/config.txt
			read -p "PCIe Gen 3 enabled (reboot required), press enter to continue"
		else
			read -p "PCIe Gen 3 already enabled, press enter to continue"
		fi
	else
		read -p "PCIe not available, press enter to continue"
		return 0
	fi
}

setup_camera_csi()
{
	# Check if picamera2 installed
	pycam=$(dpkg-query --show --showformat='${Status}' python3-picamera2 2>&1 | grep "installed" | head -c -1)
	if ! [[ $pycam = "install ok installed" ]]; then
		apt-get -y install python3-picamera2 --no-install-recommends
		printf "python3-picamera2 install not done\n"
	else
		printf "python3-picamera2 already installed\n"
	fi
	# Check for camera - auto detect
	camcheck=$(rpicam-hello --list-cameras 2>&1)
	if [[ $camcheck = "No cameras available!" ]]; then
		printf "Camera not detected\n"
	else
		printf "Camera auto detected = $(rpicam-hello --list-cameras | grep "0 :" | cut -d " " -f 3)\n"
	fi
	pimod=$(check_pi_model) # Check RPi model (CM5 dual camera and autodetect doesn't work)
	if [ $pimod = "CM5" ]; then
		output_cam_config
		printf "Model = CM5\n"
		read -p "Change configuration? " inp
		if [[ ${inp,} = "y" ]]; then
			update_cam_config
		fi
	fi
	read -p "CSI camera setup done, press enter to continue"
}

output_cam_config()
{
	conf=$(cat /boot/firmware/config.txt | grep "#Compute Module Cameras" | tr -d '[:blank:]')
	if [[ $conf = "" ]]; then # First run
		echo "#Compute Module Cameras" >> /boot/firmware/config.txt
		for i in ${!arr_camera[@]}; do # Output camera options to config.txt
	  		echo "#dtoverlay=${arr_camera[$i]},cam0" >> /boot/firmware/config.txt
			echo "#dtoverlay=${arr_camera[$i]},cam1" >> /boot/firmware/config.txt
		done
		printf "Camera config output done\n"
	fi
}

update_cam_config()
{
	read -p "Cam/DSI interface (0/1): " camif # Get Camera interface
	if [ $camif = "0" ] || [ $camif = "1" ]; then # Valid interface
		printf "Camera models available\n"
		for i in ${!arr_camera[@]}; do
  			echo "$i - ${arr_camera[$i]}"
		done
		read -p "Select Camera: " camid
		cams=$(cat /boot/firmware/config.txt | grep "cam$camif")
		usercam=$(cat /boot/firmware/config.txt | grep "${arr_camera[$camid]},cam$camif")
		for cam in $cams; do # Disable camera models on selected interface
			if [ ! ${cam:0:1} = "#" ]; then # Disable
				sed -i "s/$cam/#$cam/g" /boot/firmware/config.txt
			fi
		done
		sed -i "s/$usercam/${usercam:1}/g" /boot/firmware/config.txt # Enable selected camera
		printf "Camera: ${arr_camera[$camid]} enabled on CSI $camif\n"
	else
		printf "Not a valid interface\n"
	fi
	printf "Camera config update done\n"
}

setup_camera_usb()
{
	read -p "Function not yet available, press enter to continue"
}

setup_i2c()
{
	apt-get -y install i2c-tools python3-smbus gpiod
	sed -i 's/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g' /boot/firmware/config.txt
 	echo "i2c-dev" >> /etc/modules-load.d/i2c-dev.conf
	read -p "I2C setup done, press enter to continue"
}

setup_python_usb()
{
	source $usrpath/.venv/bin/activate
	pip install pyusb
	cp -r .venv/lib/python3.13/site-packages/pyusb* /usr/lib/python3/dist-packages/
	cp -r .venv/lib/python3.13/site-packages/usb* /usr/lib/python3/dist-packages/
	read -p "Python - USB setup done, press enter to continue"
}

setup_gps_pa1010D()
{
	source $usrpath/.venv/bin/activate
	pip install pa1010d
	deactivate
	cp -r .venv/lib/python3.13/site-packages/pynmea2* /usr/lib/python3/dist-packages/
	cp -r .venv/lib/python3.13/site-packages/pa1010d* /usr/lib/python3/dist-packages/
	read -p "GPS - PA1010D setup done, press enter to continue"
}

setup_hcsr04()
{
	read -p "HC-SR04 setup TODO, press enter to continue"
}

setup_hailo()
{
	apt-get -y install hailo-all dkms
	read -p "Hailo-8 setup done, press enter to continue"
}
