class GamesController < ApplicationController
  before_action :set_user
  # before action, check, if user.role == 'admin'
  before_action :check_admin, only: %i[import_export_all_games import_all_games export_all_games]

  # before_action :set_game, except: %i[new create update destroy index show]
  # Export all games as JSON
  require 'json'

  def play
    @game = Game.find_by(id: params[:id])
    @game = Game.where(user: @user, status: "running").first if @game.nil?
    create_game if @game.nil?

    @game_cards = GameCard.where(game: @game)
    create_game_cards if @game_cards.empty?

    set_counts

    if @game.pile.zero?
      load_remaining_cards
    else
      set_all_cards
    end
  end

  def remaining
    @game = Game.find_by(id: params[:id])
    # sets the pile to 0 "remaining"
    @game.update(pile: 0)
    set_game_and_counts(@game)
    load_remaining_cards
    set_buttons_and_board
  end

  def choosen
    @game = Game.find_by(id: params[:id])
    # sets the pile to 1 "choosen"
    @game.update(pile: 1)
    set_game_and_counts(@game)
    set_all_cards
    set_buttons_and_board
  end

  def rejected
    @game = Game.find_by(id: params[:id])
    # sets the pile to 2 "rejected"
    @game.update(pile: 2)
    set_game_and_counts(@game)
    set_all_cards
    set_buttons_and_board
  end

  def plus
    @game = Game.find_by(id: params[:id])
    # sets the positive to true
    @game.update(positive: true)
    set_game_and_counts(@game)
    if @game.pile.zero?
      load_remaining_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def minus
    @game = Game.find_by(id: params[:id])
    # sets the positive to false
    @game.update(positive: false)
    set_game_and_counts(@game)
    if @game.pile.zero?
      load_remaining_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def choose
    @game = Game.find_by(id: params[:id])
    @game_card = GameCard.find(params[:game_card_id])
    @game_card.update(pile: 1)
    @game = @game_card.game
    set_counts
    if @game.pile.zero?
      load_remaining_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def reject
    @game = Game.find_by(id: params[:id])
    @game_card = GameCard.find(params[:game_card_id])
    @game_card.update(pile: 2)
    @game = @game_card.game
    set_counts
    if @game.pile.zero?
      load_remaining_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def next_group
    @game = Game.find_by(id: params[:id])
    if @game.positive
      @game.update(group_positive: @game.group_positive + 1)
    else
      @game.update(group_negative: @game.group_negative + 1)
    end
    set_game_and_counts(@game)
    load_remaining_cards
    set_buttons_and_board
  end

  def finish
    @game = Game.find_by(id: params[:id])
    if @game.update(status: "finished")
      redirect_to game_path(@game),
                  notice: ( if @user.language == "english"
                              'Game was successfully finished.'
                            elsif @user.language == "german"
                              'Spiel wurde erfolgreich beendet.'
                            end
                          )
    else
      redirect_to games_path,
                  notice: ( if @user.language == "english"
                              'Game finishing failed.'
                            elsif @user.language == "german"
                              'Das Beenden des Spiels ist fehlgeschlagen.'
                            end
                          )
    end
  end

  def history
    @finished_games = @user.games.where(status: 'finished').order(:created_at) # Sort by created_at

    # Group games by the formatted created_at date
    games_grouped_by_date = @finished_games.group_by { |game| game.created_at.strftime("%Y-%m-%d") }

    # Create a chart data array
    @line_chart_data_positive = []
    @line_chart_data_negative = []

    games_grouped_by_date.each do |date_str, games|
      games.each_with_index do |game, index|
        # Use index only when there are multiple games on the same date
        game_name = games.size > 1 ? "#{date_str}##{index + 1}" : date_str
        game.define_singleton_method(:name) { game_name } # Override name method for this instance

        # Prepare data for positive chart
        game_types_positive = [
          { name: "Methodical", count: game.cards_positive_methodical_count },
          { name: "Social", count: game.cards_positive_social_count },
          { name: "Professional", count: game.cards_positive_professional_count },
          { name: "Intuitive", count: game.cards_positive_intuitive_count },
          { name: "Personal", count: game.cards_positive_personal_count }
        ]

        # Add positive game types to chart data
        game_types_positive.each do |type|
          series_hash = @line_chart_data_positive.find { |s| s[:name] == type[:name] }
          if series_hash
            series_hash[:data][game.name] = type[:count] # Using overridden name
          else
            @line_chart_data_positive << { name: type[:name], data: { game.name => type[:count] } } # Using overridden name
          end
        end

        # Prepare data for negative chart
        game_types_negative = [
          { name: "Methodical", count: game.cards_negative_methodical_count },
          { name: "Social", count: game.cards_negative_social_count },
          { name: "Professional", count: game.cards_negative_professional_count },
          { name: "Intuitive", count: game.cards_negative_intuitive_count },
          { name: "Personal", count: game.cards_negative_personal_count }
        ]

        # Add negative game types to chart data
        game_types_negative.each do |type|
          series_hash = @line_chart_data_negative.find { |s| s[:name] == type[:name] }
          if series_hash
            series_hash[:data][game.name] = type[:count] # Using overridden name
          else
            @line_chart_data_negative << { name: type[:name], data: { game.name => type[:count] } } # Using overridden name
          end
        end
      end
    end
  end

  def share_form
    @game = Game.find(params[:id])
  end

  def share
    @game = Game.find(params[:id])
    recipient_email = params[:recipient_email]

    # Check if the email is present and valid
    unless recipient_email.present? && valid_email?(recipient_email)
      redirect_to game_path(@game), alert: email_error_message
      return
    end

    # Check if the game status is "finished"
    unless @game.status == "finished"
      redirect_to games_path, notice: game_not_finished_message
      return
    end

    # Check if the game already has a share code
    if @game.share_code.blank?
      @game.regenerate_share_code # Generate a new share code if it doesn't exist
    end

    # Here you might want to send the share code via email
    share_code = @game.share_code

    # Sending the share email
    ShareGameJob.perform_later(@user, recipient_email, share_code)

    redirect_to game_path(@game), notice: share_success_message
  end

  def challenge
    @game = Game.find(params[:id])

    # Check if the game status is "finished"
    unless @game.status == "finished"
      redirect_to games_path, notice: (if @user.language == "english"
                                        'Game must be finished to challenge.'
                                      elsif @user.language == "german"
                                        'Das Spiel muss beendet sein, um es zu teilen.'
                                       end)
      return
    end

    # Check if the game already has a challenge code
    if @game.challenge_code.blank?
      @game.regenerate_challenge_code # Generate a new challenge code if it doesn't exist
    end

    # Here you might want to send the challenge code via email
    challenge_code = @game.challenge_code

    # Assuming you have a recipient_email for demonstration purposes
    recipient_email = params[:recipient_email]

    # Sending the challenge email
    UserMailer.challenge_game(@user, recipient_email, challenge_code).deliver_now

    redirect_to game_path(@game), notice: (if @user.language == "english"
                                             'Challenge sent successfully.'
                                           elsif @user.language == "german"
                                             'Herausforderung erfolgreich gesendet.'
                                           end)
  end

  # import form for manual import of games
  def import_form
    @game = Game.new
  end

  # necessary for direct POST request to import game
  # used only from the link in the share email
  def verify_import
    @game = Game.find_by(share_code: params[:share_code])
    if @game
      # Redirect to POST action
      redirect_post(import_game_path, # URL
                    params: {
                      share_code: @game.share_code
                    }, options: {authenticity_token: :auto})
      # redirect_to import_game_path(@game.share_code)
    else
      redirect_to games_path, alert: 'Invalid share code.'
    end
  end

  def import
    @game = Game.find_by(share_code: params[:share_code]) # Find the game based on the share code
    if @game
      # Logic to add the game to the current user's records, e.g., duplicating the game
      game_user_copy = @game.dup
      game_user_copy.shared_from_user_id = @game.user.id # Set the original user id
      game_user_copy.user = current_user # Associate the copied game with the current user
      game_user_copy.share_code = nil # Clear the share code

      # Set the timestamps to match the original game
      game_user_copy.created_at = @game.created_at
      game_user_copy.updated_at = @game.updated_at

      if game_user_copy.save
        # Iterate over each GameCard in the original game
        @game.game_cards.each do |game_card|
          # Duplicate each game card and associate it with the copied game
          GameCard.create(game_id: game_user_copy.id, card_id: game_card.card_id, pile: game_card.pile)
        end

        redirect_to game_path(game_user_copy), notice: (if @user.language == "english"
                                                          'Game was successfully imported.'
                                                        elsif @user.language == "german"
                                                          'Spiel wurde erfolgreich importiert.'
                                                        end
                                                       )
      else
        redirect_to games_path, alert: (if @user.language == "english"
                                         'Game import failed.'
                                       elsif @user.language == "german"
                                         'Das Importieren des Spiels ist fehlgeschlagen.'
                                        end
                                      )
      end
    else
      redirect_to games_path, alert: (if @user.language == "english"
                                       'Game not found.'
                                     elsif @user.language == "german"
                                       'Spiel nicht gefunden.'
                                      end
                                    )
    end
  end

  def index
    @games = @user.games.order(created_at: :desc) # Sort by created_at in descending order
  end

  def show
    @game = Game.find(params[:id])
    check_shared_game
    @choosen_cards = GameCard.where(game: @game, pile: 1)

    @categories = %w[methodical social professional intuitive personal]
    @game_cards = fetch_game_cards(@categories)

    total_positive = total_card_counts(@categories, :positive)
    total_negative = total_card_counts(@categories, :negative)

    @pie_chart_data_positive = pie_chart_data(@categories, total_positive, :positive)
    @pie_chart_data_negative = pie_chart_data(@categories, total_negative, :negative)

    @categories_positive = prepare_card_hashes(@game_cards, :positive)
    @categories_negative = prepare_card_hashes(@game_cards, :negative)
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)

    # Set additional attributes
    @game.assign_attributes(user: @user, status: "running", pile: 0, positive: true)
    # if @user.client not nil
    @game.client = @user.client if @user&.client

    # Try to save the game and handle the response
    if @game.save
      redirect_to play_path(id: @game.id),
                  notice: ( if @user.language == "english"
                              'Game was successfully created.'
                            elsif @user.language == "german"
                              'Spiel wurde erfolgreich erstellt.'
                            end
                          )
    else
      redirect_to new_game_path
      flash[:notice] = if @user.language == "english"
                          'Game creation failed.'
                        elsif @user.language == "german"
                          'Die Erstellung des Spiels ist fehlgeschlagen.'
                       end
    end
  end

  def edit
    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    if @game.update(game_params)
      redirect_to play_path(@game),
                  notice: ( if @user.language == "english"
                              'Game was successfully updated.'
                            elsif @user.language == "german"
                              'Spiel wurde erfolgreich aktualisiert.'
                            end
                          )
    else
      redirect_to edit_game_path(@game)
      flash[:notice] = if @user.language == "english"
                          'Game update failed.'
                        elsif @user.language == "german"
                          'Die Aktualisierung des Spiels ist fehlgeschlagen.'
                       end
    end
  end

  def destroy
    @game = Game.find_by(id: params[:id])
    if @game.destroy
      redirect_to games_url,
                  notice: ( if @user.language == "english"
                            'Game was successfully destroyed.'
                            elsif @user.language == "german"
                              'Spiel wurde erfolgreich gelöscht.'
                            end
                          )
    else
      redirect_to games_url,
                  notice: ( if @user.language == "english"
                            'Game destruction failed.'
                            elsif @user.language == "german"
                              'Das Löschen des Spiels ist fehlgeschlagen.'
                            end
                          )
    end
  end

  def import_export_all_games
  end

  def export_all_games
    games = Game.includes(user: {}, game_cards: :card).all
    export_data = games.map do |game|
      {
        id: game.id,
        user_email: game.user.email,
        name: game.name,
        status: game.status,
        score: game.score,
        created_at: game.created_at,
        updated_at: game.updated_at,
        game_cards: game.game_cards.map do |game_card|
          {
            card_name: game_card.card.name_english, # Include card's name_english
            pile: game_card.pile
          }
        end
      }
    end

    send_data JSON.pretty_generate(export_data),
              filename: "games_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json",
              type: "application/json"
  end

  def import_all_games
    if params[:file].nil?
      flash[:error] = "No file selected."
      redirect_to import_export_all_games_url and return
    end

    file = params[:file]

    begin
      games_data = JSON.parse(file.read)

      games_data.each do |game_data|
        user = User.find_by(email: game_data["user_email"])

        if user
          @existing_game = Game.find_by(name: game_data["name"], created_at: game_data["created_at"])
          puts "inside if user"
          if @existing_game.nil?
            puts "No existing game found. Proceeding to create a new game."
            game = Game.create!(
              user_id: user.id,
              client_id: user.client.id, # Set the client_id
              name: game_data["name"],
              status: game_data["status"],
              score: game_data["score"],
              created_at: game_data["created_at"],
              updated_at: game_data["updated_at"]
            )

            # Create associated game_cards
            game_data["game_cards"].each do |game_card_data|
              card = Card.find_by(name_english: game_card_data["card_name"]) # Find card by name_english

              if card
                GameCard.create!(
                  game_id: game.id,
                  card_id: card.id, # Use the found card's ID
                  pile: game_card_data["pile"]
                )
              else
                flash[:warning] = "Card with name #{game_card_data['card_name']} not found. Game card not imported."
              end
            end
          else
            puts "Existing game found. Not importing."
            flash[:info] = "Game with name '#{game_data['name']}' already exists."
          end
        else
          flash[:warning] = "User with email #{game_data['user_email']} not found. Game not imported."
        end
      end

      flash[:success] = "Import finished successfully."
    rescue JSON::ParserError => e
      flash[:error] = "Invalid JSON file format: #{e.message}"
      puts "JSON parsing error: #{e.message}"
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "Import failed due to validation error: #{e.message}"
      puts "ActiveRecord error: #{e.message}"
    rescue StandardError => e
      flash[:error] = "Import failed: #{e.message}"
      puts "General error: #{e.message}"
    end

    redirect_to games_url
  end

  private

  def check_admin
    return if @user.role == 'admin'

    redirect_to games_path, alert: 'You are not
        authorized to perform this action.'
  end

  def game_params
    params.require(:game).permit(:name, :count_positive, :count_negative, :recipient_email)
  end

  def set_user
    @user = current_user
  end

  def set_game(game)
    @game = game
  end

  def create_game
    client = @user.client if @user.client

    @game = Game.create(
      name: "FreePlay #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
      status: "running",
      user: @user,
      client:, # This will be nil if @user.client is not present
      count_positive: 10,
      count_negative: 5,
      pile: 0,
      positive: true
    )
    @game.save
  end

  def create_game_cards
    @cards = Card.where(user: @user).or(Card.where(user_id: nil))
    @cards.each do |card|
      GameCard.create(game: @game, card:, pile: 0)
    end
  end

  def set_counts
    @game_cards = GameCard.joins(:card).where(game: @game)
    @count_positive = @game.count_positive
    @count_negative = @game.count_negative
    @count_remaining_positive = @game_cards.where(pile: 0, cards: { positive: true }).count
    @count_choosen_positive = @game_cards.where(pile: 1, cards: { positive: true }).count
    @count_rejected_positive = @game_cards.where(pile: 2, cards: { positive: true }).count
    @count_remaining_negative = @game_cards.where(pile: 0, cards: { positive: false }).count
    @count_choosen_negative = @game_cards.where(pile: 1, cards: { positive: false }).count
    @count_rejected_negative = @game_cards.where(pile: 2, cards: { positive: false }).count
  end

  def set_game_and_counts(game)
    set_game(game)
    set_counts
  end

  def set_buttons_and_board
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("buttons_frame",
                               partial: "buttons",
                               locals: { game: @game,
                                         game_cards: @game_cards,
                                         count_remaining_positive: @count_remaining_positive,
                                         count_choosen_positive: @count_choosen_positive,
                                         count_rejected_positive: @count_rejected_positive,
                                         count_remaining_negative: @count_remaining_negative,
                                         count_choosen_negative: @count_choosen_negative,
                                         count_rejected_negative: @count_rejected_negative }),
          turbo_stream.replace("board_frame",
                               partial: "board",
                               locals: { game: @game,
                                         game_cards: @game_cards })
        ]
      end
      format.html do
        redirect_to play_path, notice: 'You updated this item successfully.'
      end
    end
  end

  def set_all_cards
    @game_cards = GameCard.joins(:card).where(game: @game, pile: @game.pile,
                                              cards: { positive: @game.positive })
  end

  def load_remaining_cards
    set_counts
    @groups = Card.where(positive: @game.positive).pluck(:group).uniq.sort
    @group = @groups[@game.public_send(@game.positive ? 'group_positive' : 'group_negative')]
    @game_cards = GameCard.joins(:card).where(cards: { group: @group }).where(game_id: @game.id).order(:id)
    @cards_empty = @game.public_send(@game.positive ? 'group_positive' : 'group_negative') >= @groups.count
    if none_on_pile_zero?(@game_cards) && !@cards_empty
      @next_group = true
    else
      @next_group = false
    end
  end

  def none_on_pile_zero?(game_cards)
    game_cards.none? { |game_card| game_card.pile.zero? }
  end

  # for SHOW action
  def check_shared_game
    @is_shared = @game.shared_from_user_id?
    @shared_from = @is_shared ? User.find(@game.shared_from_user_id) : nil
  end

  def fetch_game_cards(categories)
    game_cards = {}
    categories.each do |category|
      game_cards["#{category}_positive"] = GameCard.joins(:card).where(game: @game, pile: 1, cards: { category:, positive: true })
      game_cards["#{category}_negative"] = GameCard.joins(:card).where(game: @game, pile: 1, cards: { category:, positive: false })
    end
    game_cards
  end

  def total_card_counts(categories, positivity)
    categories.sum do |category|
      @game_cards["#{category}_#{positivity}"].count
    end
  end

  def pie_chart_data(categories, total, positivity)
    categories.map do |category|
      count = @game_cards["#{category}_#{positivity}"].count
      percentage = total.zero? ? 0 : (count / total.to_f * 100).round(2)
      [category, percentage]
    end
  end

  def prepare_card_hashes(game_cards, positivity)
    {
      methodical: game_cards["methodical_#{positivity}"],
      social: game_cards["social_#{positivity}"],
      professional: game_cards["professional_#{positivity}"],
      intuitive: game_cards["intuitive_#{positivity}"],
      personal: game_cards["personal_#{positivity}"]
    }
  end

  def valid_email?(email)
    email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  def email_error_message
    @user.language == "english" ? 'Please enter a valid email address.' : 'Bitte geben Sie eine gültige E-Mail-Adresse ein.'
  end

  def game_not_finished_message
    @user.language == "english" ? 'Game must be finished to share.' : 'Das Spiel muss beendet sein, um es zu teilen.'
  end

  def share_success_message
    @user.language == "english" ? 'Share code sent successfully.' : 'Code zum Teilen erfolgreich gesendet.'
  end
end
