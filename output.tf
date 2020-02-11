data "aws_caller_identity" "self" {}

resource "local_file" "foo" {
  content  = <<k8sconfig
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${var.application_name}-external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: ${var.application_name}-external-dns
  template:
    metadata:
      labels:
        app: ${var.application_name}-external-dns
    spec:
      containers:
      - name: external-dns
        image: registry.opensource.zalan.do/teapot/external-dns:latest
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=${var.domain_name}
        - --provider=aws
        - --policy=upsert-only
        - --aws-zone-type=public
        - --registry=txt
        - --txt-owner-id=my-hostedzone-identifier
k8sconfig
  filename = "${path.root}/${var.application_name}-external-urls.yml"
}
