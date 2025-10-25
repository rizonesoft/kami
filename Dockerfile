# Use official SearXNG image
FROM searxng/searxng:latest

# Switch to root to modify files
USER root

# Download Kami branding SVG files from kami-search repository
# Using curl (more reliable than wget for GitHub raw files)
RUN curl -fsSL https://raw.githubusercontent.com/rizonesoft/kami-search/master/client/simple/src/brand/searxng.svg \
    -o /usr/local/searxng/searx/static/themes/simple/img/searxng.svg || echo "Warning: Could not download logo" && \
    curl -fsSL https://raw.githubusercontent.com/rizonesoft/kami-search/master/client/simple/src/brand/searxng-wordmark.svg \
    -o /usr/local/searxng/searx/static/themes/simple/img/searxng-wordmark.svg || echo "Warning: Could not download wordmark"

# Ensure correct ownership
RUN chown -R searxng:searxng /usr/local/searxng/searx/static/themes/simple/img/

# Switch back to searxng user
USER searxng

# Copy custom settings for Kami branding (URLs, instance name, etc.)
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
