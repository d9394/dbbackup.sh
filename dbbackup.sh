#/bin/bash
#设置Oracle环境变量
export ORACLE_SID=ORA19C
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

#数据库字典:
#格式：[数库文件名｜数据库名]="用户/密码"
#多个数据库间用空格间隔
declare -A DBCONFIG
DBCONFIG=( \
  [DB1]="db1/passwd1" \
  [DB2]="db2/passwd2" \
  [DB3]="db3/passwd3" 
)

#准备执行参数
if [ $# -gt 0 ]; then
  WORKDATE=$1
else
  WORKDATE=$(date +"%Y%m%d")
fi
WEEK_DAY=$(date -d $WORKDATE +%w)

echo `date +%H:%M:%S` backup date $WORKDATE, start....

#定义备份函数的操作
exp_db() {
  DBNAME=$1
  USERPWD=$2
  DBDATE=$3
  if [ -n "${USERPWD}" ] && [ -n "${DBNAME}" ] && [ -n "${DBDATE}" ]; then
    echo Start export db : ${DBNAME}_${DBDATE}
    exp ${USERPWD}@ORA19C buffer=409600000 file=/opt/dbbackup/${DBDATE}/${DBNAME}_${DBDATE}.dmp log=/opt/dbbackup/${DBDATE}/${DBNAME}_${DBDATE}.log > /opt/dbbackup/${DBDATE}/${DBNAME}_${DBDATE}_exp.log 2>&1
    if [ -f /opt/dbbackup/${DBDATE}/${DBNAME}_${DBDATE}.dmp ]; then
      echo Start zip ${DBNAME}_${DBDATE}
      DIR=$(pwd)
      cd /opt/dbbackup/${DBDATE}/
      /bin/tar -zcvf ${DBNAME}_${DBDATE}.tar.gz ${DBNAME}_${DBDATE}.dmp ${DBNAME}_${DBDATE}.log ${DBNAME}_${DBDATE}_exp.log --remove-files
      cd ${DIR}
    fi
  else
    echo Parameter Error : $USERPWD $DBNAME $DBDATE
  fi
}

if [ ! -d "/opt/dbbackup/$WORKDATE" ]; then
  #备份目录不存在，创建之
  mkdir /opt/dbbackup/$WORKDATE
fi
if [ $# -eq 2 ]; then
  #只备份指定的库
  exp_db $2 ${DBCONFIG[$2]} $WORKDATE
else
  #每天备份的库:
  for node in ${!DBCONFIG[@]}; do
    if [[ "${node}" == "DB2" || "${node}" == "DB3" ]]; then
      #只在周六备份的库:
      if [ ${WEEK_DAY} -eq 6 ]; then
        exp_db ${node} ${DBCONFIG[${node}]} $WORKDATE &
      fi
    else
      exp_db ${node} ${DBCONFIG[${node}]} $WORKDATE &
    fi
  done
fi
wait
echo echo `date +%H:%M:%S` backup date $WORKDATE, end....
