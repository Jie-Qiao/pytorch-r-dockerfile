#FROM nvcr.io/nvidia/pytorch:19.03-py3
FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

# set mirror 
#RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted" > /etc/apt/sources.list  \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic universe" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates universe" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic multiverse" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates multiverse" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted" >> /etc/apt/sources.list \
#&& echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security universe" >> /etc/apt/sources.list

RUN echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
&& echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
#RUN echo "nameserver 223.5.5.5" >> /etc/resolv.conf
#RUN apt-key adv --fetch-keys http://developer.download.nvidia.cn/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub


# Install some basic utilities

RUN http_proxy=http://10.21.25.61:1081 apt-get update

RUN apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    bzip2 \
    libx11-6 \
    axel

# -----------------------------start Install pytorch-----------------------
RUN  apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         libjpeg-dev \ 
         libpng-dev \
	 aria2

#https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
#https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
# use anaconda

RUN aria2c -c -x 16 -s 16 -o ~/anaconda.sh  https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2020.02-Linux-x86_64.sh  && \
     chmod +x ~/anaconda.sh && \
     ~/anaconda.sh -b -p /opt/conda && \
     rm ~/anaconda.sh 

ENV PATH /opt/conda/bin:$PATH

# config mirror from tsinghua
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
 && /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
 && /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch \
 && /opt/conda/bin/conda config --set show_channel_urls yes

#RUN  /opt/conda/bin/conda install numpy pandas pyyaml scipy ipython mkl mkl-include && \
#     /opt/conda/bin/conda install -c pytorch magma-cuda90 && \
#     /opt/conda/bin/conda clean -ya

WORKDIR /opt/pytorch

RUN conda config --set ssl_verify no \
  &&conda install pytorch torchvision cudatoolkit=10.1\
  && conda clean -ya

# -----------------------------End Install pytorch-----------------------

# -----------------------------Start Install R-----------------------
# From https://github.com/rocker-org/rocker/blob/dd21f0b706/r-apt/xenial/Dockerfile
## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
RUN sudo useradd docker \
	&& sudo mkdir /home/docker \
	&& sudo chown docker:docker /home/docker \
	&& sudo addgroup docker staff

#fix the tsinghua mirror
RUN sudo apt-get install -y apt-transport-https \
 && sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 51716619E084DAB9 
 

RUN  sudo apt-get install -y --no-install-recommends \
		software-properties-common \
                ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates 

RUN printf "deb https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu bionic-cran35/" | sudo tee -a /etc/apt/sources.list \
         && sudo add-apt-repository --enable-source --yes "ppa:marutter/rrutter" \
        && sudo add-apt-repository --enable-source --yes "ppa:marutter/c2d4u"


## Configure default locale, see https://github.com/rocker-org/rocker/issues/19

RUN printf "en_US.UTF-8 UTF-8" | sudo tee --append /etc/locale.gen \
	&& sudo locale-gen en_US.utf8 \
	&& sudo /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
## Now install R and littler, and create a link for littler in /usr/local/bin
## Default CRAN repo is now set by R itself, and littler knows about it too
## r-cran-docopt is not currently in c2d4u so we install from source

#fix the tsinghua mirror
#RUN sudo apt-get install -y apt-transport-https \
#&&sudo apt-key adv --recv-keys --keyserver pgpkeys.mit.edu 51716619E084DAB9
#  &&sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 51716619E084DAB9
#RUN gpg --keyserver pgpkeys.mit.edu --recv-key 51716619E084DAB9 \
# && gpg -a --export 51716619E084DAB9 | sudo apt-key add -

RUN  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#                 littler \
 		 r-base \
 		 r-base-dev 
# 		 r-recommended \
#                 r-cran-rcpp \
# 	&& sudo ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
# 	&& sudo ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
# 	&& sudo ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
# 	&& sudo ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
# 	&& sudo install.r docopt \
# 	&& sudo rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
# 	&& sudo rm -rf /var/lib/apt/lists/*


RUN printf "export R_HOME=/usr/lib/R" | sudo tee -a /etc/profile

# -----------------------------End Install R-----------------------




# -----------------------------Start Install Rstudio-----------------------
# From: https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.5.2/Dockerfile
ARG RSTUDIO_VERSION
#ENV RSTUDIO_VERSION=${RSTUDIO_VERSION:0.1.463}
ARG S6_VERSION
ARG PANDOC_TEMPLATES_VERSION
ENV S6_VERSION=${S6_VERSION:-v1.21.7.0}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV PATH=/usr/lib/rstudio-server/bin:$PATH
ENV PANDOC_TEMPLATES_VERSION=${PANDOC_TEMPLATES_VERSION:-2.9}

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide

RUN sudo apt-get install -y --no-install-recommends \
    file \
#    git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    libclang-dev
#    python-setuptools \
#  && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
#  && sudo dpkg -i libssl1.0.0.deb \
#  && sudo rm libssl1.0.0.deb 

RUN  RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && RSTUDIO_LATEST=$(echo $RSTUDIO_LATEST | cut -d- -f1) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && aria2c -c -x 10 -s 10 https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && sudo dpkg -i rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && sudo rm rstudio-server-*-amd64.deb 
  ## Symlink pandoc & standard pandoc templates for use system-wide
RUN   sudo ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && sudo ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && sudo git clone --recursive --branch ${PANDOC_TEMPLATES_VERSION} https://github.com/jgm/pandoc-templates \
  && sudo mkdir -p /opt/pandoc/templates \
  && sudo cp -r pandoc-templates*/* /opt/pandoc/templates && sudo rm -rf pandoc-templates* \
  && sudo mkdir /root/.pandoc && sudo  ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/ \
  ## RStudio wants an /etc/R, will populate from $R_HOME/etc
  && sudo mkdir -p /etc/R \
  ## Write config files in $R_HOME/etc
  && sudo mkdir -p /usr/lib/R/etc/ \
  && printf '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' | sudo tee /usr/lib/R/etc/Rprofile.site \
  && printf "PATH=${PATH}" | sudo tee -a /usr/lib/R/etc/Renviron \
  ## Need to configure non-root user for RStudio
  && sudo useradd rstudio \
  && printf "rstudio:rstudio" | sudo chpasswd \
	&& sudo mkdir /home/rstudio \
	&& sudo chown rstudio:rstudio /home/rstudio \
	&& sudo addgroup rstudio staff \
  ## Prevent rstudio from deciding to use /usr/bin/R if a user apt-get installs a package
  &&  printf 'rsession-which-r=/usr/bin/R' | sudo  tee -a /etc/rstudio/rserver.conf \
  ## use more robust file locking to avoid errors when using shared volumes:
  && printf 'lock-type=advisory' | sudo tee -a /etc/rstudio/file-locks \
  ## configure git not to request password each time
  && sudo git config --system credential.helper 'cache --timeout=3600' \
  && sudo git config --system push.default simple \
  ## Set up S6 init system
  && wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-amd64.tar.gz \
  && sudo tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  && sudo mkdir -p /etc/services.d/rstudio \
  && printf '#!/usr/bin/with-contenv bash \
          \n## load /etc/environment vars first: \
  		  \n for line in $( cat /etc/environment ) ; do export $line ; done \
          \n exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0' \
          | sudo tee /etc/services.d/rstudio/run \
  && printf '#!/bin/bash \
          \n rstudio-server stop' \
          | sudo tee /etc/services.d/rstudio/finish \
  && sudo mkdir -p /home/rstudio/.rstudio/monitored/user-settings \
  && printf 'alwaysSaveHistory="0" \
          \nloadRData="0" \
          \nsaveAction="0"' \
          | sudo tee /home/rstudio/.rstudio/monitored/user-settings/user-settings \
  && sudo chown -R rstudio:rstudio /home/rstudio/.rstudio

COPY userconf.sh /etc/cont-init.d/userconf

## running with "-e ADD=shiny" adds shiny server
COPY add_shiny.sh /etc/cont-init.d/add
#COPY disable_auth_rserver.conf /etc/rstudio/disable_auth_rserver.conf
COPY pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper

EXPOSE 8787
# -----------------------------End Install Rstudio-----------------------

# -----------------------------Start Install Package-----------------------
RUN http_proxy=http://10.21.25.61:1081 apt-get update

RUN sudo apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev 

# config mirror from tsinghua
#RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
# && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
# && conda config --set show_channel_urls yes 

# Install rpy2
RUN conda install -y PyHamcrest
RUN sudo apt-get install -y libreadline6-dev
RUN printf "\n export LD_LIBRARY_PATH=/usr/lib/R/lib/:/usr/lib/R/library/stats/libs/" |sudo tee -a /etc/profile
RUN sudo env "PATH=$PATH" pip install rpy2 -i https://pypi.douban.com/simple

# Install ggplot for python
RUN sudo env "PATH=$PATH" /opt/conda/bin/pip install ggplot -i https://pypi.douban.com/simple && conda clean -ya

# fix the python error in matplotlib 
RUN sudo apt-get install -y libgl1-mesa-glx

# fix the rpy2 bug: "libRlapack.so: cannot open shared object file"
RUN sudo bash -c 'echo "/usr/lib/R/lib/" > /etc/ld.so.conf.d/libR.conf' && sudo ldconfig

# fix the python error in ggplot
RUN sed -i 's/pandas.lib/pandas/g' /opt/conda/lib/python3.7/site-packages/ggplot/stats/smoothers.py \
 && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' /opt/conda/lib/python3.7/site-packages/ggplot/stats/smoothers.py \
 && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' /opt/conda/lib/python3.7/site-packages/ggplot/utils.py

# tidyverse
RUN R -e "install.packages('tidyverse',repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"
RUN R -e "install.packages(c('devtools','formatR','remotes','selectr','caTools','BiocManager'),repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

RUN R -e "install.packages('HCR', repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"
RUN R -e "install.packages('SELF', repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

RUN R -e "install.packages('reticulate', repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/')"

RUN R -e "install.packages(c('foreach','doParallel'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

# install pcalg
RUN R -e "install.packages('BiocManager', repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')" \
 && R -e "options('BioC_mirror'='http://mirrors.ustc.edu.cn/bioc/');BiocManager::install(c('graph','RBGL','Rgraphviz'))"


RUN sudo apt-get install -y libv8-3.14-dev \
 && mv /opt/conda/lib/libgfortran.so.4.0.0 /opt/conda/lib/libgfortran.so.4.0.0.bak \
 && mv /opt/conda/lib/libgfortran.so.4 /opt/conda/lib/libgfortran.so.4.bak \
 && R -e "install.packages(c('pcalg'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')" \
 && mv /opt/conda/lib/libgfortran.so.4.0.0.bak /opt/conda/lib/libgfortran.so.4.0.0 \
 && mv /opt/conda/lib/libgfortran.so.4.bak /opt/conda/lib/libgfortran.so.4 


#RUN sudo add-apt-repository ppa:jonathonf/gcc-7.1 \
# && sudo apt-get update \
# && sudo apt-get install -y gcc-7 g++-7 --no-install-recommends \
# && R -e "install.packages(c('pcalg'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

# install kpcalg
RUN R -e "install.packages(c('kpcalg'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

RUN R -e "install.packages(c('roxygen2'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"

# install plotly
RUN R -e "install.packages(c('plotly'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')"


# install opencv
RUN pip install opencv-python -i https://pypi.douban.com/simple

RUN pip install dominate visdom -i https://pypi.douban.com/simple \
 && sudo chmod -R 777 /opt/conda/lib/python3.7/site-packages/visdom/

# -----------------------------End Install Package-----------------------

#--------------------- start  Disentglement lib package------------------
WORKDIR /opt
RUN git clone https://github.com/google-research/disentanglement_lib.git \
 && cd disentanglement_lib \
 && pip install --upgrade setuptools \
 && pip install .[tf_gpu] -i https://pypi.douban.com/simple \
 && cd .. && rm -rf disentanglement_lib
#--------------------- end  Disentglement lib package------------------

#------------------- install apex -----------------------
RUN git clone https://github.com/NVIDIA/apex \
 && cd apex \
 && pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ \
 && cd .. && rm -rf apex
#------------------  end install apex -------------------




# -----------------------------Start Config SSH-----------------------
# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash qj \
 && usermod -g staff qj
RUN echo "qj ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-qj
USER qj

# All users can use /home/qj as their home directory
ENV HOME=/home/qj
RUN chmod 777 /home/qj

# creat qj
RUN echo "qj:qj1234" | sudo chpasswd 


RUN sudo sudo apt-get -y install openssh-server supervisor
RUN sudo mkdir /var/run/sshd
RUN sudo sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" |sudo tee -a /etc/profile
EXPOSE 22

# support X11 forward
RUN printf "\nX11UseLocalhost no\n" | sudo tee --append /etc/ssh/sshd_config

# -----------------------------End Config SSH-----------------------


COPY startup.sh /home/qj/startup.sh
CMD ["sh","/home/qj/startup.sh"]

#CMD rstudio-server start && bash



