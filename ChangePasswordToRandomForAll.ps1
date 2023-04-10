<#
.SYNOPSIS
This script generates a random password for each enabled user account in a specified Organizational Unit (OU) in 
Active Directory, and updates the ExtensionAttribute15 property of each user to "PasswordChanged".

.DESCRIPTION
This PowerShell script retrieves a list of enabled user accounts in a specified Organizational Unit (OU) in Active 
Directory using the Get-ADUser cmdlet. For each user account, it generates a random password that includes a mix of 
digits, lowercase and uppercase letters, and symbols, and sets the new password for the user account using the 
Set-ADAccountPassword cmdlet. It then updates the ExtensionAttribute15 property of each user to "PasswordChanged" 
using the Set-ADUser cmdlet. Finally, it writes a log message to a file named ChangedPasswords.log that shows the 
new password for each user.

.PARAMETER BaseOU
The Organizational Unit (OU) in Active Directory where user accounts are located.

.PARAMETER LogFilePath
The path to the log file where password changes are recorded. The default value is "ChangedPasswords.log".

.PARAMETER PasswordLength
The length of the generated passwords. The default value is 32.

.NOTES
- This script requires the Active Directory module for Windows PowerShell.
- The password length and symbol characters can be customized by modifying the $PasswordLength and $Symbols variables, respectively.
- The path to the log file can be customized by providing a value for the $LogFilePath parameter.

.COMPONENT
This script uses the following Windows PowerShell cmdlets:
- Get-ADUser
- Set-ADAccountPassword
- Set-ADUser
- Write-Output
- Add-Content
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$BaseOU,
    
    [Parameter(Mandatory=$false)]
    [string]$LogFilePath = "ChangedPasswords.log",
    
    [Parameter(Mandatory=$false)]
    [int]$PasswordLength = 32
)

$Symbols = "!@#$%^&*()_+-={}[]|\:;'<>,.?/"

$Users = Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase $BaseOU

foreach ($User in $Users) {
    $PasswordChars = (48..57) + (97..122) + (65..90) + $Symbols.ToCharArray()
    $NewPassword = -join ($PasswordChars | Get-Random -Count $PasswordLength | ForEach-Object {[char]$_})
    Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString -String $NewPassword -Force -AsPlainText)
    Set-ADUser -Identity $User -Replace @{ExtensionAttribute15 = "PasswordChanged"}
    $LogMessage = "Password for $($User.SamAccountName) set to: $NewPassword"
    Write-Output $LogMessage
    Add-Content -Path $LogFilePath -Value $LogMessage
}

