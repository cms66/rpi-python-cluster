# Python variables
import os

hstname = str(os.uname()[1])
usrname = os.getlogin() # Gives user with/without sudo
arrconf = {}

# Setup menus
mnuMainFull = [
"Setup - Main menu#",
"Update setup#update_setup()",
"Update system#update_system()",
"Hardware#show_menu(pv.mnuHardwareFull)",
"NFS#show_menu(pv.mnuNFSFull)",
"ZFS#show_menu(pv.mnuZFSFull)",
"Cluster#show_menu(pv.mnuClusterFull)", 
"Modules#show_menu(pv.mnuModulesFull)",
"OpenCV#show_menu(pv.mnuOpenCVFull)",
"SDM#show_menu(pv.mnuSDMFull)",
"System summary#run_bash('show_system_summary')",
"SSH keys#show_menu(pv.mnuSSHFull)",
"Check logs#check_logs",
"Test#run_bash('bash_test')",
"Data management#show_menu(pv.mnuDataFull)",
"Back|Quit#"]
