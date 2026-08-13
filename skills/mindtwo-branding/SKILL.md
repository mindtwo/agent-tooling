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

## Brand constraints (non-negotiable)

Wording
- Write the brand name lowercase everywhere: mindtwo — never Mindtwo, MindTwo, or
  MINDTWO, even at the start of a sentence or in a heading (Brand Guide p. 12).
- German client-facing copy addresses the reader as Sie. Du/Dein is reserved for
  employer-branding content (careers, benefits). Never mix the two in one deliverable
  (pp. 2, 20, 22).
- The tagline is exactly "Build. Accelerate. Scale." — a period after each word, never
  commas, never translated (pp. 2, 22, 27).

Colour
- Red #DE0639 is an accent, ~10% of any layout. No red hero bands, red-filled cards, or
  red page grounds. Light scheme: 60% #FFFFFF / 30% #121212 / 10% red; the dark scheme
  swaps the first two (p. 15).
- The ground is #FFFFFF (light) or #121212 (dark) — never pure #000, never an invented
  near-black.

Type
- Roobert only; documented cuts are Light / Regular / Semibold / Bold (p. 19). Headings
  at 600.
- Never: bold body text, justified text (Blocksatz), right-aligned text, all-caps
  headlines or paragraphs (p. 20). Body is left-aligned, ragged right, neutral
  letter-spacing.

Logo
- Never recolour, rotate, distort, restyle, or re-proportion the logo; the wordmark's
  first letter stays lowercase (p. 12). Clear space on every side ≥ the width of the
  wordmark's "m"; minimum heights: horizontal 50px / vertical 78px / symbol 32px (p. 8).

Geometry & imagery
- Corner radii 0–4px. Flat, geometric, sharp — no organic blobs, no glossy or plastic
  3D, no Corporate Memphis, no neon or aggressive gradients (pp. 27–29).

For extended palette, logo variants, or anything not covered above, read
references/brand-rules.md before deciding. If both are silent, choose the most
conservative option and say so. Never invent a brand rule.

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
Arial fallback stack in `tokens.css` — Arial is the substitute the Brand Guide mandates (p. 21).

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

Work in this order:

1. **Draft** — build the page from `references/tokens.css`. The Artifact CSP blocks every
   external host, so fonts and the logo must be embedded; do not paste base64 by hand —
   write `__ROOBERT_VF__` and `__LOGO_SVG__` placeholders instead.
2. **Brand check** — walk the draft through the "Before finishing" list below. For
   anything the list does not settle (logo variant choice, red tints, icon sizing,
   photography), consult `references/brand-rules.md`. Fix every failure before moving on.
3. **Inline assets** — run:

   ```bash
   python3 ~/.claude/skills/mindtwo-branding/references/inline-assets.py <path-to-html>
   ```

   It substitutes the font data URI and the inline logo in place and reports the resulting
   size. The script looks for the `mindtwo` repo in common project directories; set
   `MINDTWO_REPO` to its path if it lives elsewhere. The `@font-face` block to pair with
   the placeholder is in `tokens.css`.
4. **Deliver** — hand over or publish only after steps 2 and 3 have passed.

For a dark deliverable, the ground is `#121212` — mindtwo Black, not a neutral near-black — and the
accent lifts to `#FF6470` so it holds contrast. Both are CI values; do not invent a lighter red.

## Editing existing content

When editing an existing deliverable, fix brand violations only in the passages the edit
actually touches. Violations noticed elsewhere are reported to the user — location plus
the rule broken — but left unchanged unless the user asks. A brand pass over the whole
document is its own task, never a side effect of an edit.

## Before finishing

- [ ] Brand name is lowercase "mindtwo" in every occurrence, headings and sentence starts included
- [ ] Client-facing copy uses Sie; Du appears only in employer-branding content; never mixed
- [ ] Tagline, if present, reads exactly "Build. Accelerate. Scale."
- [ ] Red is accent-only (~10%) — no red surface larger than an eyebrow, rule, link, or button
- [ ] Ground is #FFFFFF or #121212; no #000 grounds, no neutrals outside the documented grey ramp
- [ ] All text is Roobert (or the sanctioned fallback); headings at 600; no bold body text
- [ ] No justified, right-aligned, or all-caps text anywhere
- [ ] Logo unmodified; clear space ≥ the wordmark's "m"; minimum height respected (50/78/32px)
- [ ] Corner radii ≤ 4px; no forbidden imagery styles (brand-rules.md "Forbidden")
- [ ] For edits: violations fixed only in touched passages; the rest listed, not changed
