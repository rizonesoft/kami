# Building from kami-search Source

This repository is configured to build Docker images directly from the [kami-search](https://github.com/rizonesoft/kami-search) repository source code.

## What Changed

The `Dockerfile` now uses a **multi-stage build** that:

1. **Build Stage** (Python 3.11 Alpine)
   - Clones the kami-search repository from GitHub
   - Installs build dependencies (Node.js, Python, Make, etc.)
   - Installs Python packages from requirements.txt
   - **CRITICAL**: Runs `make themes.all` to build static files with Kami branding
   - Compiles TypeScript, processes CSS, and copies custom logos

2. **Runtime Stage** (Official SearXNG Image)
   - Uses proven official `searxng/searxng:latest` base
   - Copies the **BUILT** application with compiled static files
   - All Kami branding assets are now properly compiled and applied

## Why Build Step is Required

⚠️ **Important Discovery**:
- The kami-search repository has custom Kami branding in source files (`client/simple/src/brand/`)
- BUT the static files (`searx/static/`) are NOT pre-built in the repository
- Simply copying source files doesn't apply the branding
- **We MUST run `make themes.all`** during Docker build to:
  - Compile TypeScript → JavaScript
  - Process LESS/CSS → compiled CSS
  - Copy branded SVG logos to static directory
  - Generate final static assets that the application serves

## Benefits

✅ **Always up-to-date**: Builds from the latest kami-search source  
✅ **Customizable**: Easy to modify and add features  
✅ **Railway-ready**: Works seamlessly with Railway deployments  
✅ **Secure**: Multi-stage build keeps image size small  

## Quick Deployment

### Railway
1. Push this repository to GitHub
2. Connect to Railway
3. Railway will automatically detect the Dockerfile
4. Configure environment variables (see RAILWAY_DEPLOYMENT.md)
5. Deploy!

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
