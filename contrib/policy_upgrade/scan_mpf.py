#!/usr/bin/env python3

import sys
import os
import json
import hashlib

from collections import OrderedDict


def json_string(data):
    return json.dumps(data, indent=2)


def json_print(data):
    print(json_string(data))


def json_save(data, path):
    string = json_string(data)
    with open(path, "w") as f:
        f.write(string)


def json_load(path):
    with open(path, "r") as f:
        data = f.read()
        return json.loads(data, object_pairs_hook=OrderedDict)


def file_hash(path):
    if not os.path.isfile(path):
        raise ValueError

    hasher = hashlib.sha256()
    block_size = 4096
    with open(path, 'rb') as f:
        buf = f.read(block_size)
        while len(buf) > 0:
            hasher.update(buf)
            buf = f.read(block_size)
    return hasher.hexdigest()


def get_file_paths(root_path):
    file_paths = []
    for subdir, dirs, files in os.walk(root_path):
        for f in files:
            path = os.path.join(subdir, f)
            if ".git/" in path:
                continue
            file_paths.append(path)
    file_paths.sort()
    return file_paths


def discovery(root_path, db):
    file_paths = get_file_paths(root_path)
    version_suggestions = []

    for path in file_paths:
        digest = file_hash(path)
        if ".cf" not in path:
            continue
        if digest in db and path not in db:
            print(
                "Renamed/copied policy: {} -> {}".format(
                    db[digest][-1], path))
            continue
        if path not in db:
            print("Custom policy: {}".format(path))
            continue
        if digest not in db:
            print("This policy differs from masterfiles: {}".format(path))
            continue
        files = db[digest]
        if len(files) > 1:
            continue
        version = files[0].split(" ")[0]
        if version not in version_suggestions:
            version_suggestions.append(version)
    if len(version_suggestions) == 0:
        print("Unable to detect current version")
    else:
        print(
            "You are running version {}".format(
                " or ".join(version_suggestions)))
    return db


def main(args):
    db = json_load("policy_hashes.json")
    discovery("./", db)


if __name__ == "__main__":
    main(sys.argv)
