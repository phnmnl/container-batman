FROM r-base

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

RUN apt-get -y update && apt-get -y install libssl-dev libcurl4-openssl-dev libssh2-1-dev
# Add automatic repo finder for R:
RUN echo 'options("repos"="http://cran.rstudio.com")' >> /etc/R/Rprofile.site

# Add installation lines
RUN echo 'install.packages(c("doSNOW","plotrix","devtools"))' > /install_batman.R
RUN echo 'library(devtools)' >> /install_batman.R
RUN echo 'install_github("jianlianggao/docker-batman/batman")' >> /install_batman.R

RUN Rscript /install_batman.R
