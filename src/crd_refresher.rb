# frozen_string_literal: true

require 'fuzzy_match'
require 'rufus-scheduler'

# CrdRefresher periodically get CRD list from kubernetes
class CrdRefresher
  attr_reader :names, :matcher

  def initialize
    @names = []
    @matcher = FuzzyMatch.new @names

    Thread.new { refresh }

    Rufus::Scheduler.s.cron '* * * * *' do
      Thread.new { refresh }
    end
  end

  private

  def refresh
    LOG.info 'refreshing CRD list'
    resp = `kubectl get crd -o jsonpath='{.items[*].metadata.name}'`
    if $CHILD_STATUS.success?
      LOG.info 'successfully refreshed CRD list'
      @names = resp.split
      @matcher = FuzzyMatch.new @names
    else
      LOG.error "failed to refresh CRD list code: #{$CHILD_STATUS.exitstatus}"
    end
  end
end
