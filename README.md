# mn watch
## Installation

Login to your VPS as the user which runs the daemon and run the following commands:
```
wget https://gitlab.crown.tech/walkjivefly/crown-core/uploads/d8b1a0f163f522059f3758bbc13249c6/crownwatch.sh
chmod +x crownwatch.sh
sudo mv crownwatch.sh /usr/local/bin
crontab -e
```
If you haven’t configured the editor setting for crontab it will ask you which editor you want to use and suggest you use nano. Use whichever one you are most familiar with to add the following line:
```
*/15 * * * * /usr/local/bin/crownwatch.sh >>~/crownwatch.log 2>&1
```
The script writes a handful of lines explaining what it is doing. If you don’t want to record that output then leave off the redirection part (>>~/crownwatch.log 2>&1).

Alternatives
If systemd is installed on your VPS (it pretty much is on anything based on Ubuntu 16 and newer) you can use it to start the daemon and automatically restart it if it stops for any reason. It won’t do pre-emptive restarts if free memory is getting low. systemd is rather like the Borg, or Marmite, and its configuration is the subject for another article.
