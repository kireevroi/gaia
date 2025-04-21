variable "cloudflare_api_token" { type = string; sensitive = true; description = "Cloudflare API Token" }
variable "cloudflare_zone_id" { type = string; description = "Zone ID" }
variable "server_ip" { type = string; description = "Server IPv4" }
variable "server_ipv6" { type = string; description = "Server IPv6" default = "" }
variable "domain_name" { type = string; description = "Root domain" }
variable "subdomains" { type = list(string); description = "Subdomains" }