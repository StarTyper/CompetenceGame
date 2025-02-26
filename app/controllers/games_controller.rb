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

    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
  end

  def remaining
    # sets the pile to 0 "remaining"
    @game.update(pile: 0)
    set_game
    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
    if @game.positive
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 0, cards: { positive: true })
    else
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 0, cards: { positive: false })
    end
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

  def choosen
    # sets the pile to 1 "choosen"
    @game.update(pile: 1)
    set_game
    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
    if @game.positive
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 1, cards: { positive: true })
    else
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 1, cards: { positive: false })
    end
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

  def rejected
    # sets the pile to 2 "rejected"
    @game.update(pile: 2)
    set_game
    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
    if @game.positive
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 2, cards: { positive: true })
    else
      @game_cards = GameCard.joins(:card).where(game: @game, pile: 2, cards: { positive: false })
    end
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

  def plus
    @game.update(positive: true)
    set_game
    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
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

  def minus
    @game.update(positive: false)
    set_game
    @game_cards = GameCard.joins(:card).where(game: @game)
    set_counts
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

  def set_user
    @user = current_user
  end

  def set_game
    @game = Game.where(user: @user, status: "running").first
  end

  def game_params
    params.require(:game).permit(:name, :status, :score, :client_id, :user_id)
  end

  def set_counts
    @count_positive = @game.count_positive
    @count_negative = @game.count_negative
    @count_remaining_positive = @game_cards.where(pile: 0, cards: { positive: true }).count
    @count_choosen_positive = @game_cards.where(pile: 1, cards: { positive: true }).count
    @count_rejected_positive = @game_cards.where(pile: 2, cards: { positive: true }).count
    @count_remaining_negative = @game_cards.where(pile: 0, cards: { positive: false }).count
    @count_choosen_negative = @game_cards.where(pile: 1, cards: { positive: false }).count
    @count_rejected_negative = @game_cards.where(pile: 2, cards: { positive: false }).count
  end
end
