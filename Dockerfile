FROM ubuntu:trusty

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="Install RStudio Server + BATMAN in Docker."

# Environment variables
#ENV DISPLAY=":1"
ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

ENV PACK_R="abind BH cba curl dendextend devtools extrafont FactoMineR geometry ggplot2 Hmisc httr klaR Matrix matrixStats mda memoise plotly plotrix R6 rCharts Rcpp rmarkdown rsm rstudioapi RUnit squash tools doSNOW dplyr Cairo"
#ENV PACK_BIOC="mtbls2 Risa"
ENV PACK_GITHUB="jcapelladesto/geoRge rstudio/rmarkdown vbonhomme/Momocs "


# Add cran R backport
RUN apt-get -y install apt-transport-https
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN echo "deb https://cran.uni-muenster.de/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list

# Update & upgrade sources
RUN apt-get -y update
RUN apt-get -y dist-upgrade

# Install RStudio-related packages
RUN apt-get -y install wget r-base gdebi-core psmisc libapparmor1

# Install development files needed for general compilation
RUN apt-get -y install cmake ed freeglut3-dev g++ gcc git libcurl4-gnutls-dev libgfortran-4.8-dev libglu1-mesa-dev libgomp1 libssl-dev libxml2-dev libcairo2-dev python xorg-dev libxext-dev libxrender-dev libxtst-dev xorg openbox


# Install RStudio from their repository
RUN wget -O /tmp/rstudio-server-download.html https://www.rstudio.com/products/rstudio/download-server/
RUN wget -O /tmp/rstudio.deb "$(cat /tmp/rstudio-server-download.html | grep amd64\.deb | grep wget | sed -e "s/.*https/https/" | sed -e "s/deb.*/deb/")"
RUN dpkg -i /tmp/rstudio.deb
RUN rm /tmp/rstudio-server-download.html
RUN rm /tmp/rstudio.deb
# Clean up
#RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*



# Install R packages
RUN for PACK in $PACK_R; do R -e "install.packages(\"$PACK\", repos='https://cran.rstudio.com/')"; done


# Update R packages
RUN R -e "update.packages(repos='https://cran.rstudio.com/', ask=F)"

# install BATMAN packages in R
RUN R -e "install.packages('batman', repos='http://R-Forge.R-project.org')"


# Configure RStudio server
ADD rserver.conf /etc/rstudio/rserver.conf
ADD rsession.conf /etc/rstudio/rsession.conf
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN echo "sudo xvfb-run rstudio-server restart" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh


# Infrastructure specific
RUN groupadd -g 9999 -f rstudio
RUN useradd -d /home/rstudio -m -g rstudio -u 9999 -s /bin/bash rstudio
RUN echo 'rstudio:docker' | chpasswd


# expose port
EXPOSE 8080

# Define Entry point script
WORKDIR /
ENTRYPOINT ["/bin/sh","/usr/sbin/rstudio-server.sh"]
