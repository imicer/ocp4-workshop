apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: prometheus-ocp4
  namespace: grafana-operator
spec:
  name: prometheus-ocp4.yaml
  datasources:
    - name: Prometheus-OCP4
      type: prometheus
      version: 1
      access: proxy
      url: https://prometheus-k8s.openshift-monitoring.svc:9091
      basicAuth: true
      basicAuthUser: ${PROMETHEUS_USER}
      basicAuthPassword: ${PROMETHEUS_PASSWORD}
      editable: true
      isDefault: true
      jsonData:
        timeInterval: 5s
        tlsSkipVerify: true