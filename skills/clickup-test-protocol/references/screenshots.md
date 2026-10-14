# Screenshots

## Where

Ask the user which environment (local, staging, live) once, then stay with it. Use the
built-in browser pane. If the change only exists on a branch, test on that branch locally,
or render from the branch without checking it out (mails, see below).

Logins: never type passwords. Ask the user to log in **in the browser pane** (not their
own Chrome; sessions aren't shared). If the login doesn't stick after one retry, go on
without it and back the point with DB/test evidence instead of looping.

## What

- **Only the changed area.** Hero changed → hero only. Use `computer` → `zoom` with a
  `region` to crop, or crop afterwards (`sips --cropToHeightWidth H W --cropOffset Y X`
  with `--out`, or PHP GD when `sips` can't write its temp file in a sandbox).
- Crop out anything the user decided to leave out of the protocol.
- Before/after only when the difference isn't obvious from the text.
- Copy every screenshot from the browser tool's `tool-results/` folder into
  `<scratchpad>/<ticket-id>/NN-name.ext` straight away, numbered in comment order.

## Mail templates

Changed mails can't be screenshotted from an inbox reliably. Render them instead:

1. Take the template source from the branch: `git show <branch>:resources/views/mail/<name>.blade.php`.
2. Wrap every changed expression from the diff in a highlight, e.g. with
   `preg_replace('/\{\{\s*\$activeEvent\[[^\]]+\]\s*\}\}/', '<mark class="chg">$0</mark>', $src)`.
3. Render it in the app context (Boost `tinker`) with real data:
   ```php
   View::replaceNamespace('mail', app(\Illuminate\Mail\Markdown::class)->htmlComponentPaths());
   $html = Blade::render($src, $data);
   ```
   Fill form variables with sample data (Max Mustermann). Statamic form mails expect
   `Statamic\Fields\Value` objects (`->raw()`), so wrap them as `new Value($v)`.
   If the template uses a class that only exists on the branch, `eval` its source
   from `git show` (strip `<?php`).
4. Show the result in the browser pane (`javascript_tool`, replace `document.documentElement.innerHTML`)
   with a small header block above the mail: **E-Mail** name and **Betreff**, with the
   subject's changed part highlighted too (`mark.chg { background:#fde047; outline:2px solid #f59e0b }`).
5. Take one screenshot per mail, cropped to the header and the paragraphs with highlights.
6. In the comment, say what the highlight means: „Gelb markiert = …, vorher fest …“.
