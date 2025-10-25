# Use official SearXNG image
FROM searxng/searxng:latest

# Copy Kami logo from local branding directory
# This replaces the default SearXNG logo
COPY --chown=searxng:searxng branding/kami-logo.svg /usr/local/searxng/searx/static/themes/simple/img/searxng.svg

# Also use it as the wordmark (can be replaced with a separate wordmark file if needed)
COPY --chown=searxng:searxng branding/kami-logo.svg /usr/local/searxng/searx/static/themes/simple/img/searxng-wordmark.svg

# Copy custom settings for Kami branding (URLs, instance name, etc.)
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
