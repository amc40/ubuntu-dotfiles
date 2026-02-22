ARG UBUNTU_VERSION=latest
FROM ubuntu:$UBUNTU_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y sudo wget git

ARG USERNAME=dev
RUN useradd -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME

ENV USER_HOME=/home/${USERNAME} \
    DOTFILES_PATH=/home/${USERNAME}/ubuntu-dotfiles

COPY --chown=${USERNAME}:${USERNAME} . $DOTFILES_PATH

RUN $DOTFILES_PATH/install.sh

WORKDIR /home/${USERNAME}

SHELL ["/bin/zsh", "-c"]
