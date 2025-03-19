class ShareGameJob < ApplicationJob
  queue_as :default

  def perform(user, recipient_email, share_code)
    Rails.logger.info("ShareGameJob started for: #{recipient_email}")
    UserMailer.share_game(user, recipient_email, share_code).deliver_now
    Rails.logger.info("ShareGameJob completed for: #{recipient_email}")
  end
end
