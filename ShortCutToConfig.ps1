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
$found=$false;
$foundArray = [System.Collections.ArrayList]@()
foreach ($file in $files) {
    $ManifestExe = Split-Path $app.Executable -Leaf
    $ShortcutExe = Split-Path $sh.CreateShortcut($file).TargetPath  -Leaf
    #$ShortcutExe
    $shResult = $sh.CreateShortcut($file);
    $shResult 
    Write-Host("---")
    $foundPath='';
    # Search for ShortCutExe in appArray, add addtional Application node to AppxManifest if exe appears in multiple lnks.
    # MPT only creates one Application node per exe.
    $res1 = ($appsArray | Where-Object { (Split-Path $_.executable -Leaf) -eq (Split-Path $sh.CreateShortcut($file).TargetPath -Leaf)})
    if ($null -ne $res1) {
        $findRes =($foundArray | Where-Object {((Split-Path $sh.CreateShortcut($file).TargetPath -Leaf))})
        if ($null -eq $findRes) {
            $index = [array]::IndexOf($appsArray, $res1)
            # $t = apps[$index];
            #$t = $manifest.CreateElement("Application");
            #$t.SetAttribute("Id",$apps[$index].Id);
            #$manifest.Package.Applications.AppendChild($t);
            $t = $manifest.Package.Applications.Application[$index].Clone();
            $manifest.Package.Applications.AppendChild($t);
            

        } else {
            $foundArray.Add((Split-Path $sh.CreateShortcut($file).TargetPath -Leaf))
        }
        if ($found -eq $true) {
            $i = $appsArray.Add($res1);
            $res1 = res$appsArray[$i];
            $found=$false;
        } 
        $res1.executable = $sh.CreateShortcut($file).TargetPath  
        $res1.arguments = $sh.CreateShortcut($file).Arguments
    }
}
$appsArray | ConvertTo-Json 

