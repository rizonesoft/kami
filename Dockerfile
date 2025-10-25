# Build stage - clone kami-search for source files
FROM alpine:latest AS builder

# Install git
RUN apk add --no-cache git

# Clone kami-search repository
WORKDIR /app
RUN git clone https://github.com/rizonesoft/kami-search.git .

# Final stage - use official SearXNG image and overlay kami-search customizations
FROM searxng/searxng:latest

# Copy Python source (settings, engines, etc.)
COPY --from=builder --chown=searxng:searxng /app/searx /usr/local/searxng/searx

# Copy branding source files directly (SVG logos, etc.)
# These will be served by SearXNG from the client directory
COPY --from=builder --chown=searxng:searxng /app/client/simple/src/brand/*.svg /usr/local/searxng/searx/static/themes/simple/img/

# Copy custom settings
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
