variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API Token"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "server_ipv4" {
  type        = string
  description = "Server IPv4 address"
}

variable "server_ipv6" {
  type        = string
  default     = ""
  description = "Server IPv6 address (optional)"
}

variable "domain_name" {
  type        = string
  description = "Primary domain to manage DNS records for"
}

variable "subdomains" {
  type        = list(string)
  description = "List of subdomains to create DNS records for"
}