Summary: CFEngine Test Package Charlie
Name: test-package-charlie
Version: 1.0
Release: 2
License: MIT
Group: Other
Url: http://example.com
BuildRoot: %{_topdir}/BUILD/%{name}-%{version}-%{release}-buildroot

AutoReqProv: no

%description
CFEngine Test Package Beta

%prep


%install
%ifarch i386
ARCH="i386"
%else
ARCH="x86_64"
%endif
export ARCH
CWD=$(pwd)
export CWD

mkdir -p ${RPM_BUILD_ROOT}
echo $RPM_BUILD_DIR
cp -f ~/rpmbuild/SOURCES/test-package-charlie-1.0-%{release}-"$ARCH"-rpm-installed.txt ${RPM_BUILD_ROOT}


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/*.txt
