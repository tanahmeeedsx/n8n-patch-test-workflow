# Patch Static Compatibility Assessment

Reviewed repo: MatrixForgeLabs/n8n-dev-license-bypass
Reviewed commit: 4e69096875a618d894a11b995c5658214f400e68
Patch SHA-256: d2f4fd8cb4b0cfaeed6dc7fb1e5e65885b96ce549993d48dcfe7566ecf634d6b
Documented compatible target: n8n v1.119.0
Validated staging baseline: n8n v2.36.7
Review method: Read-only static analysis (git clone + grep), no execution, no build

## Commands Used

```bash
git clone https://github.com/MatrixForgeLabs/n8n-dev-license-bypass.git
cd n8n-dev-license-bypass
git status --short

grep -Ein "version|compatible|requirement|prerequisite|node|pnpm" \
  README.md PATCH_README.md DEV_LICENSE_BYPASS.md

grep '^diff --git' dev-license-bypass.patch

grep -En "NODE_ENV|N8N_DEV_LICENSE_BYPASS|VITE_DEV_LICENSE_BYPASS|getManagementJwt|Proxy|as any|UNLIMITED" \
  dev-license-bypass.patch

sha256sum dev-license-bypass.patch
```

## Modified Files

- packages/@n8n/backend-common/src/logging/logger.ts
- packages/@n8n/node-cli/src/configs/eslint.ts
- packages/cli/src/license.ts
- packages/frontend/editor-ui/src/app/components/EnterpriseEdition.ee.vue
- packages/frontend/editor-ui/src/app/stores/settings.store.ts
- packages/frontend/editor-ui/src/shims.d.ts
- pnpm-workspace.yaml

## Security & Stability Findings

| Finding | Impact |
|---|---|
| Dev-mode fallback (NODE_ENV development) | Bypass may activate without explicit flag |
| Fake license manager / getManagementJwt | Replaces real entitlement validation |
| UNLIMITED_LICENSE_QUOTA overrides | Removes standard product limits |
| Frontend Proxy object | Features appear enabled without backend support |
| Broad as any casts | Type-safety bypassed, runtime risk |
| pnpm-workspace edits | Build reproducibility / maintenance risk |
| Major version mismatch (v1.119.0 vs v2.36.7) | Patch conflicts or silent failures likely |

## Conclusion

Given the documented version mismatch and the security/stability
findings above, the patch was not applied to the validated staging
baseline. This assessment is static/read-only; no license-bypass code
was ever executed or built.
