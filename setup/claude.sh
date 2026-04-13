#!/bin/sh
# Set up Claude Code and its MCP servers.
#
# Servers that require API keys or tokens (context7, Neon) must be added
# manually per machine:
#   claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key <KEY>
#   claude mcp add Neon --transport http --url https://mcp.neon.tech/mcp --header "Authorization: Bearer <TOKEN>"

# Install Claude Code if not present
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code..."
  curl -fsSL https://cli.claude.ai/install.sh | sh
fi

# Bail if install failed
if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code installation failed, skipping MCP server setup"
  exit 0
fi

echo "Setting up Claude Code MCP servers..."

claude mcp add linear-server --transport http \
  --url https://mcp.linear.app/mcp

claude mcp add graphite -- gt mcp

claude mcp add statsig --transport http \
  --url https://api.statsig.com/v1/mcp

claude mcp add Railway -- npx @railway/mcp-serverr

claude mcp add playwright -- npx @playwright/mcp@latest

claude mcp add posthog --transport http \
  --url https://mcp.posthog.com/mcp

echo "Claude Code MCP servers configured."
echo "NOTE: Add secret-bearing servers manually (context7, Neon). See comments in this script."
