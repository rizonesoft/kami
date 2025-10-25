# Use official SearXNG image as base
FROM searxng/searxng:latest

# Method 1: Volume mount approach (for docker-compose)
# Add these branding files from kami-search via volume mounts in docker-compose.yaml
# This is the official community-recommended method for Docker deployments

# For Railway/standalone: Copy branding files directly
# Download kami-search branding and copy to static directory
USER root

# Add wget to download files
RUN apk add --no-cache wget

# Download Kami branding files from kami-search repository
RUN wget -O /usr/local/searxng/searx/static/themes/simple/img/searxng.svg \
    https://raw.githubusercontent.com/rizonesoft/kami-search/master/client/simple/src/brand/searxng.svg && \
    wget -O /usr/local/searxng/searx/static/themes/simple/img/searxng-wordmark.svg \
    https://raw.githubusercontent.com/rizonesoft/kami-search/master/client/simple/src/brand/searxng-wordmark.svg || true

# Fix ownership
RUN chown -R searxng:searxng /usr/local/searxng/searx/static/themes/simple/img/

USER searxng

# Copy custom settings for Kami branding
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
