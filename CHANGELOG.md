# Changelog
Notable changes to the framework should be documented here

## [Unreleased][unreleased]
### Added
 - CHANGELOG.md
 - Support for user specified overring of framework defaults without modifying
   policy supplied by the framework itself (see example_def.json)

### Changed
 - Re-organize cfe_internal splitting core from enterprise specific policies
   and loading the appropriate inputs only when necessary
 - Moved update directory into cfe_internal as it is not generally intended to
   be modified

### Deprecated

### Removed
 - Diff reporting on /etc/shadow (Enterprise)

### Fixed

### Security

