#!/bin/bash
# -----------------------------------------------------------------------------
# backup-meister.sh
# -----------------------------------------------------------------------------
# 
# Because some people more granular control than just rsync'ing their home
# directory for backups. I suggest running as a cron job =)
#
# TODOs:
#  - add remote server backup option (w/ optional PGP encryption)
#  - add versioning (by day / week / month) per folder
#  - offer more control per folder (specific drives, remote, etc)
#
# Dependencies: rsync
#
# -----------------------------------------------------------------------------
# Manually create a .backup_meisterrc config file in your home directory
# with the following values
# -----------------------------------------------------------------------------
# 
# DRIVES_PATH="/media/user"                                            
#                                                                               
# declare -a BACKUP_DRIVES=(                                                    
# 	 "MyHardDrive"                                                                 
# 	 "ExtraDrive"                                                               
#  )                                                                             
# 
# BACKUP_PATH="/home/user"
# 
# declare -a BACKUP_FOLDERS=(
#	 "Documents"
#	 "Pictures"
# )
#
# -----------------------------------------------------------------------------
#
# Preferably run as a cron job or manually with ./backup-meister

# Load Config
source ~/.backup_meisterrc

LINE="\e[36m-------------------------------------------------------------------"

# Check Drive Allowed
for DRIVE in "${BACKUP_DRIVES[@]}"
do
	# Check if Mounted
	if mount | grep $DRIVES_PATH/$DRIVE > /dev/null; then
		echo -e "\e[36mYay \"${DRIVE}\" drive exists. Performing backups :)"
		sleep 1	
		for FOLDER in "${BACKUP_FOLDERS[@]}"
		do
			echo -e "\e[94mSyncing $BACKUP_PATH/$FOLDER --> \"$DRIVE/Backups/$FOLDER\""
			echo -e $LINE
			rsync -chazP --stats $BACKUP_PATH/$FOLDER $DRIVES_PATH/$DRIVE/Backups
			echo -e $LINE
			sleep 1
		done
	else
		echo "Nope drive \"${DRIVE}\" is not connected :("
	fi
	sleep 1
done
