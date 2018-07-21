FROM ubuntu:16.04

# Prepare Ubuntu

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "XKBMODEL=\"pc105\"\n \
          XKBLAYOUT=\"us\"\n \
          XKBVARIANT=\"\"\n \
          XKBOPTIONS=\"\"" > /etc/default/keyboard

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        curl \
        vim \
        ca-certificates \
        libjpeg-dev \
        libpng-dev \
        sudo \
        apt-utils \
        man \
        tmux \
        less \
        wget \
        iputils-ping \
        zsh \
        htop \
        software-properties-common \
        tzdata \
        locales \
        openssh-server \
        xauth \
        rsync

RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

# Install Conda

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \     
    rm ~/miniconda.sh
RUN echo "export PATH=/opt/conda/bin:\$PATH" > /etc/profile.d/conda.sh
ENV PATH /opt/conda/bin:$PATH

# Install NLTK

RUN pip install nltk==3.2.5
WORKDIR /opt
RUN python -m nltk.downloader perluniprops nonbreaking_prefixes

# Install PyTorch, TorchVision, TorchText

RUN conda install numpy pyyaml scipy ipython cython mkl pytorch-cpu torchvision-cpu -c pytorch && \
    conda clean -ya 
RUN git clone https://github.com/pytorch/text /tmp/torchtext --depth 1
WORKDIR /tmp/torchtext
RUN python setup.py install

# Install KoNLPy with Mecab

RUN sudo apt install -y g++ openjdk-8-jdk autoconf
RUN pip install konlpy jpype1
WORKDIR /tmp
RUN wget https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh
RUN chmod +x mecab.sh
RUN bash mecab.sh
RUN ldconfig
WORKDIR /tmp/mecab-ko-dic-2.0.1-20150920
RUN make && make install

# Install Champollion

RUN git clone https://github.com/juneoh/champollion /opt/champollion --depth 1
WORKDIR /opt/champollion
ENV CTK /opt/champollion
ENV PATH /opt/champollion/bin:$PATH
RUN echo "export CTK=/opt/champollion\nexport PATH=/opt/champollion/bin:\$PATH" > /etc/profile.d/champollion.sh

# Install FastText

RUN git clone https://github.com/facebookresearch/fasttext /opt/fasttext --depth 1
WORKDIR /opt/fasttext
RUN make
ENV PATH /opt/fasttext:$PATH
RUN echo "export PATH=/opt/fasttext:\$PATH" > /etc/profile.d/fasttext.sh

# Install gensim

RUN pip install gensim

# Install MUSE

WORKDIR /root
RUN git clone https://github.com/facebookresearch/MUSE --depth 1
WORKDIR /root/MUSE/data
RUN bash get_evaluation.sh

# Install SRILM

COPY srilm-1.7.2.tar.gz /tmp/
RUN mkdir /opt/srilm
RUN tar -xvf /tmp/srilm-1.7.2.tar.gz -C /opt/srilm
WORKDIR /opt/srilm
RUN SRILM=/opt/srilm make
ENV PATH /opt/srilm/bin/i686-m64:$PATH
RUN echo "export PATH=/opt/srilm/bin/i686-m64:\$PATH" > /etc/profile.d/srilm.sh

# Install sample codes

WORKDIR /root
RUN git clone https://github.com/kh-kim/nlp_preprocessing --depth 1
RUN git clone https://github.com/kh-kim/OpenNLMTK --depth 1
RUN git clone https://github.com/kh-kim/simple-nmt --depth 1
RUN git clone https://github.com/kh-kim/subword-nmt --depth 1
RUN mkdir data

# Prepare SSH

RUN mkdir /var/run/sshd
RUN echo 'root:fastcampus' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN service ssh restart

# Wrap up

RUN rm -rf /tmp/* /var/lib/apt/lists/*
ENV PYTHONUNBUFFERED=1
EXPOSE 22 8888
WORKDIR /root
CMD ["/usr/sbin/sshd", "-D"]
