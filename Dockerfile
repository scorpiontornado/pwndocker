# [Nick] upgraded from phusion/baseimage:jammy-1.0.4, for newer neovim version
FROM phusion/baseimage:noble-1.0.2
LABEL maintainer="skysider <skysider@163.com>"

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Australia/Sydney

# [Nick] added neovim, replaced netcat with netcat-traditional & python3-distutils with python3-setuptools
# [Nick] also removed python3-pip, added python3-venv and curl, added noninteractive, and no-install-recommends
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        libc6:i386 \
        libc6-dbg:i386 \
        libc6-dbg \
        lib32stdc++6 \
        g++-multilib \
        cmake \
        ipython3 \
        vim \
        neovim \
        net-tools \
        iputils-ping \
        libffi-dev \
        libssl-dev \
        python3-dev \
        python3-venv \
        build-essential \
        ruby \
        ruby-dev \
        tmux \
        strace \
        ltrace \
        nasm \
        wget \
        curl \
        gdb \
        gdb-multiarch \
        netcat-traditional \
        socat \
        git \
        patchelf \
        gawk \
        file \
        python3-setuptools \
        bison \
        rpm2cpio cpio \
        zstd \
        zsh \
        tzdata \
        # additional -dev packages for heavy pip builds:
        libcapstone-dev libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev \
        libbz2-dev libz3-dev pkg-config rustc cargo --fix-missing && \
    rm -rf /var/lib/apt/lists/*

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

RUN version=$(curl -s https://api.github.com/repos/radareorg/radare2/releases/latest | grep -P '"tag_name": "(.*)"' -o| awk '{print $2}' | awk -F"\"" '{print $2}') && \
    wget https://github.com/radareorg/radare2/releases/download/${version}/radare2_${version}_amd64.deb && \
    dpkg -i radare2_${version}_amd64.deb && rm radare2_${version}_amd64.deb

# [Nick] removed Tsinghua stuff & get-pip to avoid externally managed environment
# because of PEP668 (& noble's Python version), --break-system-packages wasn't enough

# RUN python3 -m pip install -U pip && \
#    python3 -m pip install --no-cache-dir \
# Install a standalone pip (not the Debian-managed one) and packages
RUN wget -q https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py --break-system-packages && \
    rm get-pip.py && \
    pip install --upgrade --break-system-packages pip setuptools wheel && \
    pip install --break-system-packages --no-cache-dir --prefer-binary \
        ropgadget \
        z3-solver \
        smmap2 \
        apscheduler \
        ropper \
        unicorn \
        keystone-engine \
        capstone \
        angr \
        pebble \
        r2pipe \
        pwntools

RUN gem install elftools one_gadget seccomp-tools && rm -rf /var/lib/gems/*/cache/*

RUN wget -q -O /usr/local/bin/pwninit \
        https://github.com/io12/pwninit/releases/latest/download/pwninit && \
    chmod +x /usr/local/bin/pwninit

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg && \
    cd pwndbg && chmod +x setup.sh && ./setup.sh

# [Nick] removed Pwngdb because it was overriding pwndbg's `got` command with an inferior version

# RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
#     cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
#     sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb && \
#     echo "source ~/Pwngdb/.gdbinit-pwngdb" >> ~/.gdbinit

RUN wget -O ~/.gdbinit-gef.py -q http://gef.blah.cat/py

# [Nick] cloned to /var/lib/libc-database, where pwntools looks for a local libc-database
RUN git clone --depth 1 https://github.com/niklasb/libc-database.git /var/lib/libc-database && \
    cd /var/lib/libc-database && ./get ubuntu debian && \
    rm -rf /tmp/* /var/lib/libc-database/.git

WORKDIR /ctf/work/

# [Nick] removed the skysider/glibc_builder copies (2.19-2.36, none as new as noble's 2.39).
# Use pwninit, or ./download in /var/lib/libc-database, to get a matching libc and ld.

COPY linux_server linux_server64  /ctf/

RUN chmod a+x /ctf/linux_server /ctf/linux_server64

CMD ["/sbin/my_init"]
