FROM jenkins/jenkins:lts

MAINTAINER F0otsh0T <jychen1@hotmail.com>

WORKDIR /tmp

# BECOME ROOT TO INSTALL REQUIRED PACKAGES
USER root

RUN apt-get -y update &&\
    apt-get -y upgrade &&\
    apt-get -yq install \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        sudo \
        software-properties-common\
        vim &&\
    which curl

# INSTALL DOCKER-CE FOR DEBIAN
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" &&\
    apt-get -y update &&\
    apt-cache madison docker-ce
RUN apt-get install -yq docker-ce=17.03.2~ce-0~debian-stretch
RUN which docker &&\
    usermod -aG docker jenkins

# INSTALL DOCKER COMPOSE
RUN apt-get install -yq docker-compose
RUN which docker-compose &&\
    docker-compose --version

# INSTALL KUBECTL
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list
RUN apt-get -y update &&\
    apt-get -yq install kubectl
RUN which kubectl

## INSTALL HELM
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get-helm.sh
RUN chmod 700 get-helm.sh
RUN ./get-helm.sh -v v2.8.2

# CLEAN UP
RUN apt-get -y autoremove &&\
    apt-get -y autoclean &&\
    apt-get -y clean &&\
    apt -y autoremove &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/archive/* /var/lib/apt/lists/*

# BECOME REGULAR JENKINS USER - GOOD PRACTICE
#USER jenkins
