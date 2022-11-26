# syntax = docker/dockerfile:1.4

################# dependencies ##############
FROM ruby:3.1.2-alpine AS dependencies

# Install system dependencies required to build some Ruby gems (pg)
RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
      ln -vs /var/cache/apk /etc/apk/cache && \
      apk add --update \
      build-base

COPY Gemfile Gemfile.lock ./

# Install gems (excluding development/test dependencies)
RUN --mount=type=cache,sharing=locked,target=/usr/local/bundle/cache \
      bundle config set without "development test" && \
      bundle install --jobs=5 --retry=5


################# runtime ####################
FROM ruby:3.1.2-alpine AS runtime

ENV TZ=Asia/Seoul
ENV RACK_ENV=production

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
      echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
      ln -vs /var/cache/apk /etc/apk/cache && \
      apk add --update \
      tzdata \
      kubectl \
      jq

# Create a non-root user to run the app and own app-specific files
RUN adduser -D app

# Switch to this user
USER app

# We'll install the app in this directory
WORKDIR /home/app

# Copy over gems from the dependencies stage
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/

# Copy rackup files
COPY --chown=app Gemfile Gemfile.lock config.ru ./

# Copy config files
COPY --chown=app config ./config

# Copy src files
COPY --chown=app src ./src

# Launch the server
CMD ["bundle", "exec", "puma", "-t", "8:32"]

