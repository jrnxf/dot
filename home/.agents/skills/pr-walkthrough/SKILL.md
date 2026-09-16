---
name: pr-walkthrough
description: Explain a pull request in plain English with an interactive HTML walkthrough, publish it as a Claude Code artifact, and add its link to the PR description without committing the generated page. Use when the user wants a visual PR explanation or a shareable walkthrough for reviewers.
---

# PR walkthrough

Turn a PR into a self-contained HTML app that helps someone understand the change without reading the diff. Default to creating, opening, and publishing a private Claude Code artifact, then adding its link to the PR description. Updating the description is part of invoking this workflow; do not ask for separate confirmation. Honor requests for local-only output or no PR edits. If the user supplies an existing walkthrough, preserve it and start at verification and publishing unless they request changes.

Example invocation: `/pr-walkthrough 309` or `/pr-walkthrough <PR URL>`.

## Establish what actually changed

- Resolve the repository and PR from the user's arguments and current workspace. Ask only if the target is ambiguous.
- Use `gh-axi` for PR metadata and discussion. Read the actual diff and relevant source at the PR's head commit, using local Git objects where available. Do not assume the current checkout is the PR branch.
- For stacked PRs, compare against the PR's declared base, not the default branch. Explain where this PR sits in the stack and which capabilities belong to other PRs.
- Trace the important behavior through its callers, storage, and tests. Treat code as authoritative when the PR description is stale. Distinguish intended behavior, observed implementation, and unresolved uncertainty.
- Record the head SHA and reading date. Link source references to that immutable commit. Attribute reported test results to the PR; do not imply tests were run during this walkthrough when they were not.

Finish this step with enough evidence to explain the problem, before/after behavior, main mechanisms, and practical boundaries accurately.

## Build the explanation

Write one HTML file with inline CSS and JavaScript in a temporary directory outside the repository. Keep generated files, screenshots, and artifact metadata out of Git. Do not stage or commit them, and do not add ignore rules just to house them in the repo.

Lead with what changes for a person using the product and why. Explain unfamiliar terms where they first appear. Use short chapters with optional technical detail and source links. A useful shape, adapted to the PR:

1. The big picture: the problem, before/after, and scope.
2. A concrete example: let the reader change inputs and see the result.
3. A flow diagram: follow one request, event, or save through the system.
4. Data or architecture: ownership, persistence, or component relationships.
5. Details that matter: limitations, failure behavior, and verification evidence.

Choose diagrams that teach the actual mechanism. Use interactive controls when they clarify cause and effect, not as decoration. Label simulated values and previews as illustrative; never connect the explainer to production writes. Preserve important distinctions such as saved versus applied, default versus override, and visible output versus internal tracking.

Make the app work offline with no build step, external fonts, CDN scripts, or backend. Use inline SVG or HTML/CSS diagrams. If a diagramming library is needed, bundle it locally into the page. Avoid routing and browser-history dependencies that could fail in an artifact iframe; switch views through page state. Use responsive layouts, readable contrast, semantic controls, keyboard navigation, and accessible names.

Do not carry repository-private details into a reusable skill or public template. The walkthrough itself should contain only the information needed to explain its PR.

## Verify and open

Open the HTML locally and use `chrome-devtools-axi` when available to inspect wide and narrow layouts, click through every chapter, and exercise meaningful control combinations. Check that the examples agree with the code, links target the recorded commit, and there are no JavaScript errors or clipped diagrams.

If browser automation is unavailable, perform available syntax and interaction checks, still open the file using the operating system, and state the visual-verification limitation accurately. Do not install a browser framework solely to claim visual verification.

## Publish as a Claude Code artifact

Use the native artifact capability exposed by the current Claude Code session to publish the existing HTML file. Inspect the actual tool schema instead of guessing a CLI command, API endpoint, or argument names. Preserve the page's content and interactions. Give it a descriptive title such as `PR 309: live settings explained`.

- Creating a private artifact is part of this workflow. Follow the session's actual tool approval requirements without adding a separate confirmation loop.
- If updating an existing artifact, reuse its URL rather than creating a duplicate. Preserve its audience, and honor any approval required for updating content already shared with others.
- Open the returned URL and check the hosted interactions when the tools permit. A local preview alone does not verify the hosted artifact.
- New artifacts start private. A PR link does not grant readers access. Use the artifact's Share control to grant the intended audience access when the user has authorized that audience. Do not silently make a private repository's walkthrough public.
- Team/Enterprise can support organization sharing; personal plans may require public sharing. If audience selection or a manual Share action is still needed, state the exact remaining step. Do not call an owner-only URL reviewer-accessible.

If the native artifact capability is unavailable, complete the local walkthrough and provide a ready-to-paste Claude Code prompt containing its absolute path, desired title, and instructions to publish it unchanged without committing. Do not claim publishing succeeded, fabricate a URL, launch another agent, or substitute another hosting service merely to bypass the missing capability.

For capability or sharing questions, consult the current official [Claude Code artifact documentation](https://code.claude.com/docs/en/artifacts) through the available documentation tools, following the user's web-access preferences. Avoid hardcoding plan or version assumptions when troubleshooting.

## Add the walkthrough to the PR description

Once publishing returns a real hosted URL, use `gh-axi` to update the PR description, not a comment. Re-read the latest description immediately before editing and preserve all existing content outside the walkthrough block. The walkthrough block is always the first thing in the description, above the summary and any other heading. On the first run, insert this block at the very top followed by a blank line; on subsequent runs, replace the existing block in place (and move it to the top if it is not already there) so links do not accumulate:

```markdown
<!-- pr-walkthrough:start -->
### Interactive walkthrough

[Explore the change in plain English, with diagrams and interactive examples](ARTIFACT_URL)
<!-- pr-walkthrough:end -->
```

Substitute the returned URL. Do not add an access or sharing status line to the block; report sharing status to the user in the final message instead. Posting the link does not authorize making the artifact public. Never post a local file path or a placeholder URL to the PR.

Use a structured body argument or a temporary body file to preserve Markdown and newlines. Read back the description to verify the block is the first content in the body, the correct link appears exactly once and unrelated content is preserved. If publishing or the PR edit is unavailable, report that remaining step accurately instead of claiming completion.

## Deliver

Return the PR link, artifact URL, actual sharing status, and a local file link as a fallback. Confirm the description update and mention verification briefly. If access still needs to be granted through Share, state that remaining action explicitly.
