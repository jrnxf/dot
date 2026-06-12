#!/bin/sh
# Set up Claude Code and its MCP servers.
#
# Servers that require API keys or tokens (context7) must be added
# manually per machine:
#   claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key <KEY>

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

add_mcp() {
  name="$1"; shift
  if claude mcp get "$name" >/dev/null 2>&1; then
    echo "MCP server '$name' already configured, skipping."
  else
    claude mcp add "$name" "$@"
  fi
}

add_mcp linear-server --transport http --url https://mcp.linear.app/mcp
add_mcp graphite -- gt mcp
add_mcp statsig --transport http --url https://api.statsig.com/v1/mcp
add_mcp playwright -- npx @playwright/mcp@latest
add_mcp posthog --transport http --url https://mcp.posthog.com/mcp

echo "Claude Code MCP servers configured."
echo "NOTE: Add secret-bearing servers manually (context7). See comments in this script."
