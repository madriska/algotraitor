module Algotraitor

  class Participant
    attr_reader :id, :name, :cash_balance

    def initialize(id, name, cash_balance)
      @id = id
      @name = name
      @cash_balance = cash_balance
    end

  end

end
