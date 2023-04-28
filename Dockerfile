FROM ubuntu:latest AS jenkins_builder


RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    git

ENV JENKINS_HOME=/var/jenkins_home

RUN mkdir  jenkins \
    && mkdir -p /usr/share/jenkins \
    && wget http://updates.jenkins-ci.org/download/war/2.319/jenkins.war \
    && mv jenkins.war /usr/share/jenkins/jenkins.war \
    && chown -R root:root /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/jenkins.war \
    && mkdir -p $JENKINS_HOME \
    && chown -R 1000:1000 $JENKINS_HOME

FROM ubuntu:latest AS tomcat_builder

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget 

ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

RUN wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz \
    && tar -xzvf apache-tomcat-9.0.74.tar.gz -C /opt \
    && mv /opt/apache-tomcat-9.0.74 $CATALINA_HOME \
    && rm apache-tomcat-9.0.74.tar.gz

COPY --from=jenkins_builder /usr/share/jenkins/jenkins.war $CATALINA_HOME/webapps/jenkins.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
