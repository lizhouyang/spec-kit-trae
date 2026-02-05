#!/usr/bin/env bash
set -euo pipefail

# Automated GitHub Release Creation Script
# Creates a GitHub release and uploads all template packages

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if GitHub token is available
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        print_error "GITHUB_TOKEN environment variable is not set"
        print_status "Please set it with: export GITHUB_TOKEN=your_token_here"
        print_status "You can create a token at: https://github.com/settings/tokens"
        exit 1
    fi
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed"
        print_status "Install it with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [[ ! -d ".genreleases" ]]; then
        print_error "Must be run from the repository root directory"
        print_status "Current directory: $(pwd)"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Create GitHub release
create_release() {
    local version="$1"
    local repo_owner="lizhouyang"
    local repo_name="spec-kit-trae"
    
    print_status "Creating GitHub release for $version..."
    
    local release_body=$(cat <<EOF
# $version

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
EOF
)
    
    local response
    response=$(curl -s -w "%{http_code}" -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/$repo_owner/$repo_name/releases \
        -d "{\"tag_name\":\"$version\",\"name\":\"$version\",\"body\":\"$(echo "$release_body" | jq -sR .)\",\"draft\":false,\"prerelease\":false}")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [[ "$http_code" != "201" ]]; then
        print_error "Failed to create release. HTTP $http_code"
        echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
        exit 1
    fi
    
    # Extract release ID and upload URL
    RELEASE_ID=$(echo "$response_body" | jq -r '.id')
    UPLOAD_URL=$(echo "$response_body" | jq -r '.upload_url' | sed 's/{?name,label}//')
    
    print_success "Release created successfully (ID: $RELEASE_ID)"
    echo "Release URL: https://github.com/$repo_owner/$repo_name/releases/tag/$version"
}

# Upload release assets
upload_assets() {
    local version="$1"
    local upload_url="$2"
    local assets_dir=".genreleases"
    
    print_status "Uploading release assets..."
    
    local uploaded_count=0
    local failed_count=0
    
    # Upload all zip files
    for asset_file in "$assets_dir"/*.zip; do
        if [[ -f "$asset_file" ]]; then
            local filename=$(basename "$asset_file")
            print_status "Uploading $filename..."
            
            local response
            response=$(curl -s -w "%{http_code}" \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Content-Type: application/zip" \
                --data-binary @"$asset_file" \
                "$upload_url?name=$filename")
            
            local http_code="${response: -3}"
            local response_body="${response%???}"
            
            if [[ "$http_code" == "201" ]]; then
                print_success "Uploaded $filename"
                ((uploaded_count++))
            else
                print_error "Failed to upload $filename. HTTP $http_code"
                echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
                ((failed_count++))
            fi
        fi
    done
    
    print_status "Upload summary:"
    print_success "Successfully uploaded: $uploaded_count files"
    if [[ $failed_count -gt 0 ]]; then
        print_error "Failed to upload: $failed_count files"
        exit 1
    fi
}

# Main function
main() {
    local version="v0.1.0"
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  GitHub Release Automation Script     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    check_prerequisites
    echo
    create_release "$version"
    echo
    upload_assets "$version" "$UPLOAD_URL"
    echo
    print_success "Release $version created and published successfully!"
    print_status "You can now test with:"
    echo "  uvx --from git+https://github.com/lizhouyang/spec-kit-trae.git specify init . --ai qoder --ignore-agent-tools"
}

# Run main function
main "$@"