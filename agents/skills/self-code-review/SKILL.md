---
name: self-code-review
description: Code Review
disable-model-invocation: true
---

---
description: Code review changes in the current working branch
---

Code review changes in the current working branch.

**Assumptions:**
- All tools are functional and will work without error. Do not test tools or make exploratory calls.
- Only call a tool if it is required to complete the task. Every tool call should have a clear purpose.

To do this, follow these steps precisely:

1. Perform a quick check to verify if there are any changes to review:
   - Check for unstaged changes using `git status`
   - Determine the base branch (typically main or master, or use `git merge-base HEAD main` or `git merge-base HEAD master` to find the common ancestor)
   - Check for committed changes in the current branch compared to the base branch
   - If neither unstaged changes nor committed changes exist, stop and do not proceed

2. Get a list of file paths (not their contents) for all relevant project guideline files (CLAUDE.md, AGENTS.md, etc.):
   - The root guideline file, if it exists
   - All guideline files in directories containing files modified by the changes

3. Review the changes in the current branch and return a summary of the changes:
   - If there are unstaged changes, use `git diff` to get the unstaged changes
   - Determine the base branch (try main first, then master, or use `git merge-base` to find the common ancestor)
   - If there are committed changes (or in addition to unstaged changes), use `git diff <base-branch>...HEAD` to get committed changes compared to the base branch
   - Get a list of all changed files (both unstaged and committed)
   - Summarize the changes

4. Launch 4 parallel tasks to independently review the changes. Each task should return a list of issues, where each issue includes a description and the reason it was flagged (e.g., "project guideline compliance", "bug"). The tasks should do the following:

   Tasks 1 + 2: Project guideline compliance review
   Audit changes for project guideline compliance in parallel. Note: When evaluating guideline compliance for a file, you should only consider guideline files that share a file path with the file or its parent directories.

   Task 3: Bug detection review (parallel with task 4)
   Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that you cannot validate without looking at context outside of the git diff.

   Task 4: Bug detection review (parallel with task 3)
   Look for problems that exist in the introduced code. This could be security issues, incorrect logic, etc. Only look for issues that fall within the changed code.

   **CRITICAL: We only want HIGH SIGNAL issues.** Flag issues where:
   - The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
   - The code will definitely produce wrong results regardless of inputs (clear logic errors)
   - Clear, unambiguous project guideline violations where you can quote the exact rule being broken

   Do NOT flag:
   - Code style or quality concerns
   - Potential issues that depend on specific inputs or state
   - Subjective suggestions or improvements

   If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

   In addition to the above, each review task should be told the current branch name and latest commit message (if any). This will help provide context regarding the author's intent.

5. For each issue found in the previous step by tasks 3 and 4, validate the issue in parallel. These validation tasks should get the issue description along with the current branch name and latest commit message. The validation task's job is to review the issue to validate that the stated issue is truly an issue with high confidence. For example, if an issue such as "variable is not defined" was flagged, the validation task's job would be to validate that is actually true in the code. Another example would be project guideline issues. The validation task should validate that the guideline rule that was violated is scoped for this file and is actually violated. Use detailed validation for bugs and logic issues, and standard validation for guideline violations.

6. Filter out any issues that were not validated in step 5. This step will give us our list of high signal issues for our review.

7. If issues were found, skip to step 8 to output review results.

   If NO issues were found, output a summary comment in the following format:
   ```
   ## Code Review

   No issues found. Checked for bugs and project guideline compliance.
   ```

8. Create a list of all issues that you plan on reporting. This is only for you to make sure you are comfortable with the comments. Do not post this list anywhere.

9. Output review results for each issue in the following format:
   - A brief description of the issue
   - The file and line number where the issue occurs
   - For small, self-contained fixes, include a committable suggestion block
   - For larger fixes (6+ lines, structural changes, or changes spanning multiple locations), describe the issue and suggested fix without a suggestion block
   - Never post a committable suggestion UNLESS committing the suggestion fixes the issue entirely. If follow up steps are required, do not leave a committable suggestion.

   **IMPORTANT: Only report ONE comment per unique issue. Do not post duplicate comments.**

Use this list when evaluating issues in Steps 4 and 5 (these are false positives, do NOT flag):

- Pre-existing issues
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch (do not run the linter to verify)
- General code quality concerns (e.g., lack of test coverage, general security issues) unless explicitly required in project guidelines
- Issues mentioned in project guidelines but explicitly silenced in the code (e.g., via a lint ignore comment)

Notes:

- Use git commands to interact with Git (e.g., fetch changes, get branch information)
- Create a todo list before starting.
- Cite and link each issue in comments (e.g., if referring to a project guideline file, include a link to it).
- If no issues are found, output a comment in the following format:

---

## Code Review

No issues found. Checked for bugs and project guideline compliance.

---

- When linking to code in comments, follow the following format precisely, otherwise the Markdown preview won't render correctly: `file-path:line-number`
  - Use relative or absolute file paths
  - # sign after the file name
  - Line range format is `L[start]-L[end]`
  - Provide at least 1 line of context before and after, centered on the line you are commenting about (e.g., if you are commenting about lines 5-6, you should link to `L4-7`)

