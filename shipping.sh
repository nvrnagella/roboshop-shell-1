source common.sh
if [ -z "${mysql_root_password}" ]
then
  echo mysql_root_password is missing
  exit 1
fi
component=shipping
schema_load=true
MAVEN
