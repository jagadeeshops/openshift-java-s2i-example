FROM registry.access.redhat.com/rhel7-atomic
MAINTAINER Chakradhar Rao Jonagam (9chakri@gmail.com)

ENV BUILDER_VERSION 1.1

RUN microdnf --enablerepo=rhel-7-server-rpms \ 
    install -y wget tar unzip ca-certificates sudo && \ 
    microdnf clean all -y 

ENV TOMCAT_MAJOR_VERSION 8 
ENV TOMCAT_MINOR_VERSION 8.0.32 
ENV CATALINA_HOME /tomcat 


# Install openjdk 1.8 
RUN microdnf --enablerepo=rhel-7-server-rpms install java-1.8.0-openjdk-headless --nodocs  -y && \ 
    microdnf clean all -y && \
    rm -rf /var/lib/apt/lists/* 

# INSTALL TOMCAT 
WORKDIR /

RUN wget -q -e use_proxy=yes https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz && \
    tar -zxf apache-tomcat-*.tar.gz &&\
    rm -f apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat 


ENV JAVA_OPTS="-Dtuf.environment=DEV -Dtuf.appFiles.rootDirectory=/TempDirRoot" 


#RUN groupadd -r safe 
#RUN useradd  -r -g safe safe 
RUN mkdir -p /tomcat/webapps /TempDirRoot
RUN chown -R 1001:1001 /tomcat /TempDirRoot 
RUN chmod -R 777 /tomcat /TempDirRoot 

RUN cd /tomcat/webapps/; rm -rf ROOT docs examples host-manager manager 

COPY ./.s2i/bin/ /usr/libexec/s2i
LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
USER 1001

EXPOSE 8080

CMD $STI_SCRIPTS_PATH/usage
