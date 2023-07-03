#!/bin/bash

export SQLCMDPASSWORD=SuperPass123$

# decalring arrays for all host and directions to their scripts
declare -A HOSTS
# HOSTS["bi01.c6bkmuvtgdqt.us-east-1.rds.amazonaws.com"]="
# ../../db/DBGeneration_Scripts/BI01-ABS/BI01_ABS.sql
# ../../db/DBGeneration_Scripts/BI01-ArtOnline_CORP/BI01_ArtOnline_CORP.sql
# ../../db/DBGeneration_Scripts/BI01-chsMETs_CORP/BI01_chsMETs_CORP.sql
# ../../db/DBGeneration_Scripts/BI01-chsMets_Norfolk/BI01_chsMets_Norfolk.sql
# ../../db/DBGeneration_Scripts/BI01-FacilityDistance/BI01_FacilityDistance.sql
# ../../db/DBGeneration_Scripts/BI01-MedicalResults_CORP/BI01_MedicalResults_CORP.sql
# ../../db/DBGeneration_Scripts/BI01-ProviderServices/BI01_ProviderServices.sql
# ../../db/DBGeneration_Scripts/BI01-SSISDB/BI01_SSISDB.sql
# "
HOSTS["bi01.c6bkmuvtgdqt.us-east-1.rds.amazonaws.com"]="
../../db/DBGeneration_Scripts/BI01-ABS/BI01_ABS.sql
../../db/DBGeneration_Scripts/BI01-ArtOnline_CORP/BI01_ArtOnline_CORP.sql
"

# SQL Server connection details
username="admin"

for host in "${!HOSTS[@]}"; 
do 
    echo "Running scripts for host: $host";
    scripts=${HOSTS[$host]}
    for script in ${scripts}; 
    do 
        echo " Running script: $script";
        echo "sqlcmd -U admin -S $host -i $script";
        sqlcmd -U admin -S $host -i $script;
    done
done

