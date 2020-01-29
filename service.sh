if [ $# -eq 0 ]; then
    echo "apply/delete name port exposed:false"
    exit 1
fi

script="$(cat << EOF
apiVersion: v1
kind: Service
metadata:
  name: backend-$2
spec:
  ports:
  
EOF
)"

for ports in $3
do
ports=($(echo $ports | tr ':' "\n"))
script+="$(cat << EOF
- name: "${ports[0]}"
    port: ${ports[0]}
    targetPort: ${ports[1]}
  
EOF
)"
done

if [ $4 == "true" ]; then
script+="$(cat << EOF
externalIPs:
    - 91.121.82.115
  
EOF
)"
fi

script+="$(cat << EOF
selector:
    app: $2
    tier: $2
EOF
)"

echo "$script" | kubectl $1 -f -
