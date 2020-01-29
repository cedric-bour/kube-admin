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


listports=$(echo $3 | tr ";" "\n")
for ports in $listports
do
IFS=', ' read -r -a port <<< "$ports"
script+="$(cat << EOF
- name: "${port[0]}"
    port: ${port[0]}
    targetPort: ${port[1]}
  
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
