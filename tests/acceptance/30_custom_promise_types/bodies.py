#!/usr/bin/python3
#
# Sample custom promise type, uses cfengine.py library located in same dir.
#
# Use it in the policy like this:
# promise agent append
# {
#   interpreter => "/usr/bin/python3";
#   path => "$(sys.inputdir)/bodies.py";
# }
# body example_type example_name
# {
#   foo => "Hello";
#   bar => "World";
# }
# bundle agent main
# {
#   append:
#       "/path/to/target/file"
#         example_type => example_name;
# }


import json
from cfengine import PromiseModule, ValidationError, Result


class BodiesPromiseTypeModule(PromiseModule):
    def __init__(self):
        super().__init__("bodies_promise_module", "0.0.1")

    def validate_promise(self, promiser, attributes, meta):
        pass

    def evaluate_promise(self, promiser, attributes, meta):
        try:
            with open(promiser, "rw") as f:
                if (json.dumps(attributes) == f.read()):
                    self.log_verbose("Promise '%s' kept" % promiser)
                    return Result.KEPT
                f.seek(0)
                f.write(json.dumps(attributes))
        except:
            try:
                with open(promiser, "w") as f:
                    f.write(json.dumps(attributes))
                    self.log_verbose("Promise '%s' repaired" % promiser)
                    self.log_info("Written attributes into file %s" % promiser)
                    return Result.REPAIRED
            except Exception as e:
                self.log_error(e)
                self.log_error("Promise '%s' not kept" % promiser)

        return Result.NOT_KEPT


if __name__ == "__main__":
    BodiesPromiseTypeModule().start()
