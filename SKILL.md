---
name: skynetx
description: Use when building autonomous agents that need runtime self-monitoring, context pressure detection, token budget management, session memory, or halt/continue decisions. Use when agents drift, get verbose, exhaust tokens, or need cognitive telemetry.
license: MIT
metadata:
  author: https://github.com/alexcarney460-hue
  version: "0.1.0"
  domain: agent-infrastructure
  triggers: agent monitoring, cognitive telemetry, drift detection, context pressure, verbosity control, session half-life, token budget, circuit breaker, agent memory, agent compression
  role: agent-runtime
  scope: integration
  output-format: api-calls
  related-skills: mcp-developer, api-designer
---

# SkynetX

Cognitive runtime API for autonomous agents. Provides real-time self-monitoring so agents can detect drift, manage token budgets, compress context, store session memory, and make halt/continue decisions.

**Base URL:** `https://skynetx.io/api/v1`
**Auth:** `Authorization: Bearer sk_<your_key>`
**Signup:** skynetx.io (100 free credits on signup, 1 credit per API call)

## When to Use

- Agent sessions that consume large token budgets and need to self-regulate
- Multi-step agent workflows that may drift off-task or get verbose
- Agents that need persistent memory across sessions (7-day TTL)
- Any agent that should decide when to halt vs continue
- Compressing conversation history to extend context windows

## Quick Start

```bash
# Get your API key at skynetx.io, then:
curl https://skynetx.io/api/v1/drift \
  -H "Authorization: Bearer sk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"memoryUsedPercent":60,"tokenBurnRate":45,"contextDriftPercent":30,"sessionAgeMinutes":20}'
```

## Core Endpoints

| Endpoint | Purpose | Cost |
|----------|---------|------|
| `POST /drift` | System state health score | 1 credit |
| `POST /pressure` | Session survivability | 1 credit |
| `POST /verbosity` | Output inflation detection | 1 credit |
| `POST /half-life` | Stability decay prediction | 1 credit |
| `POST /circuit-breaker` | Composite halt/continue | FREE |
| `POST /compress` | Conversation compression | 1 credit |
| `POST /memory/store` | Save session data | 1 credit |
| `GET /memory/retrieve` | Load session data | 1 credit |
| `DELETE /memory/clear` | Clear session data | FREE |
| `GET /usage` | Check credit balance | FREE |

## Integration Pattern

The recommended pattern for agent self-monitoring:

```typescript
// 1. Check drift periodically during long sessions
const drift = await fetch('https://skynetx.io/api/v1/drift', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${SKYNET_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    memoryUsedPercent: 65,
    tokenBurnRate: 50,
    contextDriftPercent: 25,
    sessionAgeMinutes: 45,
  }),
}).then(r => r.json());

// 2. If drifting, use circuit breaker to decide halt/continue
if (drift.status !== 'OPTIMAL') {
  const decision = await fetch('https://skynetx.io/api/v1/circuit-breaker', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${SKYNET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      drift: { memoryUsedPercent: 65, tokenBurnRate: 50, contextDriftPercent: 25, sessionAgeMinutes: 45 },
      thresholds: { driftScore: 0.7, pressureLevel: 'HIGH' },
    }),
  }).then(r => r.json());

  if (decision.halt) {
    // Save state and stop
    await fetch('https://skynetx.io/api/v1/memory/store', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SKYNET_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        agent_id: 'my-agent',
        session_id: 'session-123',
        data: { progress: currentState, reason: decision.recommendation },
      }),
    });
    return; // halt
  }
}

// 3. If context is bloated, compress before continuing
const compressed = await fetch('https://skynetx.io/api/v1/compress', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${SKYNET_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    messages: conversationHistory,
    mode: 'compress',
  }),
}).then(r => r.json());
// compressed.savings_percent tells you how much was saved
```

## Metric Details

Full API reference with algorithms, all parameters, and response shapes: see `api-reference.md` in this skill directory.

### Drift (system health)

**Input:** `memoryUsedPercent`, `tokenBurnRate`, `contextDriftPercent`, `sessionAgeMinutes`
**Output:** `score` (0-1), `status`: OPTIMAL | WARNING | AT_RISK | CRITICAL
**Algorithm:** Weighted sum — memory 40%, burn rate 30%, drift 30%

### Pressure (survivability)

**Input:** `memoryUsedPercent`, `tokenBurnRatePerMin`, `contextDriftPercent`, `sessionAgeSeconds`, `tokenBudgetTotal`, `tokenBudgetUsed`
**Output:** `level`: LOW | MODERATE | HIGH | CRITICAL
**Algorithm:** Threshold-based on memory and drift percentages

### Verbosity (output inflation)

**Input:** `recentOutputLengths` (array), `expectedBaseline`, `tokenBudgetUsed`, `tokenBudgetTotal`
**Output:** `level`: OPTIMAL | DRIFTING | EXCESSIVE, `driftPercent`
**Algorithm:** Average output vs baseline — >15% = DRIFTING, >30% = EXCESSIVE

### Half-Life (stability decay)

**Input:** `sessionAgeMinutes`, `memoryPressure`, `contextDrift`, `tokenRemaining`, `tokenTotal`, `errorCount`
**Output:** `estimatedHalfLifeMinutes`, `stability`: STABLE | DECAYING | FRAGILE
**Algorithm:** Token exhaustion time adjusted by decay rate from memory+drift pressure

### Circuit Breaker (halt/continue)

**Input:** Any combination of the 4 metrics + custom `thresholds`
**Output:** `halt` (boolean), `severity`, `signals`, `reasons`, `recommendation`
**Defaults:** drift > 0.7, pressure >= HIGH, verbosity > 30%, half-life < 10min

## Compression

Two modes:
- **`compress`** (fast) — Deduplicates, strips filler phrases, collapses whitespace. For conversations >20 messages, keeps first 3 + last 15.
- **`truncate`** (deep) — Scores messages by importance (system > recent > code > decisions), keeps top-scored until token budget met.

## Session Memory

- **Store:** `POST /memory/store` — `{ agent_id, session_id, data, metadata? }` — max 500KB, 7-day TTL
- **Retrieve:** `GET /memory/retrieve?agent_id=x&session_id=y` — omit session_id to list all
- **Clear:** `DELETE /memory/clear?agent_id=x&session_id=y` — omit session_id to clear all

## Auth & Credits

- Sign up at skynetx.io for API key + 100 free credits
- All responses include `_credits` field with remaining balance
- Rate limits: 30/min (starter), 100/min (pro), 500/min (scale)
- Credit packs: $5/1K, $29/10K, $99/100K (crypto payments on ETH, Base, Polygon, Arbitrum, BSC, and Solana via Phantom)
- Solana payments: USDC and USDT on Solana are supported alongside EVM chains

## Error Handling

All errors return JSON with `error` field:
```json
{ "error": "No credits remaining", "credits": 0 }
```

| Code | Meaning |
|------|---------|
| 400 | Missing or invalid parameters |
| 401 | Bad or revoked API key |
| 413 | Memory payload > 500KB |
| 429 | Rate limited or no credits |
| 503 | Service unavailable |

## Common Mistakes

- Forgetting `Content-Type: application/json` header on POST requests
- Using `sessionAge` instead of `sessionAgeMinutes` (query params use `sessionAge`, POST body uses `sessionAgeMinutes`)
- Sending `recentOutputLengths` as a string instead of an array in POST body (use comma-separated in query string)
- Not checking `_credits` in responses — you'll get 429 when they hit 0
