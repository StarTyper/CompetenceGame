# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def share_game
    user = User.first
    recipient_email = "florian.sitte@live.de"
    share_code = Game.first.share_code
    UserMailer.share_game(user, recipient_email, share_code)
  end
end
