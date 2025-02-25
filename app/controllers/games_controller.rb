class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  def index
    @games = Game.where(user: current_user)
  end

  def play
    # current user
    @user = current_user
    # find the current game for the user
    @game = Game.where(user: current_user, status: "running").first
    # if there is no current game, create one
    if @game.nil?
      @game = Game.create(name: "FreePlay", status: "running", client: current_user.client, user: current_user)
    end
    # find the game cards for the game
    @game_cards = GameCard.where(game: @game)
    # if there are no game cards, create them
    if @game_cards.empty?
      # find the cards for the client to include special cards
      @cards = Card.where(client: current_user.client)
      # add cards from the client "default" to include the base game
      @cards += Card.where(client: Client.where(name: "default").first)
      # create a game card for each card
      @cards.each do |card|
        GameCard.create(game: @game, card: card, pile: 0)
      end
    end
    # find the game cards for the game
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

  def remaining
    @game = Game.where(user: current_user, status: "running").first
    @game_cards = GameCard.where(game: @game, pile: 0)
  end

  def choosen
    @game = Game.where(user: current_user, status: "running").first
    @game_cards = GameCard.where(game: @game, pile: 1)
  end

  def rejected
    @game = Game.where(user: current_user, status: "running").first
    @game_cards = GameCard.where(game: @game, pile: 2)
  end

  def plus
    @game = Game.where(user: current_user, status: "running").first
    @game_cards = GameCard.joins(:card).where(game: @game)
    @count_remaining_positive = @game_cards.where(pile: 0, cards: { positive: true }).count
    @count_choosen_positive = @game_cards.where(pile: 1, cards: { positive: true }).count
    @count_rejected_positive = @game_cards.where(pile: 2, cards: { positive: true }).count
  end

  def minus
    @game = Game.where(user: current_user, status: "running").first
    @game_cards = GameCard.joins(:card).where(game: @game)
    @count_remaining_negative = @game_cards.where(pile: 0, cards: { positive: false }).count
    @count_choosen_negative = @game_cards.where(pile: 1, cards: { positive: false }).count
    @count_rejected_negative = @game_cards.where(pile: 2, cards: { positive: false }).count
  end

  def finish
    @game = Game.where(user: current_user, status: "running").first
    @game.status = "finished"
    @game.save
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

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :status, :score, :client_id, :user_id)
  end
end
