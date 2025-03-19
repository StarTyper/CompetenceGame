class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @user = current_user
  end

  def rules
  end

  def send_alert(alert_type, alert_message)
    flash[alert_type] = alert_message
    redirect_to import_export_all_games_url and return
  end

  def alert_notice
    send_alert(:notice, "alert_notice")
  end

  def alert_alert
    send_alert(:alert, "alert_alert")
  end

  def alert_error
    send_alert(:error, "alert_error")
  end

  def alert_success
    send_alert(:success, "alert_success")
  end

  def alert_info
    send_alert(:info, "alert_info")
  end
end
