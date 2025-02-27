class GamesController < ApplicationController
  before_action :set_user
  before_action :set_game

  def index
    @games = Game.where(user: @user)
  end

  def play
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

    load_game_cards
  end

  def remaining
    # sets the pile to 0 "remaining"
    @game.update(pile: 0)
    set_game_and_counts
    load_game_cards
    set_buttons_and_board
  end

  def choosen
    # sets the pile to 1 "choosen"
    @game.update(pile: 1)
    set_game_and_counts
    set_all_cards
    set_buttons_and_board
  end

  def rejected
    # sets the pile to 2 "rejected"
    @game.update(pile: 2)
    set_game_and_counts
    set_all_cards
    set_buttons_and_board
  end

  def plus
    # sets the positive to true
    @game.update(positive: true)
    set_game_and_counts
    if @game.pile == 0
      load_game_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def minus
    # sets the positive to false
    @game.update(positive: false)
    set_game_and_counts
    if @game.pile == 0
      load_game_cards
    else
      set_all_cards
    end
    set_buttons_and_board
  end

  def finish
    @game.update(status: "finished")
    redirect_to games_url
  end

  def show
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to @game, notice: 'Game was successfully created.'
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
    @game.destroy
    redirect_to games_url, notice: 'Game was successfully destroyed.'
  end

  private

    def game_params
      params.require(:game).permit(:name, :status, :score, :client_id, :user_id)
    end

  def set_user
    @user = current_user
  end

  def set_game
    @game = Game.where(user: @user, status: "running").first
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

    def set_game_and_counts
      set_game
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


  def load_game_cards
    set_counts
    unique_groupsgerman(@game.positive)
    raise
    @game_cards = @game_cards.sort_by { |game_card| game_card.card.groupgerman }
    first_group = @game_cards.first.card.groupgerman
    @game_cards.select! { |game_card| game_card.card.groupgerman == first_group }
    @game_cards.each { |game_card| game_card.update(selected: true) }

    @game_cards = @game_cards.select { |game_card| game_card.selected }
  end

  def unique_groupsgerman(positive)
    @groupsgerman = Card.where(positive: positive)           # Filter cards where positive is true
                         .pluck(:groupgerman)            # Get the groupgerman values
                         .uniq                            # Get unique entries
                         .sort                            # Sort them alphabetically

    # You can now use @groupsgerman in your view or further processing in this action
  end
end
