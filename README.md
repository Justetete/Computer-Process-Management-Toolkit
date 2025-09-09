# Process Management Toolkit 🛠️

## Project Overview 💡
This is a **bash-based helper script** designed to be a simple yet effective tool for managing and gaining insights into system processes. It provides a user-friendly, menu-driven interface, allowing for easy process inquiry, signal control, and logging. The script is an ideal utility for system administrators, developers, or anyone who needs to quickly monitor and interact with running processes.

![](https://raw.githubusercontent.com/Justetete/PicGo-Photo-Cloud/main/Screenshot%202025-09-09%20at%2022.35.32.png)

## Key Features 🔮
- 🟩 **Interactive Menu**: A clear and intuitive menu guides users through all available functionalities, making it easy to navigate.
- 🟦 **Comprehensive Process Inquiry**:
    - **User-Specific Processes**: Display detailed information for processes owned by the current user.
    - **All System Processes**: View a complete list of all running processes on the system.
    - **Process Search**: Find specific processes by name or PID (Process ID).
- 🟨 **Process Control**: Send various signals (e.g., `SIGKILL`, `SIGTERM`) to processes by their PID to terminate, stop, or manage them.
- 🟪 **Session Logging**: Track all signals sent to processes during a session and save the log to a file for future reference.
- 🟥 **Status Legend**: A color-coded legend helps users quickly identify the state of each process (e.g., Running, Sleeping, Zombie).

## How to Start 🚀
1. Clone the repository:
```bash
git clone git@github.com:Justetete/Computer-Process-Management-Toolkit.git
```
2. Navigate to the project directory:
```bash
cd Computer-Process-Management-Toolkit
```
3. Run the script:
```bash
./bash-helper.sh
```
***Note***: You might need to make the script executable first with `chmod +x bash-helper.sh`.

## Technology Stack
- **Bash**: The entire toolkit is built using Bash scripting, leveraging standard Linux commands like `ps` and `kill`.
- **Terminal Colors**: The script uses ANSI color codes to provide a more readable and visually appealing output.

## Contributing 🤝
We welcome contributions! 🎉 If you'd like to contribute, please follow these steps:

1. Fork the repository.

2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Commit your changes:
   ```bash
   git commit -m "feat: Add your awesome feature"
   ```

4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```

5. Open a Pull Request to the `main` branch of this repository. 🚀
