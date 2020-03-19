apiVersion: integreatly.org/v1alpha1
kind: Grafana
metadata:
  name: grafana
  namespace: grafana-operator
spec:
  ingress:
    enabled: true
  config:
    auth:
      disable_signout_menu: false
    auth.anonymous:
      enabled: false
    log:
      level: warn
      mode: console
    security:
      admin_user: admin
      admin_password: ${GRAFANA_ADMIN_PASSWORD}
  dashboardLabelSelector:
    - matchExpressions:
        - key: app
          operator: In
          values:
            - grafana
