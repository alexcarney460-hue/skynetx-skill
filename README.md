# SkynetX Skill for Claude Code

Cognitive runtime API for autonomous agents. Gives your Claude Code agents real-time self-monitoring: drift detection, context pressure, verbosity control, session memory, compression, and halt/continue decisions.

## Install

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/install.ps1 | iex
```

**Manual:**
```bash
mkdir -p ~/.claude/skills/skynetx
curl -fsSL https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/SKILL.md -o ~/.claude/skills/skynetx/SKILL.md
curl -fsSL https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/api-reference.md -o ~/.claude/skills/skynetx/api-reference.md
```

## Setup

1. Sign up at [skynetx.io](https://skynetx.io) to get your API key
2. You get the **Free tier** (100 credits/mo, 1 credit per API call)
3. Restart Claude Code — the `skynetx` skill will appear in your skill list

## What It Does

Once installed, Claude Code will automatically use SkynetX when building agents that need:

| Capability | Endpoint | What It Measures |
|------------|----------|-----------------|
| Drift Detection | `/api/v1/drift` | System state health (OPTIMAL → CRITICAL) |
| Context Pressure | `/api/v1/pressure` | Session survivability (LOW → CRITICAL) |
| Verbosity Control | `/api/v1/verbosity` | Output inflation (OPTIMAL → EXCESSIVE) |
| Session Half-Life | `/api/v1/half-life` | Stability decay prediction (STABLE → FRAGILE) |
| Circuit Breaker | `/api/v1/circuit-breaker` | Composite halt/continue decision (FREE) |
| Compression | `/api/v1/compress` | Conversation history compression |
| Session Memory | `/api/v1/memory/*` | Persistent agent memory (7-day TTL) |

## Quick Example

```bash
curl https://skynetx.io/api/v1/drift \
  -H "Authorization: Bearer sk_YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"memoryUsedPercent":60,"tokenBurnRate":45,"contextDriftPercent":30,"sessionAgeMinutes":20}'
```

```json
{
  "score": 0.510,
  "status": "AT_RISK",
  "recommendations": ["High drift detected; consider compressing context"],
  "_credits": 99
}
```

## Pricing

### Monthly Subscriptions (Stripe)

| Tier | Price | Credits/mo | Rate Limit |
|------|-------|------------|------------|
| Free | $0 | 100 | 30/min |
| Starter | $9/mo | 5,000 | 60/min |
| Pro | $29/mo | 25,000 | 200/min |
| Scale | $99/mo | 150,000 | 500/min |

Credits refresh automatically each billing cycle.

### Crypto Top-Ups (non-card users)

| Pack | Credits | Price |
|------|---------|-------|
| Small | 5,000 | $12 |
| Medium | 25,000 | $40 |
| Large | 150,000 | $130 |

Available via EVM (Ethereum, Base, Polygon, Arbitrum, BSC) or Solana (USDC/USDT).

## Uninstall

```bash
rm -rf ~/.claude/skills/skynetx
```

## Links

- [SkynetX API](https://skynetx.io)
- [Full API Reference](./api-reference.md)
- [GitHub](https://github.com/alexcarney460-hue/skynet)

## License

MIT
