# AI & Project Guidelines

This document serves as the overarching "brain" for AI agents and developers working on this repository. It tracks the core philosophies, architectural preferences, and key prompt desires that drive our projects.

## 1. Core Development Philosophy
- **Lean Architecture:** Avoid unnecessary paid third-party services (e.g., Sentry, Percy) unless absolutely critical. Rely on native tools (GitHub Actions, Firebase native logging, etc.) where possible.
- **Notification Hygiene:** Avoid notification fatigue. Default to daily scheduled digests rather than real-time transactional emails for non-urgent tasks.
- **Fail-Safe by Default:** Implement strict guardrails around destructive actions. Destructive operations (like deleting users or resources) must be explicitly flagged and restricted. Automation should proactively prevent dangling references (e.g., un-allocating relationships when a parent record is deleted).

## 2. Dependency Management & Upgrades (The Blast Radius Rule)
- **Blast Radius Analysis:** Before updating major dependencies, the AI must perform a "dry run" or impact analysis. 
- **Conservative Bumping:** If automated tools (like Dependabot) flag a transitive dependency conflict that does not contain a critical security vulnerability, the AI must evaluate if forcing an update will cause breaking API changes. If it will, the warning should be ignored until a stable patch is provided by the vendor.
- **What to ask the AI:** When dealing with dependency errors, use this prompt constraint:
  > *"Analyze this error log. What is the blast radius of fixing this? Do not attempt to update dependencies until you have summarized the potential breaking changes and I have approved them."*

## 3. Testing Strategy
- **Backend Priority:** Prioritize automated testing for business-critical backend logic (payments, database syncs, background cron jobs, critical data mutations). This provides rock-solid guarantees that data is handled safely.
- **Mobile First UI E2E:** E2E UI testing (via tools like Cypress or Playwright) must enforce mobile layout stability. Always include a suite that simulates mobile viewports (e.g., iPhone X) to ensure critical UI components don't overflow or become un-clickable.
- **Pre-commit Integrity:** All code must pass linting and type-checking via a pre-commit hook (e.g., `husky` and `lint-staged`) before being committed.

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
- **One-Click, One-Confirm Deployments:** All projects must contain interactive scripts (e.g., `scripts/deploy-staging.sh` and `scripts/deploy-prod.sh`) that encapsulate deployment logic. These scripts must prompt the user with a single `[Y/n]` confirmation before executing destructive or production-altering changes (like pushing to a main branch or creating a GitHub Release).
- **Self-Healing AI Workflows:** Deployment scripts *must* include `gh run watch` logic to monitor the remote GitHub Actions pipeline. If a pipeline fails, the script must automatically run `gh run view <RUN_ID> --log-failed` to dump the error logs into the terminal. This allows an orchestrating AI (like Antigravity) to automatically capture the error, analyze the failure, and propose a code fix to the developer.
