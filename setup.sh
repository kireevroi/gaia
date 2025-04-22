// setup.sh
#!/bin/bash
CHOICES=$(whiptail --title "Etherea Setup" --checklist \
"Choose setup modules:" 20 78 12 \
"system" "System Updates & Dependencies" ON \
"docker" "Docker & Docker Compose" ON \
"nginx" "Nginx Web Server" ON \
"certbot" "SSL Certificates (Certbot)" ON \
"monitoring" "Monitoring Stack (Grafana, Prometheus, Loki)" ON \
"security" "Security (UFW, Fail2Ban)" ON \
"gitlab" "GitLab CE (Git hosting & CI/CD)" OFF \
"storage" "MinIO Storage Server" OFF \
"cloudflare-dns" "Cloudflare DNS via Terraform" OFF 3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
    echo "Setup cancelled."
    exit 1
fi

source ./scripts/helpers.sh

for choice in $CHOICES; do
    case $choice in
        "\"system\"") bash modules/01-system.sh ;;
        "\"docker\"") bash modules/02-docker.sh ;;
        "\"nginx\"") bash modules/03-nginx.sh ;;
        "\"certbot\"") bash modules/04-certbot.sh ;;
        "\"monitoring\"") bash modules/05-monitoring.sh ;;
        "\"security\"") bash modules/06-security.sh ;;
        "\"gitlab\"") bash modules/07-gitlab.sh ;;
        "\"storage\"") bash modules/08-storage.sh ;;
        "\"cloudflare-dns\"") source modules/09-cloudflare-dns.sh ;;
    esac
done

success "Full setup complete!"
