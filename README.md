# AD-ComputerAudit

A PowerShell-based tool to audit **Active Directory computer accounts**, with a focus on identifying **inactive** and **active** Windows devices based on `LastLogonDate`. Helps IT admins maintain a clean and secure directory by aligning with Microsoft’s device hygiene best practices.


## Author

Dimitrios "GreekGothGuy" Kasderidis | Cybersecurity Analyst & Rechercher | [LinkedIN](https://www.linkedin.com/in/dimitrios-kasderidis-ab3768205/)

## Features

- Interactive menu to select Windows version (e.g., Windows 10, Windows 11)
- Customizable inactivity threshold (defaults to 90 days)
- Lists:
  - Inactive devices
  - Active devices
  - Both (split into clearly labeled sections)
- Option to export results to a `.txt` file
- Built-in links to Microsoft’s official cleanup guidance and release information

## Getting Started

### Prerequisites

- Windows machine with PowerShell 5.1+
- Run as Admin  
- RSAT (Remote Server Administration Tools) installed — specifically the **Active Directory module**  
- Permissions to query AD (`Get-ADComputer`)

You can check for the module with:

```powershell
Get-Module -ListAvailable ActiveDirectory
```
Install RSAT if needed:

```powershell
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
```

### Usage

Clone the repository:

```powershell
git clone https://github.com/your-org/AD-ComputerAudit.git
cd AD-ComputerAudit
```

Run the script in PowerShell:

```powershell
.\AD-ComputerAudit.ps1
```

Follow the interactive prompts:
- Select Windows version
- Choose inactivity window (defaults to 90 days)
- Choose whether to export results (in .txt)

---

## License

MIT License — feel free to use, modify, and contribute.
