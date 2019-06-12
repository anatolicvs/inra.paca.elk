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
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get -y install apt-transport-https

# Note: elasticsearch requires java runtime environment
RUN apt-get install -y openjdk-11-jre-headless

# now install elasticsearch
# RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-amd64.deb
# RUN dpkg -i elasticsearch-7.1.1-amd64.deb

RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get -y update && apt-get install -y elasticsearch

# set default host to 0.0.0.0
RUN sed -i "s|#network.host: 192.168.0.1|network.host: 0.0.0.0|g" /etc/elasticsearch/elasticsearch.yml

# install and configure kibana
# RUN wget https://artifacts.elastic.co/downloads/kibana/kibana-7.1.1-amd64.deb
# RUN dpkg -i kibana-7.1.1-amd64.deb

RUN apt-get install -y kibana

# set default host to 0.0.0.0
RUN sed -i "s|#server.host: \"localhost\"|server.host: 0.0.0.0|g" /etc/kibana/kibana.yml

RUN sysctl -w vm.max_map_count=262144

# install workshop data
RUN git clone https://github.com/aytacozkan/inra.paca.elk.git

WORKDIR /home/inra/inra.paca.elk
RUN npm install

# set default host to 0.0.0.0
RUN sed -i "s|const hostname = '127.0.0.1'|const hostname = '0.0.0.0'|g" /home/inra/inra.paca.elk/js/app.js

# start all services 
CMD service elasticsearch start && service kibana start && npm start
