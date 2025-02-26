class GameCardsController < ApplicationController

  def choose
    @game_card = GameCard.find(params[:game_card_id])
    @game_card.update(pile: 1)
  end

  def reject
    @game_card = GameCard.find(params[:game_card_id])
    @game_card.update(pile: 2)
  end

  private

  def game_card_params
    params.require(:game_card).permit(:game_id, :game_card_id, :pile)
  end
end
