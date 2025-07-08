FROM rockylinux:8

RUN yum update -y && yum install -y \
    openssh \
    openssh-clients \
    iputils \
    sudo \
    sshpass

# Crear usuario normal
RUN useradd -m -s /bin/bash publisher && \
    echo "publisher:publisher" | chpasswd && \
    mkdir -p /home/publisher/.ssh && \
    chown -R publisher:publisher /home/publisher/.ssh && \
    chmod 700 /home/publisher/.ssh

COPY setup_ssh.sh /setup_ssh.sh
RUN chmod +x /setup_ssh.sh

RUN mkdir -p /cvmfs/software.dipc.org && chown -R publisher:publisher /cvmfs/software.dipc.org

# Install LUA
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y epel-release \
        lua lua-devel bc \
        procps-ng unzip findutils \
        wget git make gcc gcc-c++ \
        zlib-devel bzip2 bzip2-devel xz xz-devel \
        readline-devel openssl-devel file patch

# Instala luarocks desde fuente
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

# Load Lmod 
RUN echo 'source /cvmfs/software.dipc.org/lmod/lmod/8.7.63/init/profile' >> /etc/bashrc

RUN yum install -y \
        gcc gcc-c++ gcc-gfortran make automake autoconf wget curl \
        python3 python3-pip python3-devel \
        bzip2-devel \
        libffi-devel \
        openssl-devel \
        git \
        epel-release && \
    yum clean all

## Install EasyBuild
RUN yum install -y \
        gcc gcc-c++ gcc-gfortran make automake autoconf wget curl \
        python3 python3-pip python3-devel \
        bzip2-devel \
        libffi-devel \
        openssl-devel \
        git \
        epel-release && \
    yum clean all

# Upgrade pip and install EasyBuild via pip
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install easybuild easybuild-easyconfigs

# Set environment variable for EasyBuild prefix
ENV EASYBUILD_PREFIX=/cvmfs/software.dipc.org

# (Optional) Add easybuild to PATH for convenience (adjust path if needed)
ENV PATH=$EASYBUILD_PREFIX/bin:$PATH


USER publisher
WORKDIR /home/publisher

CMD ["/bin/bash", "/setup_ssh.sh"]

