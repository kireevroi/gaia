resource "cloudflare_record" "root_ipv4" {
  zone_id          = var.cloudflare_zone_id
  name             = "@"
  content          = var.server_ipv4
  type             = "A"
  proxied          = true
  allow_overwrite  = true
}

resource "cloudflare_record" "root_ipv6" {
  count            = var.server_ipv6 != "" ? 1 : 0
  zone_id          = var.cloudflare_zone_id
  name             = "@"
  content          = var.server_ipv6
  type             = "AAAA"
  proxied          = true
  allow_overwrite  = true
}

resource "cloudflare_record" "subdomains_ipv4" {
  for_each         = toset(var.subdomains)
  zone_id          = var.cloudflare_zone_id
  name             = each.key
  content          = var.server_ipv4
  type             = "A"
  proxied          = true
  allow_overwrite  = true
}

resource "cloudflare_record" "subdomains_ipv6" {
  count            = var.server_ipv6 != "" ? length(var.subdomains) : 0
  zone_id          = var.cloudflare_zone_id
  name             = element(var.subdomains, count.index)
  content          = var.server_ipv6
  type             = "AAAA"
  proxied          = true
  allow_overwrite  = true
}

resource "cloudflare_record" "www_redirect" {
  zone_id          = var.cloudflare_zone_id
  name             = "www"
  type             = "CNAME"
  content          = var.domain_name
  proxied          = true
  allow_overwrite  = true
}
