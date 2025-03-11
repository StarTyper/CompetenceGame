class CardsController < ApplicationController
  before_action :find_card, only: %i[show edit update destroy]
  before_action :find_user

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    @card.user_id = @user.id
    @card.client = @user.client
    @card.group = "own cards"
    if @card.save
      redirect_to cards_path,
                  notice: ( if @user.language == "english"
                              'Card was successfully created.'
                            elsif @user.language == "german"
                              'Karte wurde erfolgreich erstellt.'
                            end
                          )
    else
      render :new
      flash[:notice] = if @user.language == "english"
                         'Creation of card failed.'
                       elsif @user.language == "german"
                         'Erstellung der Karte fehlgeschlagen.'
                       end
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
    params.require(:card).permit(:positive, :namegerman, :nameenglish, :explanationgerman,
                                 :explanationenglish, :image, :groupgerman, :groupenglish, :category)
  end
end
