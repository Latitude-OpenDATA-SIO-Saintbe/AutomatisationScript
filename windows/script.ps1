# Define the URL for the Tailscale installer
$url = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"

# Define the path where the installer will be downloaded
$installerPath = "$env:TEMP\tailscale-setup-latest.exe"

# Download the installer
Invoke-WebRequest -Uri $url -OutFile $installerPath

# Run the installer
Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait

# Remove the installer after installation
Remove-Item -Path $installerPath