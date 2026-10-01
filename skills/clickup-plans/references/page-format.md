# Page format — seed

**This file is not the contract.** The contract is the live conventions page in the bound
ClickUp doc (`conventions_page_id`). Read that before rendering anything.

This file exists for one purpose: `setup` copies the block below into a new conventions page
when a project has none. That resolves the chicken-and-egg without leaving a second authority
in place. Once the page exists, this file is dead weight — if the two ever disagree, the live
page wins.

The Claude desktop chat app ships no seed at all. If the page is missing there, it stops
and directs the user to run `setup` from Claude Code.

**The seed is a starting point, not a standard.** It is written in German because most of our
docs are, and it splits the two pages by audience and language. A project is free to use one
language throughout, rename every section, or restructure the header — that is what editing
the live page is for. Translate the seed at `setup` time if the project's doc is
English-speaking; do not translate it here.

---

## SEED CONTENT — copy everything below this line, adapting language and names to the project

# Konventionen für Plan-Seiten

Diese Seite definiert das Format aller Plan-Seiten in diesem Dokument. Sie wird von Claude
Code und Claude Desktop vor jedem Schreibvorgang gelesen. **Änderungen an dieser Seite
ändern das Format** — es muss kein Code angepasst werden.

## Seitenstruktur

Ein Plan besteht aus zwei Seiten:

```
🟡 ⟨Plantitel⟩                         DE · Product Owner, Stakeholder
  └─ Technical Specification           EN · Entwickler:innen
```

Die Elternseite ist die produktseitige Übersicht, die Kindseite die technische
Spezifikation. Die Elternseite kann ohne Kindseite existieren (z. B. wenn sie in Claude
Desktop ohne Codebase-Zugriff entstanden ist).

## Status

Drei Zustände. Der Status steht im Header der Elternseite **und** als Emoji im Seitennamen,
damit er in der Seitenleiste erkennbar ist, ohne die Seite zu öffnen.

| Emoji | Status (Elternseite) | Status (Kindseite) | Gesetzt von |
| --- | --- | --- | --- |
| 🟡 | Review ausstehend | Draft for review | `publish` |
| 🟢 | Freigegeben | Approved | `review` |
| ✅ | Umgesetzt | Implemented | `implement` |

Seitenname und Header werden immer gemeinsam geändert. Die Elternseite entscheidet über
den Status; die Kindseite spiegelt ihn im selben Schreibvorgang.

## Elternseite (Deutsch)

Header als fette Schlüssel-Wert-Zeilen, **keine Tabelle**:

```markdown
**Status:** 🟡 Review ausstehend
**Zielgruppe:** Product Owner, Stakeholder
**Repositories:** app-backend, app-frontend
**Ticket:** [CU-5678](https://app.clickup.com/t/5678)
**Design:** — _(Link folgt)_
**PRs:** —
**Aktualisiert:** 2026-08-11 · ⟨Name⟩
```

### `Ticket`-Zeile

Verweist auf das Ticket, aus dem der Plan entstanden ist — sofern es eines gibt. Gibt es
keines, entfällt die Zeile ganz.

Beim Veröffentlichen wird umgekehrt **ein** Kommentar am Ticket hinterlassen, der auf die
Plan-Seite verweist. Wer im Ticket arbeitet, findet die Spezifikation dadurch ohne Nachfrage.
**Es wird nie ein neues Ticket angelegt** — verlinkt wird nur, was ohnehin existiert.

`Repositories` listet **alle** Repositories, die der Plan berührt — Backend und Frontend
gehören zum selben Plan und zur selben Seite. Wird nur eines genannt, ist die Hälfte der
Arbeit unsichtbar. `—`, solange der Plan noch keinem Repository zugeordnet ist (z. B. bei
einem Plan aus Claude Desktop).

Die Namen sind die Anzeigenamen aus der Projektbindung (`.claude/clickup-plans.json`), nicht
Verzeichnisnamen.

Abschnitte in dieser Reihenfolge:

| Abschnitt | Inhalt |
| --- | --- |
| `Worum geht's?` | Fachliche Einordnung in einfacher Sprache, inkl. Begründung |
| `Aktueller Stand` | Was das System heute schon kann |
| `Zielsetzung` | Was mit diesem Plan erreicht werden soll |
| `Umfang & Pakete` | Eigenständig auslieferbare Pakete mit Aufwandsgröße |
| `Bewusste Nicht-Ziele` | Tabelle `Nicht-Ziel` / `Begründung` |
| `Aufwandsübersicht` | Tabelle `Paket` / `Aufwand` / `Hängt ab von` |
| `Offene Fragen ans Produkt` | Fragen, die der Plan selbst aufwirft |
| `Feedback` | Rückmeldungen der Kolleg:innen (siehe unten) |

### Aufwandsgrößen

Immer mit ausgeschriebenen Personentagen, damit die Größe ohne Rückfrage lesbar ist:

* **S (klein):** bis zu 2 Personentage
* **M (mittel):** 3–7 Personentage
* **L (groß):** über eine Woche

Jedes Paket wird als **eigenständig auslieferbar** gekennzeichnet oder seine Abhängigkeit
wird explizit genannt.

### `Bewusste Nicht-Ziele`

Der wichtigste Abschnitt der Seite. Hier werden Scope-Diskussionen einmal entschieden und
festgehalten, statt sie in jedem Meeting neu zu führen. Zwei Spalten, jede Zeile mit
Begründung — nie nur eine Aufzählung.

### `Design`-Zeile

Wird **nur** ausgegeben, wenn der Plan Frontend berührt. Andernfalls entfällt die Zeile
ganz — kein Platzhalter ohne Zweck.

Zulässig ist jede Design-Quelle: Figma, ein claude.ai/design-Projekt oder ein
veröffentlichtes Artifact.

```markdown
**Design:** [Mockup](https://…)
**Design:** — _(Link folgt)_
```

### `PRs`-Zeile

Pull Requests werden als Markdown-Links gesammelt und **angehängt, nie ersetzt** — ein Plan
kann über mehrere PRs und mehrere Repositories ausgeliefert werden.

Jeder Link wird mit seinem Repository beschriftet. Ohne Beschriftung ist die Liste nicht
mehr lesbar, sobald Backend und Frontend zu unterschiedlichen Zeitpunkten ausgeliefert
werden — und die Nummernkreise verschiedener Hosts überschneiden sich ohnehin.

```markdown
**PRs:** app-backend [#2094](…), app-frontend [#312](…)
```

Der Status wechselt erst auf ✅ `Umgesetzt`, wenn **alle** unter `Repositories` genannten
Repositories ausgeliefert sind.

## Kindseite (Englisch)

```markdown
**Status:** Draft for review
**Related:** [⟨Plantitel⟩](…)
**Author:** ⟨name@example.com⟩
**Date:** 2026-08-11
```

Abschnitte: `Goal` · `Scope Decisions` · `Technical Design` · `Edge Cases & Semantics` ·
`Migration & Rollout` · `Test Plan` · `Open Questions` · `Review Feedback`

Die Kindseite ist entwicklungsseitig und konkret: betroffene Dateien und Klassen,
Datenmodell, Migrationsschritte, Testfälle. Entscheidungen werden mit Begründung
festgehalten, nicht nur als Ergebnis.

## Feedback

Zwei verschiedene Dinge, die bewusst nicht vermischt werden:

* `Offene Fragen ans Produkt` — Fragen, die der Plan selbst stellt.
* `Feedback` (Elternseite) / `Review Feedback` (Kindseite) — Rückmeldungen der
  Kolleg:innen.

**Wichtig:** Kommentare, die über die Inline-Kommentarfunktion von ClickUp an einer
Dokumentseite hinterlassen werden, sind über die API **nicht lesbar** und gehen damit
verloren. Rückmeldungen deshalb bitte als Listenpunkt direkt in den Abschnitt schreiben.

```markdown
## Feedback
> Feedback bitte als Listenpunkt mit Namen eintragen. Inline-Kommentare an der Seite
> können nicht verarbeitet werden.
- [ ] [⟨Name⟩] Abschnitt 3: Der Import sollte pro Mandant konfigurierbar sein
- [x] [⟨Name⟩] Was passiert bei einem Abbruch mitten im Import? → in §5.3 ergänzt
```

Offene Punkte stehen auf `- [ ]`. Sobald ein Punkt eingearbeitet ist, wird er auf `- [x]`
gesetzt und um eine kurze Auflösung ergänzt. Dadurch wird derselbe Punkt nie zweimal
verarbeitet, und Kolleg:innen sehen ohne Nachfrage, dass ihr Hinweis angekommen ist.
