# Nginx Challenge Project

This repository is an instantiation of the AIxCC ASC Challenge Project (CP)
format for the Nginx project.

## What's in this repository

`src/` - this directory is where CP source code is loaded, analyzed, and built
         from.

`out/` - this directory is used to store artifacts generated from the docker
         containers.

`work/` - this directory is used to store temporary or intermediate artifacts
          passed to and from containers.

`container_scripts/` - this directory contains scripts used in the Docker
                       container to process requested operations from `run.sh`.

`includes/` - directory that holds target-specific Makefiles.

`run.sh` - a script that provides a CRS with a standardized interface to
           interact with the challenge project.

`project.yaml` - a yaml document detailing many important aspects of the
                 challenge project.

`Dockerfile` - the Dockerfile used to create the CP docker image for building,
               running, testing.

`.env.project` - CP-specific environment variables used for configuration.

`.env.docker` - Default environment variables file passed to running docker
                containers.

`Makefile` - top-level Makefile for development-related targets.

## Setup

Prior to evaluating a CP that is specified in this repo, there are a number of
dependencies and initial steps that should be taken.

First, to use this repository in a development (pre-game) environment, the
following dependencies are required. Note, the tested (default) operating system
is Ubuntu 22.04.

```bash
- docker >= 24.0.5
- GNU make >= 4.3
- yq >= 4
```

**NOTE:** Due to recent changes in newer kernels, some sanitizers can encounter
undesirable behaviors because the default value for `vm.mmap_rnd_bits` was
increased to 32. More details can be found here: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2056762.
The CP Docker container will issue a warning if it finds that the host setting
for `vm.mmap_rnd_bits` is above 28, which was the old default. This can be
quieted by overriding the host setting with `sudo sysctl vm.mmap_rnd_bits=28`.

Prior to using `run.sh`, the CP source code repositories specified in the
`project.yaml` file must be obtained. Assuming the proper repository access
tokens are in place, the code will be cloned into `./src` by invoking the
following command:

```bash
make cpsrc-prepare
```

Additionally, the CP repositories can be removed using the make command, which
deletes the folders:

```bash
make cpsrc-clean
```

In addition to the CP source, executing `run.sh` requires the appropriate
Docker image for the CP. Various Makefile targets detailed below will help
in obtaining a valid Docker image for the CP.

Run the following command to pull down the CP-specific Docker image specified
in the `project.yaml` file. Note, the other Docker-specific Makefile targets can
be ignored when using the published image specified in `project.yaml`.

```bash
make docker-pull
```

Another option is to build the CP-specific Docker image locally using the CP
source and the included `Dockerfile`. The following command will initiate the
build process. Note, for the following commands, the environment variable
`DOCKER_IMAGE_NAME` may be specified as an environment variable to assign a
specific name to the locally built docker image. The default value of
`DOCKER_IMAGE_NAME` is derived from the Docker image name in `project.yaml`.

```bash
make docker-build
```

The following command will add an environment variable entry for
`DOCKER_IMAGE_NAME` to `.env.project` such that calls to `run.sh` will use the
locally built docker image by default.

```bash
make docker-config-local
```

Lastly, the following command will delete the docker image specified with
|`DOCKER_IMAGE_NAME` from the local host and remove any mention of it from
`.env.project`. Note, this command will not remove the CP-specific docker image
(from `.project.yaml`) unless `DOCKER_IMAGE_NAME` was explicitly set to that
name (which is unexpected and not recommended).

```bash
make docker-clean
```

## Usage

The included `run.sh` script is the primary mechanism to build and test the CP.
The usage output with example commands is included below.

```bash
A helper script for CP interactions.

Usage: run.sh [OPTIONS] build|run_pov|run_test|custom

OPTIONS:
  -h    Print this help menu
  -v    Turn on verbose debug messages
  -x    Force this script to exit with the exit code from the docker run command

Subcommands:
  build [<patch_file> <source>]       Build the CP (an optional patch file for a given source repo can be supplied)
  run_pov <blob_file> <harness_name>  Run the binary data blob against specified harness
  run_tests                           Run functionality tests
  custom <arbitrary cmd ...>          Run an arbitrary command in the docker container
```

Each subcommand in `run.sh` ultimately results in an invocation of `docker run`
using the various environment variables that `run.sh` supports and supplied
from `.env.project` and `.env.docker`.

The `run.sh` script can exit prior to invoking `docker run` due to some error
in usage or configuration. Such an error will result in an exit code of 1 being
returned directly to the caller.

Assuming no preceding errors, `run.sh` will exit after the call to `docker run`
returns, regardless of the state of the target docker container. If option "-x"
is not specified, the `run.sh` script will return 0 if the container was
launched and has internal state to report on. With "-x" specified, the `run.sh`
script returns the exit code from `docker run`.

The `run.sh` script records the logs, ID, and exit code (if any), from all
invocations of `docker run` in the folder `out/output`. The per invocation data
will be found in subfolders with the naming scheme `<timestamp>--<subcommand>`,
where `<timestamp>` is of the format `<seconds>.<nanoseconds>` from UTC and
`<subcommand>` is the first argument passed to `run.sh`.

The contents of the subfolders (`out/output/<timestamp>--<subcommand>`) include:

- `docker.cid`: Container ID recorded using the `--cidfile` option
  to `docker run`. This is used only for tracking and housekeeping of the
  container.

- `stdout.log`: stdout output from docker container

- `stderr.log`: stderr output from docker container

- `exitcode`: The exit code from the command in the docker container

Note that the exit code value from `docker run` invocations may include
docker-specific values. Per the `docker` conventions, these exit codes are
expected to be in a range of 125 or higher. The CP-specific scripts and
utilities are designed to not overload or reuse exit codes in the `docker`
range.

For the `build` subcommand, the recorded exit code will indicate if the build
process completed successfully or not. Per usual Linux shell / bash conventions,
a value of 0 indicates success, and a non-zero value (usually 1) indicates an
error. The recorded standard output and standard error logs will contain any
useful information regarding the CP-specific build process.

For the `run_pov` subcommand, the recorded exit code will indicate if the PoV
evaluation was performed or not. Per usual Linux shell / bash conventions,
a value of 0 indicates the evaluation was performed, and a non-zero value
(usually 1) indicates an error that stopped the evaluation from running. Note,
the exit code does not indicate if a sanitizer triggered or not. Instead, the
output (e.g., the contents of `stdout.log` and `stderr.log`) must be inspected
to search for the applicable sanitizer strings (see the `sanitizers` element
in the `project.yaml` file) and any helpful stacktraces. Per the exit code
conventions for `run_pov`, any non-zero (error) value suggests an internal error
that prevented the evaluation from running; therefore, sanitizers will likely
only be detectable if the exit code is 0 indicating the evaluation of the
submitted PoV was completed.

For the `run_tests` subcommand, the recorded exit code will indicate if the
functionality tests were performed and if there were any failures in the tests.
Per usual Linux shell / bash conventions, a value of 0 indicates the tests
were performed and there were no failures. A value of 1 indicates the tests
did not complete successfully due to some internal error. Any value greater than
1 (usually 2) but less than 125 (see note about `docker run` exit codes)
indicates the tests were performed but failures were detected in the tests. This
latter indicator suggests something in the build / patching of the CP has
broken or invalidated the functionality and needs addressing. The standard
output and standard error logs may be useful to determine why something failed
in the tests; however, the exit code value is the ultimate indicator of
success or failure.

For the `custom` subcommand, the recorded exit code is the final exit code
returned from the arbitrary command that was invoked. Its meaning is entirely
subject to the invoked command(s).

For almost all cases, a CRS should expect to see all four files from a
successful invocation of `docker run` in the `run.sh` script. The one expected
exception is `exitcode` will be missing if the container is still running.
This may occur if `run.sh` is invoked with options such as
`DOCKER_EXTRA_ARGS="-d"`.

## CP Environment Variables

The various CP containers are configured to support set of both generic and
language-specific environment variables. These variables can be set using
the `.env.docker` file or using the `-e <VARIABLE_NAME>=<VALUE>` argument
syntax to `docker run` (e.g., `DOCKER_EXTRA_ARGS="-e CP_BASE_BUILD_PREFIX=time ./run.sh build`).

### Generic Environment Variables

The following are environment variables that will apply to all CPs:

`CP_BASE_BUILD_PREFIX` - Precedes build command for CP base target (default: empty)

`CP_BASE_BUILD_SUFFIX` - Follows build command for CP base target (default: empty)

`CP_HARNESS_BUILD_PREFIX` - Precedes build command for CP harness(es) (default: empty)

`CP_HARNESS_BUILD_SUFFIX` - Follows build command for CP harness(es) (default: empty)

`NPROC_VAL` - Processing unit count to apply to CP build or test commands to control
              parallelization (when supported) of internal commands (default: `nproc`).

### C-Specific Environment Variables

The following are environment variables that apply to the CPs for the C
programming language (see the `language` element in the CP's `project.yaml`
file).

`CC` - C compiler binary

`CXX` - C++ compiler binary

`CCC` - C++ compiler binary

`CP_BASE_CFLAGS` - C compiler flags for CP base target (default: CP-specific)

`CP_BASE_CXXFLAGS` - C++ compiler flags for CP base target (default: CP-specific)

`CP_BASE_LDFLAGS` - Linker flags for CP base target (default: CP-specific)

`CP_BASE_LIBS` - Libraries to be linked for CP base target (default: CP-specific)

`CP_HARNESS_CFLAGS` - C compiler flags for CP harness(es) target (default: CP-specific)

`CP_HARNESS_CXXFLAGS` - C++ compiler flags for CP harness(es) target (default: CP-specific)

`CP_HARNESS_LDFLAGS` - Linker flags for CP harness(es) target (default: CP-specific)

`CP_HARNESS_LIBS` - Libraries to be linked for CP harness(es) target (default: CP-specific)
