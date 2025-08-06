# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    git build-essential autoconf automake libtool pkg-config \
    libssl-dev libunbound-dev libcap-ng-dev \
    libjson-c-dev libevent-dev libsystemd-dev \
    python3 python3-pip python3-setuptools python3-wheel \
    vim cscope curl wget unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy your vim configuration
COPY .vim /root/.vim
COPY .vimrc /root/.vimrc

# Ensure pathogen is loaded (in case plugins require activation)
RUN mkdir -p /root/.vim/autoload /root/.vim/bundle && \
    vim -u /root/.vimrc +qall || true

# Set working directory
WORKDIR /src

# Default command
CMD ["/bin/bash"]
