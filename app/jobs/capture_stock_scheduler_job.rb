class CaptureStockSchedulerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Calculate the next interval and schedule the job to run again    
    CaptureStockSchedulerJob.schedule
    # Immediately perform the job to fetch stock values
    CaptureStockValueJob.perform_later
  end

  def self.schedule
    # Values for interval calculation (use yesterday to ensure the calculation is always positive)
    start_time = (ActiveSupport::TimeZone["UTC"].parse("05:00") - 1.day)
    run_every = 5.minutes.to_i
    current_time = Time.current

    # Calculate how long until the next interval
    time_diff = (current_time - start_time)    
    wait = (run_every - (time_diff % run_every).to_i) + 1
    
    # Re-queue this job at the next interval
    CaptureStockSchedulerJob.set(wait: wait.seconds).perform_later
  end
end