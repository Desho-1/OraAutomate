#!/bin/sh
Mon=$(date "+%b%d%H%M%S")

echo "starting backup..."

echo "[INFO] starting oracle home backup..."
#tar --preserve-permissions --preserve-order --same-owner -czpf $BACKUP_DIR/oracleHome_Backup.tar.gz $ORACLE_DIR >> $LOG_DIR/InitializePatch.log;
echo "[SUCCESS] Oracle home backup succeeded"
echo "[INFO] starting grid home backup..."
#tar --preserve-permissions --preserve-order --same-owner -czpf $BACKUP_DIR/gridHome_Backup.tar.gz $GRID_DIR >> $LOG_DIR/InitializePatch.log;
echo "[SUCCESS] Grid home backup succeeded"
echo "[INFO] starting oracle inventory backup..."
#tar --preserve-permissions --preserve-order --same-owner -czpf $BACKUP_DIR/oraInv_Backup.tar.gz $ORAINV_DIR >> $LOG_DIR/InitializePatch.log;
echo "[SUCCESS] Oracle inventory home backup succeeded"


echo "[SUCCESS] Profiles backup succeeded"
echo "[INFO] Updating profiles.."
echo '##Change Profile ADBA
export BASE_DIR='$BASE_DIR';
export ORACLE_DIR='$ORACLE_DIR';
export GRID_DIR='$GRID_DIR';
export ORAINV_DIR='$ORAINV_DIR';
export SOURCE_DIR='$BASE_DIR'/source;
export BACKUP_DIR='$BASE_DIR'/Backup;
export LOG_DIR='$BASE_DIR'/Logs;
export OPATCH='$OPATCH'
export GIPATCH='$GIPATCH'
export PATH=$PATH:'$ORACLE_DIR'/OPatch;' | tee -a ~/.profile ~/.bash_profile /home/grid/.profile /home/grid/.bash_profile /home/oracle/.profile /home/oracle/.bash_profile >> /dev/null
if [ $? -eq 0 ]
then
echo "[SUCCESS] profiles updated successfully"
else
echo "[ERROR] profiles update failed"
fi

chown oracle:oinstall /home/oracle/.profile /home/oracle/.bash_profile
chown grid:oinstall /home/grid/.profile /home/grid/.bash_profile

echo "[INFO] Extracting sources.."

chown -R oracle:oinstall $BASE_DIR $SOURCE_DIR;
chown -R grid:oinstall $SOURCE_DIR; chown oracle:oinstall $BASE_DIR;
chmod -R 777 $SOURCE_DIR
su - grid -c 'unzip -d $SOURCE_DIR $BASE_DIR/$GIPATCH' >> $LOG_DIR/InitializePatch.log;
echo "" >> $LOG_DIR/InitializePatch.log;
#su oracle -c 'unzip -d $SOURCE_DIR $BASE_DIR/$OJVM' >> $LOG_DIR/InitializePatch.log;
if [ $? -eq 0 ]
then
echo "[SUCCESS] sources extracted successfully"
else
echo "[ERROR] sources extraction failed"
fi

echo "[INFO] Current opatch version: "

su - oracle -c '$ORACLE_DIR/OPatch/opatch version'
su - grid -c '$GRID_DIR/OPatch/opatch version'

read -p "do you want to upgrade Opatch (Y/N): " Ans
Ans=$(echo "$Ans" | tr '[:upper:]' '[:lower:]')

if [ "$Ans" = "y" ] || [ "$Ans" = "yes" ]
then
mv $ORACLE_DIR/OPatch $ORACLE_DIR/OPatch_$Mon >> $LOG_DIR/InitializePatch.log;
mv $GRID_DIR/OPatch $GRID_DIR/OPatch_$Mon >> $LOG_DIR/InitializePatch.log;
echo "[SUCCESS] OPatch backup succeeded"
echo "[INFO] Upgrading OPatch version.."
cd $GRID_DIR/..
chown grid grid/
su - oracle -c 'unzip -d $ORACLE_DIR -o $BASE_DIR/$OPATCH' >> $LOG_DIR/InitializePatch.log;
echo "" >> $LOG_DIR/InitializePatch.log;
su grid -c 'unzip -d $GRID_DIR -o $BASE_DIR/$OPATCH' >> $LOG_DIR/InitializePatch.log;

su - oracle -c '$ORACLE_DIR/OPatch/opatch version'
su - grid -c '$GRID_DIR/OPatch/opatch version'

if [ $? -eq 0 ]
then
echo "[SUCCESS] OPatch upgraded successfully"
else
echo "[ERROR] OPatch upgrade failed"
fi

else
echo "[INFO] Skipping Opatch upgrade"
echo "[INFO] Oracle current version:"
su - oracle -c '$ORACLE_DIR/OPatch/opatch version'
echo "[INFO] Grid current version:"
su - grid -c '$GRID_DIR/OPatch/opatch version'
fi

echo "[INFO] Collecting logs.."


echo 'Invalid Objects' > $LOG_DIR/InvalidObjects.log;
echo '=================' >>$LOG_DIR/InvalidObjects.log;
su - oracle -c "
sqlplus / as sysdba << SHU
select count(*) from dba_objects where status='INVALID';
select count(*) from dba_objects where status='INVALID' and owner in ('SYS','SYSTEM');
SHU
" | tee -a $LOG_DIR/InvalidObjects.log >> $LOG_DIR/InitializePatch.log;
echo "" >> $LOG_DIR/InvalidObjects.log;

echo 'running Listeners' >$LOG_DIR/listeners.log;
echo '=================' >>$LOG_DIR/listeners.log;
ps -ef | grep tns | tee -a $LOG_DIR/listeners.log >> $LOG_DIR/InitializePatch.log;

echo "" >>$LOG_DIR/listeners.log;
echo 'running Instances' >$LOG_DIR/instances.log;
echo '=================' >>$LOG_DIR/instances.log;
ps -ef | grep pmon | tee -a $LOG_DIR/instances.log >> $LOG_DIR/InitializePatch.log;

echo "" >>$LOG_DIR/instances.log;
echo 'Cluster resources ' >$LOG_DIR/cluster.log;
echo '=================' >>$LOG_DIR/cluster.log;
su - grid -c 'crsctl stat res -t' | tee -a $LOG_DIR/cluster.log >> $LOG_DIR/InitializePatch.log;

echo "" >> $LOG_DIR/cluster.log;
echo 'Grid Patches' > $LOG_DIR/lspatches.log;
echo '=================' >>$LOG_DIR/lspatches.log;
su - grid -c '$GRID_DIR/OPatch/opatch lspatches -oh $ORACLE_HOME' | tee -a $LOG_DIR/lspatches.log >> $LOG_DIR/InitializePatch.log;
echo "" >>$LOG_DIR/lspatches.log;

su - grid -c '$GRID_DIR/OPatch/opatch lsinventory -oh $ORACLE_HOME' | tee $LOG_DIR/grid_lsinventory.log >> $LOG_DIR/InitializePatch.log;

su - grid -c '$GRID_DIR/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME' | tee $LOG_DIR/grid_lsinv_details.log >> $LOG_DIR/InitializePatch.log;

echo 'Oracle Patches' >> $LOG_DIR/lspatches.log
echo '=================' >> $LOG_DIR/lspatches.log;
su - oracle -c '$ORACLE_HOME/OPatch/opatch lspatches -oh $ORACLE_HOME' | tee -a $LOG_DIR/lspatches.log >> $LOG_DIR/InitializePatch.log;

su - oracle -c '$ORACLE_HOME/OPatch/opatch lsinventory -oh $ORACLE_HOME' | tee $LOG_DIR/oracle_lsinventory.log >> $LOG_DIR/InitializePatch.log;

su - oracle -c '$ORACLE_HOME/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME' | tee $LOG_DIR/oracle_lsinv_details.log >> $LOG_DIR/InitializePatch.log;

if [ $? -eq 0 ]
then
echo "[SUCCESS] Collecting logs was successful"
else
echo "[ERROR] there was an error when collecting logs"
fi

echo "[INFO] Script finished successfully"
