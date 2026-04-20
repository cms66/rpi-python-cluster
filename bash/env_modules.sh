# Setup Environment Modules

install_modules_server()
{
    apt-get -y install tcl tcl-dev m4 sphinx autoconf automake autopoint
    git clone https://github.com/envmodules/modules.git
    cd modules
    ./configure --prefix=/usr/local
    make
    make install
	ldconfig
    # Modules initialization
    cd $usrpath
	echo ". /usr/local/init/bash" >> .bashrc
	rm -rf modules*
    read -p "Environment Modules install done, press enter to continue" input
}

install_modules_client()
{
    apt-get -y install tcl
	echo ". /usr/local/init/bash" >> .bashrc
	read -p "Environment Modules setup done, press enter to continue" input
}
