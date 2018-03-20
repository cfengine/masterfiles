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


def generate_db(root_path, version):
    db = OrderedDict()
    file_paths = get_file_paths(root_path)

    for path in file_paths:
        digest = file_hash(path)
        if digest not in db:
            db[digest] = []
        if path not in db:
            db[path] = []
        file_info = "{} {}".format(version, path)
        db[digest].append(file_info)
        db[path].append(file_info)
        print("{} {}".format(digest, path))
    return db


def merge_databases(dbs):
    master = OrderedDict()
    for db in dbs:
        for digest in db:
            if digest not in master:
                master[digest] = []
            for file_info in db[digest]:
                master[digest].append(file_info)
    return master


def main(args):
    assert (len(args) > 1)
    versions = args[1:]
    path = "./"
    dbs = []

    for version in versions:
        os.system("git checkout {}".format(version))
        db = generate_db(path, version)
        dbs.append(db)
    db = merge_databases(dbs)

    json_print(db)
    json_save(db, "policy_hashes.json")


if __name__ == "__main__":
    main(sys.argv)
