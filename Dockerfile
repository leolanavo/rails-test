################################################################################
#                                 BASE IMAGE                                   #
################################################################################

FROM ruby:2.5-alpine AS base

ENV API_PATH=/usr/src/api

ENV BUNDLE_PATH="vendor/bundle" \
    PATH="$API_PATH/bin:$PATH"

ENV PORT=3000 \
    HOST=0.0.0.0

EXPOSE $PORT

WORKDIR $API_PATH

################################################################################
#                          DEVELOPMENT IMAGE                                   #
################################################################################

FROM base AS development

ENV RAILS_ENV=development

RUN apk add --update \
    build-base \
    sqlite-dev \
    yaml-dev \
    nodejs \
    tzdata \
    yarn \
    && rm -rf /var/cache/apk/*


COPY Gemfile Gemfile.lock ./

# RUN bundle update

RUN bundle install

COPY . .

CMD ["rails", "server"]

################################################################################
#                           PRODUCTION IMAGE                                   #
################################################################################

FROM base AS production

ENV RAILS_ENV=production

RUN apk add --update \
    libressl-dev \
    sqlite-libs \
    tzdata \
    nodejs \
    && rm -rf /var/cache/apk/*

COPY --from=development $API_PATH/ ./ ./

RUN bundle --clean --frozen --without development test

CMD ["rails", "server"]
