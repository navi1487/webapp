FROM stakater/java-centos:7-1.8

LABEL name="Naveen Maven Image on CentOS" \
      release="1" \
      summary="A Maven based image on CentOS"

# Setting Maven Version that needs to be installed
ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.3.9

# Changing user to root to install maven
USER root

# Install required tools
# which: otherwise 'mvn version' prints '/usr/share/maven/bin/mvn: line 93: which: command not found'
RUN yum update -y && \
  yum install -y which && \
  yum update -y && \
  yum install -y curl && \
  yum install -y java-11-openjdk-devel  && \
  yum install -y git && \
  yum clean all && \
   curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn


ENV MAVEN_VERSION=${MAVEN_VERSION}
ENV M2_HOME /usr/share/maven
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH



RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app


RUN git clone https://github.com/navi1487/webapp.git
# Define default command, can be overriden by passing an argument when running the container

# Maven assembly will package the project into a JAR FILE which can be executed
RUN cd /usr/src/app/webapp &&   mvn clean  package


#Tomcat installation
RUN mkdir /opt/tomcat/
WORKDIR /opt/tomcat

RUN curl -O https://www-eu.apache.org/dist/tomcat/tomcat/tomcat-8/v8.5.61/bin//apache-tomcat-8.5.61.tar.gz && \
 tar xvfz apache*.tar.gz && \
 mv apache-tomcat-8.5.40/* /opt/tomcat/. && \
 cp  /usr/src/app/webapp/target/WebApp.war /opt/tomcat/webapps
 
 EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]



