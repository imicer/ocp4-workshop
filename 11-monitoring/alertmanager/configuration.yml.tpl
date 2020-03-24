global:
  resolve_timeout: 5m
receivers:
  - name: default
    email_configs:
      - to: '${SMTP_RECEIVER}'
        from: '${SMTP_SENDER}'
        smarthost: '${SMTP_HOST}'
        auth_username: '${SMTP_USER}'
        auth_password: '${SMTP_PASS}'
        require_tls: true
        tls_config:
          insecure_skip_verify: true
        send_resolved: true
  - name: watchdog
route:
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: default
  routes:
    - match:
        alertname: Watchdog
      repeat_interval: 5m
      receiver: watchdog

