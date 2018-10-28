# Группа ВМ с приложениями
resource "google_compute_instance_group" "reddit-app-inst-group" {
  name = "reddit-app-inst-group-name"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  named_port {
    name = "puma-9292"
    port = "9292"
  }

  zone = "${var.zone}"
}

# Сервис проверки "здоровья" нашего приложения. То, что обеспечивает отказоустойчивость.
resource "google_compute_http_health_check" "reddit-app-health-check" {
  name               = "reddit-app-health-check-name"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = "9292"
}

# То, что перенаправляет пользователя на определённый бэкэнд, учитывая проверку "здоровья" инстанса.
resource "google_compute_backend_service" "reddit-app-backend-service" {
  name        = "reddit-app-backend-service-name"
  port_name   = "puma-9292"
  protocol    = "HTTP"
  timeout_sec = 3

  health_checks = [
    "${google_compute_http_health_check.reddit-app-health-check.self_link}",
  ]

  backend = {
    group = "${google_compute_instance_group.reddit-app-inst-group.self_link}"
  }
}

# То, по чьей конфигурации target https proxy перенаправляет ссылки/модули приложения (GET звпросы) на бэкэнд сервисы.
resource "google_compute_url_map" "reddit-app-urlmap" {
  name            = "reddit-app-urlmap-name"
  default_service = "${google_compute_backend_service.reddit-app-backend-service.self_link}"
}

# Перенаправляет запросы в соответствии с url map.
resource "google_compute_target_http_proxy" "reddit-app-target-proxy" {
  name    = "reddit-app-target-proxy-name"
  url_map = "${google_compute_url_map.reddit-app-urlmap.self_link}"
}

# То, что торчит наружу. Ресурс, имеющий IP-адрес и перенаправляющий запросы.
resource "google_compute_global_forwarding_rule" "reddit-app-fw-rule" {
  name       = "reddit-app-fw-rule-name"
  target     = "${google_compute_target_http_proxy.reddit-app-target-proxy.self_link}"
  port_range = "80"
}
