# Bash functions

source_bash()
{
	# Source setup shell scripts in same directory
	for file in $(find $(dirname -- "$0") -type f -name "*.sh" ! -name $(basename "$0"));
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

