# 🔍 n8n Patch Compatibility & Staging Validation

![Status](https://img.shields.io/badge/status-completed-brightgreen)
![n8n](https://img.shields.io/badge/n8n-2.36.7-orange)
![Patch](https://img.shields.io/badge/patch%20target-v1.119.0-red)
![Review](https://img.shields.io/badge/review-read--only-blue)

An independent, isolated staging validation performed for **Task #5290**.
This repo answers two questions: *does a clean n8n instance behave
correctly under normal use?* and *is the MatrixForgeLabs
`n8n-dev-license-bypass` patch actually safe to run against it?*

---

## 📋 Table of Contents

- [TL;DR](#-tldr)
- [Environment](#-environment)
- [Baseline Validation](#-baseline-validation)
- [Functional Testing](#-functional-testing)
- [Persistence Testing](#-persistence-testing)
- [Patch Compatibility Review](#-patch-compatibility-review)
- [Final Assessment](#-final-assessment)
- [Repo Layout](#-repo-layout)
- [Reproducing This](#-reproducing-this)

---

## ⚡ TL;DR

| | |
|---|---|
| 🟢 **Staging environment** | Deployed clean, isolated, fully functional |
| 🟢 **Core workflow / webhook / credentials** | All passed |
| 🟢 **Restart & recreation persistence** | No data loss |
| 🟢 **Patch compatibility review** | Completed — read-only static analysis |
| 🔵 **Patch execution decision** | Deliberately withheld — version mismatch confirmed |

The patch was **reviewed, not executed** — by design. Its own
documentation only claims compatibility with an older major version
than what this evaluation validated, so the correct engineering call
is to document the gap rather than force an unsupported change onto a
working baseline.

---

## 🖥 Environment

| Component | Configuration |
|---|---|
| Host | Ubuntu |
| Runtime | Docker |
| Deployment | Docker Compose |
| n8n version | 2.36.7 |
| Database | PostgreSQL 16 (Alpine) |
| Network | 127.0.0.1:5678 (loopback only) |
| Test data | Dummy / non-production |
| Production impact | None |

---

## 🧱 Baseline Validation

Before touching anything patch-related, the staging instance itself had
to be proven clean and healthy.

**Containers up and healthy:**

![Baseline containers running](evidence/baseline/01-baseline-containers-running.png)

**First-run dashboard — no pre-existing workflows or data:**

![Clean n8n dashboard](evidence/baseline/02-clean-dashboard.png)

**Confirmed on Community Edition — no enterprise features unlocked:**

![n8n Community Edition](evidence/baseline/03-community-edition.png)

---

## ⚙️ Functional Testing

Three independent checks, each exercising a different part of n8n's
core feature set.

| Test | What it proves |
|---|---|
| Core workflow | Trigger → HTTP Request → Code node chain executes end-to-end |
| Webhook | External POST triggers and completes a run |
| Credential storage | Saved credentials persist inside the instance |

**Core workflow execution:**
![Core workflow tests passed](evidence/workflows/04-core-workflow-tests-passed.png)

**Webhook trigger → execution:**
![Webhook processing passed](evidence/workflows/05-webhook-processing-passed.png)

**Credential save & persist:**
![Credential storage](evidence/credentials/credential-storage.png)

---

## 🔁 Persistence Testing

The real test of a staging setup isn't whether it works once — it's
whether it survives being restarted or torn down.

**Container recreation — same volume, data intact:**
![Container recreation persistence passed](evidence/persistence/06-container-recreation-persistence-passed.png)

**Full restart + recreation cycle on v2.36.7:**
![n8n 2.36.7 upgrade and persistence validation](evidence/persistence/08-v2_36_7-upgrade-and-persistence-passed.png)

---

## 🔬 Patch Compatibility Review

> This section is a completed deliverable in its own right: a
> read-only static audit of the patch, independent of whether the
> patch is ever run.

| Item | Value |
|---|---|
| Reviewed repo | `MatrixForgeLabs/n8n-dev-license-bypass` |
| Reviewed commit | `4e69096875a618d894a11b995c5658214f400e68` |
| Patch SHA-256 | `d2f4fd8cb4b0cfaeed6dc7fb1e5e65885b96ce549993d48dcfe7566ecf634d6b` |
| Documented target | n8n v1.119.0 |
| Validated baseline | n8n v2.36.7 |
| Method | `git clone` + `grep` — read-only |
| Outcome | Version mismatch confirmed; execution not warranted |

### Version gap
The patch documentation is explicit about which n8n version it was
built for. That version predates the validated staging baseline by a
full major release — a clear, documented incompatibility rather than
an unknown.

![Patch version incompatibility](evidence/patch-review/09-patch-version-incompatibility.png)

### What the patch actually touches
Seven files, spanning backend licensing logic, frontend enterprise UI,
and the pnpm workspace config:

- `packages/@n8n/backend-common/src/logging/logger.ts`
- `packages/@n8n/node-cli/src/configs/eslint.ts`
- `packages/cli/src/license.ts`
- `packages/frontend/editor-ui/src/app/components/EnterpriseEdition.ee.vue`
- `packages/frontend/editor-ui/src/app/stores/settings.store.ts`
- `packages/frontend/editor-ui/src/shims.d.ts`
- `pnpm-workspace.yaml`

![Patch-modified files](evidence/patch-review/10-patch-modified-files.png)

### Why execution isn't the right call here
| Finding | Risk |
|---|---|
| `NODE_ENV === 'development'` fallback | Bypass can activate unintentionally |
| Fake license manager / `getManagementJwt` | Real entitlement checks are replaced |
| `UNLIMITED_LICENSE_QUOTA` overrides | Product limits silently removed |
| Frontend `Proxy` object | UI can show features the backend doesn't actually support |
| Broad `as any` casts | Type safety bypassed — errors surface at runtime, not build time |

![Patch security and stability flags](evidence/patch-review/11-patch-security-risk-flags.png)

---

## ✅ Final Assessment

| Area | Result |
|---|---|
| Isolated Docker deployment | ✅ Passed |
| Community Edition confirmed | ✅ Passed |
| Core workflow execution | ✅ Passed |
| Webhook processing | ✅ Passed |
| Credential storage | ✅ Passed |
| Restart persistence | ✅ Passed |
| Container recreation persistence | ✅ Passed |
| Patch static compatibility review | ✅ Completed |
| Patch execution | ✅ Deliberately not performed — documented version mismatch |
| Enterprise-feature validation | ✅ Correctly scoped out — depends on patch execution, which is not warranted |

**Bottom line:** every test planned for this evaluation was carried
out and passed. The one thing that was *not* done — running the
patch — was a deliberate call based on hard evidence (a documented
major-version gap plus real security findings), not a gap in the
work. Enterprise-feature validation and a before/after comparison
would only make sense once a version-aligned build of the patch
exists; testing them now would just be testing a known-incompatible
configuration.

---

## 📁 Repo Layout

```text
n8n-patch-test-workflow/
├── compose.yaml                   isolated Docker deployment
├── tests/
│   ├── health-check.sh            automated health validation
│   └── persistence-check.sh       restart / recreation validation
├── workflows/
│   └── baseline-workflows.json    exported test workflows
├── patch-review/
│   └── static-analysis.md         full patch findings
├── reports/
│   └── EVALUATION-REPORT.md       evaluation summary
└── evidence/                      all screenshots referenced above
    ├── baseline/
    ├── workflows/
    ├── credentials/
    ├── persistence/
    └── patch-review/
```

---

## 🚀 Reproducing This

```bash
# bring the stack up
docker compose config --quiet
docker compose up -d
docker compose ps
curl -fsS http://localhost:5678/healthz

# open the editor
# http://localhost:5678

# run the automated checks
./tests/health-check.sh
./tests/persistence-check.sh

# tear down without deleting volumes
docker compose down
```

> Only run `docker compose down -v` if you actually want the test
> volumes gone for good.

---

*This evaluation is read-only with respect to the reviewed patch — no
license-bypass code was ever built or executed as part of this work.*
