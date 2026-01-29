# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a static website for a Claude Code workshop targeting non-technical marketing folks at Spotify. It includes:

- **workshop-presentation.html** - Main slide deck presentation (scroll-snap based)
- **index.html** - Copy of workshop-presentation.html for Vercel root
- **installation-helper.html** - AI-powered chatbot for installation troubleshooting (uses Spotify's Taskforce gateway with GPT-5.2)
- **pre-work-email.html** - Email template to send before the workshop
- **troubleshooting-cheatsheet.html** - Quick reference for workshop helpers

## Deployment

Static files deployed to Vercel:
```bash
npx vercel --prod --yes
```

Live URL: https://claude-code-workshop-flame.vercel.app/

GitHub repo: https://github.com/rlester7/claude-code-workshop

## Key Architecture Notes

### Presentation Structure
- Uses CSS scroll-snap for slide navigation
- Keyboard navigation (arrow keys, spacebar)
- Nav dots on right side, slide counter bottom-left
- Dark theme with Spotify green (#1DB954) accent

### Installation Helper Chatbot
- Client-side only (no server needed)
- API key embedded in HTML for internal Spotify use
- Calls Taskforce endpoint: `https://hendrix-genai.spotify.net/taskforce/openai/v1/chat/completions`
- System prompt contains full installation guide context

### Keeping Files in Sync
When editing `workshop-presentation.html`, always copy to `index.html`:
```bash
cp workshop-presentation.html index.html
```

## Assets

- `assets/images/` - Slide images and screenshots
- `assets/images/logos/` - ChatGPT and Claude logos
- `assets/images/gifs/` - Animated GIFs
- `assets/videos/` - Background video for slide 2
