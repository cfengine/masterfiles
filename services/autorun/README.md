When the ```services_autorun``` class is defined ```.cf``` files located in `services/autorun/` are automatically
included in inputs and bundles tagged with ```autorun``` are actuated in lexical order.

Example definition of ```services_autorun``` using [Augments (def.json)][Augments]:

```json
{
  "classes": {
    "services_autorun": [ "any::" ]
  }
}
```

Example policy with bundle tagged for execution when ```services_autorun``` is defined:

```cf3
bundle agent example
{
  meta:
    "tags" slist => { "autorun" };

  reports:
    "I will report when 'services_autorun' is defined."
}
```

**Note:** The `services_autorun_inputs` and `services_autorun_bundles` classes
allow policy files to be dynamically loaded or tagged bundles to be run
independently of each-other. If you have an automatically loaded policy file in
`services/autorun` which loads additional policy dynamically, `cf-promises` may
not be able to resolve syntax errors. Use
[`mpf_extra_autorun_inputs`][Masterfiles Policy Framework#Add additional policy files for update (inputs)]
and or
[`control_common_bundlesequence_classification`][Masterfiles Policy Framework#Classification bundles before autorun]
to work around this limitation.

**History:**

* Added in CFEngine 3.6.0

#### Automatically add policy files to inputs

When the ```services_autorun_inputs``` class is defined ```.cf``` files located
in `services/autorun/` are automatically included in inputs.

Example definition of ```services_autorun_inputs``` using [Augments (def.json)][Augments]:

```json
{
  "classes": {
    "services_autorun_inputs": [ "any::" ]
  }
}
```

**History:**

* Added in CFEngine 3.19.0, 3.18.1

#### Automatically run bundles tagged autorun

When the ```services_autorun_bundles``` class is defined bundles tagged with ```autorun``` are actuated in lexical order.

Example definition of ```services_autorun_bundles``` using [Augments (def.json)][Augments]:

```json
{
  "classes": {
    "services_autorun_bundles": [ "any::" ]
  }
}
```

**History:**

* Added in CFEngine 3.19.0, 3.18.1

#### Additional automatically loaded inputs

When `def.mpf_extra_autorun_inputs` is defined (and `services_autorun` is defined), the policy files (`*.cf`) in those directories will be added to inputs. If a directory is specified but is not a directory, it will be skipped.

```json
{
  "vars": {
    "mpf_extra_autorun_inputs": [ "$(sys.policy_entry_dirname)/services/autorun/custom2",
                                    "$(sys.policy_entry_dirname)/services/custom1" ]
  }
}
```

**See Also:** [Append to inputs used by main policy][Append to inputs used by main policy], [Append to inputs used by update policy][Append to inputs used by update policy]

**History:**

* Added in CFEngine 3.18.0
