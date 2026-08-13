#!/usr/bin/env python3
"""Inline mindtwo brand assets into an HTML file for Artifact publishing.

The Artifact CSP blocks every external host, so the Roobert font and the logo
have to be embedded. Emitting ~120 KB of base64 by hand is wasteful and
error-prone, so write the page with placeholders and let this substitute them.

    python3 inline-assets.py path/to/page.html

Placeholders it replaces, wherever they appear in the file:

    __ROOBERT_VF__      variable-font data URI (woff2, weight axis 300-900)
    __ROOBERT_REGULAR__ static 400 data URI, if a variable font is not viable
    __ROOBERT_SEMIBOLD__ static 600 data URI
    __LOGO_SVG__        horizontal logo, wordmark switched to currentColor so it
                        works on both themes; the mark stays mindtwo Red
    __LOGO_SVG_BRAND__  horizontal logo verbatim (white wordmark, red mark) —
                        for dark grounds only

Running it twice is safe: placeholders are gone after the first pass, so the
second is a no-op. Substitution happens in place.
"""

import base64
import os
import pathlib
import sys


def find_brand_repo() -> pathlib.Path:
    """Locate the mindtwo repo checkout. Set MINDTWO_REPO to override."""
    if env := os.environ.get("MINDTWO_REPO"):
        return pathlib.Path(env).expanduser()
    home = pathlib.Path.home()
    candidates = [
        home / "Development/Projects/mindtwo",
        home / "code/mindtwo",
        home / "Projects/mindtwo",
    ]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate
    return candidates[0]


BRAND_REPO = find_brand_repo()
FONT_DIR = BRAND_REPO / "resources/assets/fonts/roobert"
LOGO = BRAND_REPO / "resources/assets/images/mindtwo/logo-horizontal.svg"

FONTS = {
    "__ROOBERT_VF__": FONT_DIR / "RoobertVF.woff2",
    "__ROOBERT_REGULAR__": FONT_DIR / "Roobert-Regular.woff2",
    "__ROOBERT_SEMIBOLD__": FONT_DIR / "Roobert-SemiBold.woff2",
}


def font_data_uri(path: pathlib.Path) -> str:
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:font/woff2;base64,{encoded}"


def logo_svg(theme_aware: bool) -> str:
    svg = LOGO.read_text(encoding="utf-8").strip()
    if theme_aware:
        # The wordmark paths are filled #fff; the mark is mindtwo Red and stays.
        svg = svg.replace('fill="#fff"', 'fill="currentColor"')
    return svg


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2

    target = pathlib.Path(sys.argv[1])
    if not target.is_file():
        print(f"error: {target} does not exist")
        return 1

    missing = [p for p in (LOGO, *FONTS.values()) if not p.is_file()]
    if missing:
        print(
            "error: brand assets not found — is the mindtwo repo checked out?"
            " (set MINDTWO_REPO to its path if it lives elsewhere)"
        )
        for path in missing:
            print(f"  {path}")
        return 1

    html = target.read_text(encoding="utf-8")
    before = len(html)
    applied = []

    for token, path in FONTS.items():
        if token in html:
            html = html.replace(token, font_data_uri(path))
            applied.append(f"{token} → {path.name} ({path.stat().st_size / 1024:.0f} KB raw)")

    for token, theme_aware in (("__LOGO_SVG__", True), ("__LOGO_SVG_BRAND__", False)):
        if token in html:
            html = html.replace(token, logo_svg(theme_aware))
            applied.append(f"{token} → {LOGO.name}")

    if not applied:
        print("no placeholders found — nothing to do")
        return 0

    target.write_text(html, encoding="utf-8")

    for line in applied:
        print(f"  {line}")
    print(f"\n{target.name}: {before / 1024:.0f} KB → {len(html) / 1024:.0f} KB")
    print("Artifact limit is 16 MB, so this is fine unless you embedded images too.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
