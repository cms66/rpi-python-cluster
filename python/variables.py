# Python variables
import os

hstname = str(os.uname()[1])
usrname = os.getlogin() # Gives user with/without sudo
# TODO get usrid from usrname 
#usrid = os.getuid()
#usrid = int(os.system("cat /etc/passwd | grep " + usrname + " cut -d ':' -f 3"))
usrid = 1000
arrconf = {}

# Setup menus
mnuMainFull = [
"Setup - Main menu#",
"Update setup#update_setup()",
"Update system#update_system()",
"SDM#show_menu(pv.mnuSDMFull)",
"Modules#show_menu(pv.mnuModulesFull)",
"OpenCV#show_menu(pv.mnuOpenCVFull)",
"Hardware#show_menu(pv.mnuHardwareFull)",
"NFS#show_menu(pv.mnuNFSFull)",
"ZFS#show_menu(pv.mnuZFSFull)",
"Cluster#show_menu(pv.mnuClusterFull)", 
"SSH keys#show_menu(pv.mnuSSHFull)",
"Check logs#check_logs",
"Data management#show_menu(pv.mnuDataFull)",
"System summary#run_bash('show_system_summary')",
"Test#set_owner('/data/current/src/git', pv.usrname)",
"Back|Quit#"]

mnuHardwareFull=[
"Setup - Hardware menu#",
"PCIe#run_bash('setup_pcie')",
"Camera - CSI#run_bash('setup_camera_csi')",
"Camera - USB#run_bash('setup_camera_usb')",
"I2C#run_bash('setup_i2c')",
"Python - USB#run_bash('setup_python_usb')",
"GPS#run_bash('setup_gps_pa1010D')",
"HC-SR04#run_bash('setup_hcsr04')",
"Hailo-8#run_bash('setup_hailo')",
"Back|Quit#"]
