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

bash_test()
{
	read -p "bash_test in functions.sh. Git dir = ${arrconf[imgdirectory]}"
}
