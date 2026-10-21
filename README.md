These files assume you are installing a new Debian 13 server VM on XCP-NG. Please read the comments in the files and change as needed.
You will need to setup a small web server to host the two files. Be aware of firewalls blocking incoming requests.

NGINX (Debian/Ubuntu)

    sudo apt update
    sudo apt install nginx -y

Python (Most Linux)

    sudo python3 -m http.server 80

Windows cmd

    python -m http.server 80

Debian Server Auto install

Initialize Infrastructure:
Create the server in XO.
Choose Installation Mode from boot menu:
Choose Advanced Options > Automated install

Provide Preconfiguration File:
Enter https://<URL>/debiansvr.cfg when prompted

Log Into The Server:
SSH to the new server username password changeme
    
    ssh <USERNAME>@<IPFROMdebiansvr.cfg>

Execute Finalization Script:
Once downloaded run and follow prompts:

    wget https://<URL>/serversetup.sh
    chmod +x ./serversetup.sh
    sudo ./serversetup.sh

Update the DNS Server:
Add new a new A record for the Server
