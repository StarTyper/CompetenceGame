class ShareGameJob < ApplicationJob
  queue_as :default

  def perform(user, recipient_email, share_code)
    UserMailer.share_game(user, recipient_email, share_code).deliver_now
  end
end
