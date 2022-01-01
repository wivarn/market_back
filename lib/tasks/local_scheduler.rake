namespace :local_scheduler do
  desc 'Runs the local version of CloudWatch Log Events jobs'
  task run: :environment do
    scheduler = Rufus::Scheduler.new

    # Local runs more often than CloudWatch
    scheduler.every '2m', first: :now do
      OfferJob.perform_now(:expire)
      OfferJob.perform_now(:reminder)
      OrderJob.perform_now(:mark_received)
      OrderJob.perform_now(:auto_review)
    end

    scheduler.every '10m', first: :now do
      OrderJob.perform_now(:review_reminder)
    end

    scheduler.join
  end
end
