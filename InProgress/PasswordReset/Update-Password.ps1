Import-Module MSOnline
Add-Type -AssemblyName PresentationFramework

Function Check-Connection {
    If (-not (Get-PSSession | where{$_.ComputerName -eq "ps.outlook.com"})) {
        $O365Credentials = Get-Credential
        $O365Session = New-PSSession –ConfigurationName "Microsoft.Exchange" -ConnectionUri "https://ps.outlook.com/powershell" -Credential $O365Credentials -Authentication Basic -AllowRedirection
        Import-PSSession $O365Session -AllowClobber
        Connect-MsolService –Credential $O365Credentials
    }
    return (Get-PSSession | where{$_.ComputerName -eq "ps.outlook.com"}) -ne $null
}

Function Generate-Password() {
    For($i=0;$i -lt 12; $i++) {
        $random = (Get-Random(74))+48
        $char = [char]$random
        $password += $char
    }
    Return $password
}

[xml]$Form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Password Reset" Height="168" Width="261">
<Grid>
    <Label Name="labelUserName" Content="User Name:" HorizontalAlignment="Left" Height="25" Margin="10,10,0,0" VerticalAlignment="Top" Width="77"/>
    <Label Name="labelPassword" Content="Password:" HorizontalAlignment="Left" Height="23" Margin="10,40,0,00" VerticalAlignment="Top" Width="77"/>
    <TextBox Name="UserName" HorizontalAlignment="Left" Height="25" Margin="92,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="140"/>
    <TextBox Name="Password" HorizontalAlignment="Left" Height="23" Margin="92,40,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="140"/>
    <Button Name="GeneratePassword" Content="Generate Password" HorizontalAlignment="Left" Height="35" Margin="10,82,0,0" VerticalAlignment="Top" Width="110"/>
    <Button Name="UpdatePassword" Content="Update Password" HorizontalAlignment="Left" Height="35" Margin="125,82,0,0" VerticalAlignment="Top" Width="110"/>
</Grid>
</Window>
"@

$NodeReader = (New-Object System.Xml.XmlNodeReader $Form)
$Window = [Windows.Markup.XamlReader]::Load($NodeReader)

$userNameField = $Window.FindName("UserName")
$passwordField = $Window.FindName("Password")
$generateButton = $Window.FindName("GeneratePassword")
$updateButton = $Window.FindName("UpdatePassword")

$generateButton.Add_Click({
    $passwordField.text = Generate-Password
})

$updateButton.Add_Click({
    If (Check-Connection) {
        Try {
            $user = Get-MsolUser -UserPrincipalName $userNameField.Text
        } Catch {
            $user = $null
        }
        $password = $passwordField.Text
        Write-Host $password
        Write-Host $passwordField.Text
        If ($passwordField.Text -eq "") {
            [System.Windows.MessageBox]::Show("Please make sure that the Password has been generated.", "Password Error")
        } ElseIf ($user -eq $null) {
            [System.Windows.MessageBox]::Show("Please enter a valid User Name before clicking Update Password.", "User Error")
        } Else {
            Set-MsolUserPassword -UserPrincipalName $userNameField.Text -NewPassword (ConvertTo-SecureString -AsPlainText $passwordField.Text -Force)
            [System.Windows.MessageBox]::Show("Your password has been reset. Your new password is $passwordField.Text and it must be changes on first use.", "Update Completed")
            $userNameField.text = ""
            $passwordField.text = ""
        }
    }
})

$Window.ShowDialog()