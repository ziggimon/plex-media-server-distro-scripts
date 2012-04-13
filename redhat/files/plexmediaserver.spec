Buildroot: /plexmediaserver
Name: plexmediaserver
Version: 1
Release: 1
Summary: Plex Media Server for Linux
License: see /usr/share/doc/plexmediaserver/copyright
Distribution: Redhat
Group: Converted/video

%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0

%pre
# Add Plex user if not allready on system
if [ `cat /etc/passwd|grep ^plex:|wc -l` -eq 0 ]; then adduser -d /var/lib/plexmediaserver -c "RPM Created PlexUser" --system -s /sbin/nologin plex; fi

if [ "$1" = "2" ]; then
  if [[ ! $(cat /etc/redhat-release) =~ (^Fedora).*?1[5-9].*$ ]]; then
     /etc/init.d/plexmediaserver stop
  else
     service plex stop
  fi
fi

%post
# If /etc/init.d/plexmediaserver file not there, then add symlink to real init script.
if [ ! -f /etc/init.d/plexmediaserver ]; then ln -s /etc/rc.d/init.d/plexmediaserver /etc/init.d/plexmediaserver;fi

# Create Library dir for Plex user in /var/lib/plexmediaserver if not in place (default)
if [ ! -d "/var/lib/plexmediaserver" ]; then
mkdir /var/lib/plexmediaserver; chown plex:plex /var/lib/plexmediaserver
fi

# Check if release is systemd based and add plex service accordingly.
if [[ ! $(cat /etc/redhat-release) =~ (^Fedora).*?1[5-9].*$ ]]; then
    chkconfig --add plexmediaserver
else
    systemctl daemon-reload
    systemctl enable plex.service
fi

# Tell users to go and read readme file, if fw.
echo ""
echo " Note: To edit plex Library home settings edit /etc/sysconfig/PlexMediaServer"
echo " And remember if you run a firewall/iptables add a rule for that."
echo ""
echo " Read more here /usr/share/doc/plexmediaserver/README.Redhat"
echo ""
%preun

if [ "$1" = "0" ]; then
  if [[ ! $(cat /etc/redhat-release) =~ (^Fedora).*?1[5-9].*$ ]]; then
     /etc/init.d/plexmediaserver stop
  else
     service plex stop
  fi
fi

if [ "$1" = "0" ]; then
  if [[ ! $(cat /etc/redhat-release) =~ (^Fedora).*?1[5-9].*$ ]]; then
    chkconfig --del plexmediaserver
  else
    systemctl disable plex.service
    systemctl daemon-reload
  fi
else
  if [[ $(cat /etc/redhat-release) =~ (^Fedora).*?1[5-9].*$ ]]; then
    systemctl daemon-reload
  fi
fi

%postun

%description
 Stream media everywhere(tm)

(RPM Made by ZiGGiMoN)

%files
%dir "/etc/"
%dir "/etc/rc.d/"
%dir "/etc/rc.d/init.d/"
"/etc/rc.d/init.d/plexmediaserver"
%dir "/etc/sysconfig/"
%config "/etc/sysconfig/PlexMediaServer"
%dir "/lib"
%dir "/lib/systemd"
%dir "/lib/systemd/system"
"/lib/systemd/system/plex.service"
%dir "/usr"
%dir "/usr/local"
%dir "/usr/local/bin"
"/usr/local/bin/python"
%dir "/usr/share/"
%dir "/usr/share/doc/"
%dir "/usr/share/doc/plexmediaserver/"
"/usr/share/doc/plexmediaserver/README.Redhat"
"/usr/share/doc/plexmediaserver/copyright"
%dir "/usr/lib/"
