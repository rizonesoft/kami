# Build stage - clone and build kami-search with custom branding
FROM python:3.11-alpine AS builder

# Install build dependencies (git, node, make, python build tools)
RUN apk add --no-cache \
    git \
    make \
    bash \
    nodejs \
    npm \
    python3-dev \
    build-base \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    libffi-dev

# Clone kami-search repository
WORKDIR /app
RUN git clone https://github.com/rizonesoft/kami-search.git .

# Install Python dependencies
RUN pip install --no-cache-dir -e .

# Build the themes/static files with custom Kami branding
# This compiles TypeScript, processes CSS, and copies branded assets
RUN make themes.all

# Final stage - use official SearXNG image and overlay built kami-search
FROM searxng/searxng:latest

# Copy the BUILT application with compiled static files
COPY --from=builder --chown=searxng:searxng /app/searx /usr/local/searxng/searx

# Copy custom settings
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1
