# BATMAN Dockerfile without rstudio, R only.
# use following command to mount docker container on locally controlled Ubuntu server
# docker run -d -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --publish=9000:8787 <container image name>

FROM r-base:latest

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

##LABEL Description="RStudio Server + BATMAN Docker container"

## Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin/:$PATH

## Download and install RStudio dependencies
RUN rm -rf /var/lib/apt/lists/ \
  && apt-get update \
  && apt-get install -y -t unstable --no-install-recommends \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    psmisc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

## install BATMAN dependencies
RUN echo 'install.packages(c("doSNOW","plotrix","devtools"))' > /install_batman.R
RUN echo 'library(devtools)' >> /install_batman.R
RUN echo 'install_github("jianlianggao/docker-batman/batman")' >> /install_batman.R

RUN Rscript /install_batman.R

## Port number
EXPOSE 8787

CMD ["R"]

