FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y build-essential libssl-dev

WORKDIR /app

# Copia i file principali
COPY Gemfile* wallet_passkit.gemspec Rakefile ./
RUN bundle install

# Copia il codice e i test
COPY lib/ lib/
COPY spec/ spec/

CMD ["bundle", "exec", "rspec"]
