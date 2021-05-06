FROM ruby:2.5.3

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    libgmp3-dev \
    libpq-dev \
    nodejs

RUN apt-get install net-tools

RUN gem update
RUN gem install bundler:2.0.0.pre.3
# RUN gem install capybara-webkit -v '1.15.1'

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
# # ADD Gemfile.lock Gemfile.lock
ADD app app
ADD db db
ADD public public
RUN mkdir tmp

RUN mkdir -p ~/.ssh/
RUN touch ~/.ssh/config
RUN chmod 644 ~/.ssh/config
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
RUN bundle config git.allow_insecure true
RUN bundle _2.0.0.pre.3_ install

ENV APP_HOME /usr/app

EXPOSE 3000
