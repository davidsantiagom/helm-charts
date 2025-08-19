# Scheduler Verification – Tenant Node Isolation

## Purpose
We wanted to verify that tenant workloads in **vCluster-based multi-tenancy** are scheduled only onto their own nodes (with `tenancy.fcp.io/tenant=<TENANT>` labels), and to detect any gaps where a pod could land on another tenant’s node.

## What We Tested
We ran three types of checks:

1. **Verification Job (`CTRL-SCHED-VERIFY`)**  
   - A Python job in the host namespace looked up a pod deployed from the vCluster with label `CTRL-SCHED-ALLOW`.  
   - It fetched the node where that pod was running and checked the node’s `tenancy.fcp.io/tenant` label.  
   - ✅ Confirmed that the pod actually landed on the expected `t001` node.

2. **Wrong Tenant Selector inside the vCluster (`CTRL-SCHED-DENY`)**  
   - We deployed a pod in vCluster `t001` that explicitly requested nodes from tenant `t002`.  
   - After sync to the host cluster, the **vCluster syncer rewrote the nodeSelector**, and the pod still landed correctly on a `t001` node.  
   - This shows that **nodeSelector enforcement works correctly across the vCluster/host boundary**.

3. **Wrong Tenant Selector directly in the Host namespace**  
   - We bypassed vCluster and scheduled a pod in the host namespace `vcl-t001-dev`, asking for `t002` nodes.  
   - This pod was successfully scheduled on a `t002` node.  
   - This demonstrates that **without policy, a tenant could technically create host-level objects that escape their own node group**.

## Lessons Learned
- **Inside vClusters**:  
  The syncer rewrites `nodeSelector`s, so tenant pods always end up on the correct tenant nodes, even if the spec is wrong on purpose.  
  👉 Safe by default.

- **In Host Namespaces**:  
  A pod created directly in the host namespace can bypass this guardrail and land on the wrong tenant’s nodes.  
  👉 This is a gap that must be closed.

## Next Steps
To enforce the guarantee platform-wide, we need **admission-time guardrails** (e.g., Kyverno or OPA Gatekeeper) in the host cluster to reject pods with mismatched or missing tenant nodeSelectors. This ensures that no workload—vCluster-managed or otherwise—can break node isolation.
