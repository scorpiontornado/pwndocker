Pwndocker
=========
A docker environment for pwn in ctf based on **phusion/baseimage:noble-1.0.2**, which is a modified ubuntu 24.04 baseimage for docker

WARNING: if you're going to expose this container to the internet, it might be wise to remove `/root/.ssh:/root/.ssh` from the volumes in `docker-compose.yml`.

TODO:
- Add neovim-ppa/unstable, Go, NodeJS/npm/fnm, copilot-cli/gemini-cli, etc

### Usage

	docker compose pull
	docker compose up -d
	docker exec -it pwn /bin/zsh

`docker compose pull` downloads the prebuilt image `scorpiontornado/pwndocker:noble` (glibc 2.39).
To build it yourself from the Dockerfile instead, run `docker compose up -d --build`.


### included software

- [pwntools](https://github.com/Gallopsled/pwntools)  —— CTF framework and exploit development library
- [pwndbg](https://github.com/pwndbg/pwndbg)  —— a GDB plug-in that makes debugging with GDB suck less, with a focus on features needed by low-level software developers, hardware hackers, reverse-engineers and exploit developers
- [pwninit](https://github.com/io12/pwninit) -- patch a binary to run with a given libc and matching ld
- [libc-database](https://github.com/niklasb/libc-database) -- every Ubuntu and Debian libc, in `/var/lib/libc-database`
- [ROPgadget](https://github.com/JonathanSalwan/ROPgadget)  —— facilitate ROP exploitation tool
- [one_gadget](https://github.com/david942j/one_gadget) —— A searching one-gadget of execve('/bin/sh', NULL, NULL) tool for amd64 and i386
- [angr](https://github.com/angr/angr)   ——  A platform-agnostic binary analysis framework
- [radare2](https://github.com/radare/radare2) ——  A rewrite from scratch of radare in order to provide a set of libraries and tools to work with binary files
- [seccomp-tools](https://github.com/david942j/seccomp-tools) —— Provide powerful tools for seccomp analysis
- linux_server[64] 	—— IDA 7.0 debug server for linux
- [tmux](https://tmux.github.io/) 	—— a terminal multiplexer
- [ltrace](https://linux.die.net/man/1/ltrace)      —— trace library function call
- [strace](https://linux.die.net/man/1/strace)     —— trace system call

### included glibc

The system glibc is 2.39 (Ubuntu 24.04).
For other versions, use the libc from the challenge with `pwninit`, or look it up in `/var/lib/libc-database`.

### Q&A

#### How to run in custom libc version?

Put the challenge binary and its `libc.so.6` in the same folder, then run:

```shell
pwninit --bin ./test
```

This downloads the matching ld and writes `test_patched`, which runs with that libc.

To do it by hand, get the matching ld from libc-database:

```shell
cd /var/lib/libc-database
./identify /path/to/libc.so.6   # prints the libc id
./download <libc id>            # downloads ld.so and other libs to libs/<libc id>
ls libs/<libc id>                # find the ld file, e.g. ld-linux-x86-64.so.2
patchelf --set-interpreter /var/lib/libc-database/libs/<libc id>/<ld file> ./test
```

or

```python
from pwn import *
p = process(["/path/to/ld.so", "./test"], env={"LD_PRELOAD":"/path/to/libc.so.6"})

```

### ChangeLog

#### 2026-11-11
publish `scorpiontornado/pwndocker:noble` to Docker Hub, remove Pwngdb (it overrode pwndbg's `got`), move libc-database to `/var/lib/libc-database`, add pwninit, remove the glibc_builder copies

#### 2025-10-12
update base image to ubuntu 24.04 (noble, glibc 2.39)

#### 2025-09-14
update base image to ubuntu 22.04 and update `pwntools` version to 4.14.1

#### 2023-10-22
add `zsh` and `ohmyzsh` to docker image, update `pwntools` version to 4.11.0

#### 2023-01-27
add `glibc` versions 2.33~2.36 to docker image, and update `pwntools` version to `4.9.0`

#### 2022-03-06
add `pwntools_version` docker build argument, `4.8.0b0` is set in repo docker build actions

#### 2022-2-10
add docker-compose.yml

#### 2021-10-25
add docker build action and update radare2 version to latest

#### 2020-09-06
update base image to 20.04(glibc 2.31) and add glibc 2.27

#### 2020-05-22
update radare2 to version 4.4.0 and add r2pipe python binding

#### 2020-04-11
add libc 2.30 and 2.31

#### 2020-02-19

python packages switched to python3 version, remove roputils.py
