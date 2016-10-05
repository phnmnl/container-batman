FROM r-base:3.3.1

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

# Perform upgrades
RUN apt-get -y update

# Install dependencies
RUN apt-get -y --no-install-recommends install \
	libcurl4-openssl-dev \
	libssl-dev
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Install BATMAN dependencies
RUN R -e "install.packages(c('doSNOW','plotrix','devtools','getopt','optparse'))"
RUN R -e "library(devtools); install_github('jianlianggao/docker-batman/batman',ref='eabb79136ae162e8291ac3af0f4c5fcb1f2c217e')"

# Add runBATMAN.r to /usr/local/bin
ADD runBATMAN.R /usr/local/bin
RUN chmod 0755 /usr/local/bin/runBATMAN.R

# Define entry point, useful for generale use
ENTRYPOINT ["runBATMAN.R"]
