# AI & Project Guidelines

This document serves as the overarching "brain" for AI agents and developers working on this repository. It tracks the core philosophies, architectural preferences, and key prompt desires that drive our projects.

## 1. Core Development Philosophy
- **Lean Architecture:** Avoid unnecessary paid third-party services (e.g., Sentry, Percy) unless absolutely critical. Rely on native tools (GitHub Actions, Firebase native logging, etc.) where possible.
- **Notification Hygiene:** Avoid notification fatigue. Default to daily scheduled digests rather than real-time transactional emails for non-urgent tasks.
- **Fail-Safe by Default:** Implement strict guardrails around destructive actions. Destructive operations (like deleting users or resources) must be explicitly flagged and restricted. Automation should proactively prevent dangling references (e.g., un-allocating relationships when a parent record is deleted).
- **Ghost Process Mitigation (Port Safety):** All local development workflows running background servers or database emulators must implement automated cleanup hooks (e.g., `scripts/clear-ports.cjs` run in `predev`) to terminate ghost processes and prevent port conflict errors (`EADDRINUSE`). Configure pre-dev hooks in package manager scripts (e.g., `"predev": "node scripts/clear-ports.cjs"`) and regularly audit processes via `lsof -i :<port>`.
- **Production Config Seeding (Drift Prevention):** Seeding scripts and local clients should query production REST endpoints (such as public Firestore JSON REST APIs) to load dynamic trip settings and configuration values rather than relying on stale local hardcoded fallbacks. Seeding scripts (e.g., `node scripts/seed-emulator.cjs`) must be idempotent and clear the database before reconstructing mock data using dynamic, relative timestamps.


## 2. Dependency Management & Upgrades (The Blast Radius Rule)
- **Blast Radius Analysis:** Before updating major dependencies, the AI must perform a "dry run" or impact analysis. 
- **Conservative Bumping:** If automated tools (like Dependabot) flag a transitive dependency conflict that does not contain a critical security vulnerability, the AI must evaluate if forcing an update will cause breaking API changes. If it will, the warning should be ignored until a stable patch is provided by the vendor.
- **What to ask the AI:** When dealing with dependency errors, use this prompt constraint:
  > *"Analyze this error log. What is the blast radius of fixing this? Do not attempt to update dependencies until you have summarized the potential breaking changes and I have approved them."*

## 3. Testing Strategy
- **Backend Priority:** Prioritize automated testing for business-critical backend logic (payments, database syncs, background cron jobs, critical data mutations). This provides rock-solid guarantees that data is handled safely.
- **Mobile First UI E2E:** E2E UI testing (via tools like Cypress or Playwright) must enforce mobile layout stability. Always include a suite that simulates mobile viewports (e.g., iPhone X) to ensure critical UI components don't overflow or become un-clickable.
- **Pre-commit Integrity:** All code must pass linting and type-checking via a pre-commit hook (e.g., `husky` and `lint-staged`) before being committed.
- **CI Memory-Optimized E2E (OOM Prevention):** To prevent CI runners from running out of memory (exit code 137), E2E test suites must build static assets first and run Cypress directly against the lightweight static Hosting emulator (e.g., `test:e2e:hosting`) instead of a dynamic dev server, eliminating the compiler overhead. In the CI environment, set `CYPRESS_NO_COMMAND_LOG=1` and `NODE_OPTIONS=--max-old-space-size=2048`. In `cypress.config.ts`, set `numTestsKeptInMemory: 0` and `video: false` to optimize memory utilization.


## 4. Mobile UI & Rendering (WebKit Safety)
- **Native Scrolling:** Never apply custom `::-webkit-scrollbar` styling globally on mobile devices. Isolate it within `@media (hover: hover) and (pointer: fine)` to prevent touch-gesture lockups on iOS WebKit.
- **Touch-Scrolling Physics:** Do not override native scrolling physics with custom JavaScript momentum-scroll utilities unless explicitly requested.
- **Tap Safety:** Utilize `-webkit-tap-highlight-color: transparent` globally for touch devices to remove grey tap boxes (FOUC). Ensure all interactive elements have touch-friendly tap targets without causing layout shifts.

## 5. Security & Reliability
- **Automated Backups:** Databases must execute automated daily exports to a secure bucket or automated backup solution.
- **Feature Gating:** New, risky, or administrative UI features should be wrapped in Remote Configuration Feature Flags so they can be toggled remotely without requiring a new code deployment.

## 6. The "Zero to One" Initialization Rule
- **Foundational Integrity First:** Before writing *any* feature code for a new repository, the AI must ensure that the foundational production values are active. This means setting up a basic CI/CD pipeline (e.g., GitHub Actions), a Dependabot configuration (`.github/dependabot.yml`) to monitor package managers and GitHub Actions, enforcing a code formatter (Prettier), a linter (ESLint), and pre-commit hooks (Husky). 
- **No Naked Codebases:** Do not allow new projects (like Vite or Firebase boilerplates) to exist without an automated E2E test folder (e.g., Cypress) and backend test folder being initialized.

## 7. Safe Deployments
- **One-Click, One-Confirm Deployments:** All projects must contain interactive scripts (e.g., `scripts/deploy-staging.sh` and `scripts/deploy-prod.sh` or `scripts/deploy_pipeline.js`) that encapsulate deployment logic. These scripts must prompt the user with a single `[Y/n]` confirmation before executing destructive or production-altering changes (like pushing to a main branch or creating a GitHub Release).
- **Self-Healing AI Workflows:** Deployment scripts *must* include `gh run watch` logic to monitor the remote GitHub Actions pipeline. If a pipeline fails, the script must automatically run `gh run view <RUN_ID> --log-failed` to dump the error logs into the terminal. This allows an orchestrating AI (like Antigravity) to automatically capture the error, analyze the failure, and propose a code fix to the developer.
- **Clean Shell Isolation:** Local and remote execution scripts must proactively sanitize inherited shell environment states (such as deleting stale, expired variables like `FIREBASE_TOKEN` or `GOOGLE_APPLICATION_CREDENTIALS` on launch) to prevent active processes from blocking or corrupting standard credential fallbacks.
- **Build-Time Compilation Guards:** The build process must run static validation passes (e.g., broken link checkers, schema validators, linting audits) *before* assets are generated or uploaded, so that broken internal hashes or malformed configurations halt compilation and prevent broken versions from ever hitting production.
- **Automated Resource Optimization:** The pipeline should automatically optimize raw media files (e.g., converting and compressing raw high-resolution images to efficient modern formats like `.webp`) at build-time rather than requiring manual developer compression, lowering Largest Contentful Paint (LCP) out-of-the-box.

## 8. Command Automation & Sandbox Privileges
To maximize execution velocity and prevent prompt/confirmation friction during active engineering loops, the AI agent is granted absolute permission to execute the following generalized command patterns on behalf of the developer:
- **Diagnostic Network Queries:** `curl -i *`, `curl -L *`, `ping *`, `dig *` (Validating routing endpoints, CORS, redirect logic, and payloads).
- **Docker & Compose Operations:** `docker ps*`, `docker logs*`, `docker exec*`, `docker compose*` (Inspecting, running, and orchestrating container environments).
- **Local & Remote SSH Operations:** `ssh -i *` (Querying, verifying, and deploying updates on the Linode VPS host securely).
- **Version Control & Repository Operations:** `git status*`, `git diff*`, `git add*`, `git commit*`, `git push*`, `git fetch*`, `git reset*`, `git checkout*`, `git update-index*`, `chmod +x*`, `git config*` (Managing codebase version control pipelines).
- **Firebase CLI Operations:** `firebase *`, `npx firebase *` (Deploying hosting/functions, managing secrets, authenticating sessions, listing projects, and running local emulators).
- **Local Testing & Script Pipelines:** `npm run *`, `node *`, `./scripts/*` (Executing local dev servers, build compilers, pre-commit hooks, and Puppeteer E2E verification suites).
- **Package Manager Operations:** `npm install *`, `npm audit *`, `npm update *` (Managing third-party libraries and running vulnerability audits).
- **GitHub CLI Workflow Automation:** `gh run *`, `gh secret *`, `gh auth*`, `gh repo*` (Monitoring GitHub Actions pipelines and configuring remote repository secrets).
- **Utility, Cleanup, and System Diagnostics:** `rm -rf *`, `rm *`, `python3 *`, `ps aux*`, `grep*` (Pruning obsolete deployment configurations/Netlify artifacts, executing diagnostic scripts, and inspecting system processes).

## 9. Centralized Interface String Management (String Isolation Rule)
- **Centralized Content Store:** All user-facing UI copy, labels, SEO titles, descriptions, aria-labels, form helper texts, and metadata must be stored in a centralized configuration file (`content.json`) rather than being hardcoded or distributed across HTML template files, client-side JavaScript, or backend functions.
- **Compile-Time Schema Validation:** The centralized content file must be validated at compile-time against a strict JSON Schema (`content.schema.json`) to enforce type constraints, ensure structural completeness, and prevent build execution if any keys are missing or malformed.
- **Recursive Template Compilation:** The build compiler (`build.js`) must recursively replace double-curly brace placeholders (e.g., `{{hero.title}}` or `{{analytics.sentryDsn}}`) within all HTML templates and JS scripts. This ensures a clean separation of interface concerns: templates manage structure and interactions, while `content.json` defines all textual configurations.
- **Dynamic Content Safeguards:** Any CMS actions (such as adding or modifying content via the admin workstation dashboard) must update this single central file or its respective markdown directories, programmatically triggering a compiler rebuild to regenerate static HTML/JS pages.

## 10. Context Preservation & Truncation Resilience (The Context Continuity Rule)
- **High-Density Summary File:** To guard against context window truncation or overflow, the project root must maintain a high-density, chronological `PROJECT_CONTEXT.md` file.
- **Automatic Context Maintenance:** AI agents are expected to keep `PROJECT_CONTEXT.md` updated as they make progress. It must track the project overview, active conversation IDs, boundaries (first/last requests in each thread), uncommitted changes (git status), pending backlog tasks, and recent git commits.
- **Context Restoration Flow:** In the event of a context truncation or starting a new thread, the user or agent can point the new session at `PROJECT_CONTEXT.md` to immediately restore full developer alignment.
- **Living Action Items:** Alongside `PROJECT_CONTEXT.md`, maintain local, granular checklists like `task.md` and design outlines like `implementation_plan.md` to track progress step-by-step and keep execution aligned across chat sessions.
- **Write Down Decisions:** Document complex architecture decisions, technical design trade-offs, and "gotchas" in code comments or documentation rather than leaving them only in conversation chat logs.

## 11. Git Hygiene & Branch Management (Drift Prevention)
- **Incremental Commits:** Commit code frequently with clear, conventional messages. Do not leave a large chunk of work unstaged or uncommitted at the end of a session.
- **Clean Working Directory:** Ensure that temporary files, logs, environment variables, or local configs are strictly ignored in `.gitignore` to prevent polluting the git tree.


