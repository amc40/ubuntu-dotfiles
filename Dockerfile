ARG UBUNTU_VERSION=latest
FROM ubuntu:$UBUNTU_VERSION

ENV DEBIAN_FRONTEND=noninteractive

# fixes agnoster oh-my-zsh theme issue
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y sudo wget git locales

ARG USERNAME=dev
RUN useradd -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV USER_HOME=/home/${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} . ${USER_HOME}/ubuntu-dotfiles

RUN USERNAME=${USERNAME} ${USER_HOME}/ubuntu-dotfiles/dotfiles/install.sh

USER $USERNAME

WORKDIR /home/${USERNAME}

SHELL ["/bin/zsh", "-c"]

ENTRYPOINT ["/usr/bin/zsh", "-l"]
