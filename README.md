# Angular Setup Script README

This script automates the process of setting up a new Angular project on your local machine. It will check and install necessary dependencies, create the project structure, and optionally setup a GitHub repository and Vercel deployment.

## Prerequisites

You need to have the following installed:

1. **Bash Shell**: Bash is a Unix shell and command language, which can be installed on any operating system.
2. **Node.js and npm**: This is required to run the Angular CLI and manage project dependencies.
3. **jq**: This is a lightweight and flexible command-line JSON processor.
4. **Angular CLI**: This is a command-line interface for Angular.
5. **GitHub CLI** (optional): This is required to create a GitHub repository for your project.
6. **Vercel CLI** (optional): This is required to deploy your project on Vercel.

## How to Run the Script

1. Save the script to your local machine. You can give it any name, for example, `setup-angular.sh`.
2. Open your terminal.
3. Navigate to the directory where you have saved the script, using the `cd` command.
4. Make the script executable using the following command:

    ```bash
    chmod +x setup-angular.sh
    ```

5. Run the script using the following command:

    ```bash
    ./setup-angular.sh
    ```

## Follow the Prompts

When you run the script, it will guide you through the setup process by prompting you for inputs:

1. The script will first check for the necessary installations - Node.js, Angular CLI, jq, GitHub CLI, and Vercel CLI.
2. It will then ask if you want to create a GitHub repository for your project.
3. If you answer 'yes', it will then ask if you want to deploy this project on Vercel.
4. It will then check for Angular CLI installation. If found, it will ask if you want to proceed with the current version or install a new one.
5. You will then be asked to enter the path and name of your new project.
6. The script will then navigate to your specified location and create a new workspace there.
7. The script will install the project dependencies, initialize and configure TailwindCSS, Prettier, Husky, and lint-staged.
8. If you had chosen to create a GitHub repository, it will then initialize a git repository, commit the initial setup, and push it to GitHub.
9. If you had chosen to deploy the project on Vercel, it will then run the Vercel command for deployment.

## Troubleshooting

If you encounter any problems while running the script:

1. Ensure that you have all the necessary installations and that they are up-to-date.
2. Make sure you have internet connectivity during the setup, as the script needs to download dependencies.
3. Ensure that the directory path you provide does not already exist.

If the issue persists, seek help from your system administrator or an experienced colleague.

Remember, this script is meant to be run in a bash shell environment. If you're using another shell (like zsh, fish, etc.), some commands may not work as expected. It's recommended to switch to bash while running this script.

## FAQ

**Q: Do I need to install GitHub CLI or Vercel CLI if I don't plan on using them?**  
A: No, the script will only check for these installations if you answer 'yes' to creating a GitHub repository and deploying on Vercel.

**Q: What happens if I don't have one of the prerequisites installed?**  
A: The script will exit, and you will be provided with a message indicating which prerequisite is missing. You will need to install the missing prerequisite and run the script again.

**Q: Can I run this script on any operating system?**  
A: This script is designed to run on a Unix-like operating system with a Bash shell, such as Linux or MacOS. It may not run correctly on other operating systems like Windows, unless you are using a compatible shell such as WSL (Windows Subsystem for Linux).

**Q: I encountered a problem while running the script. How can I debug it?**  
A: The script is designed to provide informative messages if something goes wrong. Check these messages for clues about what went wrong. If you're still having trouble, you may wish to consult with a more experienced colleague or seek help online.
