#!/bin/bash

apt-get update -y
apt-get install -y docker.io

cat <<JSON > /tmp/servers.json
{
  "Servers": {
    "1": {
      "Name": "AWS RDS Postgres",
      "Group": "Servers",
      "Port": 5432,
      "Username": "${db_username}",
      "Host": "${db_host}",
      "SSLMode": "prefer",
      "MaintenanceDB": "postgres"
    }
  }
}
JSON

docker run -d \
  -p 80:80 \
  -e "PGADMIN_DEFAULT_EMAIL=admin@admin.com" \
  -e "PGADMIN_DEFAULT_PASSWORD=${pgadmin_passwd}" \
  -v /tmp/servers.json:/pgadmin4/servers.json \
  --name pgadmin \
  dpage/pgadmin4