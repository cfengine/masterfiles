{ stdenv
, nix-gitignore
, autoreconfHook
, version
}:

stdenv.mkDerivation {
  pname = "cfengine-masterfiles";
  version =  version;

  src = ../../.;

  nativeBuildInputs = [ autoreconfHook ];

  postPatch = ''
    echo "${version}" > CFVERSION
  '';

  enableParallelBuilding = true;

  configureFlags = [
    "--without-core"
    "--without-enterprise"
  ];
}
