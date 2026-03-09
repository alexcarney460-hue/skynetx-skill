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
2. You get **100 free credits** on signup (1 credit per API call)
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

| Pack | Credits | Price |
|------|---------|-------|
| Free | 100 | $0 |
| Starter | 1,000 | $5 |
| Pro | 10,000 | $29 |
| Scale | 100,000 | $99 |

Payments via crypto (ETH, Base, Polygon, Arbitrum, BSC, and Solana via Phantom). USDC/USDT supported on Solana.

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
