data "aws_caller_identity" "self" {}

resource "local_file" "k8s" {
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
      annotations:
        iam.amazonaws.com/role: arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/${aws_iam_role.route53.name}
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
        - --txt-owner-id={aws_route53_zone.zone_id}
k8sconfig
  filename = "${path.root}/${var.application_name}-external-urls.yml"
}
