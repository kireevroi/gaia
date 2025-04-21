resource "cloudflare_record" "root" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = var.server_ip
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

resource "cloudflare_record" "www" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  value   = var.domain_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "subdomains" {
  for_each = toset(var.subdomains)

  zone_id = var.cloudflare_zone_id
  name    = each.value
  value   = var.server_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "subdomains_ipv6" {
  for_each = var.server_ipv6 != "" ? toset(var.subdomains) : toset([])

  zone_id = var.cloudflare_zone_id
  name    = each.value
  value   = var.server_ipv6
  type    = "AAAA"
  proxied = true
}