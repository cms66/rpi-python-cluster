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

