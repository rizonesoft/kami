# Use official SearXNG image
FROM searxng/searxng:latest

# Switch to root to install conversion tools
USER root

# Install ImageMagick to convert SVG to PNG
RUN apk add --no-cache imagemagick

# Copy Kami logo SVG from local branding directory
COPY branding/kami-logo.svg /tmp/kami-logo.svg

# Replace ALL logo files (SVG, PNG, and wordmark)
RUN cp /tmp/kami-logo.svg /usr/local/searxng/searx/static/themes/simple/img/searxng.svg && \
    cp /tmp/kami-logo.svg /usr/local/searxng/searx/static/themes/simple/img/searxng-wordmark.svg && \
    convert /tmp/kami-logo.svg -resize 200x200 /usr/local/searxng/searx/static/themes/simple/img/searxng.png && \
    convert /tmp/kami-logo.svg -resize 32x32 /usr/local/searxng/searx/static/themes/simple/img/favicon.png && \
    chown -R searxng:searxng /usr/local/searxng/searx/static/themes/simple/img/ && \
    rm /tmp/kami-logo.svg

# Switch back to searxng user
USER searxng

# Copy custom settings for Kami branding (URLs, instance name, etc.)
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
