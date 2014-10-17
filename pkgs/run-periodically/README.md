run-periodically
=================

`run-periodically` runs a given program at specified intervals, running as
once soon as possible if the machine was down when it should have run.

Currently only a daily run to minute precision can be specified, this will
likely expand in the future as needs dictate.

Arguments
----------

* `name`: The name of the resultant executable
* `prog`: The program to run
* `hour`: The hour at which to run
* `min`: The minute at which to run
* `state-file`: The path to a state file. `run-periodically` will try to create
  it on first start and will assume its parent directory exists. It should be
  unique for each "job" on the system, as it is used to track when the last
  run was.
