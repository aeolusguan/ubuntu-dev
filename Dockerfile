FROM ubuntu:16.04

########################################################
# Essential packages for remote debugging and login in
########################################################

RUN echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse' > /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse' >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates openssh-server build-essential cmake gdb gdbserver git rsync \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 22 for ssh server. 7777 for gdb server.
EXPOSE 22 7777

RUN useradd -ms /bin/bash debugger
RUN echo 'debugger:pwd' | chpasswd

########################################################
# Add custom packages and development environment here
########################################################
# Install Google Test
ENV GTEST_ROOT=/opt/googletest
WORKDIR $GTEST_ROOT
ENV CLONE_TAG=release-1.8.0
RUN git clone -b ${CLONE_TAG} https://github.com/google/googletest.git . && \
    mkdir build && cd build && cmake .. && make && make install

# Install OpenCV & Eigen3 & ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
				libopencv-dev \
				libeigen3-dev \
				ffmpeg && \
		rm -rf /var/lib/apt/lists/*
########################################################

CMD ["/usr/sbin/sshd", "-D"]
