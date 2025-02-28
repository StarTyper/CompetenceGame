class GamesController < ApplicationController
  before_action :set_user
  # before_action :set_game, except: %i[new create update destroy index show]

  def play
    @game = Game.find_by(id: params[:id])
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

  def index
    @games = Game.where(user: @user)
  end

  def show
    @game = Game.find(params[:id])
    # function to assign all positive game cards on pile 1 from the categorygerman "methodisch" to @methodical_positive
    @methodical_positive = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "methodisch", positive: true })
    # function to assign all negative game cards on pile 1 from the categorygerman "methodisch" to @methodical_negative
    @methodical_negative = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "methodisch", positive: false })
    # function to assign all positive game cards on pile 1 from the categorygerman "sozial" to @social_positive
    @social_positive = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "sozial", positive: true })
    # function to assign all negative game cards on pile 1 from the categorygerman "sozial" to @social_negative
    @social_negative = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "sozial", positive: false })
    # function to assign all positive game cards on pile 1 from the categorygerman "fachlich" to @professional_positive
    @professional_positive = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "fachlich", positive: true })
    # function to assign all negative game cards on pile 1 from the categorygerman "fachlich" to @professional_negative
    @professional_negative = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "fachlich", positive: false })
    # function to assign all positive game cards on pile 1 from the categorygerman "intuitiv" to @intuitive_positive
    @intuitive_positive = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "intuitiv", positive: true })
    # function to assign all negative game cards on pile 1 from the categorygerman "intuitiv" to @intuitive_negative
    @intuitive_negative = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "intuitiv", positive: false })
    # function to assign all positive game cards on pile 1 from the categorygerman "persönlich" to @personal_positive
    @personal_positive = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "persönlich", positive: true })
    # function to assign all negative game cards on pile 1 from the categorygerman "persönlich" to @personal_negative
    @personal_negative = GameCard.joins(:card).where(game: @game, pile: 1, cards: { categorygerman: "persönlich", positive: false })
    # function to assign all cards from this game on pile 1 to @choosen_cards
    @choosen_cards = GameCard.where(game: @game, pile: 1)
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
