# Extended update concept

This concept is about policy files distribution approach where each client receives from hub only those files that are 
specific to him. Atop of that, it uses autorun option to execute those. It is about extending existing update process to 
copy client specific CFEngine policy files from separate repository directory on hub but not located in "masterfiles", since 
those there will be copied to all clients.

## Description

Client uses it's IP address, hostname and tags file content to enlist subdirectories in hub repository (`$(sys.workdir)/repository/cfengine` 
or check and adapt `jb_update_policy3.cf` file to your needs). Additional update policy file will look for `$(sys.workdir)/node_tags.dat`
file where tags can be separated with white space character (\s, \n), coma (,) or semicolon (;). 

Hub repository directory is added to to maintained CFEngine infrastructure, to be shared, with granted access and permissions adjusted (to 0600).

## Schema

This schema shall present this concept:

```
-------                                               --------------------------------
| hub |                                               | client1: tag1, tag3, 1.2.3.4 |
-------------------------------------------           ------------------------------------------------
|/var/cfengine/masterfiles/*              | --------> | /var/cfengine/inputs/*                       |
|            -/repository/tag1/pol1.cf    | --------> | /var/cfengine/inputs/service/autorun/pol1.cf |
|                            -/pol2.cf    | --------> |                                    -/pol2.cf |
|                       -/tag2/pol3.cf    |    -----> |                                    -/pol5.cf |
|                            -/pol4.cf    |   |   --> |                                    -/pol6.cf |
|                       -/tag3/pol5.cf    | --   |    ------------------------------------------------
|                       -/1.2.3.4/pol6.cf | -----     --------------------------------
|                       -/2.3.4.5/pol7.cf | -----     | client2: tag2, tag3, 2.3.4.5 |
-------------------------------------------      |    ------------------------------------------------
                                                 |    | /var/cfengine/inputs/*                       |
                                                 |    | /var/cfengine/inputs/service/autorun/pol3.cf |
                                                 |    |                                    -/pol4.cf |
                                                 |    |                                    -/pol5.cf |
                                                  --> |                                    -/pol7.cf |
                                                      ------------------------------------------------
```
