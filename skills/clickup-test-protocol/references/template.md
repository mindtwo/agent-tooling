# Comment template and posting

## Template

One block per test point, separated by `----`. The heading stays exactly `#### Testprotokoll`.

```markdown
#### Testprotokoll

**<Kurzer Titel des Testpunkts>**
<1–3 Sätze: was umgesetzt / geändert wurde, mit konkreten Werten statt „angepasst“.>
Testszenario: <Schritt → erwartetes Ergebnis>          ← only when there is a real use case

📎 [Screenshot: 01-<name>.jpg](<attachment url>)

----

**<Nächster Testpunkt>**
<…>

📎 [Screenshot: 02-<name>.png](<attachment url>)

Änderungen sind auf <Staging|Live> deployed.
z.K. [@<Name>](#user_mention#<user_id>)
```

Writing rules:

- Concrete beats vague: „zeigt Dresden, 2.–3. Juni“, not „Daten wurden aktualisiert“.
- Changed texts: say what it was before („vorher fest 2026 / Hamburg“).
- Points without a visible change (data integrity, background logic) get a text block
  backed by evidence (counts from the DB, test results) and no screenshot.
- Unverified points are written as `Offen: …`. Leave out anything the user excluded.
- Filenames are numbered in comment order: `01-hero-startseite.jpg`, `02-mail-….png`.

## Posting (only after approval)

### 1. Upload each screenshot

`clickup_request_attachment_upload(task_id, file_name)` returns an `upload_url` and an
`upload_ticket`, valid for a few minutes. Request all tickets first, then upload:

```bash
curl -sS -X POST "$UPLOAD_URL" \
  -H "X-Upload-Ticket: $TICKET" \
  -F "attachment=@$DIR/01-hero-startseite.jpg;filename=01-hero-startseite.jpg"
```

The JSON response has `url`. In a sandbox, allow `mcp.clickup.com`.

### 2. Link the screenshots; don't embed them

ClickUp does **not** render Markdown images (`![](url)`) in comments created through the
MCP; they come out as nothing. Write each screenshot as a link to its attachment:

```markdown
📎 [Screenshot: 01-hero-startseite.jpg](<url>)
```

The files are also listed in the ticket's attachments, numbered in comment order.

### 3. Create the comment once, final

`clickup_create_comment(entity_type: "task", entity_id: <id>, comment_text: …)`.

- Mention `[@Name](#user_mention#<id>)` works **only on create**. `clickup_update_comment`
  drops the mention and sends no notification, so get the text right before posting.
- If you must fix a posted comment, use `clickup_update_comment` and write the name as
  plain text, then tell the user the edit did not notify anyone.

### 4. Check

`clickup_get_task_comments` returns plain text: links show as `📎 Screenshot: …`. Ask the
user to open the ticket once.

## Example (SD-124263, Event 2027 im System anlegen)

```markdown
#### Testprotokoll

**Event 2027 angelegt**
Das Event „Deutscher Stiftungstag 2027“ ist mit Titel, Datum (02.–03.06.2027) und Veranstaltungsort (ICD – Internationales Congress Center Dresden) angelegt und als aktives Event veröffentlicht. Logo-Zeile und Hero der Startseite zeigen automatisch „Deutscher Stiftungstag 2027 · Dresden, 2.–3. Juni“.
Testszenario: Startseite aufrufen → Header und Hero zeigen Titel, Ort und Datum 2027.

📎 [Screenshot: 01-hero-startseite-2027.jpg](…)

----

**Event 2026 unverändert**
Event 2026 bleibt mit allen Daten erhalten: alle 2.473 Tickets inkl. Teilnehmenden sind weiterhin dem Event 2026 zugeordnet. Geändert wurde nur der Veröffentlichungsstatus (nicht mehr aktiv).

----

**E-Mails nutzen das aktive Event**
Jahr, Titel, Datum, Ort und Veranstaltungsort in den E-Mail-Vorlagen sind nicht mehr fest auf 2026 / Hamburg / CCH hinterlegt, sondern werden aus dem aktiven Event gelesen. Gelb markiert = automatisch aus dem Event 2027 befüllt.
Testszenario: Vorlagen mit dem aktiven Event 2027 gerendert → alle markierten Stellen zeigen 2027 / Dresden / ICD.

*Ticketübertragung an Empfänger\*in (inkl. Betreff)*
📎 [Screenshot: 02-mail-ticketuebertragung-empfaenger.jpg](…)

Änderungen sind auf Staging deployed.
z.K. [@Anna-Lena Weber](#user_mention#100621655)
```
