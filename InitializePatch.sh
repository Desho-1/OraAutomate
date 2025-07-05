#!/bin/sh

Mon=`date | awk {'print $2'}`
read -p "Enter the BASE_DIR path: " BASE_DIR

if [ ! -d "$BASE_DIR" ]; then
    echo "[ERROR] BASE_DIR directory does not exist."
    exit 1
fi

read -p "Enter the ORACLE_DIR path: " ORACLE_DIR
read -p "Enter the ORACLE_INV path: " ORAINV_DIR
read -p "Enter the GRID_DIR path: " GRID_DIR

if [ ! -d "$ORACLE_DIR" ] || [ ! -d "$GRID_DIR" ] || [ ! -d "$ORAINV_DIR" ]; then
    echo "[ERROR] ORACLE_DIR or GRID_DIR or ORAINV_DIR directory does not exist."
    exit 1
fi

read -p "Enter OPatch zip file name: " OPATCH
read -p "Enter GI Patch zip file name: " GIPATCH
#read -p "Enter OJVM Patch zip file name: " OJVM
#|| [ ! -f "$BASE_DIR/$GIPATCH" ] || [ ! -f "$BASE_DIR/$OJVM" ]

#if [ ! -f "$BASE_DIR/$OPATCH" ]; then
#echo "[ERROR] zip file does not exist."
#exit 1
#fi
echo "[INFO] Initializing variables.."

export BASE_DIR=$BASE_DIR;
export SOURCE_DIR=$BASE_DIR/source;
export BACKUP_DIR=$BASE_DIR/Backup;
export LOG_DIR=$BASE_DIR/Logs;
export ORACLE_DIR=$ORACLE_DIR;
export GRID_DIR=$GRID_DIR;
export ORAINV_DIR=$ORAINV_DIR;
export PATH=$PATH:$ORACLE_DIR/OPatch;
export OPATCH=$OPATCH
export GIPATCH=$GIPATCH

echo "[INFO] Creating directories.."

mkdir -p $BASE_DIR $SOURCE_DIR $LOG_DIR $BACKUP_DIR;
chown -R oracle:oinstall $BASE_DIR $SOURCE_DIR;


cat ~/.profile >> $BACKUP_DIR/root_profile
cat ~/.bash_profile >> $BACKUP_DIR/root_bash_profile
cat /home/grid/.profile >>$BACKUP_DIR/grid_profile
cat /home/grid/.bash_profile >>$BACKUP_DIR/grid_bash_profile
cat /home/oracle/.profile >>$BACKUP_DIR/oracle_profile
cat /home/oracle/.bash_profile >>$BACKUP_DIR/oracle_bash_profile


free=`df -h $BASE_DIR |awk '{ print $4 }' | grep G | cut -d"G" -f1 | cut -d"." -f1`
oh=`du -sh $ORACLE_DIR | cut -d"G" -f1 | cut -d"." -f1`
gh=`du -sh $GRID_DIR | cut -d"G" -f1 | cut -d"." -f1`
rec=$((oh + gh))
echo "[INFO] recommended value is : $rec Gigabytes"

if [[ "$free" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    check=G
echo "[INFO] Space found $free Gigabytes"
else
    check=F
free=`df -h $BASE_DIR |awk '{ print $4 }' | grep T | cut -d"T" -f1 | cut -d"." -f1`
if [[ "$free" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    check=T
echo "[INFO] Space found $free is in Terabytes"
else
    check=F
fi
fi

if [ "$check" = "T" ]; then
cd /root/Mine
./Run.sh

elif [ "$check" = "G" ]; then

if [ $free -gt $rec ]; then

cd /root/Mine
./Run.sh

else
echo "[ERROR] backup directory size is less than the recommended value"
exit 1
fi

else
echo "[ERROR] free space $free is insufficient"
fi
