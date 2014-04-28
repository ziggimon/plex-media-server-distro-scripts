Name: Plex
Version: <%module_version%>
Release: <%git_version%>
Vendor: Plex
Summary: Plex Media Server
License: GPL
Group: System

%define debug_package %{nil}
%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%global _python_bytecompile_errors_terminate_build 0
AutoReqProv: no

%description
Plex Media Server

%post
/opt/%{name}/shell/module.rc stop
cd /opt/%{name}/
rm -rf /opt/%{name}/sys
tar zxvf sys.tar.gz
/img/bin/rc/rc.treemenu init
/opt/%{name}/shell/module.rc boot

%preun
if [ "$1" == "0" ]; then
/opt/%{name}/shell/module.rc stop
/img/bin/rc/rc.pkg treeid_del %{name}
fi

%postun
if [ "$1" == "0" ];then
    /img/bin/rc/rc.treemenu init
    rm -f /var/tmp/modules/%{name}
    rm -rf /opt/%{name}
fi

%files
%defattr(-,root,root)
"/opt"
"/var"
%define date    %(echo `LC_ALL="C" date +"%a %b %d %Y"`)
