# frozen_string_literal: true

require 'English'

get '/' do
  return 200, { status: 'OK' }.to_json
end

get '/healthz' do
  return 200, { status: 'OK' }.to_json
end

get '/crds' do
  return 200, CRD.names.to_json
end

get '/crds/:name' do
  crd = CRD.matcher.find params[:name]
  halt 404, { error: "failed to fuzzy search CRD with name: #{params[:name]}" }.to_json if crd.nil?

  logger.info "found #{crd}"

  begin
    resp = CACHE.get(crd, lifetime: 300) do
      logger.info "fetching #{crd}"
      schema = `kubectl get crd #{crd} -o json | jq -Rs 'fromjson? // error("Bad input") | \
      .spec.versions[0].schema.openAPIV3Schema * {"type": "object", "$schema": "http://json-schema.org/draft-04/schema#"}'`
      raise "failed to get CRD with name: #{crd}, code: #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

      schema
    end
  rescue StandardError => e
    halt 500, { error: e.message }.to_json
  end

  return 200, resp
end
