#!/usr/bin/python3
#
# Sample custom promise type, uses cfengine.py library located in same dir.
#
# Use it in the policy like this:
# promise agent append
# {
#   interpreter => "/usr/bin/python3";
#   path => "$(sys.inputdir)/append_promises.py";
# }
# bundle agent main
# {
#   append:
#       "/path/to/target/file"
#         string => "string to append";
# }


from cfengine import PromiseModule, ValidationError, Result


class AppendPromiseTypeModule(PromiseModule):
    def __init__(self):
        super().__init__("append_promise_module", "0.0.1")

    def validate_promise(self, promiser, attributes):
        if type(promiser) != str:
            raise ValidationError("Promiser must be of type string")
        if not "string" in attributes:
            raise ValidationError("Missing attribute 'string'")
        if type(attributes["string"]) != str:
            raise ValidationError("Attribute 'string' must be of type string")

    def evaluate_promise(self, promiser, attributes):
        assert "string" in attributes

        try:
            with open(promiser, "a+") as f:
                f.seek(0)
                if (attributes["string"] not in f.read()):
                    f.write(attributes["string"])
                    self.log_verbose("Promise '%s' repaired" % promiser)
                    return Result.REPAIRED
                else:
                    self.log_verbose("Promise '%s' kept" % promiser)
                    return Result.KEPT
        except Exception as e:
            self.log_error(e)
            self.log_error("Promise '%s' not kept" % promiser)
            return Result.NOT_KEPT


if __name__ == "__main__":
    AppendPromiseTypeModule().start()
