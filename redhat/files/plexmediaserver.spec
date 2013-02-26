%define _rpmdir ../
%define _rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm
%define _unpackaged_files_terminate_build 0
%define        daemon_user plex
%define        daemon_group plex
Name:           plexmediaserver
Version:        1
Release:        1
Summary:        A media server and organization system
Group:          Productivity/Networking/Other

License:        GPL3
URL:            http://www.plexapp.com/
Source0:        ##plexmediaserver.tar.gz
Source1:        plex.init      ##/etc/init.d/plexmediaserver
Source2:        plex.limits    ##/etc/security/limits.d/plex.conf
Source3:        plex.env       ##/etc/sysconfig/PlexMediaServer
Source4:        plex.repo      ##/etc/yum.repos.d/plex.repo
Source5:        plex.service   ##/lib/systemd/system/plexmediaserver.service
Source6:        plex.firewalld ##/usr/lib/firewalld/services/plex.xml

BuildRequires:  ## The main BuildRequires
%if 0%{?suse_version} >= 1210
BuildRequires: systemd
%endif

Requires:       ## The main Requires
%if 0%{?suse_version}
Requires(pre): pwdutils
%endif
%if 0%{?fedora} || 0%{?rhel_version} || 0%{?centos_version}
Requires(pre): shadow-utils
%endif
%if 0%{?suse_version} >= 1210
%{?systemd_requires}
%endif
%if 0%{?fedora} >=18
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
%endif
%if 0%{?fedora} <=17
Requires(post): systemd-units
Requires(preun): systemd-units
Requires(postun): systemd-units
%endif
%if 0%{?suse_version} < 1210
Requires(pre): %insserv_prereq %fillup_prereq
%endif
%if 0%{?rhel_version} <=6 || 0%{?centos_version} <=6
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts
%endif

%description
Plex allows you to organize and view your collections of movies, television, music, photos, and personal movies and stream them to anywhere, including mobile devices.

%prep
## Assumes there's a tarball in Source0.
%setup -q


%build
## If you're using cmake, it goes somewhere around here.
%configure
make %{?_smp_mflags}


%install
rm -rf %{buildroot}
%make_install
%if 0%{?suse_version} < 1210 || %if 0%{?rhel_version} <=5 || 0%{?centos_version} <=5
install -Dm 755 %{S:1} %{buildroot}%{_initrddir}/plexmediaserver
%endif
%if 0%{?rhel_version} =6 || 0%{?centos_version} =6
install -Dm 755 %{S:1} %{buildroot}%{_initddir}/plexmediaserver
%endif
%if 0%{?fedora} >=17 || 0%{?suse_version} >= 1210
install -Dm 644 %{S:5} %{buildroot}%{_unitdir}/plexmediaserver.service
%endif
%if 0%{?fedora}
install -Dm 644 %{S:4} %{buildroot}%{_sysconfdir}/yum.repos.d/plex.repo
%endif
%if 0%{?suse_version}
install -Dm 644 %{S:4} %{buildroot}%{_sysconfdir}/zypp/repos.d/plex.repo
%endif
%endif
install -Dm 644 %{S:3} %{buildroot}%{_sysconfdir}/sysconfig/PlexMediaServer
install -Dm 644 %{S:2} %{buildroot}%{_sysconfdir}/security/limits.d/plex.conf
mkdir -p %{buildroot}%{_sbindir}
ln -sf %{buildroot}%{_initrddir}/plexmediaserver %{buildroot}%{_sbindir}/plexmediaserver

%pre
%if 0%{?suse_version} >= 1210
%service_add_pre plexmediaserver.service
%endif
%if 0%{?suse_version}
getent group %{daemon_group} >/dev/null || groupadd -r %{daemon_group}
getent passwd %{daemon_user} >/dev/null || \
    useradd -r -o -g %{daemon_group} -d %{_var}/lib/%{name} -s /sbin/nologin \
    -c "Plex Media Server daemon" %{daemon_user}
exit 0

%post
%if 0%{?suse_version} < 1210
%fillup_and_insserv plexmediaserver
%endif
%if 0%{?suse_version} >= 1210
%service_add_post plexmediaserver.service
%endif
%if 0%{?fedora} >=18 || 0%{?rhel_version} >=7
%systemd_post plexmediaserver.service
%endif
%if 0%{?fedora} <=17
if [ $1 -eq 1 ] ; then 
/bin/systemctl daemon-reload >/dev/null 2>&1 || :
fi
%endif
%if 0%{?rhel_version} <=6 || 0%{?centos_version} <=6
/sbin/chkconfig --add plexmediaserver
%endif
install -o plex -g plex -d /var/lib/plexmediaserver
# Tell users to go and read readme file, if fw.
echo ""
echo " Note: To edit plex Library home settings edit /etc/sysconfig/PlexMediaServer"
echo " And remember if you run a firewall/iptables add a rule for that."
echo ""
echo " Read more here /usr/share/doc/plexmediaserver/README.Redhat"
echo ""

%preun
%if 0%{?suse_version} < 1210
%stop_on_removal plexmediaserver
%if 0%{?suse_version} >= 1210
%service_del_preun plexmediaserver.service
%endif
%if 0%{?fedora} >=18
%systemd_preun plexmediaserver.service
%endif
%if 0%{?fedora} <=17
if [ $1 -eq 0 ] ; then
/bin/systemctl --no-reload disable plexmediaserver.service > /dev/null 2>&1 || :
/bin/systemctl stop plexmediaserver.service > /dev/null 2>&1 || :
fi
%endif
%if 0%{?rhel_version} <=6 || 0%{?centos_version} <=6
if [ $1 -eq 0 ] ; then
    /sbin/service plexmediaserver stop >/dev/null 2>&1
    /sbin/chkconfig --del plexmediaserver
fi
%endif

%postun
%if 0%{?suse_version} < 1210
%restart_on_update plexmediaserver
%insserv_cleanup
%if 0%{?suse_version} >= 1210
%service_del_postun plexmediaserver.service
%endif
%if 0%{?fedora} >=18
%systemd_postun_with_restart plexmediaserver.service
%endif
%if 0%{?fedora} <=17
/bin/systemctl daemon-reload >/dev/null 2>&1 || :
if [ $1 -ge 1 ] ; then
/bin/systemctl try-restart plexmediaserver.service >/dev/null 2>&1 || :
fi
%endif
%if 0%{?rhel_version} <=6 || 0%{?centos_version} <=6
if [ "$1" -ge "1" ] ; then
/sbin/service plexmediaserver condrestart >/dev/null 2>&1 || :
fi
%endif

%files
%defattr(-,root,root,-)
%doc copyright README.Redhat
%config(noreplace) %{_sysconfdir}/sysconfig/PlexMediaServer
%if 0%{?fedora} >=17 || 0%{?suse_version} >= 1210
%{_unitdir}/plexmediaserver.service
%endif
%if 0%{?suse_version} < 1210 || %if 0%{?rhel_version} <=5 || 0%{?centos_version} <=5
%{_initrddir}/plexmediaserver
%endif
%if 0%{?rhel_version} =6 || 0%{?centos_version} =6
%{_initddir}/plexmediaserver
%endif
%{_sysconfdir}/security/limits.d/plex.conf
%if 0%{?fedora}
%{_sysconfdir}/yum.repos.d/plex.repo
%endif
%if 0%{?suse_version}
%{_sysconfdir}/zypp/repos.d/plex.repo
%endif
%{_sbindir}/rcservice
