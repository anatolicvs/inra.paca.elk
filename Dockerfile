FROM ubuntu:latest

WORKDIR /home/inra
RUN apt-get -y update
RUN apt-get -y upgrade

# install some general tools
RUN apt-get install -y gnupg2
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y jq
RUN apt-get install -y apt-utils
RUN apt-get install -y make
RUN apt-get install -y g++


# install node (8.x or higher):
RUN curl -sL https://deb.nodesource.com/setup_8.x > setup_8.x
RUN chmod 755 ./setup_8.x && ./setup_8.x
RUN apt-get install -y nodejs

# install the hbz jsonld-cli fork:
RUN git clone https://github.com/hbz/jsonld-cli.git
RUN cd jsonld-cli && npm install -g


EXPOSE 9200 5601 3000

# Note: elasticsearch requires java runtime environment
RUN apt-get install -y openjdk-11-jre-headless

# now install elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-amd64.deb

RUN dpkg -i elasticsearch-7.1.1-amd64.deb

# set default host to 0.0.0.0
RUN sed -i "s|#network.host: 192.168.0.1|network.host: 0.0.0.0|g" /etc/elasticsearch/elasticsearch.yml

# install and configure kibana
RUN wget https://artifacts.elastic.co/downloads/kibana/kibana-7.1.1-amd64.deb

RUN dpkg -i kibana-7.1.1-amd64.deb

# set default host to 0.0.0.0
RUN sed -i "s|#server.host: \"localhost\"|server.host: 0.0.0.0|g" /etc/kibana/kibana.yml

RUN sysctl -w vm.max_map_count=262144

# install workshop data
RUN git clone https://github.com/hbz/swib18-workshop.git

WORKDIR /home/loud/swib18-workshop
RUN npm install

# set default host to 0.0.0.0
RUN sed -i "s|const hostname = '127.0.0.1'|const hostname = '0.0.0.0'|g" /home/loud/swib18-workshop/js/app.js

# start all services 
CMD service elasticsearch start && service kibana start && npm start
