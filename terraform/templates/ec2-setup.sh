#!/bin/bash

apt-get update -y
apt-get install -y docker.io postgresql-client awscli

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

cat <<EOF > /home/ubuntu/db_backup.sh
#!/bin/bash
export PGPASSWORD='${db_password}'
DATE=\$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/tmp/backup_${db_name}_\$DATE.dump"

pg_dump -h ${db_host} -p 5432 -U ${db_username} -d ${db_name} -F c -f \$BACKUP_FILE
aws s3 cp \$BACKUP_FILE s3://${s3_bucket_name}/
rm \$BACKUP_FILE
EOF

chmod +x /home/ubuntu/db_backup.sh
(crontab -l 2>/dev/null; echo "0 3 * * * /home/ubuntu/db_backup.sh >> /home/ubuntu/backup.log 2>&1") | crontab -
systemctl restart cron

sleep 30
cat <<SQL > /tmp/init_db.sql
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email) VALUES 
('maskio_admin', 'admin@example.com'),
('devops_engineer', 'devops@cloud.ua'),
('test_user_1', 'user1@test.com'),
('test_user_2', 'user2@test.com')
ON CONFLICT (email) DO NOTHING;
SQL

export PGPASSWORD='${db_password}'
psql -h ${db_host} -U ${db_username} -d ${db_name} -f /tmp/init_db.sql

rm /tmp/init_db.sql
