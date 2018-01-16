
FROM centos:7
MAINTAINER SubPoint Solutions Team "support@subpointsolutions.au"

RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install which git vim mlocate curl sudo unzip zip file python-devel python-pip python34 python34-devel wget bind-utils

RUN useradd -m -u 501 subpoint
RUN chown subpoint:subpoint /home/subpoint/
RUN echo '%wheel    ALL=(ALL)    NOPASSWD:ALL' > /etc/sudoers.d/wheel
RUN chmod 0440 /etc/sudoers.d/wheel

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN usermod -G rvm,wheel subpoint
RUN usermod -G rvm root
RUN su - root -c "rvm install 2.4.0"

# dev
RUN su - root -c "gem install bundler -v 1.15.4"
RUN su - root -c "gem install rake -v 10.4.2"

# test
RUN su - root -c "gem install rspec -v 3.6.0"
RUN su - root -c "gem install simplecov-bamboo -v 0.1.0"
RUN su - root -c "gem install coderay -v 1.1.2"

# continious testing
RUN su - root -c "gem install guard -v 2.14.1"
RUN su - root -c "gem install guard-rspec -v 4.7.3"

RUN su - root -c "gem install rschema -v 3.2.0"

WORKDIR /metabox