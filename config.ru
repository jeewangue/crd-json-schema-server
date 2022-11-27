# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'

require_relative 'src/configure'
require_relative 'src/app'

run Sinatra::Application
