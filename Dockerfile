FROM ubuntu:trusty

MAINTAINER Kristian Peters <kpeters@ipb-halle.de>

LABEL Description="Install RStudio Server + important R & Bioconductor packages in Docker."



# Environment variables
ENV DISPLAY=":1"
ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

ENV PACK_R="abind BH cba curl dendextend devtools eigenfaces extrafont FactoMineR geometry ggplot2 Hmisc httr klaR magic Matrix matrixStats mda memoise plotly plotrix R6 rCharts Rcpp rmarkdown rsm rstudioapi RUnit squash tools"
#ENV PACK_BIOC="mtbls2 Risa"
ENV PACK_GITHUB="dragua/xlsx glibiseller/IPO jcapelladesto/geoRge rstudio/rmarkdown vbonhomme/Momocs vbonhomme/eigenfaces"


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
RUN apt-get -y install cmake ed freeglut3-dev g++ gcc git libcurl4-gnutls-dev libgfortran-4.8-dev libglu1-mesa-dev libgomp1 libssl-dev libxml2-dev python xorg-dev


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



# Configure RStudio server
ADD rserver.conf /etc/rstudio/rserver.conf
ADD rsession.conf /etc/rstudio/rsession.conf
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh

# install additional packages in R
RUN echo 'install.packages("doSNOW")' > /install_batman.R
RUN echo 'install.packages("plotrix")' >> /install_batman.R
RUN echo 'install.packages("batman", repos="http://R-Forge.R-project.org")' >> /install_batman.R

RUN Rscript /install_batman.R

# Infrastructure specific
RUN groupadd -g 9999 -f rstudio
RUN useradd -d /home/rstudio -m -g rstudio -u 9999 -s /bin/bash rstudio
RUN echo 'rstudio:docker' | chpasswd

#RUN apt-get -y install ldap-utils libpam-ldapd libnss-ldapd libldap2-dev nslcd
#WORKDIR /
#ADD etc/ldap.conf /etc/ldap.conf
#ADD etc/ldap /etc/ldap
#ADD etc/pam.d /etc/pam.d
#ADD etc/nsswitch.conf /etc/nsswitch.conf
#ADD etc/nslcd.conf /etc/nslcd.conf
#RUN chmod 660 /etc/nslcd.conf
#ADD etc/ssl/certs/IPB* /etc/ssl/certs/
#RUN update-rc.d nslcd enable
#RUN mkdir /raid
#RUN ln -s /home /raid/home
#
#RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
#RUN echo "service nslcd start" >> /usr/sbin/rstudio-server.sh
#RUN echo "sleep 10" >> /usr/sbin/rstudio-server.sh
#RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
#RUN chmod +x /usr/sbin/rstudio-server.sh



# expose port
EXPOSE 8080

# Define Entry point script
WORKDIR /
ENTRYPOINT ["/bin/sh","/usr/sbin/rstudio-server.sh"]

