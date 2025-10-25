# Use official SearXNG image
FROM searxng/searxng:latest

# Copy all Kami branding files directly (pre-converted by user)
COPY --chown=searxng:searxng branding/searxng.svg /usr/local/searxng/searx/static/themes/simple/img/searxng.svg
COPY --chown=searxng:searxng branding/searxng.png /usr/local/searxng/searx/static/themes/simple/img/searxng.png
COPY --chown=searxng:searxng branding/searxng.svg /usr/local/searxng/searx/static/themes/simple/img/searxng-wordmark.svg
COPY --chown=searxng:searxng branding/favicon.png /usr/local/searxng/searx/static/themes/simple/img/favicon.png
COPY --chown=searxng:searxng branding/favicon.svg /usr/local/searxng/searx/static/themes/simple/img/favicon.svg

# Copy custom settings for Kami branding (URLs, instance name, etc.)
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
