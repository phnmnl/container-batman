FROM r-base:latest

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

# Perform upgrades
RUN apt-get -y update
RUN apt-get -y upgrade

# Install dependencies
RUN apt-get -y --no-install-recommends install \
	libapparmor-dev \
	libedit-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	psmisc
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Install BATMAN dependencies
RUN R -e "install.packages(c('doSNOW','plotrix','devtools','getopt','optparse'))"
RUN R -e "library(devtools); install_github('jianlianggao/docker-batman/batman')"

# Add runBATMAN.r to /usr/local/bin
ADD runBATMAN.R /usr/local/bin
RUN chmod 0755 /usr/local/bin/runBATMAN.R

# Define entry point, useful for generale use
ENTRYPOINT [ "/bin/sh", "-c", "/usr/local/bin/runBATMAN.R" ]
