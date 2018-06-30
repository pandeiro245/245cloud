FROM ruby:2.5.1

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    apt-utils \
    mysql-client \
    build-essential \
    libgmp3-dev \
    less \
    vim

RUN apt-get install net-tools
RUN rm -rf /var/lib/apt/lists/*

RUN gem update
RUN gem install bundler
RUN gem install json -v '1.8.3'

WORKDIR /usr/app
ADD Dockerfile Dockerfile
ADD bin bin
ADD spec spec
ADD vendor vendor
ADD Rakefile Rakefile
ADD config config
ADD Gemfile Gemfile
ADD config.ru config.ru
RUN mkdir log
ADD Gemfile.lock Gemfile.lock
ADD app app
ADD db db
ADD public public
RUN mkdir tmp

RUN bundle config git.allow_insecure true
RUN bundle install

ENV APP_HOME /usr/app

EXPOSE 3000
# ENTRYPOINT ./start.sh
