# SearXNG Branding Approach

This repository applies Kami branding to the official SearXNG Docker image.

## Official SearXNG Position on Branding

### What We Learned

After extensive research of official SearXNG documentation and maintainer guidance:

**From SearXNG Core Maintainer (@return42):**
> "We do not have options to customize UI .. if someone wants to customize 'this or that' it is recommended to **create a fork (we call it a brand)** and modify the logo, theme or .. to your needs. Don't forget to rebase your customized branch regularly to get latest updates."

### Current SearXNG Limitations

- ❌ **No settings.yml option** for logo/favicon customization
- ❌ **No UI customization settings** in the official release
- ✅ **Only URL branding** available (`brand:` section in settings.yml)

### Official Recommended Approach

1. **Fork the repository** (kami-search is such a fork)
2. **Modify branding files** in your fork
3. **Rebase regularly** to get upstream updates
4. **Deploy your fork** directly

### Community Workarounds

Since official customization options don't exist yet:

**Method 1: Volume Mounts (docker-compose)**
```yaml
volumes:
  - ./custom-logo.svg:/usr/local/searxng/searx/static/themes/simple/img/searxng.svg
```
❌ Problem: Lost on container updates

**Method 2: Direct File Replacement (Dockerfile)**
```dockerfile
COPY custom-logo.svg /usr/local/searxng/searx/static/themes/simple/img/searxng.svg
```
✅ Persistent across deployments

## Our Implementation

We use **Method 2** with a smart twist:

1. **Base**: Official `searxng/searxng:latest` image
2. **Download**: Fetch Kami branding from kami-search repository
3. **Replace**: Overwrite default logos in static directory
4. **Deploy**: Railway automatically rebuilds when needed

## Benefits

✅ **Uses official image**: Proven stability and security  
✅ **Simple approach**: No complex builds required  
✅ **Persistent branding**: Survives container updates  
✅ **Railway-ready**: Fast deployment (<30 seconds)  
✅ **Minimal size**: Only downloads 2 SVG files

## How It Works

```dockerfile
# Start with official SearXNG
FROM searxng/searxng:latest

# Download Kami branding
RUN wget -O /usr/local/searxng/searx/static/themes/simple/img/searxng.svg \
    https://raw.githubusercontent.com/rizonesoft/kami-search/master/client/simple/src/brand/searxng.svg

# Copy custom settings
COPY settings.yml /etc/searxng/settings.yml
```

## Deployment

### Railway
1. Push this repository to GitHub
2. Connect to Railway
3. Railway auto-detects Dockerfile
4. Configure environment variables
5. Deploy! (Build time: ~30 seconds)

### Local Testing
```bash
# Build the image
docker build -t kami-search:local .

# Run the container
docker run -p 8080:8080 \
  -e SEARXNG_SECRET=$(openssl rand -hex 32) \
  -e SEARXNG_BASE_URL=http://localhost:8080 \
  kami-search:local
```

## Configuration

The Dockerfile clones from `master` branch by default. To customize:

### Use a specific branch
```dockerfile
RUN git clone --branch your-branch https://github.com/rizonesoft/kami-search.git .
```

### Use a specific tag/version
```dockerfile
RUN git clone --branch v1.0.0 --depth 1 https://github.com/rizonesoft/kami-search.git .
```

### Use a different fork
```dockerfile
RUN git clone https://github.com/your-username/your-fork.git .
```

## File Structure

```
kami-docker/
├── Dockerfile              ← Builds from kami-search source
├── railway.toml            ← Railway configuration
├── settings.yml            ← Custom SearXNG settings
├── docker-compose.yaml     ← Local development (uses official image)
├── RAILWAY_DEPLOYMENT.md   ← Full Railway guide
└── BUILD_FROM_SOURCE.md    ← This file
```

## Troubleshooting

### Build fails with "git clone" error
- Check internet connectivity in build environment
- Verify the repository URL is correct
- Ensure git is installed in the builder stage

### Python dependencies fail
- Check `requirements.txt` compatibility with Python 3.11
- Verify all system dependencies are installed in build stage

### Application won't start
- Check uWSGI configuration
- Verify the `searx/webapp.py` path exists in the cloned repo
- Check logs for specific errors

## Related Documentation

- [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) - Railway deployment guide
- [README.md](README.md) - General usage and local development
- [kami-search repository](https://github.com/rizonesoft/kami-search) - Source code
