# frozen_string_literal: true

require 'sinatra'
require 'English'
require 'fuzzy_match'
require 'rufus-scheduler'
require 'logger'

LOG = Logger.new($stdout).tap do |l|
  l.datetime_format = '%FT%T.%6N%:z '
  l.level = Logger::DEBUG
end

configure do
  use Rack::CommonLogger, LOG
end

# CRD is a singleton in-memory crd list retreiver.
CRD = Class.new do
  attr_reader :names, :matcher

  def initialize
    @names = []
    @matcher = FuzzyMatch.new @names

    refresh

    Rufus::Scheduler.s.cron '* * * * *' do
      refresh
    end
  end

  private

  def refresh
    LOG.info 'refreshing CRD list'

    resp = `kubectl get crd -o jsonpath='{.items[*].metadata.name}'`
    unless $CHILD_STATUS.success?
      LOG.error "failed to refresh CRD list code: #{$CHILD_STATUS.exitstatus}"
      return
    end

    @names = resp.split
    @matcher = FuzzyMatch.new @names

    LOG.info 'successfully refreshed CRD list'
  end
end.new

get '/crds' do
  resp = CRD.names.to_json

  return 200, { 'Content-Type' => 'application/json' }, resp
end

get '/crds/:name' do
  crd = CRD.matcher.find params[:name]
  if crd.nil?
    resp = {
      message: "failed to fuzzy search CRD with name: #{params[:name]}"
    }.to_json
    halt 404, { 'Content-Type' => 'application/json' }, resp
  end

  logger.info "fuzzy matcher found #{crd}"

  resp = `kubectl get crd #{crd} -o json | jq -Rs 'fromjson? // error("Bad input") | .spec.versions[0].schema.openAPIV3Schema * {"type": "object", "$schema": "http://json-schema.org/draft-04/schema#"}'`
  unless $CHILD_STATUS.success?
    resp = {
      message: "failed to get CRD with name: #{crd}",
      code: $CHILD_STATUS.exitstatus
    }.to_json
    logger.error resp

    halt 500, { 'Content-Type' => 'application/json' }, resp
  end

  return 200, { 'Content-Type' => 'application/json' }, resp
end
