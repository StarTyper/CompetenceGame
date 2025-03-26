class CardsController < ApplicationController
  before_action :find_card, only: %i[show edit update destroy]
  before_action :find_user
  before_action :translate_category_param, only: [:create, :update]

  CATEGORY_MAPPING = {
    1 => "methodical",
    2 => "social",
    3 => "professional",
    4 => "intuitive",
    5 => "personal"
  }

  def new
    @card = Card.new
  end

  def create
    assign_card_name_if_empty
    @card = Card.new(card_params)
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
      redirect_to edit_card_path(@card)
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
    :explanation_english, :category)
  end

  def translate_category_param
    return unless params[:card] && params[:card][:category]

    integer_value = params[:card][:category].to_i
    params[:card][:category] = CATEGORY_MAPPING[integer_value]
  end

  def assign_card_name_if_empty
    card_params = params[:card]

    if !card_params.key?(:name_english)
      card_params[:name_english] = @card.name_english.presence || "no name"
    end
    # Set name_english to the existing value in @card or the default if not provided
    card_params[:name_english] = if card_params[:name_english].blank?
                                    "no name"
                                  else
                                    card_params[:name_english]
                                 end

    if !card_params.key?(:explanation_english)
      card_params[:explanation_english] = @card.explanation_english.presence || "no explanation - add a name and an explanation in the card settings"
    end
    # Set explanation_english to the existing value in @card or the default if not provided
    card_params[:explanation_english] = if card_params[:explanation_english].blank?
                                           "no explanation - add a name and an explanation in the card settings"
                                         else
                                           card_params[:explanation_english]
                                        end

    if card_params.key?(:name_german)
      # Handle name_german, checking for empty string and fallback logic
      card_params[:name_german] = if card_params[:name_german].blank?  # checks for empty string or nil
                                    @card.name_english.presence || "no name"
                                  else
                                    card_params[:name_german]
                                  end
    end

    return unless card_params.key?(:explanation_german)

      # Handle explanation_german, checking for empty string and fallback logic
    card_params[:explanation_german] = if card_params[:explanation_german].blank?
                                          @card.explanation_english.presence || "no explanation - add a name and an explanation in the card settings"
                                        else
                                          card_params[:explanation_german]
                                       end

  end
end
