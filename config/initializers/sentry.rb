# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://03873b138c4e4c529be31ce044735fe2@o989331.ingest.sentry.io/5946076'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |_context|
    true
  end
end
