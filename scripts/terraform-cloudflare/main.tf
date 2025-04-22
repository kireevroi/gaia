provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "root_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = var.server_ipv4
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "root_ipv6" {
  count   = var.server_ipv6 != "" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = var.server_ipv6
  type    = "AAAA"
  proxied = true
}

resource "cloudflare_record" "subdomains_ipv4" {
  for_each = toset(var.subdomains)
  zone_id  = var.cloudflare_zone_id
  name     = each.key
  value    = var.server_ipv4
  type     = "A"
  proxied  = true
}

resource "cloudflare_record" "subdomains_ipv6" {
  count   = var.server_ipv6 != "" ? length(var.subdomains) : 0
  zone_id = var.cloudflare_zone_id
  name    = element(var.subdomains, count.index)
  value   = var.server_ipv6
  type    = "AAAA"
  proxied = true
}

resource "cloudflare_record" "www_redirect" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  type    = "CNAME"
  value   = var.domain_name
  proxied = true
}