if [ $# -eq 0 ]; then
    echo "apply/delete name replicat"
    exit 1
fi

script="$(cat << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-$2
spec:
  selector:
    matchLabels:
      app: $2
  replicas: $3
  template:
    metadata:
      labels:
        app: $2
    spec:
      containers:
      - name: $2
        image: localhost:5000/$2
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

if [ $2 == "jenkins" ]; then
script+="$(cat << EOF

        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: dockersock
          mountPath: "/var/run/docker.sock"
      volumes:
      - name: jenkins-home
        emptyDir: {}
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
EOF
)"
fi

echo "$script" | kubectl $1 -f -
