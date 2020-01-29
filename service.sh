if [ $# -eq 0 ]; then
    echo "apply/delete name port containerport"
    exit 1
fi
cat << EOF | kubectl $1 -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-$2
spec:
  ports:
  - port: $3
    targetPort: $4
  selector:
    app: $2
    tier: $2
EOF
