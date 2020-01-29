if [ $# -eq 0 ]; then
    echo "apply/delete name"
    exit 1
fi
cat << EOF | kubectl $1 -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-$2
spec:
  externalIPs:
    - 91.121.82.115
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  selector:
    app: $2
    tier: $2
EOF
