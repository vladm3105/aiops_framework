# Repository Guidelines

## Project Structure & Module Organization
- agents/: Role playbooks and contributor personas.
- init/: Initialization flows and startup protocols.
- development/: Product/development process, ADRs, prompts, and guides.
- deployment/: CI/CD, infrastructure, and release practices.
- operations/: Runbooks, monitoring, and ops prompts.
- .ai_context/: State, progress, and automation notes.
- .archive_devops_legacy_files/: Legacy/archived references.
- Root files: README.md, QUICK_START.md, CLAUDE.md, GEMINI.md.

## Build, Test, and Development Commands
This repository is documentation-first; no compile step is required.
- Preview: Use your editor’s Markdown preview or `grip README.md` (optional).
- Search: `rg -n "keyword"` or `grep -R "keyword" .` to find references.
- List docs: `find . -maxdepth 2 -name "*.md"` to scan sections.

## Coding Style & Naming Conventions
- Files: `lowercase_with_underscores.md`; framework docs use `_v3.7.md` suffix.
- Headings: Title Case; use `#`, `##`, `###` in order with no jumps.
- Lists: `- ` with one space; prefer concise bullets over prose.
- Links: Relative paths (e.g., `[AI Startup](development/AI_ASSISTANT_STARTUP.md)`).
- Formatting: Keep lines ≤ 100 chars; wrap thoughtfully around links and code spans.

## Testing Guidelines
- Accuracy: Verify internal links resolve and section anchors exist.
- Consistency: Ensure cross-file terminology and version (`v3.7`) are consistent.
- Quick checks: `rg -n "\[.*\]\(.*\)"` to audit links; open changed files in preview.
- Coverage: When adding a new section, update related READMEs and cross-links.

## Commit & Pull Request Guidelines
- Commits: Imperative, concise, scoped (e.g., "Add operations monitoring guide v3.7").
- Group related changes per directory; avoid sweeping edits across domains.
- PRs include: purpose, scope (dirs/files), highlights, and breaking changes (if any).
- Reference issues where relevant; include before/after screenshots of rendered Markdown when helpful.

## Security & Configuration Tips
- Secrets: Do not commit credentials; `.env` is for local examples only.
- Paths: Prefer relative links; avoid external URLs unless stable and necessary.

## Agent-Specific Notes
- When adding a new agent guide, update `agents/README.md` with a brief description and links.
- Reuse existing templates and tone from `development/*` and `operations/*` for consistency.
