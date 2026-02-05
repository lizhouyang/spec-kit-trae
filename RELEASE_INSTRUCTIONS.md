# GitHub Release Creation Instructions

## Manual Steps (Recommended)

1. **Create GitHub Personal Access Token:**
   - Visit: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Name: "spec-kit-release"
   - Select scope: `public_repo`
   - Click "Generate token"
   - COPY the generated token (you won't see it again)

2. **Create Release Manually:**
   - Visit: https://github.com/lizhouyang/spec-kit-trae/releases/new
   - Tag version: `v0.1.0`
   - Release title: `v0.1.0`
   - Description:
     ```
     # v0.1.0

     Initial release of the lizhouyang/spec-kit-trae fork with the following improvements:

     ## Key Features
     - Fixed hardcoded repository URLs to support forked repositories
     - Added intelligent fallback mechanism when releases are not found
     - Improved error handling and user feedback
     - Support for all major AI coding assistants

     ## Improvements
     - Better repository detection and fallback logic
     - Enhanced debugging information
     - More robust template downloading

     ## Supported Agents
     All major AI coding assistants are supported including Qoder, Claude, Copilot, Cursor, Gemini, and many others.
     ```

3. **Upload Assets:**
   Upload all 34 files from the `.genreleases` directory:
   
   Files to upload:
   - spec-kit-template-amp-ps-v0.1.0.zip
   - spec-kit-template-amp-sh-v0.1.0.zip
   - spec-kit-template-auggie-ps-v0.1.0.zip
   - spec-kit-template-auggie-sh-v0.1.0.zip
   - spec-kit-template-bob-ps-v0.1.0.zip
   - spec-kit-template-bob-sh-v0.1.0.zip
   - spec-kit-template-claude-ps-v0.1.0.zip
   - spec-kit-template-claude-sh-v0.1.0.zip
   - spec-kit-template-codebuddy-ps-v0.1.0.zip
   - spec-kit-template-codebuddy-sh-v0.1.0.zip
   - spec-kit-template-codex-ps-v0.1.0.zip
   - spec-kit-template-codex-sh-v0.1.0.zip
   - spec-kit-template-copilot-ps-v0.1.0.zip
   - spec-kit-template-copilot-sh-v0.1.0.zip
   - spec-kit-template-cursor-agent-ps-v0.1.0.zip
   - spec-kit-template-cursor-agent-sh-v0.1.0.zip
   - spec-kit-template-gemini-ps-v0.1.0.zip
   - spec-kit-template-gemini-sh-v0.1.0.zip
   - spec-kit-template-kilocode-ps-v0.1.0.zip
   - spec-kit-template-kilocode-sh-v0.1.0.zip
   - spec-kit-template-opencode-ps-v0.1.0.zip
   - spec-kit-template-opencode-sh-v0.1.0.zip
   - spec-kit-template-q-ps-v0.1.0.zip
   - spec-kit-template-q-sh-v0.1.0.zip
   - spec-kit-template-qoder-ps-v0.1.0.zip
   - spec-kit-template-qoder-sh-v0.1.0.zip
   - spec-kit-template-qwen-ps-v0.1.0.zip
   - spec-kit-template-qwen-sh-v0.1.0.zip
   - spec-kit-template-roo-ps-v0.1.0.zip
   - spec-kit-template-roo-sh-v0.1.0.zip
   - spec-kit-template-shai-ps-v0.1.0.zip
   - spec-kit-template-shai-sh-v0.1.0.zip
   - spec-kit-template-windsurf-ps-v0.1.0.zip
   - spec-kit-template-windsurf-sh-v0.1.0.zip
