class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  def index
    @games = Game.where(user: current_user)
  end

  def play
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
    @game_cards = GameCard.where(game: @game)
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
