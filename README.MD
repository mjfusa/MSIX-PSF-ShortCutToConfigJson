# Sample: MSIX PSF - Create config.json with command line arguments extracted from app Shortcuts 

## PowerShell Script: ShortCutToConfig.ps1

## Requires:

1. AppxManifest.xml extracted from the MSIX created with the [MSIX Packaging tool](https://www.microsoft.com/en-us/p/msix-packaging-tool/9n5lw3jbcxkf).
2. All Shortcut files (*.LNK) (created when app installed via MSI).
3. All files should be in the same folder as this script.

## Introduction

The [Package Support Framework](https://github.com/Microsoft/MSIX-PackageSupportFramework/) (PSF) is a powerful tool for extending the capabilities of out-of-the-box MSIX. For example, you can run PowerShell scripts, add fix ups that can change the current working directory or re-route file writes - without having to modify the application itself. 

Some packaging scenarios require reusing the same executable with different command line arguments to in-effect, present a different app to the user.  Others require the app be started with command line arguments to properly initialize. Take for example the command lines for Python 3.9:

This command line starts the Python IDE:

```pythonw.exe Lib\idlelib\idle.pyw```

This command line starts the Python Documentation:

```python.exe  -m pydoc -b```

This command line starts the Python CLI:

```python.exe```

By default, when using the MSIX Packaging Tool, python.exe and pythonw.exe are detected and added to the manifest. When installed there will be seperate entires in the Start menu - but there will be no  entries for exes the need to be started with unique command lines. We will use PSF to enable this senario.

## ShortCutToConfig.ps1

This script:
1. Creates an AppxManifestNew.xml which contains:

* Additional applications as needed for the multiple non-unique executables

* Replaces the Executable element in the Application defintion with ```PsfLauncher32/64.exe```

2. Creates config.txt which contains an ```application``` definition for each app launch scenario including the command line parameters. 

```
{
    "applications": [
        {
            "id": "",
            "executable": "",
            "arguments": ""
        }
    ]
}
```

It does this by reading the shortcut files (.lnks) and reconciling the manifest and config.json with the needed entries.

## Integrate PSF

Use the MSIX Packaging tool to modify the original MSIX to include the manifest and add PSF.

