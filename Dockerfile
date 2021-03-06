FROM python:2

MAINTAINER Fokko Driesprong <fokkodriesprong@godatadriven.com>

RUN update-ca-certificates -f \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    wget \
    git \
    npm \
    nodejs-legacy \
    libatlas3-base \
    libopenblas-base \
    postgresql-client \
  && apt-get clean \
  && git config --global http.sslverify false

ENV GIT_SSL_NO_VERIFY=false

# Java
RUN cd /opt/ \
  && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz" \
  && tar xzf jdk-8u66-linux-x64.tar.gz \
  && rm jdk-8u66-linux-x64.tar.gz \
  && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_66/bin/java 100 \
  && update-alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_66/bin/jar 100 \
  && update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_66/bin/javac 100

# SPARK
RUN cd /usr/ \
  && wget http://d3kbcqa49mib13.cloudfront.net/spark-1.6.3-bin-hadoop2.6.tgz \
  && tar xzf spark-1.6.3-bin-hadoop2.6.tgz \
  && rm spark-1.6.3-bin-hadoop2.6.tgz \
  && mv spark-1.6.3-bin-hadoop2.6 spark

ENV SPARK_HOME /usr/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip

RUN mkdir -p /usr/spark/work/ \
  && chmod -R 777 /usr/spark/work/

ENV SPARK_MASTER_PORT 7077

RUN pip install --upgrade pip \
  && pip install pylint coverage --quiet

RUN wget -O ./bin/sbt https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt \
  && chmod 0755 ./bin/sbt \
  && ./bin/sbt -v -211 -sbt-create about

ENV PHANTOM_JS phantomjs-1.9.8-linux-x86_64

RUN cd /tmp/ \
 && wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
 && tar xvjf $PHANTOM_JS.tar.bz2 \
 && rm $PHANTOM_JS.tar.bz2 \
 && mv $PHANTOM_JS /usr/local/share \
 && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

RUN pip install pytest airflow

CMD /usr/spark/bin/spark-class org.apache.spark.deploy.master.Master
