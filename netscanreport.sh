#!/bin/bash

# Check Linux OS
if [ "$(uname)" != "Linux" ]; then
    echo "This script is Linux compatible only"
    exit 1
fi

# Check root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please execute as root"
    exit 1
fi

# Check if an argument is provided
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <domain|IP|IP-range>"
    exit 1
fi

# Install required tools if missing
for pkg in nmap xsltproc; do
    if ! command -v $pkg >/dev/null 2>&1; then
        echo "$pkg is required. Installing..."
        if command -v apt >/dev/null 2>&1; then
            packagemanager=apt
        elif command -v dnf >/dev/null 2>&1; then
            packagemanager=dnf
        elif command -v zypper >/dev/null 2>&1; then
            packagemanager=zypper
        else
            echo "Unsupported package manager. Install $pkg manually."
            exit 1
        fi
        $packagemanager install -y $pkg
    fi
done

# Create nmap reports folder if it doesn't exist
REPORT_DIR="/root/nmapreports"
mkdir -p "$REPORT_DIR"

# Regex patterns for validation
valid_domain='^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}$'
valid_ip='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
valid_cidr='^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$'  # CIDR support (e.g., 192.168.1.0/24)

# Validate target
if [[ $1 =~ $valid_domain || $1 =~ $valid_ip || $1 =~ $valid_cidr ]]; then
    target=$1
    echo -e "\nStarting scan on $target, please be patient..."
else
    echo -e "\n$1 is not a valid domain, IP address, or IP range\n"
    exit 1
fi

# Scan target
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
scan_output="$REPORT_DIR/${target//\//_}-$timestamp.xml"

sudo nmap -sV -A -vv --script ssl-cert,ssl-enum-ciphers,http-enum,vuln,vulners $target -oX "$scan_output"

# Convert report to HTML
report="${scan_output%.xml}.html"
xsltproc -o "$report" "$scan_output"

# Final message
if [[ $? -eq 0 ]]; then
    echo "Scan completed. Report saved in: $report"
else
    echo "Scan failed!"
    exit 1
fi
