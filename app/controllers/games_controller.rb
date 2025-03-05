class GamesController < ApplicationController
  before_action :set_user
  # before_action :set_game, except: %i[new create update destroy index show]

  def play
    @game = Game.find_by(id: params[:id])
    @game = Game.where(user: @user, status: "running").first if @game.nil?

    if @game.nil?
      @game = Game.create(name: "FreePlay #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
                          status: "running",
                          user: @user,
                          client: @user.client,
                          count_positive: 10,
                          count_negative: 5,
                          pile: 0,
                          positive: true)
      @game.save
    end

    @game_cards = GameCard.where(game: @game)

    if @game_cards.empty?
      @cards = Card.where(client: @user.client).or(Card.where(client: Client.find_by(name: "default")))
      @cards.each do |card|
        GameCard.create(game: @game, card:, pile: 0)
      end
    end

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
      redirect_to game_path(id: @game), notice: 'Game successfully finished.'
    else
      redirect_to games_path, alert: 'Failed to finish game.'
    end
  end

  def history
    @finished_games = @user.games.where(status: 'finished').order(:created_at) # Sort by created_at

    # Group games by the formatted created_at date
    games_grouped_by_date = @finished_games.group_by { |game| game.created_at.strftime("%Y-%m-%d") }

    # Create a chart data array
    @chart_data_positive = []
    @chart_data_negative = []

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
          series_hash = @chart_data_positive.find { |s| s[:name] == type[:name] }
          if series_hash
            series_hash[:data][game.name] = type[:count] # Using overridden name
          else
            @chart_data_positive << { name: type[:name], data: { game.name => type[:count] } } # Using overridden name
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
          series_hash = @chart_data_negative.find { |s| s[:name] == type[:name] }
          if series_hash
            series_hash[:data][game.name] = type[:count] # Using overridden name
          else
            @chart_data_negative << { name: type[:name], data: { game.name => type[:count] } } # Using overridden name
          end
        end
      end
    end
  end

  def index
    @games = @user.games.order(created_at: :desc) # Sort by created_at in descending order
  end

  def show
    @game = Game.find(params[:id])

    # Assign all cards from this game on pile 1 to @choosen_cards
    @choosen_cards = GameCard.where(game: @game, pile: 1)

    # Assign all positive and negative game cards for each category
    @methodical_positive = GameCard.joins(:card).where(game: @game, pile: 1,
                                                       cards: { categorygerman: "methodisch", positive: true })
    @methodical_negative = GameCard.joins(:card).where(game: @game, pile: 1,
                                                       cards: { categorygerman: "methodisch", positive: false })
    @social_positive = GameCard.joins(:card).where(game: @game, pile: 1,
                                                   cards: { categorygerman: "sozial", positive: true })
    @social_negative = GameCard.joins(:card).where(game: @game, pile: 1,
                                                   cards: { categorygerman: "sozial", positive: false })
    @professional_positive = GameCard.joins(:card).where(game: @game, pile: 1,
                                                         cards: { categorygerman: "fachlich", positive: true })
    @professional_negative = GameCard.joins(:card).where(game: @game, pile: 1,
                                                         cards: { categorygerman: "fachlich", positive: false })
    @intuitive_positive = GameCard.joins(:card).where(game: @game, pile: 1,
                                                      cards: { categorygerman: "intuitiv", positive: true })
    @intuitive_negative = GameCard.joins(:card).where(game: @game, pile: 1,
                                                      cards: { categorygerman: "intuitiv", positive: false })
    @personal_positive = GameCard.joins(:card).where(game: @game, pile: 1,
                                                     cards: { categorygerman: "persönlich", positive: true })
    @personal_negative = GameCard.joins(:card).where(game: @game, pile: 1,
                                                     cards: { categorygerman: "persönlich", positive: false })

    # Calculate totals for positive and negative cards
    total_positive = @methodical_positive.count + @social_positive.count + @professional_positive.count + @intuitive_positive.count + @personal_positive.count
    total_negative = @methodical_negative.count + @social_negative.count + @professional_negative.count + @intuitive_negative.count + @personal_negative.count

    # Create pie chart data for positive categories
    @pie_chart_data_positive = [
      ["methodical", total_positive.zero? ? 0 : (@methodical_positive.count / total_positive.to_f * 100).round(2)],
      ["social", total_positive.zero? ? 0 : (@social_positive.count / total_positive.to_f * 100).round(2)],
      ["professional", total_positive.zero? ? 0 : (@professional_positive.count / total_positive.to_f * 100).round(2)],
      ["intuitive", total_positive.zero? ? 0 : (@intuitive_positive.count / total_positive.to_f * 100).round(2)],
      ["personal", total_positive.zero? ? 0 : (@personal_positive.count / total_positive.to_f * 100).round(2)]
    ]

    # Create pie chart data for negative categories
    @pie_chart_data_negative = [
      ["methodical", total_negative.zero? ? 0 : (@methodical_negative.count / total_negative.to_f * 100).round(2)],
      ["social", total_negative.zero? ? 0 : (@social_negative.count / total_negative.to_f * 100).round(2)],
      ["professional", total_negative.zero? ? 0 : (@professional_negative.count / total_negative.to_f * 100).round(2)],
      ["intuitive", total_negative.zero? ? 0 : (@intuitive_negative.count / total_negative.to_f * 100).round(2)],
      ["personal", total_negative.zero? ? 0 : (@personal_negative.count / total_negative.to_f * 100).round(2)]
    ]
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)

    # Set additional attributes
    @game.user = @user
    @game.client = @user.client
    @game.status = "running"
    @game.pile = 0
    @game.positive = true

    # Try to save the game and handle the response
    if @game.save
      redirect_to play_path(id: @game), notice: 'Game was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: 'Game was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @game = Game.find_by(id: params[:id])
    @game.destroy
    redirect_to games_url, notice: 'Game was successfully destroyed.'
  end

  private

  def game_params
    params.require(:game).permit(:name, :count_positive, :count_negative)
  end

  def set_user
    @user = current_user
  end

  def set_game(game)
    @game = game
    # @game = Game.where(user: @user, status: "running").first
    # @game = Game.find_by(id: params[:id]) || Game.find_by(user: @user, status: "running").first
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
    @groups = Card.where(positive: @game.positive).pluck(:groupgerman).uniq.sort
    @group = @groups[@game.public_send(@game.positive ? 'group_positive' : 'group_negative')]
    @game_cards = GameCard.joins(:card).where(cards: { groupgerman: @group }).where(game_id: @game.id).order(:id)
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
end
