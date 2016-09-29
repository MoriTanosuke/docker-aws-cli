FROM alpine
MAINTAINER Carsten Ringe, carsten@kopis.de

ENV LAST_UPDATE=2016-08-21

#####################################################################################
# Current version is aws-cli/1.10.53 Python/2.7.12
#####################################################################################

RUN apk update

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

# man and less are needed to view 'aws <command> help'
# ssh allows us to log in to new instances
# vim is useful to write shell scripts
# python* is needed to install aws cli using pip install

RUN apk add \
    groff \
    less \
    man \
    python \
    py-pip
RUN pip install virtualenv

RUN addgroup aws
RUN adduser -S -G aws aws
WORKDIR /home/aws

USER aws

RUN \
    mkdir aws && \
    virtualenv aws/env && \
    ./aws/env/bin/pip install awscli && \
    echo 'source $HOME/aws/env/bin/activate' >> .bashrc && \
    echo 'complete -C aws_completer aws' >> .bashrc

USER root

RUN mkdir examples
ADD examples/etag.sh /home/aws/examples/etag.sh
ADD examples/s3diff.sh /home/aws/examples/s3diff.sh
ADD examples/start.sh /home/aws/examples/start.sh
ADD examples/terminate.sh /home/aws/examples/terminate.sh
ADD examples/init-instance.script /home/aws/examples/init-instance.script
ADD examples/README.md /home/aws/examples/README.md
RUN chown -R aws:aws /home/aws/examples

USER aws

