class CaptureStockSchedulerJob < ApplicationJob
  queue_as :default

  @@schedule_id = nil

  def perform(schedule_id)
    # Don't do anything if we're paused or we're not the expected schedule_id
    return if (@@schedule_id != schedule_id || CaptureStockValueJob::Status.paused)
    # Calculate the next interval and schedule the job to run again    
    CaptureStockSchedulerJob.schedule
    # Immediately perform the job to fetch stock values
    CaptureStockValueJob.perform_later
  end

  def self.pause
    # The default backend doesn't let us cancel scheduled tasks
    # so let's at least invalidate them.
    @@schedule_id = nil
  end

  def self.schedule
    # Values for interval calculation (use yesterday to ensure the calculation is always positive)
    start_time = (ActiveSupport::TimeZone["EST"].parse(Rails.configuration.x.stock_query.start_time_est) - 1.day)
    run_every = Rails.configuration.x.stock_query.run_every_minutes.minutes.to_i
    current_time = Time.current.in_time_zone('Eastern Time (US & Canada)')

    # Calculate how long until the next interval
    time_diff = (current_time - start_time)    
    wait = (run_every - (time_diff % run_every).to_i) + 1
    
    # Re-queue this job at the next interval
    @@schedule_id = SecureRandom.uuid
    CaptureStockSchedulerJob.set(wait: wait.seconds).perform_later @@schedule_id
  end
end