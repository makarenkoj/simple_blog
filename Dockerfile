FROM ruby:3.0

USER root
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y nodejs postgresql-client vim && \
    apt-get install -y yarn && \
    apt-get install -y imagemagick && \
    apt-get install -y libvips-tools && \
    apt-get install -y locales

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem update
RUN gem install bundler
RUN bundle check || bundle install
COPY package.json yarn.lock ./
COPY . /myapp
RUN yarn add bootstrap jquery popper.js

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
