
source ./scripts/helpers.sh

info "Setting up Terraform for Cloudflare DNS..."

whiptail --msgbox "📌 Make sure your domain's nameservers are set to Cloudflare.
If not, DNS changes won't take effect!

You can check and update this at your domain registrar." 10 78 --title "Important DNS Note" || exit 1

whiptail --msgbox "🌐 First, make sure you've added your domain to Cloudflare.

Steps:
1. Go to https://dash.cloudflare.com
2. Click 'Add a Site'
3. Enter your domain (e.g., ethereatech.com)
4. Follow the steps to point your nameservers to Cloudflare.

⚠️ Terraform cannot add domains — only configure records inside one that already exists." 14 78 --title "Add Domain to Cloudflare" || exit 1

whiptail --msgbox "🔐 You'll need your Cloudflare API Token.

🔗 Create here: https://dash.cloudflare.com/profile/api-tokens

✅ Permissions required:
   - Zone → DNS → Edit
   - Zone → Zone Settings → Read" 13 78 --title "Cloudflare API Token Info" || exit 1

whiptail --msgbox "🆔 You'll also need your Cloudflare Zone ID.

⚠️ If you haven't added a domain to Cloudflare yet, do that first.

Once a domain is added, your Zone ID will be visible in:
Settings → API section of your domain's dashboard." 12 78 --title "Cloudflare Zone ID Info" || exit 1

CF_API_TOKEN=$(whiptail --inputbox "Enter your Cloudflare API Token:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1
CF_ZONE_ID=$(whiptail --inputbox "Enter your Cloudflare Zone ID:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1
SERVER_IP=$(whiptail --inputbox "Enter your Server IPv4 address:" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1
SERVER_IPV6=$(whiptail --inputbox "Enter your Server IPv6 address (leave empty to skip):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1
DOMAIN_NAME=$(whiptail --inputbox "Enter your main domain (e.g., ethereatech.com):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1
SUBDOMAINS=$(whiptail --inputbox "Enter subdomains separated by commas (e.g., monitor,logs,docker):" 8 78 --title "Cloudflare Setup" 3>&1 1>&2 2>&3) || exit 1

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

info "Validating Cloudflare token permissions..."

curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" | grep -q '"success":true'

if [ $? -ne 0 ]; then
  error "Cloudflare API token is invalid or lacks required permissions."
  exit 1
fi

info "Validating Cloudflare zone ownership..."

ZONE_VERIFY=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json")

if ! echo "$ZONE_VERIFY" | grep -q '"success":true'; then
  error "Failed to retrieve zone. Check if the Zone ID is correct and if the domain is added to your account."
  exit 1
fi

cd "$TERRAFORM_DIR"

terraform init

info "Generating Terraform plan (dry-run)..."
terraform plan -out=tfplan.out

info "Previewing plan output..."
terraform show tfplan.out | head -n 100

echo

if whiptail --yesno "Apply the above Terraform DNS changes?" 10 78 --title "Confirm Apply"; then
    terraform apply tfplan.out
    success "Cloudflare DNS configured successfully!"
else
    error "Terraform apply aborted by user."
fi

cd - > /dev/null