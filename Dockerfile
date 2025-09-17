# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GO_VERSION=1.23.0
ENV PATH="/usr/local/go/bin:${PATH}"

# Install required packages (without golang-go)
RUN apt-get update && apt-get install -y \
    git build-essential autoconf automake libtool pkg-config \
    libssl-dev libunbound-dev libcap-ng-dev \
    libjson-c-dev libevent-dev libsystemd-dev \
    python3 python3-pip python3-setuptools python3-wheel \
    vim cscope curl wget unzip libvirt-dev libvirt-daemon-system \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go from tar.gz
RUN curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

# Verify Go install
RUN go version

# Copy editor configs
COPY .vim /root/.vim
COPY .vimrc /root/.vimrc

# Copy source code
COPY code/src /src

# Set working directory
WORKDIR /src

# Default command
CMD ["/bin/bash"]
