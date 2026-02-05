#!/usr/bin/env bash
set -euo pipefail

# Simplified GitHub Release Script with interactive token input

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

# Get GitHub token interactively
get_github_token() {
    echo
    print_status "GitHub Personal Access Token Required"
    echo "----------------------------------------"
    echo "To create a release, you need a GitHub Personal Access Token."
    echo
    echo "Steps to create a token:"
    echo "1. Visit: https://github.com/settings/tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Give it a name (e.g., 'spec-kit-release')"
    echo "4. Select scope: 'public_repo' (for public repositories)"
    echo "5. Click 'Generate token'"
    echo "6. Copy the generated token"
    echo
    read -p "Enter your GitHub token: " -s GITHUB_TOKEN
    echo
    echo
    
    if [[ -z "$GITHUB_TOKEN" ]]; then
        print_error "No token provided. Exiting."
        exit 1
    fi
}

# Check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Attempting to install..."
        if command -v brew &> /dev/null; then
            brew install jq
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        else
            print_error "Cannot install jq automatically. Please install it manually:"
            print_status "  macOS: brew install jq"
            print_status "  Ubuntu/Debian: sudo apt-get install jq"
            print_status "  CentOS/RHEL: sudo yum install jq"
            exit 1
        fi
        print_success "jq installed successfully"
    fi
}

# Create GitHub release
create_release() {
    local version="$1"
    local repo_owner="lizhouyang"
    local repo_name="spec-kit-trae"
    
    print_status "Creating GitHub release for $version..."
    
    local release_body="# $version

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
All major AI coding assistants are supported including Qoder, Claude, Copilot, Cursor, Gemini, and many others."
    
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
        return 1
    fi
    
    # Extract release ID and upload URL
    RELEASE_ID=$(echo "$response_body" | jq -r '.id')
    UPLOAD_URL=$(echo "$response_body" | jq -r '.upload_url' | sed 's/{?name,label}//')
    
    print_success "Release created successfully (ID: $RELEASE_ID)"
    echo "Release URL: https://github.com/$repo_owner/$repo_name/releases/tag/$version"
    return 0
}

# Upload release assets
upload_assets() {
    local version="$1"
    local upload_url="$2"
    local assets_dir=".genreleases"
    
    print_status "Uploading release assets..."
    
    local uploaded_count=0
    local failed_count=0
    local total_files=$(ls "$assets_dir"/*.zip 2>/dev/null | wc -l)
    
    print_status "Found $total_files files to upload"
    echo
    
    # Upload all zip files
    for asset_file in "$assets_dir"/*.zip; do
        if [[ -f "$asset_file" ]]; then
            local filename=$(basename "$asset_file")
            printf "${BLUE}[INFO]${NC} Uploading %-40s " "$filename"
            
            local response
            response=$(curl -s -w "%{http_code}" \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Content-Type: application/zip" \
                --data-binary @"$asset_file" \
                "$upload_url?name=$filename" 2>/dev/null)
            
            local http_code="${response: -3}"
            
            if [[ "$http_code" == "201" ]]; then
                echo -e "${GREEN}✓${NC}"
                ((uploaded_count++))
            else
                echo -e "${RED}✗ (HTTP $http_code)${NC}"
                ((failed_count++))
            fi
        fi
    done
    
    echo
    print_status "Upload summary:"
    print_success "Successfully uploaded: $uploaded_count files"
    if [[ $failed_count -gt 0 ]]; then
        print_error "Failed to upload: $failed_count files"
        return 1
    fi
    return 0
}

# Main function
main() {
    local version="v0.1.0"
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  GitHub Release Automation Script     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # Check if we're in the right directory
    if [[ ! -d ".genreleases" ]]; then
        print_error "Must be run from the repository root directory"
        print_status "Current directory: $(pwd)"
        print_status "Expected to find .genreleases directory with zip files"
        exit 1
    fi
    
    # Check for jq
    check_jq
    
    # Get GitHub token
    get_github_token
    
    # Validate token by testing API access
    print_status "Validating GitHub token..."
    local validation_response
    validation_response=$(curl -s -w "%{http_code}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/user 2>/dev/null)
    
    local validation_code="${validation_response: -3}"
    if [[ "$validation_code" != "200" ]]; then
        print_error "Invalid GitHub token or insufficient permissions"
        print_status "Please ensure your token has 'public_repo' scope"
        exit 1
    fi
    print_success "Token validated successfully"
    echo
    
    # Create release
    if ! create_release "$version"; then
        print_error "Failed to create release"
        exit 1
    fi
    echo
    
    # Upload assets
    if ! upload_assets "$version" "$UPLOAD_URL"; then
        print_error "Failed to upload some assets"
        exit 1
    fi
    echo
    
    print_success "Release $version created and published successfully!"
    echo
    print_status "Release URL: https://github.com/lizhouyang/spec-kit-trae/releases/tag/$version"
    echo
    print_status "You can now test with:"
    echo "  uvx --from git+https://github.com/lizhouyang/spec-kit-trae.git specify init . --ai qoder --ignore-agent-tools"
    echo
    print_status "The CLI will now download templates directly from your fork instead of falling back to the original repository."
}

# Run main function
main "$@"