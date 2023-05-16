# dbbackup.sh
a shell script for oracle exp db

USAGE: dbbackup.sh   
   OR: dbbackup.sh 20230510   
   OR: dbbackup.sh 20230510 DB3   
   
# expdp_backup.sh    
a shell script for oracle backup database using expdp    
    
USAGE: expdp_backup.sh    
   OR: expdp_backup.sh 20230511    
   OR: expdp_backup.sh 20230511 DB-3    
   
before using expdp , you need create a target directory on shell system, such as '/opt/dbbackup/temp'    
and then login oracle as sysdba do this:    
    1. create or replace directory DBTMP as '/opt/dbbackup/temp';    
    2. grant read,write on directory DBTMP to public;   (this mean grant right to all oracle user)    
       grant read,write on directory DBTMP to user1;   (this mean grant right to only user1)    
    
    
