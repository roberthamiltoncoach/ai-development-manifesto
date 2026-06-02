# AI Development Manifesto

A centralized "single source of truth" repository for managing AI-driven software development outcomes. 

As I build multiple software projects using AI agents, they learn critical lessons about my preferences—how I handle dependencies, how I structure my tests, and how I enforce safety guardrails. Instead of starting from scratch with a "blank slate" AI on every new project, I use this repository to compile my core rules into a single manifesto.

**Philosophy: "All Boats Rise"**  
When I learn a new architectural lesson or UI safety rule, I update this central repository. Then, all of my other projects pull down the latest rules, meaning every project improves simultaneously.

## How to use in your own projects

To inject these guidelines into a new project, simply run this command in your project's root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/roberthamiltoncoach/ai-development-manifesto/main/install.sh | bash
```

This will instantly download `AI_PROJECT_GUIDELINES.md` into your repository. The AI agents working on your project will read it and instantly conform to your established development philosophy.

### Contributing / Updating
1. When you encounter a major friction point with an AI agent, solve it.
2. Formulate a rule to prevent it from happening again (e.g., "The Blast Radius Protocol").
3. Add the rule to `AI_GUIDELINES.md` in this repository.
4. Run the curl script in your active projects to sync them up!
