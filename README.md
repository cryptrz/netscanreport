# Description

**netscanreport** scans a server for analyzing **open ports**, **TLS certificates** and **vulnerabilities**. It generates 2 **reports** in **XML** and **HTML**.

**nmap** for scanning and **xsltproc** for XLS for HTML conversion are required. They're installed automatically on operating systems using **apt**, **dnf**, or **zypper**. For other systems, you have to install the missing component if needed.

The target can be a domain name, an IP address or an IP addresses range.

# Usage

## Preparation

```
sudo chmod +x netscanreport.sh
```

## Scanning
Scan a domain name
```
./netscanreport.sh scanme.nmap.org
```

Scan an IP address
```
./netscanreport.sh 45.33.32.156
```

Scan an IP addresses range
```
./netscanreport.sh 192.168.1.1/24
```

The report is saved in **XML** in **/root/nmapreports** and converted in **HTML** in the same folder (which will be created automatically if it doesn't exist yet)
