# Angular Tailwind Vercel starter

## Table of Contents
- [General Info](#general-info)
- [Prerequisites](#prerequisites)
- [How to Run the Script](#how-to-run-the-script)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## General Info

This script automates the process of setting up a new Angular Tailwind project, with the option to create a Github repository and automatically deploy on Vercel.

What the script does in general:
1. Install Angular CLI or use existing installation.
2. Install and configure tailwindcss, postcss, autoprefixer, prettier, prettier-plugin-tailwind, husky, lint-staged.
3. Create a new GitHub with the same name as the project (optional).
4. Deploy project on Vercel (optional).

What the script does in explicit detail:
1. Check for Node.js and jq.
2. Ask if the script should later create a GitHub repository for you and if so, check for GitHub CLI.
3. If you said yes to creating a GitHub repository, ask if the script should later deploy the project on Vercel and if so, check for Vercel CLI.
4. Check for Angular CLI installation. If found, ask if you want to proceed with the current version or install a new one. If not found, ask which version to install.
5. Ask for the path.
6. Create a new Angular project in the specified path with Angular CLI. 
7. Install the following dependencies: tailwindcss, postcss, autoprefixer, prettier, prettier-plugin-tailwind, husky, lint-staged.
8. Initialize Tailwind with: `npx tailwindcss init`.
9. Finish tailwind config by modifying tailwind.config.js.
10. Add prettier.config.js with the official tailwind prettier plugin.
11. Add .prettierignore with the usual suspects.
11. Add .vscode/settings.json and specify to use prettier as a formatter for ts and html.
12. Create a new GitHub public repository with the same name as the project (optional).
13. Deploy project on Vercel (optional).
14. It is recommended to download Tailwind CSS IntelliSense extension for VSCode.

## Prerequisites

You need to have the following installed:

1. **Node.js and npm**: This is required to run the Angular CLI and manage project dependencies.
2. **jq**: This is a lightweight command-line JSON processor. Most, but not all, Linux distributions have this installed by default.
3. **Angular CLI**: This is a command-line interface for Angular. You will have the option to install and choose the version during this script.
4. **GitHub CLI** (optional): This is required to create a GitHub repository for your project.
5. **Vercel CLI** (optional): This is required to deploy your project on Vercel.

## How to Run the Script

1. Clone the repository with `https://github.com/stechermichal/angular-tailwind-vercel-starter.git`.
2. Make the script executable using the following command:

    ```bash
    chmod +x angular-tailwind-vercel-starter.sh
    ```

5. Run the script using the following command:

    ```bash
    ./angular-tailwind-vercel-starter.sh
    ```

## Troubleshooting

If you encounter any problems while running the script:

1. Make sure you changed the script to be executable using the `chmod` command.
2. Make sure you have the necessary prerequisites installed. If the script fails while running, it will tell you which prerequisite is missing.
3. Make sure you entered the path correctly. `Documents/all-projects-folder/my-new-project` The path to where the project will be created should exist, with the last directory being the name of the project, which should not exist yet, as that will be created byt Angular CLI.

Script was tested in bash and zsh shells, but should work in other shells as well.

## FAQ

**Q: Why is this script so opinionated?**  
A: Some of that isn't entirely my fault, such as Angular CLI inexplicably forgetting that other IDEs other than VSCode exist and automatically creating .vscode folder for you. Other part is that if this script didn't do so many things, there wouldn't be much point in using it, since you could just run `ng new my-new-project` and `npx tailwindcss init` yourself. If you can think of a way to make this script less opinionated, feel free to open an issue or a pull request.

**Q: Do I need to install GitHub CLI or Vercel CLI if I don't plan on using them?**  
A: No, the script will only check for these installations if you answer 'yes' to creating a GitHub repository and deploying on Vercel.

**Q: What happens if I don't have one of the prerequisites installed?**  
A: The script will exit, and you will be provided with a message indicating which prerequisite is missing. You will need to install the missing prerequisite and run the script again. No changes will be made to your system if there was a failure with pre-requisites. That is not the case for other failures, as that might happen after the some of the commands that create the project were executed.

**Q: Can I run this script on any operating system?**  
A: This script is designed to run on a Unix-like operating system, such as Linux or MacOS. It will not run on Windows, unless you are using a compatible shell such as WSL.

**Q: I encountered a problem while running the script. How can I debug it?**  
A: Aside from checking the terminal for error messages, common point of failure might be problems inside the github or vercel CLIs, such as not being logged in, or entering the path in a different format than outlined in the Troubleshooting section.
