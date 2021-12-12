# Sample: MSIX PSF - Create config.json to pass command line arguments

## This script does the following:

* Creates config.json for apps that rely on command line parameters

* Reads shortcut files, extract exe with parameters

* Creates config.json application record with arguments and App id extracted from AppxManifest.XML

## Requires:

1. AppxManifest.xml 
2. All Shortcut files (*.LNK) (created when app installed via MSI).
3. All files should be in the same folder as this script.