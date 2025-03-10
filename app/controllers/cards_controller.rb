class CardsController < ApplicationController
  before_action :find_card, only: %i[show edit update destroy]
  before_action :find_user

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    raise
    if @card.save
      redirect_to cards_path
    else
      render :new
    end
  end

  def index
    # cards where user = @user
    @cards = Card.where(user_id: @user)
  end

  def show
  end

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to cards_path
    else
      render :edit
    end
  end

  def destroy
    @card.destroy
    redirect_to cards_path
  end

  private

  def find_user
    @user = current_user
  end

  def find_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:categorygerman, :positive, :namegerman, :nameenglish, :explanationgerman,
                                 :explanationenglish, :image, :groupgerman, :groupenglish, :categoryenglish)
  end
end
