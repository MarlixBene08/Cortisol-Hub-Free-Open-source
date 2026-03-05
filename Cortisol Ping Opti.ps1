# ============================================

# Windows Network / LAN Optimization Script

# Run PowerShell as Administrator

# ============================================

Write-Host "Starting Network Optimization..." -ForegroundColor Green

# -------------------------------

# TCP Global Settings

# -------------------------------

netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set global rss=enabled
netsh interface tcp set global chimney=enabled
netsh interface tcp set global dca=enabled
netsh interface tcp set global netdma=enabled
netsh interface tcp set global ecncapability=disabled

# -------------------------------

# Flush DNS / Reset Network

# -------------------------------

ipconfig /flushdns
netsh winsock reset
netsh int ip reset

# -------------------------------

# Disable Network Throttling

# -------------------------------

$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

Set-ItemProperty -Path $path -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord
Set-ItemProperty -Path $path -Name "SystemResponsiveness" -Value 0 -Type DWord

# -------------------------------

# Gaming TCP Tweaks

# -------------------------------

$interfaces = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

Get-ChildItem $interfaces | ForEach-Object {
New-ItemProperty -Path $*.PSPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $*.PSPath -Name "TCPNoDelay" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -PropertyType DWord -Force
}

# -------------------------------

# Disable Power Saving on NIC

# -------------------------------

Get-NetAdapter | ForEach-Object {
powercfg -devicequery wake_from_any
}

# -------------------------------

# Set DNS Servers (Cloudflare)

# -------------------------------

$adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

foreach ($adapter in $adapters) {
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses ("1.1.1.1","1.0.0.1")
}

# -------------------------------

# Increase TCP ephemeral ports

# -------------------------------

netsh int ipv4 set dynamicport tcp start=1024 num=64511
netsh int ipv4 set dynamicport udp start=1024 num=64511

# -------------------------------

# Restart Network Adapter

# -------------------------------

Get-NetAdapter | Restart-NetAdapter -Confirm:$false

Write-Host "Network Optimization Complete!" -ForegroundColor Green
Write-Host "Please reboot your PC for full effect."
