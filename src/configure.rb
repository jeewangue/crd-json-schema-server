# frozen_string_literal: true

require 'logger'
require 'zache'

require_relative 'crd_refresher'

CACHE = Zache.new
LOG = Logger.new($stdout)

# CRD is a singleton in-memory crd list retreiver.
CRD = CrdRefresher.new

use Rack::Logger, Logger::DEBUG
use Rack::ContentType, 'application/json'
