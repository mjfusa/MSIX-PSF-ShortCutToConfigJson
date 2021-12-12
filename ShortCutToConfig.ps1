# Create config.json for apps that rely on command line parameters
# Read shortcut files, extract exe with parameters
# Create config.json application record with arguments and App id extracted from AppxManifest.XML
# Requires:
# AppxManifest.xml 
# All Shortcut files (*.LNK) (created when app installed via MSI).
# All files should be in the same folder as this script.

# config.json Application arguments
$applications = @{
    id = 'APP'
    executable = ''
    arguments = ''
    }
$appsArray = [System.Collections.ArrayList]@()

# Get AppIds from manifest
[xml]$manifest = get-content "AppxManifest.xml"
#$manifest.Package.Identity.Version = "$env:NBGV_SimpleVersion.0"
$apps= $manifest.Package.Applications.Application
foreach ($app in $apps) {
    $object = new-object psobject -Property $applications
    $object.id= $app.id;
    $object.executable = $app.Executable;
    $res = $appsArray.Add($object);
}

# https://www.alexandrumarin.com/add-shortcut-arguments-in-msix-with-psf/
$sh = New-Object -ComObject WScript.Shell
$files=Get-ChildItem *.lnk
foreach ($file in $files) {
    $ManifestExe = Split-Path $app.Executable -Leaf
    $ShortcutExe = Split-Path $sh.CreateShortcut($file).TargetPath  -Leaf
    $res1 = ($appsArray | where { (Split-Path $_.executable -Leaf) -eq (Split-Path $sh.CreateShortcut($file).TargetPath -Leaf)})
    if ($res1 -ne $null) {
        $res1.executable = $sh.CreateShortcut($file).TargetPath  
        $res1.arguments = $sh.CreateShortcut($file).Arguments
    }
}
$appsArray | ConvertTo-Json 

