# variables: host namespace that backs the vcluster, and the virtual namespace you used
NS_HOST=vcl-t001-dev
NS_VIRT=test

POD=$(kubectl -n "$NS_HOST" get pods \
  -l vcluster.loft.sh/namespace="$NS_VIRT",fcp/control=CTRL-SCHED-ALLOW \
  -o jsonpath='{.items[0].metadata.name}')

NODE=$(kubectl -n "$NS_HOST" get pod "$POD" -o jsonpath='{.spec.nodeName}')
# Get tenant from node label
TENANT=$(kubectl get node "$NODE" -o jsonpath='{.metadata.labels.tenancy\.fcp\.io/tenant}')

echo "Pod: $POD"
echo "Node: $NODE"
echo "Node tenancy label: $TENANT"

if [ "$TENANT" = "t001" ]; then
  echo "CONTROL 3 (allow) PASSED — node has tenancy.fcp.io/tenant=t001"
  exit 0
else
  echo "CONTROL 3 (allow) FAILED — node label is '$TENANT' (expected t001)"
  exit 1
fi
