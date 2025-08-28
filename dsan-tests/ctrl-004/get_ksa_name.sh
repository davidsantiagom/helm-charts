# Define the function to get the KSA name using curl
get_ksa_name() {
  local vcluster_ksa_name=$1
  local vcluster_ksa_namespace=$2
  local vcluster_name=$3
  local host=$4
  local access_key=$5

  local resource_path="/kubernetes/management/apis/management.loft.sh/v1/translatevclusterresourcenames"
  local host_with_scheme=$([[ $host =~ ^(http|https):// ]] && echo "$host" || echo "https://$host")
  local sanitized_host="${host_with_scheme%/}"
  local full_url="${sanitized_host}${resource_path}"

  local response=$(curl -s -k -X POST "$full_url" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${access_key}" \
    -d @- <<EOF
{
  "spec": {
    "name": "${vcluster_ksa_name}",
    "namespace": "${vcluster_ksa_namespace}",
    "vclusterName": "${vcluster_name}"
  }
}
EOF
  )

  local status_name=$(echo "$response" | jq -r '.status.name')
  if [[ -z "$status_name" || "$status_name" == "null" ]]; then
    echo "Error: Unable to fetch KSA name from response: $response"
    exit 1
  fi
  echo "$status_name"
}

# Get the KSA name
export KSA_NAME=$(get_ksa_name "$SERVICE_ACCOUNT_NAME" "$SERVICE_ACCOUNT_NAMESPACE" "$VCLUSTER_NAME" "$HOST" "$ACCESS_KEY")
