class CardsController < ApplicationController
  before_action :find_card, only: %i[show edit update destroy]
  before_action :find_user

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    assign_card_name_if_empty
    @card.user_id = @user.id
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
      redirect_to new_card_path
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
    assign_card_name_if_empty
    if @card.update(card_params)
      redirect_to cards_path,
                  notice: ( if @user.language == "english"
                              'Card was successfully updated.'
                            elsif @user.language == "german"
                              'Karte wurde erfolgreich aktualisiert.'
                            end
                          )
    else
      render :edit
      flash[:notice] = if @user.language == "english"
                         'Card update failed.'
                       elsif @user.language == "german"
                         'Kartenaktualisierung fehlgeschlagen.'
                       end
    end
  end

  def destroy
    if @card.destroy
      redirect_to cards_path,
                  notice: ( if @user.language == "english"
                              'Card was successfully deleted.'
                            elsif @user.language == "german"
                              'Karte wurde erfolgreich gelöscht.'
                            end
                          )
    else
      redirect_to cards_path,
                  notice: ( if @user.language == "english"
                              'Card deletion failed.'
                            elsif @user.language == "german"
                              'Kartelöschung fehlgeschlagen.'
                            end
                          )
    end
  end

  private

  def find_user
    @user = current_user
  end

  def find_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:positive, :name_german, :name_english, :explanation_german,
    :explanation_english, :category).delete_if { |_, v| v.empty? }
  end

  def assign_card_name_if_empty
    # if card.name_english is nil or empty, set it to "no name"
    if @card.name_english.nil? || @card.name_english.empty?
      @card.name_english = "no name"
    end
    # if card.explanation_english is empty, set it to "no explanation"
    if @card.explanation_english.nil? || @card.explanation_english.empty?
      @card.explanation_english = "no explanation - add a name and an explanation in the card settings"
    end
    # if card.name_german is empty, set it to name_english
    if @card.name_german.nil? || @card.name_german.empty?
      @card.name_german = @card.name_english
    end
    # if card.explanation_german is empty, set it to explanation_english
    if @card.explanation_german.nil? || @card.explanation_german.empty?
      @card.explanation_german = @card.explanation_english
    end
  end
end
