FROM archlinux:base-devel

ARG TOOLS_PATH=/opt/gcc-arm-none-eabi
ARG ARM_VERSION=12.3.rel1
ARG ZIG_VERSION=0.10.0

RUN pacman -Syu --noconfirm --needed \
  base-devel \
  make cmake ninja \
  git gnupg curl \
  python \
  python-pip \
  python-virtualenv  # Ensure virtualenv is installed

# Install yay
RUN mkdir -p /tmp/yay-build
RUN useradd -m -G wheel builder && passwd -d builder
RUN chown -R builder:builder /tmp/yay-build
RUN echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN su - builder -c "git clone https://aur.archlinux.org/yay.git /tmp/yay-build/yay"
RUN su - builder -c "cd /tmp/yay-build/yay && makepkg -si --noconfirm"
RUN rm -rf /tmp/yay-build

RUN yay -Sy --noconfirm zig=${ZIG_VERSION}

RUN python -m virtualenv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Specifically for Compiling for arm based purposes
RUN mkdir -p ${TOOLS_PATH} \
    && curl -Lo gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VERSION}/binrel/arm-gnu-toolchain-${ARM_VERSION}-x86_64-arm-none-eabi.tar.xz" \
    && tar xf gcc-arm-none-eabi.tar.xz --strip-components=1 -C ${TOOLS_PATH} \
    && rm gcc-arm-none-eabi.tar.xz \
    && rm ${TOOLS_PATH}/*.txt \
    && rm -rf ${TOOLS_PATH}/share/doc

ENV PATH="$PATH:${TOOLS_PATH}/bin"

WORKDIR /project

COPY . .
