# Deployment

## GitHub

Intended public repository:

`emergency-lee/decision-native-rag-skills`

The repository should be public and contain the files in this directory at the repository root.

## Vercel

Production URL: https://jev-shift.vercel.app (Vercel team `emergency-lee`, project `jev-shift`).

This is a static site (`index.html`, `styles.css`, `app.js`) and requires no build step.

Recommended Vercel settings after importing the GitHub repository:

- Framework Preset: Other
- Build Command: leave empty
- Output Directory: `.`
- Install Command: leave empty

`vercel.json` enables clean URLs.

## Verification checklist

- Korean is the default language.
- EN / 한글 toggle changes all explanatory text.
- Every GitHub skill link resolves to the public repository.
- Public-source links resolve.
- No private names, private benchmarks, medical/patient examples, internal organisations, private conversations, or private corpus references appear in the repository or rendered site.
