# Create config.json for apps that rely on command line parameters
# Read shortcut files, extract exe with parameters
# Create config.json application record with arguments and App id extracted from AppxManifest.XML
# Requires:
# AppxManifest.xml 
# All Shortcut files (*.LNK) (created when app installed via MSI).
# All files should be in the same folder as this script.

$psfLauncher='psflauncher32.exe'

# config.json Application arguments
$applications = @{
    id = ''
    executable = ''
    arguments = ''
    }
$configjsonArray = [System.Collections.ArrayList]@()

# Get AppIds from manifest
[xml]$manifest = get-content "AppxManifest.xml"
$appsInManifest= $manifest.Package.Applications.Application
foreach ($app in $appsInManifest) {
    $object = new-object psobject -Property $applications
    $object.id= $app.id;
    $object.executable = $app.Executable;
    $res = $configjsonArray.Add($object);
}

# For each shortcut (lnk):
# Extract the executable shortcut and detemine the index in the Applications collection in the manifest
# https://www.alexandrumarin.com/add-shortcut-arguments-in-msix-with-psf/
$sh = New-Object -ComObject WScript.Shell
$files=Get-ChildItem *.lnk
$foundArray = [System.Collections.ArrayList]@()
foreach ($file in $files) {
    # Search for ShortCutExe in appArray, add addtional Application node to AppxManifest if exe appears in multiple lnks.
    # MPT only creates one Application node per exe.
    $searchResults = ($configjsonArray | Where-Object { (Split-Path $_.executable -Leaf) -eq (Split-Path $sh.CreateShortcut($file).TargetPath -Leaf)})
    if ($searchResults.Count -gt 1) {
        $configJson=$searchResults[0];
    } else {
        $configJson=$searchResults;
    }

    if ($null -ne $configJson) {
        $findRes =$foundArray -contains (Split-Path $sh.CreateShortcut($file).TargetPath -Leaf)
        if ($true -ne $findRes) {
            $res = $foundArray.Add((Split-Path $sh.CreateShortcut($file).TargetPath -Leaf))
            $configJson.executable = $sh.CreateShortcut($file).TargetPath  
            $configJson.arguments = $sh.CreateShortcut($file).Arguments
        } else {
            $index = [array]::IndexOf($configjsonArray, $configJson)
            if ($index -gt -1) {
                $tempNode = $manifest.Package.Applications.Application[$index].Clone();
                $attrib= $tempNode.GetAttribute("Id") + $manifest.Package.Applications.Application.Count;
                $tempNode.SetAttribute("Id",$attrib);
                $res = $manifest.Package.Applications.AppendChild($tempNode);
            
                $object = new-object psobject -Property $applications
                $object.id= $attrib;
                $object.executable = $sh.CreateShortcut($file).TargetPath
                $object.arguments = $sh.CreateShortcut($file).Arguments  
                $res = $configjsonArray.Add($object);
            }
        }
    }
}

# Set Executable in manifest to PSFLauncher32/64.exe
foreach ($app in $manifest.Package.Applications.Application) {
    $app.SetAttribute("Executable", $psfLauncher);
}

# Write new manifest and config.txt (use this in your config.json)
$outPath = (Split-Path -Path $MyInvocation.MyCommand.Path);
$manifest.Save($outPath + "\AppxManifestNew.xml");
$configjsonArray | ConvertTo-Json | Out-File ($outPath + "config.txt");

