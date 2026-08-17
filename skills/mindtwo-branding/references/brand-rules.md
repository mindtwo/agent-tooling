# mindtwo brand rules

Extracted from `mindtwo_Brand-Guide-DE_v1_FINAL_200426.pdf` (31 pages). Page numbers in
parentheses. Act only on what is written here or in SKILL.md; if both are silent, choose
the most conservative option and say so. Never invent a brand rule.

## Voice & Tone

- Address the reader as *Sie* in client-facing copy. Write "Software, die Ihr Business
  vorantreibt", not "Software, die dein Business vorantreibt" (pp. 2, 20, 22 — every
  client-facing example in the guide uses Sie).
- Use *Du* only in employer-branding content (careers, benefits). Write "Dein
  Arbeitsumfeld", "Bleibe fit und flexibel" as the careers examples do (pp. 22, 25).
  Do not mix Sie and Du within one deliverable.
- Write the tagline exactly as "Build. Accelerate. Scale." — three words, a period after
  each. Do not write "Build, Accelerate, Scale", do not translate it (pp. 2, 22, 27).

Note: the guide's table of contents announces a "Kommunikation" chapter, but this version
contains none — the Sie/Du rules above are derived from the guide's own copy examples.
See Open questions.

## Wording & Terminology

- Write the brand name lowercase: "mindtwo". Never "Mindtwo", "MindTwo", or "MINDTWO" —
  the first letter of the wordmark always stays lowercase (p. 12), and every occurrence in
  the guide's running text is lowercase (pp. 2, 4, 30).
- Name the brand colours "mindtwo Red", "mindtwo Black", "mindtwo White" — brand name
  lowercase, colour word capitalised (p. 14).
- Use the positioning line verbatim when introducing the agency: "Digitalagentur für
  Software, die Ihr Business vorantreibt." (pp. 2, 22).
- Use the extended-logo tagline verbatim: "Digitalagentur im Herzen von Bonn" (p. 11).
- Write CTAs short and goal-first, as in the guide's examples: "Jetzt bewerben",
  "Kontakt" (p. 22), "Mehr zu Benefits", "Zu Events", "Mehr dazu", "Zum Jobticket"
  (p. 25). Do not write long descriptive CTAs ("Klicken Sie hier, um mehr über unsere
  Benefits zu erfahren").

## Typography

- Set all text in Roobert, a monolinear geometric sans serif (p. 18).
- Use only the documented cuts: Light, Regular, Semibold, Bold (p. 19).
- Do not set body text or longer passages in Bold; Bold is not for Fließtext (p. 20).
- Keep letter-spacing neutral — neither too tight nor too wide (p. 20).
- Keep line-height balanced — neither too small nor too large (p. 20).
- Set text left-aligned with a ragged right edge. Do not use justified text (Blocksatz);
  do not use right-aligned ragged text (p. 20).
- Do not set headlines or longer texts in all caps (Versalien) (p. 20).
- When Roobert is technically unavailable — e-mails, newsletters, Google Docs, third-party
  tools that cannot load webfonts — use Arial as the substitute (p. 21). The fallback
  stack in `tokens.css` implements this.

## Colour

- mindtwo Red: HEX `#DE0639` · RGB 222/6/57 · CMYK 00/97/74/13 ·
  okLCH 0.5709/0.2275/20.4 · PMS 1925 C (p. 14).
- mindtwo Black: HEX `#121212` · RGB 18/18/18 · CMYK 60/40/40/100 (p. 14).
- mindtwo White: HEX `#FFFFFF` · RGB 255/255/255 · CMYK 0/0/0/0 (p. 14).
- Distribute colour by the 60:30:10 rule. Light scheme: 60% White / 30% Black / 10% Red.
  Dark scheme: 60% Black / 30% White / 10% Red (p. 15).
- Treat 60:30:10 as a rough visual guideline, not an exact ratio — the guide states
  flexibility is intended (p. 15). Red remains the 10% accent in both schemes.
- Derive red tints and shades only by lightening/darkening `#DE0639` or by reducing its
  opacity over white or black (p. 16). Do not introduce any other red; the guide fixes no
  hex values for the variants — its scale is explicitly exemplary ("beispielhaft") (p. 16).

## Imagery & Logo

### Logo variants and usage

- Use the primary logo (horizontal) by default, whenever space allows (p. 7).
- Use the secondary logo (vertical) when space is limited or the primary logo does not
  work well (p. 7).
- Use the standalone wordmark for limited space or reduced, minimalist applications —
  e.g. clothing, stationery (p. 11).
- Use the standalone symbol exclusively in small formats where a full logo does not fit
  (p. 11).
- Use the logo with the tagline "Digitalagentur im Herzen von Bonn" when introducing the
  brand or adding context — e.g. brochures, social media (p. 11).

### Clear space and minimum sizes

- Keep clear space on all sides of the logo at least the width of the wordmark's letter
  "m". Never undercut it (p. 8).
- Respect the minimum heights (p. 8):
  - Primary logo (horizontal): 50 px digital / 5 mm print.
  - Secondary logo (vertical): 78 px digital / 8 mm print.
  - Symbol alone: 32 px digital / 5 mm print.

### Colour variants

- On black grounds: white wordmark ("mind" white, "two" red) with the red symbol (p. 9).
- On white grounds: black-and-red wordmark ("mind" black, "two" red) with the red symbol
  (p. 9).
- On red grounds: the all-white logo — symbol and wordmark entirely white (p. 9).
- Use the monochrome black or white variants where a colour version cannot be used, e.g.
  reduced or low-contrast environments (p. 10).

### Logo don'ts

- Do not rotate or tilt the logo, or place it at an angle (p. 12).
- Do not move, mirror, or re-orient the symbol relative to the wordmark (p. 12).
- Do not change the size ratio between symbol and wordmark (p. 12).
- Do not distort the logo; keep its proportions (p. 12).
- Do not change the wordmark's typeface (p. 12).
- Do not capitalise the wordmark's first letter — never "Mindtwo" in the logo (p. 12).

### Icons

- Use only the approved duotone icon set (Figma / Drive) (p. 24).
- Do not use the old icon version with the red hexagon (p. 25).
- Do not use unapproved icons (p. 25).
- Size icons between one and three lines of body text in height — no larger, no smaller
  (p. 25).
- Use icons to support a statement or convey context; do not use them decoratively or in
  excess (p. 25). System icons needed for basic UI function (e.g. carets on dropdowns)
  are exempt (p. 25).

### Graphics and form language

- Build background elements from calm, geometric planes with clean edges and clear
  division of area (p. 27).
- Keep depth minimal: subtle shading only (p. 27). Show dimensionality through restrained
  shadows, never through materiality, textures, or strong realistic shading (p. 28).
- Large colour fields with a soft, flowing gradient are permitted (p. 27); keep gradients
  subtle (p. 28).
- Use 2D or flat-3D graphics with clear lines, defined planes, and a reduced palette;
  design each piece in either a light or a dark style, not both (p. 28).
- Use the historic key visual sparingly (p. 27).

### Photography

- Use bright, well-lit images with balanced, not-too-strong contrasts and slightly
  reduced, harmonious colours (p. 30).
- Show authentic, inviting, un-staged situations with tidy, calm backgrounds (p. 30).

## Forbidden

- Shapes with rounded edges, flowing lines, or organic structures (p. 29).
- Reality-detached or obviously AI-generated graphics (p. 29).
- Generic, abstract graphics without a clear motif and relation to the topic (p. 29).
- Aggressive colour gradients and strong lighting effects (p. 29).
- Plastic-looking 3D graphics with realistic shading (p. 29).
- Illustrations or humanoid figures in comic style (Corporate Memphis) (p. 29).
- Justified text (Blocksatz) (p. 20).
- Right-aligned ragged text (p. 20).
- All-caps headlines or longer all-caps texts (p. 20).
- Roobert Bold for body text or longer passages (p. 20).
- The old red-hexagon icon style; unapproved icons; purely decorative icons (p. 25).
- In photos: unnatural effects, stickers, or image manipulation; under- or overexposed
  or low-quality shots; unrealistic or heavily edited photos; staged or overly serious
  scenes; busy or untidy motifs and backgrounds; overly abstract shots without a clear
  motif or topical relation (p. 31).

## Open questions

- The table of contents (p. 4) lists chapters "Kommunikation", "Präsentation", and
  "Social Media", but this version of the PDF contains no such pages. There is therefore
  no explicit rule on address form (Sie/Du), tone, forbidden words, or sentence structure;
  the Voice & Tone rules above are inferred from the guide's own copy examples only.
- The okLCH values for mindtwo Black (0/0/0) and mindtwo White (1/0/0) on p. 14 describe
  pure black/white, not `#121212`/`#FFFFFF` — they look like placeholders. Treat the hex
  values as authoritative.
- The guide prints the colour model as "CYMK" (pp. 14, 16); assumed to mean CMYK in the
  labelled order.
- The red-variant scale (p. 16) defines no hex values. The production variants
  `#9C182E` / `#FF6470` referenced in SKILL.md come from the mindtwo repo, not from this
  PDF.
- SKILL.md calls the 60/30/10 rule "binding", while the guide explicitly calls it a rough
  guideline that need not be met exactly (p. 15).
