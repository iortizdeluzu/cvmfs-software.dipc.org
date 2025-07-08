FROM rockylinux:8

RUN yum update -y && yum install -y \
    openssh-server \
    sudo \
    && mkdir /var/run/sshd

RUN yum install -y \
        gcc gcc-c++ gcc-gfortran make automake autoconf wget curl \
        python3 python3-pip python3-devel \
        bzip2-devel \
        libffi-devel \
        openssl-devel \
        git \
        epel-release && \
        yum clean all
# Install LUA
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y epel-release \
        lua lua-devel bc \
        procps-ng unzip findutils \
        wget git make gcc gcc-c++ rsync \
        zlib-devel bzip2 bzip2-devel xz xz-devel \
        readline-devel openssl-devel file patch

# Install CernVM-FS (client and server)
RUN yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm && \
    yum install -y cvmfs cvmfs-server && \
    yum clean all

RUN useradd -m -s /bin/bash stratum && \
    echo "stratum:stratum" | chpasswd && \
    mkdir -p /home/stratum/.ssh && \
    chown stratum:stratum /home/stratum/.ssh && \
    chmod 700 /home/stratum/.ssh

RUN ssh-keygen -A  # <-- Claves de host

# Permit public key authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

RUN mkdir -p /cvmfs/software.dipc.org && chown stratum:stratum /cvmfs/software.dipc.org

EXPOSE 22

RUN rm -f /var/run/nologin

RUN cd /tmp && \
    wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz && \
    tar zxpf luarocks-3.9.2.tar.gz && \
    cd luarocks-3.9.2 && \
    ./configure --with-lua-include=/usr/include && \
    make && make install

# Asegura que los módulos Lua estén accesibles
ENV LUA_PATH="/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;;"
ENV LUA_CPATH="/usr/local/lib/lua/5.3/?.so;;"

# Instala el módulo 'posix' de Lua para Lmod
RUN luarocks --lua-version=5.3 install luaposix

RUN dnf install -y tcl tcl-devel

# Install Lmod from source under /cvmfs/software.dipc.org/lmod
RUN git clone https://github.com/TACC/Lmod.git /tmp/Lmod && \
    cd /tmp/Lmod && \
    ./configure --prefix=/cvmfs/software.dipc.org/lmod && \
    make install

RUN chown -R stratum:stratum /cvmfs
RUN echo 'source /cvmfs/software.dipc.org/lmod/lmod/8.7.63/init/profile' >> /etc/bashrc

# Upgrade pip and install EasyBuild via pip
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install easybuild easybuild-easyconfigs

# Set environment variable for EasyBuild prefix
ENV EASYBUILD_PREFIX=/cvmfs/software.dipc.org

# (Optional) Add easybuild to PATH for convenience (adjust path if needed)
ENV PATH=$EASYBUILD_PREFIX/bin:$PATH

#COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]

