# Build stage - clone and build from kami-search
FROM python:3.11-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    git \
    build-base \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    libffi-dev \
    py3-pip

# Clone kami-search repository
WORKDIR /app
RUN git clone https://github.com/rizonesoft/kami-search.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    libxml2 \
    libxslt \
    openssl \
    tini \
    uwsgi \
    uwsgi-python3 \
    brotli

# Create searxng user
RUN addgroup -g 1000 searxng && \
    adduser -u 1000 -D -h /usr/local/searxng -G searxng searxng

# Copy application from builder
COPY --from=builder --chown=searxng:searxng /app /usr/local/searxng
COPY --from=builder --chown=searxng:searxng /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy custom settings
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Set working directory
WORKDIR /usr/local/searxng

# Switch to searxng user
USER searxng

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Start SearXNG
CMD ["uwsgi", "--master", "--http-socket", "0.0.0.0:8080", "--wsgi-file", "searx/webapp.py", "--callable", "application"]
