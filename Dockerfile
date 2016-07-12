# BATMAN Dockerfile without rstudio, R only.
# use following command to mount docker container on locally controlled Ubuntu server
# docker run -d -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --publish=9000:8787 <container image name>

FROM r-base:latest

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

## Add /usr/local/bin to PATH -- you can delete this, /usr/local/bin is normally in the PATH
## ENV PATH /usr/local/bin/:$PATH

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
RUN echo 'install.packages(c("doSNOW","plotrix","devtools","optparse"))' > /install_batman.R
RUN echo 'library(devtools)' >> /install_batman.R
RUN echo 'install_github("jianlianggao/docker-batman/batman")' >> /install_batman.R

RUN Rscript /install_batman.R

## copy runBATMAN.r into /usr/local/bin folder
COPY runBATMAN.R /usr/local/bin

## Make sure runBATMAN.r is executable
RUN chmod a+x /usr/local/bin/runBATMAN.R

## Port number -- probably legacy of the RStudio version -- you don't need to expose any ports for this functionality.
## EXPOSE 8787

## Arguments are not needed in the ENTRYPOINT, only the executable, which given that it is in the path,
## doesn't need to be given with the absolute path.
ENTRYPOINT ["runBATMAN.R"]

