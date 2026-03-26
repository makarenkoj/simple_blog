FROM ruby:3.4.3-slim

ENV TZ=UTC
USER root

RUN apt-get update -qq && \
    apt-get install -y curl tzdata && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y build-essential libpq-dev postgresql-client vim imagemagick libvips-tools locales nodejs && \
    npm install -g yarn

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle check || bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . /myapp

RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 80
ENV TARGET_URL=http://0.0.0.0:3000

CMD ["bundle", "exec", "thrust", "./bin/rails", "server"]
