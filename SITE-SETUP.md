# pjjournal.com — static site setup (GitHub Pages)

Short version: **yes, it's fully automated.** GitHub Pages serves a website straight from a repo. There's no "upload" step — you edit a file, commit, and push, and the live site at pjjournal.com updates on its own (usually within a minute). No WordPress, no builder, no copy-pasting HTML. And because you're already using GitHub for PJ, this lives right alongside everything else.

## What's in this bundle
- `index.html` — the landing page (Join the beta)
- `faq.html` — the basics
- `help.html` — your existing guide, with the support email updated to support@pjjournal.com
- `pj-logo.png`, `pj-logo-dark.png` — the PJ Journal logo (light / dark header)
- `pj-mark-rounded.png` — the square mark on its own
- `pj-favicon-32.png`, `pj-apple-touch-icon.png` — the little icon in the browser tab / on a phone home screen
- `pj-dragon-hero.png` — the dragon illustration on the landing page

Keep all of these in the **same folder** (the repo root) so the pages find their images.

## One thing to change first
In `index.html` and `faq.html`, the "Join the beta" buttons point to a placeholder:
`https://testflight.apple.com/join/REPLACE_WITH_YOUR_CODE`
Swap that for your real public TestFlight link (App Store Connect → your app → TestFlight → Public Link). Two spots in `index.html`, one in `faq.html`. Until then the button goes nowhere.

## One-time setup (about 15 minutes)
1. **Make a repo.** On GitHub, create a new **public** repo named `pjjournal-site` (Pages is free on public repos). Upload all the files above to the root — drag-and-drop in the browser works, or `git push` them.
2. **Add a CNAME file.** Create a file named exactly `CNAME` (no extension) at the repo root, containing one line: `pjjournal.com`. (This is what tells GitHub to serve under your domain instead of a github.io address — it's why the site shows as pjjournal.com, not GitHub.)
3. **Turn on Pages.** Repo → Settings → Pages → "Build and deployment" → Source: **Deploy from a branch** → Branch: `main`, folder: `/ (root)` → Save.
4. **Point the domain (at GoDaddy — DNS only, ignore the Airo builder).** In GoDaddy's DNS for pjjournal.com:
   - Four **A** records for the host `@`, pointing to GitHub's IPs:
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - One **CNAME** record: host `www` → value `jackmcvickar.github.io` (your GitHub username + .github.io)
   - Delete any old "parked"/forwarding records GoDaddy added.
5. **Wait + enforce HTTPS.** DNS can take a few minutes to a few hours. Once GitHub shows the domain as verified (Settings → Pages), tick **Enforce HTTPS**. Done — https://pjjournal.com is live.

## The ongoing flow (the automated part)
From then on: **edit a file → commit → push → it's live.** That's the whole loop. No builder, no re-upload.

Because CC is already working in your Git repos on the Mac, we can keep the site in that same lane: I write or update a page here, hand it to CC to commit and push to `pjjournal-site`, and GitHub Pages publishes it automatically — same "write a prompt, cc back" rhythm we use for the app. So "as we make changes, it just pushes up and it's there" is exactly how this works.

## Cloudflare Pages (the alternative, if GoDaddy DNS is painful)
Same idea, sometimes smoother: connect the GitHub repo to Cloudflare Pages, and if you move the domain's nameservers to Cloudflare once, DNS + hosting + HTTPS all live in one place and every push still auto-deploys. Either is fine — both show pjjournal.com and both are free.

## Later polish (not needed to go live)
- The help page's screenshots still load from `mcvickar.com/wp-content/...`. They work as-is (they load across domains), but eventually copy those images into the repo and update the `src` paths so pjjournal.com doesn't depend on the old site.
- The in-app "Help" link and "Report a problem" email inside PJ still point to the old mcvickar address — that's a small code change that needs to ride a build (I can write that prompt for CC separately).
