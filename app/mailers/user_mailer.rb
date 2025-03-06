class UserMailer < ApplicationMailer
  default from: "crealeadership@gmail.com"

  def share_game(user, recipient_email, share_code)
    @user = user
    @share_code = share_code
    mail(to: recipient_email, subject: "Competence Game Share Code from #{@user.first_name} #{@user.last_name}")
  end
end
