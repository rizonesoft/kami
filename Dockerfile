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
RUN git clone https://github.com/searxng/searxng.git . && \
    git checkout latest

# Rebrand SearXNG to Kami Search in source code
RUN find . -type f \( -name "*.html" -o -name "*.py" -o -name "*.js" \) \
    -exec sed -i 's/SearXNG/Kami Search/g' {} \; && \
    find . -type f \( -name "*.html" -o -name "*.py" \) \
    -exec sed -i 's/searxng\.org/kami.onl/g' {} \; && \
    find . -type f -name "*.html" \
    -exec sed -i 's/github\.com\/searxng\/searxng//g' {} \;

# Build from source
RUN pip3 install --break-system-packages -e .

# Production image
FROM python:3.11-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    tini \
    su-exec \
    wget

# Copy built application
COPY --from=builder /app /usr/local/searxng
WORKDIR /usr/local/searxng

# Copy custom settings
COPY --chown=1000:1000 settings.yml /etc/searxng/settings.yml

# Copy custom CSS
COPY custom.css /tmp/kami-custom.css
RUN cat /tmp/kami-custom.css >> /usr/local/searxng/searx/static/themes/simple/css/searxng.min.css && \
    rm /tmp/kami-custom.css

# Create searxng user
RUN adduser -D -u 1000 -h /usr/local/searxng searxng && \
    chown -R searxng:searxng /usr/local/searxng

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
