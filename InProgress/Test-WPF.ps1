Add-Type -AssemblyName PresentationFramework

[xml]$Form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="WPF Form" Height="480" Width="640">
</Window>
"@

$NodeReader = (New-Object System.Xml.XmlNodeReader $Form)
$Window = [Windows.Markup.XamlReader]::Load($NodeReader)

$Window.ShowDialog()