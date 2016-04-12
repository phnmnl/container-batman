FROM r-base

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL Description="Install RStudio Server + BATMAN in Docker."

# Environment variables
#ENV DISPLAY=":1"
#ENV PATH="/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/bin:/sbin"
#ENV PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig"
#ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib"

#ENV PACK_R="abind BH cba curl dendextend devtools eigenfaces extrafont FactoMineR geometry ggplot2 Hmisc httr klaR magic Matrix matrixStats mda memoise plotly plotrix R6 rCharts Rcpp rmarkdown rsm #rstudioapi RUnit squash tools vegan xslx"

# Add automatic repo finder for R:
RUN echo 'options("repos"="http://cran.rstudio.com")' >> /etc/R/Rprofile.site

# install additional packages in R
RUN echo 'install.packages("doSNOW")' > /install_batman.R
RUN echo 'install.packages("plotrix")' >> /install_batman.R
RUN echo 'install.packages("batman", repos="http://R-Forge.R-project.org")' >> /install_batman.R

RUN Rscript /install_batman.R

# Alternative method to install packages in R
# Install R packages
# RUN for PACK in $PACK_R; do R -e "install.packages(\"$PACK\", repos='https://cran.rstudio.com/')"; done
# Install other R packages from source
# RUN for PACK in $PACK_GITHUB; do R -e "library('devtools'); install_github(\"$PACK\")"; done
# Update R packages if required
# RUN R -e "update.packages(repos='https://cran.rstudio.com/', ask=F)"


# Clean up
#RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*


# Configure RStudio server
ADD rserver.conf /etc/rstudio/rserver.conf
ADD rsession.conf /etc/rstudio/rsession.conf
RUN echo "#!/bin/sh" > /usr/sbin/rstudio-server.sh
RUN echo "/usr/lib/rstudio-server/bin/rserver --server-daemonize=0" >> /usr/sbin/rstudio-server.sh
RUN chmod +x /usr/sbin/rstudio-server.sh

# Infrastructure specific
RUN groupadd -g 9999 -f rstudio
RUN useradd -d /home/docker-batman -m -g rstudio -u 9999 -s /bin/bash rstudio
#RUN echo 'batman:batman' | chpasswd

# expose port
EXPOSE 8080

# Define Entry point script -- will write a R script to processing incoming data automatically later.
# WORKDIR /
ENTRYPOINT ["Rscript","/home/jianliang/welcome.r"]

