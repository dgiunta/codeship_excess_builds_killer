require 'codeship_api'
require 'sucker_punch'
require 'pry'

class ProcessWebhookJob
  include SuckerPunch::Job

  attr_reader :repo_url, :ref, :commit_sha

  def perform(repo_url, ref, commit_sha)
    @repo_url, @ref, @commit_sha = repo_url, ref, commit_sha

    if ignore_primary_branch? && ref.include?(primary_branch_name)
      log "project=#{project.name} commit_sha=#{commit_sha} IGNORING #{primary_branch_name} COMMIT"
      return
    end

    start = Time.now
    log :start

    if project
      log "project=#{project.name} builds_to_stop=#{builds_to_stop.map(&:uuid).join(",")}"
      builds_to_stop.each(&method(:stop))
    end
    log "end (#{Time.now - start})"
  end

  private

  def primary_branch_name
    ENV['PRIMARY_BRANCH_NAME']
  end

  def ignore_primary_branch?
    ENV['IGNORE_PRIMARY_BRANCH'].presence == 'true'
  end

  def project
    @project ||= CodeshipApi.projects.detect {|proj| proj.repository_url == repo_url }
  end

  def builds_to_stop
    @builds_to_stop ||= project.builds.select(&method(:excessive_build?))
  end

  def stop(build)
    start_time = Time.now
    build.stop
    puts "event#build.stop='#{build.uuid}' description='repo:#{repo_url},commit:#{commit_sha}' start_time=#{start_time.to_i} end_time=#{Time.now.to_i}"
  end

  def log(message="")
    puts [log_prefix, message].join(": ")
  end

  def log_prefix
    "[ProcessWebhookJob#perform repo_url=#{repo_url} ref=#{ref} commit_sha=#{commit_sha}]"
  end

  def excessive_build?(build)
    (build.testing? || build.waiting?) &&
      build.ref == ref &&
      build.commit_sha[0..10] != commit_sha[0..10]
  end
end
