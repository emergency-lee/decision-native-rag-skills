# Deployment

## GitHub

Intended public repository:

`emergency-lee/decision-native-rag-skills`

The repository should be public and contain the files in this directory at the repository root.

## Vercel

Production URL: https://jev-shift.vercel.app (Vercel team `emergency-lee`, project `jev-shift`).

GitHub and Vercel are **not linked**. Each is published separately from the local checkout:

```bash
scripts/check.sh                                  # consistency checks
git push                                          # GitHub (account emergency-lee)
vercel deploy --prod --yes --scope emergency-lee  # Vercel
```

A push does not deploy the site, and a deploy does not push the repository.

This is a static site (`index.html`, `styles.css`, `app.js`) and requires no build step.

Project settings (no Git import):

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
- No private names, private benchmarks, sensitive personal examples, internal organisations, private conversations, or private corpus references appear in the repository or rendered site.
