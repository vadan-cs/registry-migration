# registry-migration

## Prerequisites
```bash
cortex configure set-profile <your-prod-profile>
cortex docker login
```

## Migration
```bash
sh ./migrate.sh <yourJobDefFile> <DockerHubOrd> <dockerImageName> <account/tenant> [<cortexEnv/Tier>]
```

Example:
```bash
sh ./migrate.sh v2job.json c12esolutions hello:busybox mytenant cortex
```
