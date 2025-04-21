#!/bin/bash

source ./scripts/helpers.sh

info "Setting up Terraform for Cloudflare DNS..."

echo "\n🔗 Get your Cloudflare API Token here: https://dash.cloudflare.com/profile/api-tokens"
echo "🔗 Find your Zone ID under domain > Overview tab: https://dash.cloudflare.com/"

# Install Terraform if not present
if ! command -v terraform &> /dev/null; then
    info "Terraform not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg |
        sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
        sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
fi

# Gather Inputs
CF_API_TOKEN=$(whiptail --inputbox "Enter your Cloudflare API Token:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)
CF_ZONE_ID=$(whiptail --inputbox "Enter your Cloudflare Zone ID:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)
SERVER_IP=$(whiptail --inputbox "Enter your Server IPv4 address:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)
SERVER_IPV6=$(whiptail --inputbox "Enter your Server IPv6 address (leave empty to skip):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)
DOMAIN_NAME=$(whiptail --inputbox "Enter your main domain (e.g., ethereatech.com):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)
SUBDOMAINS=$(whiptail --inputbox "Enter subdomains separated by commas (e.g., monitor,logs,docker):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3)

if [ -z "$CF_API_TOKEN" ] || [ -z "$CF_ZONE_ID" ] || [ -z "$SERVER_IP" ] || [ -z "$DOMAIN_NAME" ]; then
    error "Cloudflare setup canceled or inputs invalid."
    exit 1
fi

SUBDOMAINS_FMT=$(echo $SUBDOMAINS | sed 's/ *, */,/g' | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')

TERRAFORM_DIR="./scripts/terraform-cloudflare"

cp "$TERRAFORM_DIR/terraform.tfvars.template" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__CF_API_TOKEN__|$CF_API_TOKEN|" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__CF_ZONE_ID__|$CF_ZONE_ID|" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__SERVER_IP__|$SERVER_IP|" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__SERVER_IPV6__|$SERVER_IPV6|" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__DOMAIN_NAME__|$DOMAIN_NAME|" "$TERRAFORM_DIR/terraform.tfvars"
sed -i "s|__SUBDOMAINS__|$SUBDOMAINS_FMT|" "$TERRAFORM_DIR/terraform.tfvars"

cd "$TERRAFORM_DIR"
terraform init
terraform plan

if whiptail --yesno "Apply Terraform DNS changes now?" 8 78; then
    terraform apply -auto-approve
    success "Cloudflare DNS configured successfully!"
else
    error "Terraform apply aborted by user."
fi
cd - > /dev/null
