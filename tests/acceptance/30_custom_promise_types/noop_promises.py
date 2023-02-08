#!/usr/bin/python3
#
# Sample custom promise type that does nothing. An optional attribute can be
# used to change the promise outcome. Attribute defaults to 'kept' if not
# specified.
#
# Use it in the policy like this:
# promise agent noop
# {
#   interpreter => "/usr/bin/python3";
#   path => "$(sys.inputdir)/noop_promises.py";
# }
# bundle agent main
# {
#   noop:
#       "anything"
#       # outcome => ("kept"|"repaired"|"not kept")
#         outcome =>  "kept";
# }


from cfengine import PromiseModule, ValidationError, Result


class NoopPromiseTypeModule(PromiseModule):
    def __init__(self):
        super().__init__("noop_promise_module", "0.0.1")

    def validate_promise(self, promiser, attributes, meta):
        if "outcome" in attributes and type(attributes["outcome"]) != str:
            raise ValidationError(
                "Attribute 'outcome' for promiser '%d' must be of type string"
                % promiser
            )

    def evaluate_promise(self, promiser, attributes, meta):
        assert type(promiser) == str

        if "outcome" in attributes:
            if attributes["outcome"].lower() == "repaired":
                self.log_verbose("Promise '%s' repaired" % promiser)
                return Result.REPAIRED
            elif attributes["outcome"].lower() in ("not_kept", "not kept"):
                self.log_error("Promise '%s' not kept" % promiser)
                return Result.NOT_KEPT
        self.log_verbose("Promise '%s' kept" % promiser)
        return Result.KEPT


if __name__ == "__main__":
    NoopPromiseTypeModule().start()
