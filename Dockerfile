FROM ubuntu:16.04

LABEL maintainer="PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )"
LABEL software.version="1.2.12.0"
LABEL version="1.0"
LABEL software="batman"
LABEL description="Estimates metabolite concentrations from Nuclear Magnetic Resonance spectral data using a specialised MCMC algorithm"
LABEL website="http://batman.r-forge.r-project.org/"
LABEL documentation="https://r-forge.r-project.org/scm/viewvc.php/*checkout*/documentation%20and%20test/batman.pdf?root=batman"
LABEL license="undefined"
LABEL tags="Metabolomics"

ENV BATMAN_REVISION "76f57f954c0b980ac0b506ed60b4db704515fbeb"

# Install R and BATMAN
RUN apt-get update && apt-get install -y --no-install-recommends r-base r-base-dev \
                              libcurl4-openssl-dev libssl-dev git && \
    echo 'options("repos"="http://cran.rstudio.com", download.file.method = "libcurl")' >> /etc/R/Rprofile.site && \
    R -e "install.packages(c('doSNOW','plotrix','devtools','getopt','optparse'))" && \
    R -e 'library(devtools); install_github("jianlianggao/batman/batman", ref=Sys.getenv("BATMAN_REVISION")[1]);' && \
    R -e 'remove.packages(c("devtools"))' && \
    apt-get purge -y r-base-dev git libcurl4-openssl-dev libssl-dev && \
    apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Add runBATMAN.r to /usr/local/bin
ADD runBATMAN.R /usr/local/bin
RUN chmod 0755 /usr/local/bin/runBATMAN.R

# Add tests
ADD runTest1.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/runTest1.sh

# Define entry point, useful for generale use
ENTRYPOINT ["runBATMAN.R"]
