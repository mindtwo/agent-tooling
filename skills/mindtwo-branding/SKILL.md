---
name: mindtwo-branding
description: Apply the mindtwo GmbH corporate identity to any client- or team-facing deliverable — Artifacts, HTML reports, one-pagers, slide decks, PDF templates, landing pages, email templates. Activates whenever a page or document is being designed or styled and it represents mindtwo, or when the user mentions CI, corporate identity, branding, brand colours, mindtwo Red, or Roobert. Do not activate for product UI inside a client application (those follow the client's own design system).
---

# mindtwo Corporate Identity

The canonical implementation lives in the `mindtwo` repo (the agency website). When anything here is
ambiguous, that repo wins — it is the source of truth, not this file.

| Asset | Path (relative to your local checkout of the `mindtwo` repo) |
|---|---|
| Markdown→PDF reference template | `resources/views/global/pdf/markdown-document.blade.php` |
| PDF chrome (top bar, footer, logo) | `app/Domains/Document/Actions/StreamMarkdownDocumentPdfAction.php` |
| Brand tokens | `resources/assets/css/mindtwo.css` (`@theme` block) |
| Written style spec | `resources/prompts/blog-featured-image.txt` + `blog-featured-image-styles/*.txt` |
| Roobert font family | `resources/assets/fonts/roobert/` |
| Logos (SVG) | `resources/assets/images/mindtwo/logo*.svg` |
| Logos (PNG/EPS, all colour spaces) | `public/downloads/logos/{rgb,cmyk,pantone}/` |

## The three brand colours

```
mindtwo Red    #DE0639   accent only — never a dominant surface
mindtwo Black  #121212   deliberately NOT pure black
mindtwo White  #FFFFFF
```

Red variants in production: `#9C182E` (dark), `#FF6470` (light).

**The 60 / 30 / 10 rule is binding.** 60% white, 30% black, 10% red. Red is for highlights: an
eyebrow, a rule, a link, a single emphasised figure. A red hero band or a red-filled card breaks the
CI. The one documented exception is the "Red Stage" poster style for marketing imagery, which is not
a document style.

Everything else is the Tailwind grey ramp, already established in the PDF template — do not invent
new neutrals:

```
#111827 headings      #374151 body       #6B7280 muted
#9CA3AF faint/meta    #D1D5DB rule-strong #E5E7EB rule
#F3F4F6 surface-2     #F9FAFB surface
```

`references/tokens.css` has all of this as a ready-to-paste `:root` block with light and dark
definitions. Start from that file rather than retyping values.

## Typeface

**Roobert** across the board — Light 300 through Heavy 900, with italics. It is a geometric
sans: monolinear strokes, high x-height, wide proportions, double-storey g, round dots on i/j.
Headings sit at 600 (SemiBold) with negative tracking, never at 700+ unless the layout genuinely
needs the weight.

`RoobertVF.woff2` (~90 KB) carries the whole weight axis in one file and is the right choice for a
web deliverable. Static weights are in the same directory if a variable font is not viable.

⚠️ **Roobert is a commercial licence from Displaay Type Foundry.** Inlining it into a page that
gets shared by public link is a licensing decision, not a technical one — confirm the licence
covers it before shipping externally. For anything public where that is unresolved, use the
fallback stack in `tokens.css`, which is chosen to sit close to Roobert's proportions.

Monospace, where code or figures appear: `ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`.

## Document patterns to reuse

These come straight from the PDF template and are what makes a deliverable read as mindtwo:

- **Eyebrow** — uppercase, ~0.75rem, `letter-spacing: .1em`, weight 600, red, with a `3px` red
  left border and ~8px padding. This is the primary red moment on most pages.
- **Title** — weight 600, `letter-spacing: -.03em`, `line-height: 1.15`, in `#000` on light.
- **h2** — weight 600, `-.02em`, with a `1px solid #E5E7EB` bottom rule and padding beneath.
- **Links** — red, `text-decoration: none`.
- **Blockquote** — `3px` red left border on `#F9FAFB`, italic.
- **Tables** — `#F3F4F6` header cells, `2px solid #D1D5DB` under the head, `1px solid #E5E7EB`
  between rows, no border on the last row, left-aligned headers, top-aligned cells.
- **Code** — inline on `#F3F4F6`; blocks on `#1A1A1A` with `#E5E7EB` text.
- **Callouts** — four semantic variants, `3px` left border + tinted background:
  note `#3B82F6` / `#EFF6FF` / title `#1D4ED8` · tip `#10B981` / `#ECFDF5` / `#047857` ·
  caution `#F59E0B` / `#FFFBEB` / `#B45309` · danger `#EF4444` / `#FEF2F2` / `#B91C1C`.
- **Page chrome** (print/PDF only) — a 4.5pt red bar across the top edge, and a footer with a rule
  above it, the horizontal logo left, "Seite X von Y" right in `#9CA3AF`.

## Form language

From the written style spec, and it applies to layout and diagrams as much as to imagery:

- Flat and geometric. Sharp edges, clear planar division, generous whitespace.
- Depth only through restrained, flat shadows used to separate layers — one light source, one
  direction, one softness. Never plastic or material-realistic.
- Rounded and organic shapes must not carry the composition. Corner radii stay small (0–4px);
  `rounded-lg` everywhere is off-brand.
- Perspective, where used, resolves to a single consistent vanishing point.

Explicitly ruled out: Corporate Memphis, humanoid illustration, glow and neon, rainbow gradients,
glossy 3D, AI-stock look, third-party logos.

## Applying this to an Artifact

`artifact-design` already defers to an existing design system — this file is that system, so its
tokens and patterns override the generic guidance there. What still applies from `artifact-design`:
build both themes at token level, give `body` an explicit background, keep wide content in its own
`overflow-x: auto` container.

The Artifact CSP blocks every external host, so fonts and the logo must be embedded. Do not paste
base64 by hand — write the page with `__ROOBERT_VF__` and `__LOGO_SVG__` placeholders, then run:

```bash
python3 ~/.claude/skills/mindtwo-branding/references/inline-assets.py <path-to-html>
```

It substitutes the font data URI and the inline logo in place and reports the resulting size.
The script looks for the `mindtwo` repo in common project directories; set `MINDTWO_REPO` to its
path if it lives elsewhere. The `@font-face` block to pair with the placeholder is in `tokens.css`.

For a dark deliverable, the ground is `#121212` — mindtwo Black, not a neutral near-black — and the
accent lifts to `#FF6470` so it holds contrast. Both are CI values; do not invent a lighter red.
