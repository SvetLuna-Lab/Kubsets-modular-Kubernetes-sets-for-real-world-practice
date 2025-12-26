```bash
#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-kubsets}"

echo "[smoke] namespace: ${NS}"

echo "[smoke] waiting for web deployment..."
kubectl wait -n "${NS}" --for=condition=available deploy/web --timeout=120s

# migrate job may or may not be launched depending on your flow
if kubectl get -n "${NS}" job migrate >/dev/null 2>&1; then
  echo "[smoke] waiting for migrate job completion..."
  kubectl wait -n "${NS}" --for=condition=complete job/migrate --timeout=180s
else
  echo "[smoke] migrate job not found (ok if you haven't applied it yet)"
fi

echo "[smoke] checking heartbeat cronjob..."
kubectl get -n "${NS}" cronjob heartbeat

echo "[smoke] OK"
