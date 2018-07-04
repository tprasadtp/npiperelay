$ErrorActionPreference = "Stop"
$NPIPE_ARTIFACT = "$env:APPVEYOR_BUILD_FOLDER\Artifacts\npiperelay.exe"
$NPIPE_ARTIFACT_UNSIGNED = "$env:APPVEYOR_BUILD_FOLDER\Artifacts\npiperelay-unsigned.exe"
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/appveyor/secure-file/master/install.ps1'))
Import-Module appveyor-tools
appveyor-tools\secure-file -decrypt .\$env:ENCRYPTED_CERT_FILE -secret $env:FILE_PWD

# Copy Unsigned
Write-Host "Copying Unsigned file...."
Copy-Item $NPIPE_ARTIFACT -Destination $NPIPE_ARTIFACT_UNSIGNED

# Sign thr Artifact
Write-Host "Signing the Artifact...."
& 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64\signtool.exe' sign /f $env:CERT_FILE /p $env:CERT_PWD /fd sha256 /tr http://timestamp.digicert.com /td sha256 $NPIPE_ARTIFACT
$SIGN_EXITCODE = $LASTEXITCODE
If ($SIGN_EXITCODE -ne 0) {exit $SIGN_EXITCODE}
# verify the signature
$SIGN_EXITCODE = 0
Write-Host "Verifying signature...."
& 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64\signtool.exe' verify /pa $NPIPE_ARTIFACT
$SIGN_EXITCODE = $LASTEXITCODE
If ($SIGN_EXITCODE -ne 0) {exit $SIGN_EXITCODE}
#Checksums for Signed File
dir $env:APPVEYOR_BUILD_FOLDER\Artifacts\*.exe | Get-FileHash -Algorithm sha1 | Format-Table > $env:APPVEYOR_BUILD_FOLDER\Artifacts\SHA1SUM.txt
dir $env:APPVEYOR_BUILD_FOLDER\artifacts\*.exe | Get-FileHash -Algorithm sha256 | Format-Table > $env:APPVEYOR_BUILD_FOLDER\Artifacts\SHA256SUM.txt
dir $env:APPVEYOR_BUILD_FOLDER\artifacts\*.exe | Get-FileHash -Algorithm md5 | Format-Table > $env:APPVEYOR_BUILD_FOLDER\Artifacts\MD5SUM.txt
