# SkynetX Skill Installer for Claude Code (Windows)
# Usage: irm https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$SkillDir = "$env:USERPROFILE\.claude\skills\skynetx"
$RepoUrl = "https://raw.githubusercontent.com/alexcarney460-hue/skynetx-skill/main"

Write-Host "Installing SkynetX skill for Claude Code..."

New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

Invoke-WebRequest -Uri "$RepoUrl/SKILL.md" -OutFile "$SkillDir\SKILL.md"
Invoke-WebRequest -Uri "$RepoUrl/api-reference.md" -OutFile "$SkillDir\api-reference.md"

Write-Host ""
Write-Host "SkynetX skill installed to $SkillDir"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Sign up at https://skynetx.io for your API key"
Write-Host "  2. You get 100 free credits on signup"
Write-Host "  3. Claude Code will now use SkynetX when building agents"
Write-Host ""
Write-Host "To verify: restart Claude Code and check that 'skynetx' appears in your skill list."
