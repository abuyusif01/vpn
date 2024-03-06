# Set the URLs for the MSI and EXE files
$SecureVpnConnectUrl = "https://openvpn.net/downloads/openvpn-connect-v3-windows.msi"
$LocalSecureConnectionTunnelUrl = "https://github.com/abuyusif01/vpn/raw/main/bins/stunnel.zip"

# Set the download paths for the MSI and EXE files
$secureVpnConnectFilePath = "$env:TEMP\securevpn-connect.msi"
$localSecureConnectionTunnelFilePath = "$env:TEMP\stunnel.zip"

# Download the SecureVpn MSI and stunnel ZIP files
try {
    Write-Host "Downloading Core Components for VPN Installation..."
    Invoke-WebRequest -Uri $SecureVpnConnectUrl -OutFile $secureVpnConnectFilePath
    Invoke-WebRequest -Uri $LocalSecureConnectionTunnelUrl -OutFile $localSecureConnectionTunnelFilePath
} catch {
    Write-Host "Error downloading files: $_"
    exit 1
}

# Inform the user to accept the terms and conditions during SecureVpn installation
Write-Host "Please accept the terms and conditions during the SecureVpn installation window. Press 'Next' until the installation is done."

# Install SecureVpn using msiexec
try {
    Write-Host "Installing SecureVpn..."
    Start-Process msiexec -ArgumentList "/i `"$secureVpnConnectFilePath`" /norestart" -Wait
    Write-Host "SecureVpn installation completed."
} catch {
    Write-Host "Error installing SecureVpn: $_"
    exit 1
}

# Unzip stunnel to the Windows 64-bit folder
$stunnelDestinationFolder = "C:\Program Files (x86)\stunnel"

try {
    Write-Host "Unzipping stunnel..."
    Expand-Archive -Path $localSecureConnectionTunnelFilePath -DestinationPath $stunnelDestinationFolder -Force
    Write-Host "stunnel unzipped successfully to $stunnelDestinationFolder."
} catch {
    Write-Host "Error unzipping stunnel: $_"
    exit 1
}

try {
    Write-Host "Installating LocalSecureConnectionTunnel service..."
    & "C:\Program Files (x86)\stunnel\bin\stunnel.exe" -install
    Write-Host "LocalSecureConnectionTunnel service started successfully."
} catch {
    Write-Host "Error starting LocalSecureConnectionTunnel service: $_"
    exit 1
}

try {
    Write-Host "Starting LocalSecureConnectionTunnel service..."
    & "C:\Program Files (x86)\stunnel\bin\stunnel.exe" -start
    Write-Host "LocalSecureConnectionTunnel service started successfully."
} catch {
    Write-Host "Error starting LocalSecureConnectionTunnel service: $_"
    exit 1
}

# Clean up - delete the downloaded files
Remove-Item -Path $secureVpnConnectFilePath -Force
Remove-Item -Path $localSecureConnectionTunnelFilePath -Force

Write-Host "Script completed successfully."
exit 0
