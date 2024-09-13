#!/bin/bash

set -e
set -x
set -o pipefail

DEBIAN_FRONTEND=noninteractive apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    binutils \
    build-essential \
    pkg-config \
    gcc \
    git \
    libelf-dev \
    make  \
    perl-base \
    rsync \
    libpcre3-dev \
    zlib1g-dev \
    libz-dev \
    libgd3 \
    libgd-dev \
    libgd-perl \
    libssl-dev \
    && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/*
echo "yes" | cpan install GD

cp /usr/local/lib/clang/18/lib/x86_64-unknown-linux-gnu/libclang_rt.fuzzer.a /usr/lib/libFuzzingEngine.a
cp /usr/local/lib/clang/18/lib/x86_64-unknown-linux-gnu/libclang_rt.asan.a /usr/lib/libasan.a
