#!/bin/bash

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "'jq' command not found. Please make sure jq is installed and is in your system's PATH."
    exit 1
fi
echo "jq is installed."

# Check Node.js installation
node_version=$(node --version)
if [ -z "$node_version" ]; then
    echo "'node' command not found. Please make sure Node.js is installed and is in your system's PATH."
    exit 1
fi
echo "Node.js version: $node_version"
sleep 2

# Check GitHub CLI installation
if ! command -v gh &>/dev/null; then
    echo "'gh' command not found. Please make sure Github CLI is installed and is in your system's PATH."
    exit 1
fi
echo "GitHub CLI is installed."
sleep 2

# Check Angular CLI installation and install if needed
if command -v ng &>/dev/null; then
    echo "Angular CLI is already installed."
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
    echo "Angular CLI not found, installing..."
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
echo "Angular CLI is installed, version: $angular_cli_version"
sleep 3

# Get project location
echo -n "Enter project location, folder must exist (relative path, e.g., 'Documents/sourcefiles', as the path is prefixed with ~): "
read location

# Change directory to project location
cd ~/"$location" || exit 1

# Initialize a new Angular project
echo -n "Enter the name of the project: "
read workspace_name
ng new $workspace_name

# Navigate into the new project directory
cd ./$workspace_name || exit 1

# Install tailwindcss, postcss, autoprefixer
npm install -D tailwindcss postcss autoprefixer

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

# Add Tailwind directives to styles.css file
cat >./src/styles.css <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Create a new repository using GitHub CLI
gh repo create

# Set the remote repository
git remote add origin https://github.com/$(gh api user | jq -r .login)/$workspace_name.git

# Add all files to the staging area
git add .

# Commit the changes
git commit -m "Initial commit"

# push the changes to the new github repository
git push -u origin master
