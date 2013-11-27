Summary: CFEngine Test Package Charlie
Name: test-package-charlie
Version: 1.0
Release: 1
Source: test-package-installed.txt
License: MIT
Group: Other
Url: http://example.com
BuildRoot: %{_topdir}/BUILD/%{name}-%{version}-%{release}-buildroot

AutoReqProv: no

%description
CFEngine Test Package Charlie

%prep
cp -f ${RPM_SOURCE_DIR}/test-package-installed.txt .

%install
mkdir -p ${RPM_BUILD_ROOT}
cp -f ${RPM_BUILD_DIR}/test-package-installed.txt ${RPM_BUILD_ROOT}/test-package-charlie-installed.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir /
/test-package-charlie-installed.txt
