FROM cardcorp/r-java

USER root
RUN apt-get update
RUN apt-get install -y r-cran-rgl
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libcurl4-gnutls-dev
RUN apt-get install -y libxml2-dev
