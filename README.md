# registry-migration

## Prerequisites
```bash
cortex configure set-profile <your-prod-profile>
cortex docker login
```

## Migration
The `migrate.sh` script does the following:

1. It pulls your Docker image `<dockerImageName>` from `<dockerHubOrg>`, and tags and pushes it to the Cortex private registry in your tenancy. The new image tag will have the pattern `private-registry.cortex.insights.ai/<tenantId>/<imageName+tag>`.
2. It updated your `<jobDefFile>` to match the appropriate image URL: `registry.cortex.insights.ai:5000/<tenantId>/<imageName+tag>`.
3. It re-deploys your job.

```bash
sh ./migrate.sh <jobDefFile> <dockerHubOrg> <dockerImageName> <account/tenant> [<cortexEnv/Tier>]
```

Example:
```bash
sh ./migrate.sh v2job.json c12esolutions hello:busybox mytenant cortex
```
