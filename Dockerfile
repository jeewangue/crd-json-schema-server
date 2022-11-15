# This stage will be responsible for installing gems
FROM ruby:2.7.6-alpine AS dependencies

# Install system dependencies required to build some Ruby gems (pg)
RUN apk add --update build-base

COPY Gemfile Gemfile.lock ./

# Install gems (excluding development/test dependencies)
RUN bundle config set without "development test" && \
      bundle install --jobs=5 --retry=5

# We're back at the base stage
FROM ruby:2.7.6-alpine AS runtime

ENV TZ=Asia/Seoul
ENV RACK_ENV=production

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
      echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk add --update --no-cache \
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

# Finally, copy over the code
# This is where the .dockerignore file comes into play
# Note that we have to use `--chown` here
COPY --chown=app . ./

# Launch the server (or run some other Ruby command)
CMD ["bundle", "exec", "rackup"]

