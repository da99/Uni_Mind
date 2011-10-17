Remove packages:
  inetd
  portmap

Installition:http://www.debian.org/doc/manuals/securing-debian-howto/ch-sec-services.en.html#s-rpc
  * Use full CD-ROM. No internet connection.
  * Update filewall rules for update from Internet: http://www.debian.org/doc/manuals/securing-debian-howto/ap-fw-security-update.en.html
  * Upgrade system.
  * Say "Yes" to shadow passwords.
    * Change "password" line in /etc/pam.d to:
       password required pam_unix.so md5 nullok obscure min=6 max=16
  * Disable RPC service.
    * Uninstall "portmap" package.
    * Using GNOME?
      * Use firewall to limit access: http/etc/rc${runlevel}.d/://www.debian.org/doc/manuals/securing-debian-howto/ch-sec-services.en.html#s-rpc
  * Check to see only services you want are running.
    * Make it a cron job.
  * invoke-rc.d
    * write a policy-rc.d file that forbids starting new daemons before you configure them. See policyrcd-script-zg2
  * Remove "inetd"   
  * /etc/rc${runlevel}.d/
    * Use CRON to check to make sure only authorized daemons are running.
    * Unauthorized should have link to kill it and nothing else.
    * Make sure indetd services are not running:
      unneeded Inetd services on your system, like echo, chargen, discard, daytime, time, talk, ntalk and r-services (rsh, rlogin and rcp) which are considered HIGHLY insecure (use ssh instead).



BIOS:
  * Disable from booting system from floppy, CD-Rom, and other devices.
  * Change BIOS password.

Partioning:
  * /
  * /home
  * /tmp (ext2)
  * /var
    * /var/tmp/
    * /var/log
    * /var/cache/apt/archives
  * /opt or /usr/local


    

    

SSH Configuration: http://wiki.centos.org/HowTos/Network/SecuringSSH#head-9c01429983dccbf74ade8674815980dc6434d3ba
  * Limit connections: http://serverfault.com/questions/156227/how-to-limit-the-number-of-ssh-connection-from-the-ssh-sever
  * Prevent keyboard interaction. http://thinkhole.org/wp/2006/10/30/five-steps-to-a-more-secure-ssh/
  * Port knocking and PAM: http://apps.ycombinator.com/item?id=1664722
  * IPTABLES: second or 3rd try to connect.
  * No root login.
  * Pubic key upload: 
    scp -v -P PORT FILE1 user@dest:/dest

  * Protocol 2 only.
  * Port 1024+

  * No X11 forwarding.
  * No other forwards.
  * Set: 
      RhostsRSAAuthentication no
      HostbasedAuthentication no
      KerberosAuthentication no
      RhostsAuthentication no # Deprecated. Use IgnoreRhosts instead
      IgnoreRhosts yes 
  * Only allow login with protected key.
  * No empty passwords.


CentOS Updating system: 
  * Upgrade system: http://www.centos.org/docs/5/html/yum/sn-updating-your-system.html

    yum update --downloadonly (screen mode)
    install "yum-utils"
    use "yum-recover-transaction" if error occurs.

  * Automatic Updates: http://scottlinux.com/2010/12/16/centos-yum-automatic-updates/

    yum install yum-cron
    chkconfig yum-cron on
    /etc/init.d/yum-cron start


Cron:
  * Alert of new updates.
  * Install all security updates. 
    * Send message to Heroku apps and related apps: Database will be back in 25 seconds.
    * Re-start system.
      * Web apps (on Heroku) automatically re-try requests when database down.


Monit
- Check file wall rules are in place.
- Reboot after kernel update.  Reboot after update.
- Reboot after all programs are given proper kill signal

Database Server:
- Fail2Ban on Mongrel2 logs for failed http-auth attempts.
- IPTABLES: limit to two computers for database traffic.
- Mongrel2 state machine security.
- SSH security.
- HTTP auth over SSL.



Final:
  * Restart SSH service: 

    service sshd restart

  * Save iptables:  

    service iptables save

  * reload nginx 
  * reload thin


