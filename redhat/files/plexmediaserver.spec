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
if [ `cat /etc/passwd|grep ^plex:|wc -l` -eq 0 ]; then
   if [ `getent group plex | wc -l` -eq 0 ]; then
     if [ -f /etc/SuSE-release ]; then
        groupadd plex
        useradd -d /var/lib/plexmediaserver -c "RPM Created PlexUser" -g plex --system -s /sbin/nologin plex
     else
        useradd -d /var/lib/plexmediaserver -c "RPM Created PlexUser" --system -s /sbin/nologin plex
     fi
   else
     useradd -d /var/lib/plexmediaserver -c "RPM Created PlexUser" -g plex --system -s /sbin/nologin plex
   fi
fi

if [ "$1" = "2" ]; then
  if [ -f /etc/redhat-release ]; then
    if [ `cat /etc/redhat-release|sed 's/[^0-9]*//g'` -gt 14 ]; then
      if [ `systemctl list-unit-files|grep plex.service|wc -l` -eq 0 ]; then
        service plexmediaserver stop
      else
        service plex stop
      fi
    else
      /etc/init.d/plexmediaserver stop
    fi
  else
    /etc/init.d/plexmediaserver stop
  fi
fi

exit 0

%post
# If /etc/init.d/plexmediaserver file not there, then add symlink to real init script.
if [ ! -f /etc/init.d/plexmediaserver ]; then ln -s /etc/rc.d/init.d/plexmediaserver /etc/init.d/plexmediaserver;fi

# Create Library dir for Plex user in /var/lib/plexmediaserver if not in place (default)
if [ ! -d "/var/lib/plexmediaserver" ]; then
mkdir /var/lib/plexmediaserver; chown plex:plex /var/lib/plexmediaserver
fi

# Check if release is systemd based and add plex service accordingly.
if [ -f /etc/SuSE-release ]; then
   if [[ `grep VERSION /etc/SuSE-release| awk '{print $3}'` > 12.1 ]]; then
      systemctl enable plexmediaserver
   else
      chkconfig --add plexmediaserver
   fi
  [ -x /bin/systemctl ] && systemctl --system daemon-reload
elif [ -f /etc/redhat-release ]; then
  if [ `cat /etc/redhat-release|sed 's/[^0-9]*//g'` -gt 14 ]; then
      chkconfig --add plexmediaserver
  else
      if [ `systemctl list-unit-files|grep plex.service|wc -l` -eq 0 ]; then
	systemctl enable plexmediaserver.service
      else
	systemctl enable plex.service
      fi
      systemctl daemon-reload
  fi
  # Add SELinux rsync policy file on CentOS/Fedora
  semodule -i /usr/lib/plexmediaserver/plexrsync.pp
fi

%preun

if [ "$1" = "0" ]; then
  if [ -f /etc/redhat-release ]; then
    if [ `cat /etc/redhat-release|sed 's/[^0-9]*//g'` -gt 14 ]; then
      if [ `systemctl list-unit-files|grep plex.service|wc -l` -eq 0 ]; then
        service plexmediaserver stop
      else
        service plex stop
      fi
    else
      /etc/init.d/plexmediaserver stop
    fi
  else
    /etc/init.d/plexmediaserver stop
  fi
fi

if [ "$1" = "0" ]; then
  if [ -f /etc/SuSE-release ]; then
    if [[ `grep VERSION /etc/SuSE-release| awk '{print $3}'` > 12.1 ]]; then
       systemctl disable plexmediaserver
    else
       chkconfig --del plexmediaserver
    fi
    [ -x /bin/systemctl ] && systemctl --system daemon-reload
  elif [ -f /etc/redhat-release ]; then
    if [ `cat /etc/redhat-release|sed 's/[^0-9]*//g'` -gt 14 ]; then
      chkconfig --del plexmediaserver
    else
      if [ `systemctl list-unit-files|grep plex.service|wc -l` -eq 0 ]; then
        systemctl disable plexmediaserver.service
      else
	systemctl disable plex.service
      fi
      systemctl daemon-reload
    fi
  fi
else
  if [ -f /etc/SuSE-release ]; then
   if [[ `grep VERSION /etc/SuSE-release| awk '{print $3}'` > 12.1 ]]; then
        systemctl disable plexmediaserver
   else
      chkconfig --del plexmediaserver
   fi
    [ -x /bin/systemctl ] && systemctl --system daemon-reload
  elif [ -f /etc/redhat-release ]; then
    if [ `cat /etc/redhat-release|sed 's/[^0-9]*//g'` -gt 14 ]; then
      systemctl daemon-reload
    fi
  fi
fi

%postun

# If uninstall and plexrsync.pp module is loaded, remove it.
if [ "$1" = "0" ]; then
  if [ -f /etc/redhat-release ]; then
    # Remove SELinux rsync policy file on CentOS/Fedora
    if [ `semodule -l |grep plexrsync| wc -l` -gt 0 ]; then
      semodule -r plexrsync
    fi
  fi
fi

%description
 Stream media everywhere(tm)

(RPM Made by ZiGGiMoN)

%files
"/usr/lib/plexmediaserver"
"/etc/zypp/repos.d/plex.repo"
"/etc/yum.repos.d/plex.repo"
"/etc/init.d/plexmediaserver"
"/etc/security/limits.d/plex.conf"
%config(noreplace) "/etc/sysconfig/PlexMediaServer"
%config(noreplace) "/lib/systemd/system/plexmediaserver.service"
"/usr/local/bin/python"
"/usr/share/doc/plexmediaserver/README.Redhat"
"/usr/share/doc/plexmediaserver/copyright"
