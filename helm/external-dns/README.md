# OCI ExternalDNS chart

This chart deploys [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) with the OCI provider. It discovers Kubernetes Services and manages records in an OCI DNS zone using instance-principal authentication from OKE worker nodes.

The chart is normally installed through Helmfile when `EXTERNAL_DNS_ENABLED=true`; it is disabled by default.

## Required values

| Value | Description |
| ----- | ----------- |
| `oci.compartmentId` | OCID of the compartment containing the DNS zone. |
| `domainFilter` | DNS zone that ExternalDNS may manage. |
| `txtOwnerId` | Unique owner ID for TXT registry records. |

The chart uses OCI instance-principal authentication and does not require an OCI credentials Secret. Records use the `upsert-only` policy and TXT ownership tracking.

## Enable through Helmfile

Install the addon with the target cluster's Helmfile environment:

```bash
# Replace the environment and OCI values with settings for the target cluster.
HELMFILE_ENV=your-environment \
EXTERNAL_DNS_ENABLED=true \
EXTERNAL_DNS_OCI_COMPARTMENT_ID=ocid1.compartment.oc1..example \
EXTERNAL_DNS_DOMAIN_FILTER=oci.hypershell.app \
EXTERNAL_DNS_TXT_OWNER_ID=hyperfleet-oci \
make install-hyperfleet
```

Helmfile maps these variables to the chart values. Set `EXTERNAL_DNS_HOSTNAME` separately when the public gateway Service should publish a hostname for ExternalDNS. The gateway Service must use `LoadBalancer` when it should receive a public DNS record.
