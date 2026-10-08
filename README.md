# PreviewGate — HackCanton Season 3 (Open Track)

**See it before it settles. Gate what shouldn't.**

PreviewGate brings pre-execution safety to Canton Network: every payment flows through a policy-bound envelope where the payer first gets a human-readable **preview** of exactly what would happen (nothing commits), then either settles instantly inside policy or escalates to the owner for approval. Deterministic policy checks do the provable work — no oracles, no off-ledger trust.

## The problem

On Canton, commits are atomic — but *intent* is still opaque. A payer staring at a contract ID cannot answer: "what will this actually do, and is it inside my mandate?" Teams, treasuries, and agent operators need that answer **before** the ledger moves, plus a hard gate for the cases that shouldn't self-execute.

## How it works

The owner co-signs a `GatedPayment` envelope, binding policy bounds (threshold, allowlist flag) to it. The payer then:

1. **`Preview`** (non-consuming choice) — returns a structured `PreviewResult`: verdict (`EXECUTABLE` / `REQUIRES_APPROVAL`) plus the exact effects (contracts that would be created, approval needed, what gets archived). Zero ledger change.
2. **`Execute`** — settles immediately. Fails closed unless inside policy.
3. **`RequestApproval` → `Approve`/`Reject` → `ExecuteApproved`** — out-of-policy payments escalate; the owner's single-use `GrantOfApproval` unblocks exactly one settlement and records the approver on the terminal `SettledPayment` audit record.

## Reproduce every claim (one command)

Prerequisites: Daml SDK 3.4.x (`damlc` on PATH) + Java 17.

```sh
sh scripts/verify.sh
# Windows:
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

This builds the package and runs the 6 scripted proofs in `daml/PolicyGateTest.daml`. Expected output: all six `ok`, ending in `Every claim held.`

| # | Claim | Script |
|---|---|---|
| 1 | In-policy payment previews `EXECUTABLE` and settles directly | `test_inPolicyExecutes` |
| 2 | Over-threshold payment previews `REQUIRES_APPROVAL`; direct execute fails | `test_overThresholdBlocked` |
| 3 | First-time (non-allowlisted) payee blocked even below threshold | `test_firstTimePayeeBlocked` |
| 4 | Owner approval unblocks settlement; grant is single-use; approver recorded | `test_approvalFlow` |
| 5 | Owner rejection kills the escalation; nothing settles | `test_rejectionKills` |
| 6 | Preview matches reality: settled payment equals the preview | `test_previewMatchesReality` |

## Track fit (Open Track)

Developer safety tooling for every other Canton product: agent wallets get mandate guardrails, treasuries get threshold governance, RWA flows get pre-settlement explanation. Small, auditable, dependency-free Daml — no tokens, no DevNet, no trusted third parties.

## Project structure

```
daml/PolicyGate.daml       # GatedPayment, ApprovalRequest, GrantOfApproval, SettledPayment, Preview
daml/PolicyGateTest.daml   # 6 Daml Script proofs (one per claim above)
scripts/verify.sh/.ps1     # single-command reproduce
daml.yaml                  # package manifest (SDK 3.4.11)
```

## Notes & limits (stated honestly)

- Verified with Daml SDK **3.4.11** (`damlc build` + `damlc test`, in-memory ledger). Patterns are standard Daml, forward-compatible with 3.5.x.
- Proofs run against the in-memory test ledger, not DevNet — reproducibility over live evidence; every claim re-runs locally in minutes.
- Thresholds/allowlist are owner-bound per envelope; recurring-policy registries and Canton Coin settlement are deliberate non-goals for this MVP.
