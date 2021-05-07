if [ $# -eq 0 ]; then
    echo "apply/delete name port"
    exit 1
fi

script+="$(cat << EOF
kind: Service
apiVersion: v1
metadata:
  name: $2
spec:
  ports:
  - port: $3
    name: web
    protocol: TCP
  selector:
    app: $2
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: $2-web
spec:
  entryPoints:
    - web
  routes:
  - kind: Rule
    match: PathPrefix(\`/$2\`)
    services:
    - name: $2
      port: $3
    middlewares:
      - name: $2-stripprefix
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: $2-web-tls
spec:
  entryPoints:
    - websecure
  routes:
  - kind: Rule
    match: PathPrefix(\`/$2\`)
    services:
    - name: $2
      port: $3
    middlewares:
      - name: $2-stripprefix
  tls:
    certResolver: le
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: $2-stripprefix
spec:
  stripPrefix:
    prefixes:
      - /$2
EOF
)"

echo "$script" | kubectl $1 -f -
