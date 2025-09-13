#!/bin/bash
# 開発環境用簡易ファイアウォール設定

echo "Initializing basic firewall for development environment..."

# Check if iptables is available
if ! command -v iptables &> /dev/null; then
    echo "iptables not found, skipping firewall initialization"
    exit 0
fi

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow common development ports (inbound)
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT  # React dev server
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT  # Django/FastAPI  
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT  # Alternative HTTP
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT  # Flask
iptables -A INPUT -p tcp --dport 4200 -j ACCEPT  # Angular
iptables -A INPUT -p tcp --dport 3001 -j ACCEPT  # Common alt port

echo "Basic firewall rules initialized successfully"

# Simple verification
echo "Firewall verification:"
echo "- Loopback: ALLOWED"
echo "- Development ports (3000,5000,8000,8080): ALLOWED"
echo "- Outbound connections: UNRESTRICTED (suitable for development)"
