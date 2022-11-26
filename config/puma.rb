# frozen_string_literal: true

min_threads = ENV.fetch('MIN_THREADS', 8).to_i
max_threads = ENV.fetch('MAX_THREADS', 32).to_i
threads min_threads, max_threads

# Specifies the `port` that Puma will listen on to receive requests, default is 9292.
port        ENV.fetch('PORT', 9292).to_i

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RACK_ENV', 'development')
