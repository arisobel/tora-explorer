# CapRover Deploy

## Goal

Generate CapRover-compatible `.tar` packages for the static Torá Explorer app.
Generated packages live in `dist/`, with only the 5 most recent packages kept.

---

## Files

| File | Purpose |
|------|---------|
| `captain-definition` | CapRover manifest pointing to the Dockerfile |
| `Dockerfile` | Minimal Nginx image for static hosting |
| `nginx.conf` | Nginx static hosting and `/api/sefaria/` reverse proxy |
| `scripts/build-caprover.ps1` | Builds the deploy tar and prunes old packages |
| `dist/` | Local output folder for generated `.tar` files |

---

## Build Command

From the repository root:

```powershell
.\scripts\build-caprover.ps1
```

If PowerShell blocks local scripts, use:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-caprover.ps1
```

Output example:

```text
dist/tora-explorer-caprover-20260531-153000.tar
```

The script keeps only the 5 newest files matching:

```text
tora-explorer-caprover-*.tar
```

Generated tar files are ignored by Git through `.gitignore`; `dist/.gitkeep`
keeps the output folder present in the repository.

---

## Package Contents

The generated tar includes:
- `captain-definition`
- `Dockerfile`
- `nginx.conf`
- `index.html`
- `data/`
- `assets/` if the folder exists

It intentionally does not include docs, scripts, Git metadata, or previous
`dist/` packages.

---

## Deploy Flow

1. Run `.\scripts\build-caprover.ps1`
2. Open CapRover
3. Select the app
4. Use tar upload deployment
5. Upload the newest tar from `dist/`

---

## Notes

- Runtime remains static: Nginx serves `index.html` and JSON files.
- Browser Sefaria requests use same-origin `/api/sefaria/`; Nginx proxies those requests to Sefaria.
- The package is suitable for CapRover's Dockerfile deployment path.
