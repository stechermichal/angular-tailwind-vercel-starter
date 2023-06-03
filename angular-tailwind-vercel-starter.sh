#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

# Icons
CHECK_MARK="✔"
X_MARK="✖"

# Functions
function check_command() {
    if ! command -v $1 &>/dev/null; then
        echo -e "${RED}${X_MARK} '$1' command not found. Please make sure $2 is installed and is in your system's PATH, as it is required for this script. No changes have been made to your system.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}${CHECK_MARK} $1 is installed.${RESET}"
}

function read_input() {
    echo -e -n "${GREEN}$1 [y/N]: ${RESET}"
    read choice
    [[ "${choice,,}" == "yes" || "${choice,,}" == "y" ]]
}

function read_input_yes_default() {
    echo -e -n "${GREEN}$1 [Y/n]: ${RESET}"
    read choice
    [[ "${choice,,}" == "no" || "${choice,,}" == "n" ]] && return 1 || return 0
}

function install_angular_cli() {
    echo -e -n "${GREEN}Enter desired Angular version (e.g., 12.0.0), or leave blank for latest: ${RESET}"
    read angular_version
    if [ -z "$angular_version" ]; then
        npm install -g @angular/cli
    else
        npm install -g @angular/cli@$angular_version
    fi
}

# Main script
node_version=$(node --version)
check_command "node" "Node.js"
echo -e "${GREEN}${CHECK_MARK} Node.js version: $node_version${RESET}"
check_command "jq" "jq"

if read_input "Will you want to create a GitHub repository for this project? If yes, you will also be offered to deploy on Vercel."; then
    check_command "gh" "Github CLI"
    create_github_repo=true

    if read_input "Do you want to deploy this project on Vercel?"; then
        check_command "vercel" "Vercel CLI"
        deploy_vercel=true
    fi
fi

if command -v ng &>/dev/null; then
    echo -e "${GREEN}${CHECK_MARK} Angular CLI installation found.${RESET}"
    angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
    echo -e "${GREEN}Current installed Angular CLI version: $angular_cli_version${RESET}"
    if ! read_input_yes_default "Do you want to proceed with this version? If not, you will be prompted for the version."; then
        install_angular_cli
        angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
    fi
else
    echo -e "${RED}${X_MARK} Angular CLI installation not found.${RESET}"
    install_angular_cli
    angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
fi
echo -e "${GREEN}${CHECK_MARK} Angular CLI version: $angular_cli_version${RESET}"

# Define project path and name
read -p "Enter the project path and name (e.g., 'Documents/new-project'): " location_and_project_name
location_and_project_name="${location_and_project_name#/}"
location_and_project_name="${location_and_project_name%/}"

# Extract workspace name and location
IFS='/' read -ra path_parts <<<"$location_and_project_name"
workspace_name="${path_parts[-1]}"
location="${location_and_project_name%/*}"

# Validate location and workspace
if [[ ! -d ~/"$location" || -d ~/"$location"/"$workspace_name" ]]; then
    echo -e "${RED}${X_MARK} Invalid location or workspace already exists. Exiting...${RESET}"
    exit 1
fi

# Navigate to location and create new workspace
cd ~/"$location" && ng new $workspace_name --routing && cd $workspace_name || exit 1

# Install dependencies
npm install -D tailwindcss postcss autoprefixer prettier prettier-plugin-tailwindcss husky lint-staged

# Configure husky
npx husky install

# Add husky hook
npx husky add .husky/pre-commit "npx lint-staged"

# Add lint-staged configuration to package.json
temp=$(mktemp)
jq '. += {"lint-staged": {"*.ts": ["prettier --write"], "*.html": ["prettier --write"], "*.css": ["prettier --write"], "*.js": ["prettier --write"]}}' package.json >"$temp" && mv "$temp" package.json

# Initialize tailwindcss
npx tailwindcss init

# Configure files
cat >tailwind.config.js <<EOL
/** @type {import('tailwindcss').Config} */
module.exports = { content: ["./src/**/*.{html,ts}"], theme: { extend: {} }, plugins: [], }
EOL

cat >prettier.config.js <<EOL
module.exports = { plugins: [require('prettier-plugin-tailwindcss')], trailingComma: 'es5', tabWidth: 2, semi: false, singleQuote: true, pluginSearchDirs: false, }
EOL

echo -e "node_modules\n.gitignore\n*.gitignore\nnode_modules\n*.min.js\n.angular" >.prettierignore

# Configure VS Code settings
mkdir -p ./.vscode && cat >./.vscode/settings.json <<EOL
{ "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode", "editor.formatOnSave": true }, "[html]": { "editor.defaultFormatter": "esbenp.prettier-vscode", "editor.formatOnSave": true }, }
EOL

# Add Tailwind directives to styles file
styles_file=$(find ./src -name "styles.*")
stylesheet_extension="${styles_file##*.}"
echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" >./src/styles.$stylesheet_extension

# Create and push to GitHub repo if requested
if [[ $create_github_repo ]]; then
    gh repo create $workspace_name --public
    git remote add origin https://github.com/$(gh api user | jq -r .login)/$workspace_name.git
    git add . && git commit -m "Initial commit" && git push -u origin master
fi

# Deploy on Vercel if requested
if [[ $deploy_vercel ]]; then vercel; fi

# Display completion messages
echo -e "${GREEN}${CHECK_MARK} Angular project with TailwindCSS created and initialized!${RESET}"
[[ $create_github_repo ]] && echo -e "${GREEN}${CHECK_MARK} Project pushed to GitHub.${RESET}"
[[ $deploy_vercel ]] && echo -e "${GREEN}${CHECK_MARK} Project deployed on Vercel!${RESET}"
echo -e "${RED}NOTE: ${RESET}For TailwindCSS, consider downloading the IntelliSense extension for VS Code (https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)."

exit 0
