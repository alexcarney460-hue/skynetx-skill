# SkynetX API Reference

Complete endpoint documentation with request/response shapes and algorithms.

## Authentication

All endpoints (except `/usage`) require:
```
Authorization: Bearer sk_<your_key>
```

Optional telemetry headers:
```
X-Agent-Id: your-agent-name
X-Session-Id: session-identifier
```

---

## POST /api/v1/drift

Evaluates system state health using weighted scoring.

### Request

```typescript
{
  memoryUsedPercent: number;     // 0-100
  tokenBurnRate: number;         // tokens per time unit
  contextDriftPercent: number;   // 0-100
  sessionAgeMinutes: number;
}
```

### Algorithm

```
score = (memoryUsedPercent / 100) * 0.4
      + min(tokenBurnRate / 50, 1.0) * 0.3
      + (contextDriftPercent / 100) * 0.3

Status:
  > 0.75 → CRITICAL
  > 0.50 → AT_RISK
  > 0.25 → WARNING
  ≤ 0.25 → OPTIMAL
```

### Response

```typescript
{
  score: number;           // 0.000 - 1.000
  status: 'OPTIMAL' | 'WARNING' | 'AT_RISK' | 'CRITICAL';
  memoryUsedPercent: number;
  tokenBurnRate: number;
  contextDriftPercent: number;
  sessionAgeMinutes: number;
  recommendations: string[];
  timestamp: string;
  _credits: number;
}
```

---

## POST /api/v1/pressure

Evaluates session survivability under resource constraints.

### Request

```typescript
{
  memoryUsedPercent: number;      // 0-100
  tokenBurnRatePerMin: number;
  contextDriftPercent: number;    // 0-100
  sessionAgeSeconds: number;
  tokenBudgetTotal: number;
  tokenBudgetUsed: number;
}
```

### Algorithm

```
First matching rule wins:
  memoryUsedPercent > 80 OR contextDriftPercent > 40 → CRITICAL
  memoryUsedPercent > 65 OR contextDriftPercent > 30 → HIGH
  memoryUsedPercent > 50 OR contextDriftPercent > 20 → MODERATE
  else → LOW
```

### Response

```typescript
{
  level: 'LOW' | 'MODERATE' | 'HIGH' | 'CRITICAL';
  sessionAgeSeconds: number;
  memoryUsedPercent: number;
  tokenBurnRatePerMin: number;
  contextDriftPercent: number;
  recommendations: string[];
  timestamp: string;
  _credits: number;
}
```

---

## POST /api/v1/verbosity

Detects output length inflation compared to baseline.

### Request

```typescript
{
  recentOutputLengths: number[];   // array of token counts
  expectedBaseline: number;        // typical output length in tokens
  tokenBudgetUsed: number;
  tokenBudgetTotal: number;
}
```

POST body aliases: `recentOutputLengthsTokens`, `expectedBaselineTokensPerOutput`
Query string: `recentOutputLengths=150,160,170` (comma-separated)

### Algorithm

```
avgOutputLength = sum(recentOutputLengths) / count
driftPercent = ((avgOutputLength - expectedBaseline) / expectedBaseline) * 100

Level:
  driftPercent > 30 → EXCESSIVE
  driftPercent > 15 → DRIFTING
  else → OPTIMAL
```

### Response

```typescript
{
  level: 'OPTIMAL' | 'DRIFTING' | 'EXCESSIVE';
  driftPercent: number;         // 1 decimal
  avgOutputLength: number;      // 1 decimal
  expectedBaseline: number;
  recommendations: string[];
  timestamp: string;
  _credits: number;
}
```

---

## POST /api/v1/half-life

Predicts session stability decay and remaining lifetime.

### Request

```typescript
{
  sessionAgeMinutes: number;
  memoryPressure: number;      // 0-100
  contextDrift: number;        // 0-100
  tokenRemaining: number;
  tokenTotal: number;
  errorCount: number;
}
```

POST body aliases: `currentMemoryPressurePercent`, `currentContextDriftPercent`, `tokenBudgetRemaining`, `tokenBudgetTotal`, `errorCountThisSession`
Query string: use `sessionAge`, `errors` (shorter names)

### Algorithm

```
tokenBurnRate = (tokenTotal - tokenRemaining) / max(sessionAgeMinutes, 1)
minutesUntilExhaustion = tokenRemaining / max(tokenBurnRate, 1)
decayRate = (memoryPressure + contextDrift) / 100
estimatedHalfLifeMinutes = minutesUntilExhaustion / (1 + decayRate)

Stability:
  < 10 min → FRAGILE
  < 30 min → DECAYING
  ≥ 30 min → STABLE
```

### Response

```typescript
{
  estimatedHalfLifeMinutes: number;  // rounded integer
  stability: 'STABLE' | 'DECAYING' | 'FRAGILE';
  sessionAgeMinutes: number;
  tokenBurnRatePerMin: number;       // 1 decimal
  minutesUntilExhaustion: number;    // rounded integer
  recommendations: string[];
  timestamp: string;
  _credits: number;
}
```

---

## POST /api/v1/circuit-breaker (FREE)

Composite halt/continue decision based on any combination of metrics.

### Request

```typescript
{
  drift?: {
    memoryUsedPercent: number;
    tokenBurnRate: number;
    contextDriftPercent: number;
    sessionAgeMinutes: number;
  };
  pressure?: {
    memoryUsedPercent: number;
    tokenBurnRatePerMin: number;
    contextDriftPercent: number;
    sessionAgeSeconds: number;
    tokenBudgetTotal: number;
    tokenBudgetUsed: number;
  };
  verbosity?: {
    recentOutputLengths: number[];
    expectedBaseline: number;
    tokenBudgetUsed: number;
    tokenBudgetTotal: number;
  };
  halfLife?: {
    sessionAgeMinutes: number;
    memoryPressure: number;
    contextDrift: number;
    tokenRemaining: number;
    tokenTotal: number;
    errorCount: number;
  };
  thresholds?: {
    driftScore?: number;              // default: 0.7
    pressureLevel?: string;           // default: 'HIGH'
    verbosityDriftPercent?: number;    // default: 30
    halfLifeMinutes?: number;         // default: 10
    maxCostUsd?: number;              // default: null
  };
  cost_per_token?: number;
  total_tokens?: number;
}
```

### Response

```typescript
{
  halt: boolean;
  severity: 'nominal' | 'warning' | 'critical';
  signals: {
    drift?: { value: number; threshold: number; tripped: boolean };
    pressure?: { value: string; threshold: string; tripped: boolean };
    verbosity?: { value: number; threshold: number; tripped: boolean };
    halfLife?: { value: number; threshold: number; tripped: boolean };
    cost?: { value: number; threshold: number; tripped: boolean };
  };
  reasons: string[];
  recommendation: string;
  timestamp: string;
}
```

---

## POST /api/v1/compress

Compresses conversation history using algorithmic methods (no LLM cost).

### Request

```typescript
{
  messages: Array<{ role: string; content: string }>;
  mode?: 'compress' | 'truncate';  // default: 'compress'
  target_tokens?: number;           // for truncate mode
}
```

### Compression Modes

**compress (fast):**
- Keeps all system messages
- Deduplicates messages with >80% content overlap
- Removes filler phrases ("certainly", "as mentioned earlier", etc.)
- Collapses whitespace
- For >20 messages: keeps first 3 + last 15, condenses middle

**truncate (deep):**
- Scores each message by importance:
  - System: +100, Recent: +30 (scaled), Code/data: +20, Decisions: +15, Questions: +10
  - Very long (>2000 chars): -10
- Keeps top-scored messages until token budget met
- Inserts `[n message(s) truncated]` markers

Token estimation: `text.length / 4`

### Response

```typescript
{
  compressed: Array<{ role: string; content: string }>;
  original_tokens: number;
  compressed_tokens: number;
  savings_percent: number;
  method: 'fast' | 'deep';
  _credits: number;
  _note: string;
}
```

---

## POST /api/v1/memory/store

Store agent session data with automatic 7-day expiry.

### Request

```typescript
{
  agent_id: string;
  session_id: string;
  data: object;        // any JSON, max 500KB
  metadata?: object;   // optional tags
}
```

### Response

```typescript
{
  stored: true;
  agent_id: string;
  session_id: string;
  token_count: number;
  bytes: number;
  expires_at: string;
  _credits: number;
}
```

---

## GET /api/v1/memory/retrieve

### Query Parameters

- `agent_id` (required)
- `session_id` (optional — omit to list all sessions)

### Response (single session)

```typescript
{
  agent_id: string;
  session_id: string;
  data: object;
  metadata: object;
  token_count: number;
  updated_at: string;
  expires_at: string;
  _credits: number;
}
```

### Response (list sessions)

```typescript
{
  agent_id: string;
  sessions: Array<{
    session_id: string;
    token_count: number;
    updated_at: string;
    expires_at: string;
  }>;
  count: number;
  _credits: number;
}
```

---

## DELETE /api/v1/memory/clear (FREE)

### Query Parameters

- `agent_id` (required)
- `session_id` (optional — omit to clear all)

### Response

```typescript
{
  cleared: true;
  agent_id: string;
  session_id: string;  // or "all"
}
```

---

## GET /api/v1/usage (FREE)

### Response

```typescript
{
  credits: number;
  totalPurchased: number;
  payments: Array<{
    tx_hash: string;
    amount_usd: number;
    credits_purchased: number;
    chain: 'ethereum' | 'base' | 'polygon' | 'arbitrum' | 'bsc' | 'solana';
    confirmed: boolean;
    created_at: string;
  }>;
}
```

---

## POST /api/v1/credits/purchase

Initiate a credit pack purchase. Returns payment details for the selected network.

### Request

```typescript
{
  pack: 'starter' | 'pro' | 'scale';
  network: 'evm' | 'solana';          // payment network
  chain?: string;                       // for EVM: 'ethereum' | 'base' | 'polygon' | 'arbitrum' | 'bsc'
  token?: 'USDC' | 'USDT';            // for Solana (default: 'USDC')
}
```

### Response

```typescript
{
  purchase_id: string;
  pack: string;
  credits: number;
  amount_usd: number;
  network: 'evm' | 'solana';
  payment_address: string;             // 0x address (EVM) or base58 address (Solana)
  solana_wallet?: string;              // included when network is 'solana'
  token?: string;                      // 'USDC' or 'USDT' for Solana
  chain?: string;                      // EVM chain name when network is 'evm'
  expires_at: string;
}
```

---

## POST /api/v1/credits/confirm

Confirm a credit purchase by submitting the transaction signature.

### Request

```typescript
{
  purchase_id: string;
  tx_signature: string;   // 0x-prefixed hex (EVM) or base58 (Solana)
  network: 'evm' | 'solana';
}
```

The `tx_signature` field accepts both EVM transaction hashes (0x-prefixed hex string) and Solana transaction signatures (base58-encoded string). The `network` field determines which chain is queried for confirmation.

### Response

```typescript
{
  confirmed: boolean;
  credits_added: number;
  credits_total: number;
  tx_hash: string;
  network: 'evm' | 'solana';
  chain?: string;
}
```

---

## Credit Packs

| Pack | Credits | Price | Rate Limit |
|------|---------|-------|------------|
| Free | 100 | $0 | 30/min |
| Starter | 1,000 | $5 | 30/min |
| Pro | 10,000 | $29 | 100/min |
| Scale | 100,000 | $99 | 500/min |

---

## Error Responses

All errors return:
```typescript
{ error: string; message?: string; credits?: number }
```

| Code | Cause |
|------|-------|
| 400 | Missing/invalid parameters |
| 401 | Invalid or revoked API key |
| 413 | Memory payload > 500KB |
| 429 | Rate limited or out of credits |
| 503 | Service unavailable |
