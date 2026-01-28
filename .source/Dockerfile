# Use the official Debian stable slim image as the base
FROM debian:stable-slim

# Arguments for User creation
ARG USERNAME=linux
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# 1. Install Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget git sudo nano procps tree \
    bash-completion man-db btop \
    zip unzip less \
    python3 python3-pip python3-venv npm ssh \
    iputils-ping dnsutils iproute2 net-tools traceroute mtr-tiny \
    nmap netcat-openbsd tcpdump socat openssl ca-certificates hping3 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "arm64" ]; then AWS_ARCH="aarch64"; else AWS_ARCH="x86_64"; fi && \
    curl -4 --http1.1 -fSL \
      "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
      -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install


# 3. Finalize
USER $USERNAME
WORKDIR /home/$USERNAME
RUN mkdir /home/$USERNAME/.logs

# Drop directly into Bash instead of hanging
CMD ["/bin/bash"]