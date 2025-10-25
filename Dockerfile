FROM alpine:3.19 as builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    sed \
    nodejs \
    npm

# Clone SearXNG source
WORKDIR /app
RUN git clone --depth 1 https://github.com/searxng/searxng.git .

# Rebrand SearXNG to Kami Search in source code
RUN find . -type f \( -name "*.html" -o -name "*.py" -o -name "*.js" \) \
    -exec sed -i 's/SearXNG/Kami Search/g' {} \; && \
    find . -type f \( -name "*.html" -o -name "*.py" \) \
    -exec sed -i 's/searxng\.org/kami.onl/g' {} \; && \
    find . -type f -name "*.html" \
    -exec sed -i 's/github\.com\/searxng\/searxng//g' {} \;

# Install Python dependencies
RUN pip3 install --break-system-packages --no-cache-dir \
    -r requirements.txt && \
    python3 -m compileall -q searx

# Production image
FROM python:3.11-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    tini \
    su-exec \
    wget

# Create searxng user first
RUN adduser -D -u 1000 searxng

# Copy built application
COPY --from=builder /app /usr/local/searxng
WORKDIR /usr/local/searxng

# Create settings directory and copy custom settings
RUN mkdir -p /etc/searxng
COPY --chown=searxng:searxng settings.yml /etc/searxng/settings.yml

# Copy custom CSS and inject into theme
COPY custom.css /tmp/kami-custom.css
RUN cat /tmp/kami-custom.css >> /usr/local/searxng/searx/static/themes/simple/css/searxng.min.css && \
    rm /tmp/kami-custom.css

# Set proper permissions
RUN chown -R searxng:searxng /usr/local/searxng /etc/searxng

# Environment variables with defaults
ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml
ENV INSTANCE_NAME="Kami Search"
ENV AUTOCOMPLETE=
ENV BASE_URL=
ENV MORTY_KEY=
ENV MORTY_URL=

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

# Switch to searxng user
USER searxng

# Start command
CMD ["python3", "-m", "searx.webapp"]
