# Block cross-tenant traffic

echo "=== SUMMARY ==="
kubectl -n vcl-t001-dev logs job/test-intra-allow | tail -1
kubectl -n vcl-t002-dev logs job/test-cross-deny  | tail -1


Expected:
CONTROL 1 (intra) PASSED — HTTP 200 from ...
CONTROL 1 (cross) PASSED — cross-tenant BLOCKED (HTTP=...)


These Jobs become Helm tests by adding:

metadata:
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded


Service/namespace names will be templated values (e.g., {{ .Values.hostNamespaces.tenantA }}), but the core logic stays identical.

The PASS/FAIL strings are already in the format you want. We’ll keep them verbatim in the chart so reviewers see the same messages.
