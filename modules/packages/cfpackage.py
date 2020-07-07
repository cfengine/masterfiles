import sys

# one_package_argument_method returns single_list, multi_list
def package_arguments_builder(is_install, one_package_argument_method):
    name = ""
    version = ""
    arch = ""
    single_cmd_args = []    # List of arguments
    multi_cmd_args = []     # List of lists of arguments
    options = []            # List of Options to include in args if appropriate
    old_name = ""
    for line in sys.stdin:
        line = line.strip()
        if line.startswith("options="):
            option = line[len("options="):]
            if option.startswith("-"):
                options.append(option)
            elif option.startswith("enablerepo=") or option.startswith("disablerepo="):
                options.append("--" + option)
        if line.startswith("Name="):
            if name:
                # Each new "Name=" triggers a new entry.
                single_list, multi_list = one_package_argument_method(name, arch, version, is_install)
                single_cmd_args += single_list
                if name == old_name:
                    # Packages that differ only by architecture should be
                    # processed together
                    multi_cmd_args[-1] += multi_list
                elif multi_list:
                    # Otherwise we process them individually.
                    multi_cmd_args += [multi_list]

                version = ""
                arch = ""

            old_name = name
            name = line.split("=", 1)[1].rstrip()

        elif line.startswith("Version="):
            version = line.split("=", 1)[1].rstrip()

        elif line.startswith("Architecture="):
            arch = line.split("=", 1)[1].rstrip()

    if name:
        single_list, multi_list = one_package_argument_method(name, arch, version, is_install)
        single_cmd_args += single_list
        if name == old_name:
            # Packages that differ only by architecture should be
            # processed together
            multi_cmd_args[-1] += multi_list
        elif multi_list:
            # Otherwise we process them individually.
            multi_cmd_args += [multi_list]

    return single_cmd_args, multi_cmd_args, options
