FROM searxng/searxng:latest

# Set working directory
WORKDIR /usr/local/searxng

# Copy custom settings
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Environment variables with defaults
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml
ENV INSTANCE_NAME=SearXNG
ENV AUTOCOMPLETE=
ENV BASE_URL=
ENV MORTY_KEY=
ENV MORTY_URL=

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

# Start command - use the default entrypoint from base image
# The base image already has the correct entrypoint configured
