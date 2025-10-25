# Use official SearXNG image as base, then overlay kami-search source
FROM searxng/searxng:latest AS official

# Build stage - clone kami-search repository
FROM python:3.11-alpine AS builder

# Install git to clone repository
RUN apk add --no-cache git

# Clone kami-search repository (rebuild from latest source)
WORKDIR /app
RUN git clone https://github.com/rizonesoft/kami-search.git .

# Final stage - use official image and overlay kami-search source
FROM searxng/searxng:latest

# Copy ALL kami-search source files (not just searx directory)
# This includes branding, static files, templates, client files, etc.
COPY --from=builder --chown=searxng:searxng /app/searx /usr/local/searxng/searx
COPY --from=builder --chown=searxng:searxng /app/searxng_extra /usr/local/searxng/searxng_extra
COPY --from=builder --chown=searxng:searxng /app/client /usr/local/searxng/client

# Copy custom settings
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
