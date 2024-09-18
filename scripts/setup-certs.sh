#!/bin/bash

# Set variables
DOMAIN="your-domain.com"
EMAIL="your-email@example.com"
CERTBOT_DIR="/etc/letsencrypt"
NGINX_CONF="/etc/nginx/nginx.conf"
ELASTICSEARCH_CERT_DIR="/usr/share/elasticsearch/config/certs"
LOGSTASH_CERT_DIR="/usr/share/logstash/config/certs"
KIBANA_CERT_DIR="/usr/share/kibana/config/certs"

# Ensure running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install Certbot if not already installed
if ! command -v certbot &> /dev/null; then
    apt-get update
    apt-get install -y certbot
fi

# Obtain SSL certificate
certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive

# Check if certificate was obtained successfully
if [ ! -d "$CERTBOT_DIR/live/$DOMAIN" ]; then
    echo "Failed to obtain SSL certificate" 1>&2
    exit 1
fi

# Copy certificates to Elasticsearch, Logstash, and Kibana directories
mkdir -p $ELASTICSEARCH_CERT_DIR $LOGSTASH_CERT_DIR $KIBANA_CERT_DIR
cp $CERTBOT_DIR/live/$DOMAIN/fullchain.pem $ELASTICSEARCH_CERT_DIR/
cp $CERTBOT_DIR/live/$DOMAIN/privkey.pem $ELASTICSEARCH_CERT_DIR/
cp $CERTBOT_DIR/live/$DOMAIN/fullchain.pem $LOGSTASH_CERT_DIR/
cp $CERTBOT_DIR/live/$DOMAIN/privkey.pem $LOGSTASH_CERT_DIR/
cp $CERTBOT_DIR/live/$DOMAIN/fullchain.pem $KIBANA_CERT_DIR/
cp $CERTBOT_DIR/live/$DOMAIN/privkey.pem $KIBANA_CERT_DIR/

# Update Nginx configuration
cat << EOF > $NGINX_CONF
http {
    server {
        listen 80;
        server_name $DOMAIN;
        location / {
            return 301 https://\$host\$request_uri;
        }
    }

    server {
        listen 443 ssl;
        server_name $DOMAIN;

        ssl_certificate $CERTBOT_DIR/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key $CERTBOT_DIR/live/$DOMAIN/privkey.pem;

        location / {
            proxy_pass http://kibana:5601;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

# Reload Nginx to apply changes
nginx -s reload

# Set up auto-renewal
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "SSL certificates have been set up and configured for $DOMAIN"