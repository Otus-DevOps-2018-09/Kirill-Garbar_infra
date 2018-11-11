output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "db_external_ip" {
  value = "${module.db.db_external_ip}"
}

# output "lb_external_ip" {
#   value = "${google_compute_global_forwarding_rule.reddit-app-fw-rule.ip_address}"
# }

