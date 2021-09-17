import subprocess


def write_secret(path, secret):
    proc = subprocess.Popen(
        ["/var/cfengine/bin/cf-secret", "encrypt", "-H", "localhost", "-o", path, "-"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    proc.communicate(input=secret.encode())


def read_secret(path):
    return subprocess.check_output(
        [
            "/var/cfengine/bin/cf-secret",
            "decrypt",
            path,
            "--output",
            "-",
        ],
        universal_newlines=True,
    ).strip()
