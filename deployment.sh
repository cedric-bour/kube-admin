if [ $# -eq 0 ]; then
    echo "apply/delete name min-replicat max-replicat cpuAverage"
    exit 1
fi

script="$(cat << EOF
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: $2-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: pod-$2
  minReplicas: $3
  maxReplicas: $4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: $5
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-$2
spec:
  selector:
    matchLabels:
      app: $2
  template:
    metadata:
      labels:
        app: $2
    spec:
      containers:
      - name: $2
        image: localhost:5000/$2
        resources:
          requests:
            cpu: 400m
EOF
)"

if [ $2 == "openvpn" ]; then
script+="$(cat << EOF

        securityContext:
          capabilities:
            add:
              - NET_ADMIN
EOF
)"
fi

echo "$script" | kubectl $1 -f -
