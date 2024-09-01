FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Install the Docker apt repository
RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-keyring.gpg
COPY docker.list /etc/apt/sources.list.d/docker.list

# Install baseline packages
RUN apt-get update && \
    apt-get install --yes \
    bash \
    build-essential \
    ca-certificates \
    containerd.io \
    curl \
    docker-ce \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin \
    htop \
    jq \
    locales \
    man \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    systemd \
    systemd-sysv \
    unzip \
    vim \
    wget \
    rsync && \
# Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    apt-get install --yes git \
    && rm -rf /var/lib/apt/lists/*

# Enables Docker starting with systemd
RUN systemctl enable docker

# Create a symlink for standalone docker-compose usage
RUN ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Make typing unicode characters in the terminal work.
ENV LANG=en_US.UTF-8

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
    --create-home \
    --shell=/bin/bash \
    --groups=docker \
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

# Install nvm, nodejs, npm, and poetry
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    nvm use --lts && \
    npm install -g npm && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'source $HOME/.nvm/nvm.sh' >> ~/.bashrc
