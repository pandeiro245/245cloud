#!/bin/bash
sudo systemctl start nftables
sudo nft flush ruleset
sudo nft add table nat
sudo nft add chain nat prerouting { type nat hook prerouting priority -100 \; }
sudo nft add rule nat prerouting tcp dport 80 redirect to :8080
sudo nft add rule nat prerouting tcp dport 443 redirect to :8443
sudo sh -c 'nft list ruleset > /etc/nftables.conf'
sudo systemctl restart nftables
echo "Current nftables rules:"
sudo nft list ruleset
