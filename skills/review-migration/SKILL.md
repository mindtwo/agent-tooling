---
name: review-migration
allowed-tools: Bash(git diff:*), Bash(git branch:*), Bash(find:*), Bash(grep:*)
description: Review database migrations for safety issues before they reach production
---

You're an experienced Laravel developer reviewing database migrations for safety and correctness.

Follow these steps:

1. Run `git branch --show-current` and `git diff master..${BRANCH_NAME} -- database/migrations/` to get changed/added migrations.
2. If no migration files changed, stop and inform the user.
3. Make a todo list.
4. For each migration file, analyse:

**Dangerous (must fix)**
- `dropColumn()`, `dropTable()`, `drop()` without a comment or ticket reference explaining why data loss is intentional
- `change()` missing full column definition — in Laravel 12+, `change()` requires re-specifying all existing attributes (nullable, default, unsigned, etc.) or they are silently dropped
- `truncate()` in a migration
- `DB::statement('DROP TABLE ...')` or similar raw destructive SQL

**Warning (should fix)**
- Missing `down()` method, or `down()` that is a no-op (`//`)
- Adding a non-nullable column without a default to an existing table (will fail on non-empty databases without `default()` or a data migration)
- Adding an index to a large table without considering the lock duration — note this as something to verify on staging
- Foreign key columns missing an index (`$table->unsignedBigInteger('user_id')` without `->index()` or a `foreign()->references()`)
- `nullable()` column that probably should not be nullable based on the domain (e.g. `user_id` on an orders table)
- Renaming a column without a corresponding model cast/fillable/accessor update — flag for cross-checking

**Consistency checks**
- New columns not reflected in the model's `$fillable`/`$guarded` and `$casts` (try to find the related model and check)
- Enum values in migrations that don't match a PHP enum in `Enumerators/`

5. Also check the `up()` method for correctness:
   - `->unique()` on columns with existing duplicates will fail — flag if this is a new constraint on an existing table
   - `->default(0)` on a boolean used as a flag — correct, but verify the model casts it as `bool`

6. For each issue, note the migration filename and line number.

---

Output format:

---

### Migration Review

**Migrations reviewed**: N

**Dangerous** (N issues)

1. **2026_03_15_add_status_to_orders.php:18** — `change()` missing full column definition

   `$table->string('status')->change()` does not re-specify `nullable()` or `default()`.
   In Laravel 12+, the existing nullable/default will be silently dropped.
   Fix: `$table->string('status')->nullable()->default('pending')->change()`

**Warning** (N issues)

1. **2026_03_15_add_status_to_orders.php:8** — Missing `down()` implementation

   `down()` is empty. Add the reverse operation so the migration can be rolled back.

**Consistency** (N issues)

1. **2026_03_15_add_status_to_orders.php** — New `status` column not in `Order::$fillable`

   Check `app/Models/Order.php` (or the relevant module model) and add `'status'` to `$fillable` or `$casts`.

---

Or, if migrations look safe:

---

### Migration Review

**Migrations reviewed**: N

All migrations look safe to run.

---
