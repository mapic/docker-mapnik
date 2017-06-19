FROM mapic/xenial:latest
MAINTAINER knutole@mapic.io

# env
ENV LANG C.UTF-8
ENV MAPNIK_VERSION 3.0.10
ENV NODE_MAPNIK_VERSION 3.5.13
ENV PYTHON_MAPNIK_COMMIT 3a60211dee366060acf4e5e0de8b621b5924f2e6

# Prerequisites and runtimes
RUN sudo apt-get purge locales
RUN sudo apt-get install locales
RUN sudo dpkg-reconfigure locales
RUN update-locale LANG=C.UTF-8
COPY setup-node.sh /tmp/setup-node.sh
RUN bash /tmp/setup-node.sh && rm /tmp/setup-node.sh
RUN apt-get upgrade -y && apt-get install -y --no-install-recommends \
    build-essential sudo software-properties-common curl \
    libboost-dev libboost-filesystem-dev libboost-program-options-dev libboost-python-dev libboost-regex-dev libboost-system-dev libboost-thread-dev libicu-dev libtiff5-dev libfreetype6-dev libpng12-dev libxml2-dev libproj-dev libsqlite3-dev libgdal-dev libcairo-dev python-cairo-dev postgresql-contrib libharfbuzz-dev \
    nodejs python3-dev python-dev git python-pip python-setuptools python-wheel python3-setuptools python3-pip python3-wheel

# Mapnik
RUN JOBS=$(nproc --all)
RUN echo "Jobs: $JOBS"
RUN curl -s https://mapnik.s3.amazonaws.com/dist/v${MAPNIK_VERSION}/mapnik-v${MAPNIK_VERSION}.tar.bz2 | tar -xj -C /tmp/
RUN cd /tmp/mapnik-v${MAPNIK_VERSION} && python scons/scons.py configure
RUN cd /tmp/mapnik-v${MAPNIK_VERSION} && make JOBS=${JOBS} && make install JOBS=${JOBS}

# Bindings
RUN mkdir -p /opt/node-mapnik && curl -L https://github.com/mapnik/node-mapnik/archive/v${NODE_MAPNIK_VERSION}.tar.gz | tar xz -C /opt/node-mapnik --strip-components=1
RUN cd /opt/node-mapnik && npm install --unsafe-perm=true --build-from-source && npm link
RUN mkdir -p /opt/python-mapnik && curl -L https://github.com/mapnik/python-mapnik/archive/${PYTHON_MAPNIK_COMMIT}.tar.gz | tar xz -C /opt/python-mapnik --strip-components=1
RUN cd /opt/python-mapnik && python2 setup.py install && python3 setup.py install && rm -r /opt/python-mapnik/build

# Tests
# RUN apt-get install -y unzip
# RUN mkdir -p /opt/demos
# COPY world.py /opt/demos/world.py
# COPY 110m-admin-0-countries.zip /opt/demos/110m-admin-0-countries.zip
# RUN cd /opt/demos && unzip 110m-admin-0-countries.zip && rm 110m-admin-0-countries.zip
# COPY world.js /opt/demos/world.js
# COPY stylesheet.xml /opt/demos/stylesheet.xml

