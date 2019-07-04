


FROM ubuntu:artful

RUN apt-get -y update && \
    apt-get -y install \
        g++ \
        gcc \
        libc6-dev \
        make \
        docker.io \
        git \
        python-dev \
        python3-dev \
        curl \
        wget \
        gccgo-6 \
    && \
    apt-get clean

WORKDIR /local/

ARG GOVERSION="1.9.5"
ARG OS="linux"
ARG ARCH="amd64"

RUN curl -Lo golang.tar.gz https://dl.google.com/go/go$GOVERSION.$OS-$ARCH.tar.gz && \
    tar -C /usr/local -xzf golang.tar.gz

RUN echo 'for bin in $(ls /usr/local/go/bin/ | xargs -n1 | sort -u | xargs); do' > /local/go_install.sh && \
    echo '  test -f /usr/bin/$bin && rm /usr/bin/$bin' >> /local/go_install.sh && \
    echo '  update-alternatives --install /usr/bin/$bin $bin /usr/local/go/bin/$bin 1' >> /local/go_install.sh && \
    echo '  update-alternatives --set $bin /usr/local/go/bin/$bin' >> /local/go_install.sh && \
    echo 'done' >> /local/go_install.sh && \
    cat /local/go_install.sh && \
    chmod +x /local/go_install.sh && \
    /local/go_install.sh

RUN test -f /usr/bin/go && rm /usr/bin/go && \
    ln -s /usr/bin/go-6 /usr/bin/go && \
    cd /usr/local/go/src && \
    GOROOT_BOOTSTRAP=/usr ./make.bash && \
    update-alternatives --set go /usr/local/go/bin/go

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get -y update && \
    apt-get -y install \
        sudo \
        fabric \
        git-lfs \
        myrepos \
        python-pip \
    && \
    apt-get clean all && \
    git lfs install && \
    pip install --upgrade pip

# dependencies
RUN apt-get -y update && \
    apt-get -y install \
        # thrift dependencies
        libboost-dev \
        libboost-test-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libevent-dev \
        automake \
        libtool \
        flex \
        bison \
        pkg-config \
        g++ \
        libssl-dev \
        ant \
        # packaging dependencies
        fakeroot \
        dh-make \
        # python dependencies
        python-dev \
        python-bitarray \
        python-paramiko \
        python-netaddr \
        # miscellaneous dependencies
        libpcap-dev \
        gcc-arm-linux-gnueabi \
        # nanomsg dependencies
        libtool \
        #libtoolize \
    && \
    apt-get clean all

# thrift install
WORKDIR /local/build/thrift/
ENV THRIFT_URL http://www-us.apache.org/dist/thrift/0.9.3/thrift-0.9.3.tar.gz
RUN wget -O thrift.tar.gz $THRIFT_URL && \
    tar -xvzf thrift.tar.gz -C /local/build/thrift && \
    cd thrift* && \
    ./configure --with-java=false && \
    make && \
    make install

# shared ENV variables
ENV ARM_BUILD /local/build/arm
ENV X86_BUILD /local/build/x86_64

RUN mkdir -p $ARM_BUILD/lib/pkgconfig && \
    mkdir -p $X86_BUILD/lib/pkgconfig

# nanomsg install
WORKDIR /local/src/external/github.com/
RUN git clone http://github.com/SnapRoute/nanomsg.git && \
    cd nanomsg && \
    libtoolize && \
    ./autogen.sh && \
    ./configure --prefix=$X86_BUILD/ && \
    make clean && \
    make && \
    make install && \
    make clean && \
    ./configure --build=x86_64-unknown-linux-gnu --host=arm-linux-gnueabi --prefix=$ARM_BUILD/ && \
    make clean && \
    make && \
    make install

# iptables install
ENV PREFIX /local/src/github.com/
WORKDIR $PREFIX
ENV PKG_CONFIG_PATH $X86_BUILD/lib/pkgconfig/:$ARM_BUILD/lib/pkgconfig/
RUN git clone http://github.com/SnapRoute/netfilter.git && \
    cd netfilter && \
    mkdir libiptables && \
    for lib in "libmnl" "libnftnl" "iptables"; do \
        cd $lib ; \
        echo $PWD ; \
        ./autogen.sh; \
        # X86 compile
        make distclean || true; \
        PKG_CONFIG_PATH=$PKG_CONFIG_PATH ./configure CFLAGS="-L$X86_BUILD/lib/" --prefix=$X86_BUILD/ ; \
        make; \
        make install; \
        # ARM compile
        make distclean || true; \
        PKG_CONFIG_PATH=$PKG_CONFIG_PATH ./configure CFLAGS="-L$ARM_BUILD/lib/" --prefix=$X86_BUILD/ --build=x86_64-unknown-linux-gnu --host=arm-linux-gnueabi; \
        make; \
        make install; \
        cd .. ;\
    done

WORKDIR /local/git/
ENV SR_CODE_BASE /local/git/
ENV PKG_CONFIG_PATH $PKG_CONFIG_PATH
ENV GOPATH /local/git/

RUN echo "#!/bin/bash" >> /etc/profile.d/build_env.sh && \
    echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile.d/build_env.sh && \
    echo "export REPO_PATH=/local" >> /etc/profile.d/build_env.sh && \
    echo "export SR_CODE_BASE=$REPO_PATH/go" >> /etc/profile.d/build_env.sh && \
    echo "export PKG_CONFIG_PATH=$REPO_PATH/reltools/build/arm/lib/pkgconfig/:$REPO_PATH/reltools/build/x86_64/lib/pkgconfig/" >> /etc/profile.d/build_env.sh && \
    echo "export GOPATH=$SR_CODE_BASE" >> /etc/profile.d/build_env.sh

RUN mkdir -p /local/startup && \
    echo "#!/bin/bash" >> /local/startup/docker_startup.sh && \
    echo "set -e" >> /local/startup/docker_startup.sh && \
    echo ". /etc/profile.d/build_env.sh" >> /local/startup/docker_startup.sh && \
    echo '/bin/sh -c "$@"' >> /local/startup/docker_startup.sh

ENTRYPOINT ["/local/startup/docker_startup.sh"]

CMD ["bash"]