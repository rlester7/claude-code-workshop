---
name: snow-deploy
description: Deploy to Snow (snow.spotify.net). Use when user says "deploy to snow", "snow deploy", runs "/snow-deploy", or wants to deploy to Spotify's internal static hosting. Supports --review for temporary 7-day deployments and --site-name to specify the site name.
---

# Snow Deployment Skill

Deploy a project to Snow (snow.spotify.net).

## Execution Steps

1. **Check if Snow CLI is installed:** `which snow`

2. **If not installed**, configure npm and install:
   ```bash
   npm config set @spotify-internal:registry https://artifactory.spotify.net/artifactory/api/npm/npm-local/
   npm install -g @spotify-internal/snow
   ```

3. **Detect project type** by checking for `package.json`:
   - **If package.json exists**: Check if it has a `name` field and `build` script
   - **If no package.json**: This is a static site, `--site-name` is required

4. **Deploy** with the appropriate command (see below)

5. **Report the deployment URL** to the user

## Project Types

### Static Sites (no package.json)
- Deployed to: `https://snow.spotify.net/s/<site-name>`
- Requires `--site-name` flag
- May need `<base href="/s/<site-name>/">` in index.html for relative URLs

### SPAs (with package.json + build script)
- Deployed to: `https://snow.spotify.net/spa/<site-name>`
- Site name auto-detected from package.json `name` field
- Snow runs the `build` script before deploying

## Deployment Commands

### Static Site (no package.json)
```bash
# Production
snow deploy --site-name <site-name> --yes

# Review (7-day TTL)
snow deploy --site-name <site-name> --review --yes
```

### SPA (with package.json)
```bash
# Production (name from package.json)
snow deploy --yes

# Production (override name)
snow deploy --site-name <site-name> --yes

# Review (7-day TTL)
snow deploy --review --yes
```

## Site Name Handling

1. **Check for package.json** with a `name` field
2. **If no name can be auto-detected**, propose a sensible name based on the project/directory
3. **Confirm with the user** before deploying
4. Deploy with `--site-name` if needed

## Arguments

- `--review` - Deploy a review version with 7-day TTL
- `--site-name <name>` - Specify the site name (required for static sites, optional override for SPAs)

## Base Href for Static Sites

For static sites deployed to `/s/<site-name>`, relative URLs may need a base href tag in `index.html`:

```html
<base href="/s/<site-name>/">
```

Check if assets load correctly after deployment. If using relative paths (e.g., `assets/images/...`) and they break, add the base href. SPAs at `/spa/` typically don't need this.
