# 🚀 Railway Deployment Guide

This guide will help you deploy SearXNG to Railway.

## 📋 Prerequisites

- A Railway account (https://railway.app)
- Git installed
- This repository

## 🛠️ Setup Steps

### 1. Commit the Railway Configuration

The following files have been created for Railway deployment:
- `Dockerfile` - Container configuration
- `railway.json` - Railway build configuration (helps Railway detect Dockerfile)
- `settings.yml` - SearXNG configuration (root level, separate from `searxng/settings.yml`)
- `.dockerignore` - Files to exclude from Docker build

Commit these files:

```bash
git add Dockerfile railway.json settings.yml .dockerignore RAILWAY_DEPLOYMENT.md
git commit -m "Add Railway deployment configuration"
git push origin master
```

### 2. Deploy to Railway

1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose this repository
5. Railway will automatically detect the Dockerfile and start building

### 3. Configure Environment Variables

Once deployed, add these environment variables in Railway dashboard (Variables tab):

#### Required Variables

```bash
# Generate a secret key (run this locally):
# openssl rand -hex 32
SEARXNG_SECRET=<your-generated-secret-key>

# Your Railway app URL (update after first deployment)
SEARXNG_BASE_URL=https://your-app.up.railway.app

# Port (Railway provides this automatically, but you can set it)
PORT=8080
```

#### Optional Variables

```bash
# Instance name (default: SearXNG)
INSTANCE_NAME=Kitsune Search

# Autocomplete provider (default: duckduckgo)
AUTOCOMPLETE=duckduckgo

# Morty proxy settings (if using)
MORTY_KEY=
MORTY_URL=
```

### 4. Generate Secret Key

Run this command on your local machine to generate a secure secret key:

```bash
openssl rand -hex 32
```

Copy the output and use it as the `SEARXNG_SECRET` environment variable.

### 5. Update Base URL

After your first deployment:
1. Copy your Railway app URL (e.g., `https://your-app-name.up.railway.app`)
2. Set `SEARXNG_BASE_URL` to this URL in Railway environment variables
3. Redeploy if necessary

## 🎯 Configuration Details

### Dockerfile
- Builds from source: `https://github.com/rizonesoft/kami-search`
- Multi-stage build using Python 3.11 Alpine
- Clones and builds the kami-search repository directly
- Exposes port 8080
- Includes health check endpoint at `/healthz`
- Copies custom `settings.yml` from root directory
- Uses uWSGI as the application server

### settings.yml
- **Instance Name**: "Kitsune Search"
- **Theme**: Simple (auto light/dark)
- **Autocomplete**: DuckDuckGo
- **Safe Search**: Disabled (0)
- **Enabled Engines**: DuckDuckGo, Brave, Wikipedia
- **Image Proxy**: Disabled (for Railway simplicity)
- **Rate Limiter**: Disabled (enable for public usage)

### Security Notes

⚠️ **Important**:
- Always use a strong, randomly generated `SEARXNG_SECRET`
- Never commit secrets to Git
- Enable `limiter: true` in `settings.yml` if running publicly
- Consider enabling `image_proxy: true` for privacy

## 🔍 Verification

After deployment:
1. Visit your Railway app URL
2. Try a search query
3. Check the health endpoint: `https://your-app.up.railway.app/healthz`

## 🐛 Troubleshooting

### Build Fails
- Check Railway build logs
- Ensure Dockerfile syntax is correct
- Verify base image is accessible

### App Won't Start
- Check that PORT is set to 8080
- Verify `SEARXNG_SECRET` is set
- Check Railway deployment logs

### Search Not Working
- Verify engines are enabled in `settings.yml`
- Check if base URL is correctly set
- Review app logs for errors

## 📚 Additional Resources

- [SearXNG Documentation](https://docs.searxng.org/)
- [Railway Documentation](https://docs.railway.app/)
- [SearXNG Settings Reference](https://docs.searxng.org/admin/settings/settings.html)

## 🔄 Local Development vs Railway

This repository contains two deployment methods:

1. **Local Development** (docker-compose.yaml)
   - Uses Caddy reverse proxy
   - Includes Redis for caching
   - Configuration in `searxng/settings.yml`

2. **Railway Deployment** (Dockerfile)
   - Standalone container
   - Builds from kami-search source
   - No reverse proxy needed
   - Configuration in root `settings.yml`

Both can coexist without conflicts.

## 🔧 Advanced Configuration

### Pinning to a Specific Version

The Dockerfile clones the latest `master` branch of kami-search. To pin to a specific version:

**Edit line 16 in `Dockerfile`:**
```dockerfile
# For a specific branch:
RUN git clone --branch your-branch-name https://github.com/rizonesoft/kami-search.git .

# For a specific tag:
RUN git clone --branch v1.0.0 --depth 1 https://github.com/rizonesoft/kami-search.git .

# For a specific commit:
RUN git clone https://github.com/rizonesoft/kami-search.git . && \
    git checkout <commit-sha>
```

### Building from a Different Repository

To use a different SearXNG fork, update line 16:
```dockerfile
RUN git clone https://github.com/your-username/your-fork.git .
```
