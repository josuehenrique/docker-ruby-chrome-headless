FROM ubuntu:16.04

#------------------------------------------------------------------------------------
# Atualiza o ubuntu e instala dependências
#------------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y build-essential \
        g++ \
        wget \
        nodejs \
        git \
        curl \
        libreadline-dev \
        libcurl4-openssl-dev \
        libffi-dev \
        libgdbm-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        libtool \
        zlib1g-dev \
        netbase \
        libpq-dev \
        libexpat1-dev \
        tzdata \
        unzip \
        qt5-default \
        libqt5webkit5-dev \
        gstreamer1.0-plugins-base \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        freetds-dev \
        libnss3 libxi6 libgconf-2-4 libfontconfig \
        # Dependencies to make "headless" chrome/selenium work:
        xvfb gtk2-engines-pixbuf xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable \
        # Optional but nifty: For capturing screenshots of Xvfb display:
        imagemagick x11-apps

#------------------------------------------------------------------------------------
# Baixa e instala google chrome latest
#------------------------------------------------------------------------------------
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update && apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 google-chrome-stable

#------------------------------------------------------------------------------------
# Baixa e instala chromedriver 2.36
#------------------------------------------------------------------------------------
RUN wget https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv ./chromedriver /usr/bin/ &&\
    chmod ugo+rx /usr/bin/chromedriver

#------------------------------------------------------------------------------------
# Baixa e instala ruby ps.: passar argumento com o --build-arg ruby_version="2.2.1"
#------------------------------------------------------------------------------------
ARG ruby_version
ENV RUBY_VERSION "$ruby_version"

RUN echo 'gem: --no-document' >> /usr/local/etc/gemrc &&\
    mkdir /src && cd /src && git clone https://github.com/sstephenson/ruby-build.git &&\
    cd /src/ruby-build && ./install.sh &&\
    cd / && rm -rf /src/ruby-build && ruby-build $RUBY_VERSION /usr/local &&\
    gem update --system

RUN mkdir /root/.ssh && echo >> ~/.ssh/known_hosts && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan bitbucket.com >> ~/.ssh/known_hosts

#------------------------------------------------------------------------------------
# Baixa e constroi o projeto ps.: passar argumento com o --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)"
#------------------------------------------------------------------------------------
ARG ssh_prv_key
ARG project_ssh_url
ARG project_name

RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa

RUN git clone "$project_ssh_url" --single-branch && cd "$project_name" && bundle install

#------------------------------------------------------------------------------------
# Limpa lixo gerado pela construção
#------------------------------------------------------------------------------------
RUN rm -rf "$project_name" \
    ~/.ssh/id_rsa \
    /var/lib/apt/lists/* \
    /chromedriver_linux64.zip \
    && truncate -s 0 /var/log/*log

#------------------------------------------------------------------------------------
# Inicia tela
#------------------------------------------------------------------------------------
RUN Xvfb -ac :99 -screen 0 1920x1080x16 &

#------------------------------------------------------------------------------------
# Cria variáveis de ambiente
#------------------------------------------------------------------------------------
ENV RAILS_ENV test
ENV DISPLAY :99
ENV RUBY_GC_MALLOC_LIMIT 90000000
ENV RUBY_GC_HEAP_FREE_SLOTS 200000
