# Branch Protection Setup Guide

This guide explains how to configure branch protection rules for the main branch to require pull request approvals.

## GitHub Settings Configuration

To require pull request approvals before merging to the main branch, follow these steps:

### Step 1: Access Branch Protection Settings

1. Navigate to your repository on GitHub: `https://github.com/AwangWOW/Wangbar`
2. Click on **Settings** (requires admin access)
3. Click on **Branches** in the left sidebar
4. Under "Branch protection rules", click **Add rule** or **Add branch protection rule**

### Step 2: Configure the Rule

1. **Branch name pattern**: Enter `main`

2. **Protect matching branches** - Enable the following settings:
   - ✅ **Require a pull request before merging**
     - ✅ **Require approvals**: Set to `1` (or more)
     - ✅ **Dismiss stale pull request approvals when new commits are pushed** (recommended)
     - ✅ **Require review from Code Owners** (optional, works with CODEOWNERS file)
   
   - ✅ **Require status checks to pass before merging** (optional, if you add CI/CD)
   
   - ✅ **Require conversation resolution before merging** (recommended)
   
   - ✅ **Do not allow bypassing the above settings** (recommended for strict enforcement)
     - Note: Repository admins can still bypass unless this is enabled
   
   - ✅ **Restrict who can push to matching branches** (optional)
     - Leave empty to allow no direct pushes, requiring PRs for everyone

3. Click **Create** or **Save changes**

### Step 3: Verify Configuration

After setting up the branch protection rule:

1. Try to push directly to main - it should be blocked
2. Create a new branch, make changes, and open a pull request
3. The pull request should require approval before it can be merged

## CODEOWNERS File

This repository includes a `.github/CODEOWNERS` file that automatically requests review from @AwangWOW for all changes. This works in conjunction with the branch protection settings.

## Important Notes

- **Admin Override**: By default, repository administrators can bypass branch protection rules. Enable "Do not allow bypassing the above settings" to enforce rules for admins too.
- **Required Reviews**: The CODEOWNERS file ensures that you (@AwangWOW) are automatically added as a reviewer on all pull requests.
- **Direct Pushes**: Once configured, direct pushes to main will be blocked, and all changes must go through pull requests.

## Alternative: GitHub Rulesets (Beta)

GitHub also offers Repository Rules (the newer approach), which you can configure at:
- Settings → Rules → Rulesets

This provides more granular control and applies to both branches and tags.
