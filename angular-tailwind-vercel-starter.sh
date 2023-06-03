#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# Icons
CHECK_MARK="✔"
X_MARK="✖"
WARNING_SIGN="⚠"

# Check Node.js installation
node_version=$(node --version)
if [ -z "$node_version" ]; then
    echo -e "${RED}${X_MARK} 'node' command not found. Please make sure Node.js is installed and is in your system's PATH, as it is required for this script. No changes have been made to your system.${RESET}"
    exit 1
fi
echo -e "${GREEN}${CHECK_MARK} Node.js version: $node_version${RESET}"
sleep 2

echo -n "Will you want to create a GitHub repository for this project? If yes, you will also be offered to deploy on Vercel. [Y/n]: "
read create_github_repo

if [[ "${create_github_repo,,}" == "yes" || "${create_github_repo,,}" == "y" ]]; then
    # Check if jq is installed
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}${X_MARK} 'jq' command not found. Please make sure jq is installed and is in your system's PATH, as it is required for Github CLI. No changes have been made to your system.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}${CHECK_MARK} jq is installed.${RESET}"

    # Check GitHub CLI installation
    if ! command -v gh &>/dev/null; then
        echo -e "${RED}${X_MARK} 'gh' command not found. Please make sure Github CLI is installed and is in your system's PATH, as it is required if you want to create a GitHub repository. No changes have been made to your system.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}${CHECK_MARK} GitHub CLI is installed.${RESET}"

    echo -n "Do you want to deploy this project on Vercel? [Y/n]: "
    read deploy_vercel
    if [[ "${deploy_vercel,,}" == "yes" || "${deploy_vercel,,}" == "y" ]]; then
        # Check Vercel CLI installation
        if ! command -v vercel &>/dev/null; then
            echo -e "${RED}${X_MARK} 'vercel' command not found. Please make sure Vercel CLI is installed and is in your system's PATH, as it is required if you want to deploy this project on Vercel. No changes have been made to your system.${RESET}"
            exit 1
        fi
        echo -e "${GREEN}${CHECK_MARK} Vercel CLI is installed.${RESET}"
    fi
fi
sleep 2

# Check Angular CLI installation and install if needed
if command -v ng &>/dev/null; then
    echo -e "${GREEN}${CHECK_MARK} Angular CLI installation found.${RESET}"
    angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
    echo "Current installed Angular CLI version: $angular_cli_version"
    echo -n "Do you want to proceed with this version? If not, you will be prompted for the version. [Y/n]: "
    read proceed_with_current
    if [[ "${proceed_with_current,,}" != "yes" && "${proceed_with_current,,}" != "y" ]]; then
        echo -n "Enter desired Angular version (e.g., 12.0.0), or leave blank for latest: "
        read angular_version
        if [ -z "$angular_version" ]; then
            # If no version is provided, install the latest version
            npm install -g @angular/cli
        else
            # If a version is provided, install that version
            npm install -g @angular/cli@$angular_version
        fi
        angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
    fi
else
    echo -e "${RED}${X_MARK} Angular CLI installation not found.${RESET}"
    echo -n "Enter the desired Angular version (e.g., 12.0.0), or leave blank for latest: "
    read angular_version
    if [ -z "$angular_version" ]; then
        # If no version is provided, install the latest version
        npm install -g @angular/cli
    else
        # If a version is provided, install that version
        npm install -g @angular/cli@$angular_version
    fi
    angular_cli_version=$(ng version | grep 'Angular CLI' | awk '{print $3}')
fi
echo -e "${GREEN}${CHECK_MARK} Angular CLI version: $angular_cli_version${RESET}"
sleep 2

# Get project location and project name
echo -n "Enter the project path and name. Start with a directory (existing) under your home directory, followed by a new project name (e.g., 'Documents/sourcefiles/new-project'). The path should be relative to your home directory (~): "
read location_and_project_name

# Remove leading "/" if any
location_and_project_name="${location_and_project_name#/}"

# Remove trailing slash if exists
location_and_project_name="${location_and_project_name%/}"

IFS='/' read -r -a path_parts <<<"$location_and_project_name"

last_index=$((${#path_parts[@]} - 1))
workspace_name="${path_parts[last_index]}"

unset 'path_parts[last_index]'
location=$(
    IFS=/
    echo "${path_parts[*]}"
)

# Check if the location exists and the new project does not
if [ -d ~/"$location" ] && [ ! -d ~/"$location"/"$workspace_name" ]; then
    # Change directory to project location
    cd ~/"$location" || exit 1

    ng new $workspace_name --routing

    # Navigate into the new project directory
    cd ./$workspace_name || exit 1
else
    if [ ! -d ~/"$location" ]; then
        echo -e "${RED}${X_MARK} The directory '$location' does not exist. Please ensure the directory exists before running the script. No changes have been made to your system, aside from potentially installing Angular CLI, if that's what you chose.${RESET}"
    else
        echo -e "${RED}${X_MARK} The project '$workspace_name' already exists in the directory '$location'. Please choose a new project name. No changes have been made to your system, aside from potentially installing Angular CLI, if that's what you chose.${RESET}"
    fi
    exit 1
fi

# Install tailwindcss, postcss, autoprefixer
npm install -D tailwindcss postcss autoprefixer

# Install prettier and the official prettier tailwind plugin
npm install -D prettier prettier-plugin-tailwindcss

# Generate tailwind.config.js file
npx tailwindcss init

# Configure Tailwind CSS in tailwind.config.js file
cat >tailwind.config.js <<EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

cat >prettier.config.js <<EOL
module.exports = {
  plugins: [require('prettier-plugin-tailwindcss')],
  trailingComma: 'es5',
  tabWidth: 2,
  semi: false,
  singleQuote: true,
  pluginSearchDirs: false,
}
EOL

cat >.prettierignore <<EOL
node_modules
.gitignore
*.gitignore
node_modules
*.min.js
.angular
EOL

# Check if the .vscode directory exists and create it if it doesn't
if [ ! -d ./.vscode ]; then
    mkdir .vscode
fi

# Add the necessary settings to .vscode/settings.json
cat >./.vscode/settings.json <<EOL
{
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
}
EOL

# Detect stylesheet extension
styles_file=$(find ./src -name "styles.*")
stylesheet_extension="${styles_file##*.}"

# Add Tailwind directives to styles.css (or styles.scss, styles.less, etc.) file
cat >./src/styles.$stylesheet_extension <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

if [[ "${create_github_repo,,}" == "yes" || "${create_github_repo,,}" == "y" ]]; then
    # Create a new repository using GitHub CLI
    gh repo create $workspace_name --public

    # Set the remote repository
    git remote add origin https://github.com/$(gh api user | jq -r .login)/$workspace_name.git

    # Add all files to the staging area
    git add .

    # Commit the changes
    git commit -m "Initial commit"

    # push the changes to the new github repository
    git push -u origin master
fi

if [[ "${deploy_vercel,,}" == "yes" || "${deploy_vercel,,}" == "y" ]]; then
    # Deploy the project on Vercel
    vercel
fi

echo -e "${GREEN}${CHECK_MARK} Angular project with TailwindCSS created and initialized!${RESET}"
if [[ "${create_github_repo,,}" == "yes" || "${create_github_repo,,}" == "y" ]]; then
    echo -e "${GREEN}${CHECK_MARK} Project pushed to GitHub.${RESET}"
fi
if [[ "${deploy_vercel,,}" == "yes" || "${deploy_vercel,,}" == "y" ]]; then
    echo -e "${GREEN}${CHECK_MARK} Project deployed on Vercel!${RESET}"
    echo -e "${GREEN}IMPORTANT:${RESET} You github repository has NOT been linked to the Vercel project, the current deployed Initial commit was deployed from the local repository."
    echo "If you want Vercel to deploy the new version each time you push to master, you can link it easily on the Vercel dashboard by clicking on the 'Connect Git Repository' button."
fi
echo "Before using TailwindCSS, it's heavily recommended to download the TailwindCSS IntelliSense extension for VS Code (https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)."

exit 0
