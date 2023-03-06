#!/usr/bin/python3
#
# Sample custom promise type that sleeps for a specified amount of time before
# creating a file with content.
#
# Use it in the policy like this:
# promise agent slow_append
# {
#   interpreter => "/usr/bin/python3";
#   path => "$(sys.inputdir)/slow_append_promises.py";
# }
# bundle agent main
# {
#   slow_append:
#       "/tmp/testfile"
#         seconds =>  "123.4",
#         content => "Hello CFEngine!";
# }


import time
from cfengine import PromiseModule, ValidationError, Result


class SlowAppendPromiseTypeModule(PromiseModule):
    def __init__(self):
        super().__init__("slow_append_promise_module", "0.0.1")

    def validate_promise(self, promiser, attributes, meta):
        seconds = attributes.get("seconds")
        if seconds is None:
            raise ValidationError(
                "Missing required attribute 'seconds' for promiser '%s'" % promiser
            )
        try:
            float(seconds)
        except ValueError:
            raise ValidationError(
                "Invalid literal '%s' in attribute 'seconds' for promiser '%s'"
                % (seconds, promiser)
            )

        if "content" not in attributes:
            raise ValidationError(
                "Missing required attribute 'content' for promiser '%s'" % promiser
            )

    def evaluate_promise(self, promiser, attributes, meta):
        seconds = float(attributes["seconds"])
        content = attributes["content"]

        self.log_debug("Sleeping %.2f seconds" % seconds)
        time.sleep(seconds)

        try:
            with open(promiser, "a+") as f:
                f.write(content)
            self.log_info("Appended content '%s' to file '%s'" % (content, promiser))
        except Exception as e:
            self.log_error(
                "Failed to append content '%s' to file '%s': %s"
                % (content, promiser, e)
            )
            self.log_error("Promise '%s' not kept" % promiser)
            return Result.NOT_KEPT

        self.log_verbose("Promise '%s' kept" % promiser)
        return Result.KEPT


if __name__ == "__main__":
    SlowAppendPromiseTypeModule().start()
