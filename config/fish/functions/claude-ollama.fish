function claude-ollama
    set -l key (security find-generic-password -s ollama-api-key -w)
    or begin
        echo "キーチェーンに ollama-api-key がありません" >&2
        return 1
    end

    ANTHROPIC_BASE_URL=https://ollama.com \
    ANTHROPIC_AUTH_TOKEN="$key" \
    ANTHROPIC_API_KEY="" \
    ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4.1-flash \
    ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4.1-flash \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4.1-flash \
    CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4.1-flash \
    CLAUDE_CODE_MAX_CONTEXT_TOKENS=1000000 \
    CLAUDE_CODE_AUTO_MODE_SERVER=0 \
    ENABLE_CLAUDEAI_MCP_SERVERS=false \
    claude --model deepseek-v4.1-flash $argv
end
