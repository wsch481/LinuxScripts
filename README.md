These files assume you are installing a new Debian 13 server VM on XCP-NG. Please read the comments in the files and change as needed.
You will need to setup a small web server i.e. NGINX, Python, etc. to host the two files.

Debian Server Auto install

Initialize Infrastructure:

Create the server in XO.
Choose Installation Mode from boot menu:

Choose Advanced Options > Automated install
Provide Preconfiguration File:

Enter https://<URL>/... when prompted
Log Into The Server:

SSH to the new server user <USERNAME> pass changeme
    ssh <USERNAME>@<IP FROM debiansvr.cfg FILE>

Execute Finalization Script:

Once downloaded run and follow prompts:

    wget https://<URL>/serversetup.sh
    chmod +x ./serversetup.sh
    sudo ./serversetup.sh

Update the DNS Server:

login to the DNS Server and create the new A record
