# 🌍 Gaia — Server Provisioning & DNS Automation

**Gaia** is your modular, bootstrapped setup system for personal or project servers. It automates everything from DNS setup with Cloudflare to future services like Docker, monitoring, Nginx, and more.

---

## 🚀 Quickstart

Install everything with **a single command**:

```bash
curl -s https://raw.githubusercontent.com/kireevroi/gaia/master/install.sh | bash
```

Or use a specific tag:

```bash
curl -s https://raw.githubusercontent.com/kireevroi/gaia/master/install.sh | bash -s -- v1.0.0
```

---

## 📦 Features

- ✅ Interactive CLI (whiptail-style GUI)
- ✅ Terraform-based Cloudflare DNS automation
- ✅ IPv4 + optional IPv6 support
- ✅ Easily extendable modules
- ✅ Works from scratch on a fresh server

---

## 📁 Project Structure

```
gaia/
├── install.sh                # Bootstrapper script
├── setup.sh                  # Main module selector
├── modules/                  # Feature modules
│   └── 09-cloudflare-dns.sh  # Cloudflare DNS setup
└── scripts/
    ├── helpers.sh            # Colored log helpers
    └── terraform-cloudflare/ # Terraform configuration
```

---

## 🛠️ Cloudflare Setup Notes

To run the Cloudflare DNS module, you'll need:

- 🔑 [API Token](https://dash.cloudflare.com/profile/api-tokens) (with `DNS:Edit` permission)
- 🌐 [Zone ID](https://dash.cloudflare.com) from your domain → **Overview** tab

---

## 💡 What It Does (Cloudflare Module)

- Adds A and AAAA records for your root domain and subdomains
- Supports optional IPv6
- Proxied by default (Cloudflare CDN & security)
- Dynamically configurable via prompts

---

## 📋 Coming Soon

- Docker & Docker Compose setup
- Monitoring stack (Grafana, Prometheus, Loki)
- Nginx + Certbot
- GitLab CE deployment
- MinIO & Redis modules

---

## 📘️ License

MIT — use freely, modify proudly.