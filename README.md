These files assume you are installing a new Debian 13 server VM on XCP-NG. Please read the comments in the files and change as needed.

Debian Server Auto install

    Initialize Infrastructure:

    Create the server in XO.
    Choose Installation Mode from boot menu:

    Choose Advanced Options > Automated install
    Provide Preconfiguration File:

    Enter https://www.theabode.cc/downloads/debiansvr.cfg when prompted
    Log Into The Server:

    SSH to 192.168.86.99 user <USERNAME> pass changeme
    Terminal Commands
    Copy

    ssh <USERNAME>@<IP FROM debiansvr.cfg FILE>

    Execute Finalization Script:

    Once downloaded run and follow prompts:
    Terminal Commands
    Copy

    wget https://www.theabode.cc/downloads/serversetup.sh
    chmod +x ./serversetup.sh
    sudo ./serversetup.sh

    Update the DNS Server:

    login to the DNS Server and create the new A record
