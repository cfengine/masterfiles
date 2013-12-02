Summary: CFEngine Test Package Beta
Name: test-package-beta
Version: 1.0
Release: 2
Source: test-package-installed.txt
License: MIT
Group: Other
Url: http://example.com
BuildRoot: %{_topdir}/BUILD/%{name}-%{version}-%{release}-buildroot

AutoReqProv: no

%description
CFEngine Test Package Beta

%prep
cp -f ${RPM_SOURCE_DIR}/test-package-installed.txt .

%install
mkdir -p ${RPM_BUILD_ROOT}
cp -f ${RPM_BUILD_DIR}/test-package-installed.txt ${RPM_BUILD_ROOT}/test-package-beta-installed.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir /
/test-package-beta-installed.txt
