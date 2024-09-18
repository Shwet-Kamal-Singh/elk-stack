# ELK Stack Setup Guide

This guide will help you set up and configure your ELK (Elasticsearch, Logstash, Kibana) stack with Nginx as a reverse proxy.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Setup Instructions](#setup-instructions)
  - [Clone the Repository](#clone-the-repository)
  - [Configure Environment Variables](#configure-environment-variables)
  - [Modify Configuration Files](#modify-configuration-files)
  - [SSL Certificate Setup](#ssl-certificate-setup)
  - [Initialize Users](#initialize-users)
  - [Start the ELK Stack](#start-the-elk-stack)
  - [Verify Setup](#verify-setup)
- [Usage](#usage)
  - [Sending Logs to Logstash](#sending-logs-to-logstash)
  - [Viewing Logs in Kibana](#viewing-logs-in-kibana)
  - [Backing Up Elasticsearch](#backing-up-elasticsearch)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Disclaimer](#disclaimer)
- [Contact](#contact)

## Prerequisites

- Docker and Docker Compose installed
- Basic understanding of ELK stack components
- A domain name (for SSL configuration)

## Directory Structure

```
elk-stack/
├── docker-compose.yml
├── .env                           # For storing passwords and sensitive information
├── elasticsearch/
│   ├── config/
│   │   └── elasticsearch.yml
│   ├── certs/                     # For storing SSL certificates
│   └── backup/                    # For storing backups
├── logstash/
│   ├── config/
│   │   └── logstash.yml
│   └── pipeline/
│       └── logstash.conf
├── kibana/
│   └── config/
│       └── kibana.yml
├── nginx/                         # For reverse proxy with SSL termination
│   ├── config/
│   │   └── nginx.conf
│   └── certbot/                   # For Certbot SSL certificates
└── scripts/
    ├── init-users.sh              # Script to initialize users and passwords
    ├── backup.sh                  # Script for regular backups
    └── setup-certs.sh             # Script to set up SSL certificates with Certbot
```


## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/Shwet-Kamal-Singh/elk-stack.git
   cd elk-stack
   ```

2. **Configure Environment Variables**

   Create a `.env` file in the root directory:

   ```
   ELASTIC_PASSWORD=your_secure_elastic_password
   LOGSTASH_INTERNAL_PASSWORD=your_secure_logstash_password
   KIBANA_SYSTEM_PASSWORD=your_secure_kibana_password
   KIBANA_ENCRYPTION_KEY=your_32+_character_encryption_key
   ```

   Replace the placeholder passwords with strong, unique passwords.

3. **Modify Configuration Files**

   - In `elasticsearch/config/elasticsearch.yml`:
     - Update `cluster.name` if desired
     - Adjust `node.name` for multi-node setups
   
   - In `logstash/config/logstash.yml`:
     - Adjust `pipeline.workers` and `pipeline.batch.size` based on your resources
   
   - In `logstash/pipeline/logstash.conf`:
     - Modify input, filter, and output sections based on your log sources
   
   - In `kibana/config/kibana.yml`:
     - Update `server.publicBaseUrl` with your domain
   
   - In `nginx/config/nginx.conf`:
     - Replace `your_domain.com` with your actual domain name

4. **SSL Certificate Setup**

   If using Let's Encrypt:
   ```bash
   ./scripts/setup-certs.sh
   ```
   
   Follow the prompts to obtain SSL certificates for your domain.

5. **Initialize Users**

   ```bash
   ./scripts/init-users.sh
   ```

   This script will set up initial users for Elasticsearch and Kibana.

6. **Start the ELK Stack**

   ```bash
   docker-compose up -d
   ```

7. **Verify Setup**

   - Elasticsearch: https://your_domain.com:9200
   - Kibana: https://your_domain.com
   
   Use the credentials set in the `.env` file to log in.

## Usage

### Sending Logs to Logstash

Configure your applications to send logs to Logstash:
- Syslog: `your_domain.com:5000`
- Filebeat: `your_domain.com:5044`
- HTTP: `http://your_domain.com:8080`

### Viewing Logs in Kibana

1. Open Kibana in your browser: https://your_domain.com
2. Log in with your credentials
3. Go to "Stack Management" > "Index Patterns" to create an index pattern
4. Use "Discover" to view and search your logs

### Backing Up Elasticsearch

To create a backup:

```bash
./scripts/backup.sh
```


Backups will be stored in `elasticsearch/backup/`.

## Maintenance

- Regularly update your ELK stack components
- Monitor disk space, especially for Elasticsearch data
- Rotate and manage logs to prevent disk space issues
- Regularly review and update security settings

## Troubleshooting

- Check Docker logs: `docker-compose logs [service_name]`
- Ensure all services are running: `docker-compose ps`
- Verify Elasticsearch health: `curl -k -u elastic:your_password https://localhost:9200/_cat/health`

## Security Considerations

- Keep your `.env` file secure and never commit it to version control
- Regularly update passwords for all services
- Use firewall rules to restrict access to your ELK stack
- Implement IP whitelisting in Nginx for additional security

## Customization

- Adjust Logstash filters in `logstash/pipeline/logstash.conf` for your specific log formats
- Modify Elasticsearch settings in `elasticsearch.yml` for performance tuning
- Customize Kibana plugins and settings in `kibana.yml` as needed

Remember to restart the respective services after making configuration changes:

```bash
docker-compose restart [service_name]
```


For any issues or additional customization needs, refer to the official documentation for each component or seek community support.

## Contributing

Contributions to improve this project are welcome. Please fork the repository, create a new branch for your feature or bug fix, make your changes, and submit a pull request with a clear description of your modifications.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Shwet-Kamal-Singh/elk-stack/blob/main/LICENSE) file for details.

![Original Creator](https://img.shields.io/badge/Original%20Creator-Shwet%20Kamal%20Singh-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Disclaimer

These scripts are provided as-is, without warranty. Review before running, especially those requiring sudo privileges.

## Contact

For any inquiries or permissions, please contact:
- Email: shwetkamalsingh55@gmail.com
- LinkedIn: https://www.linkedin.com/in/shwet-kamal-singh/
- GitHub: https://github.com/Shwet-Kamal-Singh