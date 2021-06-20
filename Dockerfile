FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

########################################################
# Essential packages for remote debugging and login in
########################################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates openssh-server build-essential cmake gdb gdbserver git rsync python3-pip \
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
# Install PyTorch
RUN pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html

########################################################

CMD ["/usr/sbin/sshd", "-D"]
