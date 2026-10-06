---
name: mindtwo-branding
description: Apply the mindtwo GmbH corporate identity to any client- or team-facing deliverable — Artifacts, HTML reports, one-pagers, slide decks, PDF templates, landing pages, email templates. Activates whenever a page or document is being designed or styled and it represents mindtwo, or when the user mentions CI, corporate identity, branding, brand colours, mindtwo Red, or Roobert. Do not activate for product UI inside a client application (those follow the client's own design system).
---

# mindtwo Corporate Identity

Sources rank in this order — a higher source wins whenever two disagree:

1. **The official Brand Guide** (`mindtwo_Brand-Guide-DE_v1_FINAL_200426.pdf`), extracted with
   page references in `references/brand-rules.md`.
2. **Design-team decisions** recorded in this file (see "Design-team decisions"). Where they
   deviate from the guide, they do so deliberately.
3. **The `mindtwo` repo** (the agency website) — the implementation that fonts, logos, and
   template metrics are taken from. It is the source for assets, not for rules.

| Asset | Path (relative to your local checkout of the `mindtwo` repo) |
|---|---|
| Markdown→PDF reference template | `resources/views/global/pdf/markdown-document.blade.php` |
| PDF chrome (top bar, footer, logo) | `app/Domains/Document/Actions/StreamMarkdownDocumentPdfAction.php` |
| Brand tokens | `resources/assets/css/mindtwo.css` (`@theme` block) |
| Image style spec (blog featured images) | `resources/prompts/blog-featured-image.txt` + `blog-featured-image-styles/*.txt` |
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
- Distribute colour by area roughly 60% #FFFFFF / 30% #121212 / 10% red #DE0639 in the light
  scheme; the dark scheme swaps the first two (p. 15). The ratio is a guideline, not an exact
  measure — but red stays the smallest share.
- Red surfaces are allowed: buttons, a red section or band, a highlighted card. What matters
  is the overall proportion of red area to black and white, not whether red appears as a fill.
- The ground is #FFFFFF (light) or #121212 (dark) — never pure #000 (neither as a
  ground nor as text), never an invented near-black.

Type
- Roobert only, in the four documented cuts: Light 300 / Regular 400 / Semibold 600 /
  Bold 700 (p. 19). Headings at 600.
- Never: bold body text, justified text (Blocksatz), right-aligned text, all-caps
  headlines or paragraphs (p. 20). Body is left-aligned, ragged right, neutral
  letter-spacing.

Logo
- Never recolour, rotate, distort, restyle, or re-proportion the logo; the wordmark's
  first letter stays lowercase (p. 12). Clear space on every side ≥ the width of the
  wordmark's "m"; minimum heights: horizontal 50px / vertical 78px / symbol 32px (p. 8).

Geometry & imagery
- Corner radius 0 — sharp corners everywhere. The only exception: pill-shaped tags may be
  fully rounded. No rounded shapes, flowing lines, or organic structures otherwise (p. 29).
- Flat, geometric, sharp — no glossy or plastic 3D, no Corporate Memphis, no neon or
  aggressive gradients (pp. 27–29).

For extended palette, logo variants, or anything not covered above, read
references/brand-rules.md before deciding. If both are silent, choose the most
conservative option and say so. Never invent a brand rule.

## Design-team decisions

Settled by the design team where the Brand Guide is silent or deliberately overridden:

| Topic | Decision |
|---|---|
| Heading colour | Titles, headings, and anything else that would be black use mindtwo Black `#121212` — never pure `#000`. On `#121212` they are `#FFFFFF`. |
| Neutrals | The official Tailwind CSS v4 grey ramp — the same defaults the `mindtwo` website uses (Tailwind 4.3). Not the older v3 values still hard-coded in the PDF template. |
| Dark-theme surfaces | `#1A1A1A` / `#232323` surfaces and `#2A2A2A` / `#3A3A3A` rules on `#121212`. Cards and code blocks share `#232323` so they stand off the ground. |
| Callouts | Four semantic variants (note, tip, caution, danger) in Tailwind v4 blue, emerald, amber, red. |
| Corner radius | `0`. Pill tags are the only fully rounded element. |
| 60 / 30 / 10 | A guideline for the share of area, as in the guide. Red fills (buttons, sections) are fine within that share. |
| Red Stage | Kept as a documented style for marketing imagery — see below. |

## The three brand colours

```
mindtwo Red    #DE0639   the 10% — accents, buttons, a red section
mindtwo Black  #121212   deliberately NOT pure black
mindtwo White  #FFFFFF
```

Red variants from the website (`mindtwo.css`, `--color-primary-dark` / `-light`): `#9C182E` (dark),
`#FF6470` (light). They follow the guide's derivation method (p. 16), which fixes no hex values
itself.

**60 / 30 / 10 by area.** Roughly 60% white, 30% black, 10% red. Red can be a highlight (an eyebrow,
a rule, a link, an emphasised figure) or a surface (a button, a red section, a highlighted card) —
keep the total red area near its share. A page that reads as predominantly red breaks the CI.

**Red Stage** is the documented poster style for marketing imagery (from the website's
blog-featured-image styles): a full red ground carrying a few precisely placed white and black
elements, editorial and maximally reduced. Use it for imagery and poster-like visuals, not as the
ground of a document or report.

Neutrals are the official Tailwind CSS v4 grey ramp — do not invent new ones:

```
#121212 headings (light)   #364153 body (gray-700)       #6A7282 muted (gray-500)
#99A1AF faint (gray-400)   #D1D5DC rule-strong (gray-300) #E5E7EB rule (gray-200)
#F3F4F6 surface-2 (gray-100) #F9FAFB surface (gray-50)
```

The hex values are the sRGB equivalents of Tailwind v4's `oklch()` definitions.

`references/tokens.css` has all of this as a ready-to-paste `:root` block with light and dark
definitions. Start from that file rather than retyping values.

## Typeface

**Roobert** in its four documented cuts — Light 300, Regular 400, Semibold 600, Bold 700. It is a
geometric sans: monolinear strokes, high x-height, wide proportions, double-storey g, round dots
on i/j. Headings sit at 600 (Semibold) with negative tracking, never at 700 unless the layout
genuinely needs the weight.

`RoobertVF.woff2` (~90 KB) carries the weight axis in one file and is the right choice for a web
deliverable. The file technically spans 300–900 and ships italics; use only the four documented
weights. Static weights are in the same directory if a variable font is not viable.

⚠️ **Roobert is a commercial licence from Displaay Type Foundry.** Inlining it into a page that
gets shared by public link is a licensing decision, not a technical one — confirm the licence
covers it before shipping externally. For anything public where that is unresolved, use the
Arial fallback stack in `tokens.css` — Arial is the substitute the Brand Guide mandates (p. 21).

Monospace, where code or figures appear: `ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`.

## Document patterns to reuse

These come from the PDF template, with colours updated to the decisions above:

- **Eyebrow** — uppercase, ~0.75rem, `letter-spacing: .1em`, weight 600, red, with a `3px` red
  left border and ~8px padding. This is the primary red moment on most pages.
- **Title** — weight 600, `letter-spacing: -.03em`, `line-height: 1.15`, in `#121212` on light.
- **h2** — weight 600, `-.02em`, `#121212` on light, with a `1px solid #E5E7EB` bottom rule and padding
  beneath.
- **Links** — red, `text-decoration: none`.
- **Buttons** — red fill `#DE0639`, white text, radius 0.
- **Tags** — pill-shaped (fully rounded), the one exception to radius 0.
- **Blockquote** — `3px` red left border on `#F9FAFB`, italic.
- **Tables** — `#F3F4F6` header cells, `2px solid #D1D5DC` under the head, `1px solid #E5E7EB`
  between rows, no border on the last row, left-aligned headers, top-aligned cells.
- **Code** — inline on `#F3F4F6`; blocks on `#1A1A1A` with `#E5E7EB` text (dark theme: `#232323`).
- **Cards** — `#F9FAFB` fill, `1px` rule border, radius 0, flat shadow; in the dark theme `#232323`,
  the same surface as code blocks. Use them to set off an element, not on every block.
- **Callouts** — four semantic variants, `3px` left border + tinted background (Tailwind v4,
  border 500 / background 50 / title 700):
  note `#2B7FFF` / `#EFF6FF` / `#1447E6` · tip `#00BC7D` / `#ECFDF5` / `#007A55` ·
  caution `#FE9A00` / `#FFFBEB` / `#BB4D00` · danger `#FB2C36` / `#FEF2F2` / `#C10007`.
- **Page chrome** (print/PDF only) — a 4.5pt red bar across the top edge, and a footer with a rule
  above it, the horizontal logo left, "Seite X von Y" right in `#99A1AF`.

## Form language

Applies to layout and diagrams as much as to imagery:

- Flat and geometric. Sharp edges, clear planar division, generous whitespace.
- Depth only through restrained, flat shadows used to separate layers — one light source, one
  direction, one softness. Never plastic or material-realistic.
- No rounded or organic shapes, no flowing lines (p. 29). Corner radius is 0; only pill tags are
  fully rounded.
- Light isometric or perspective depth is allowed (p. 28). Where perspective is used, it resolves
  to one consistent vanishing point.

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
   size. The script looks for the `mindtwo` repo in common project directories (including
   `~/Sites/mindtwo` for Herd); set `MINDTWO_REPO` to its path if it lives elsewhere. The
   `@font-face` block to pair with the placeholder is in `tokens.css`.
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
- [ ] Red is the smallest share of area (~10%); red buttons or sections are fine, a predominantly red page is not (Red Stage imagery excepted)
- [ ] Ground is #FFFFFF or #121212; headings and black text #121212, never #000; no neutrals outside the Tailwind v4 grey ramp and the documented dark surfaces
- [ ] All text is Roobert (or the sanctioned fallback) in the four documented cuts; headings at 600; no bold body text
- [ ] No justified, right-aligned, or all-caps text anywhere
- [ ] Logo unmodified; clear space ≥ the wordmark's "m"; minimum height respected (50/78/32px)
- [ ] Corner radius 0 everywhere except pill tags; no forbidden imagery styles (brand-rules.md "Forbidden")
- [ ] For edits: violations fixed only in touched passages; the rest listed, not changed
