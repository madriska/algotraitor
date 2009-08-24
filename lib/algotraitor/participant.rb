module Algotraitor

  class Participant
    attr_reader :name, :cash_balance

    def initialize(name, cash_balance)
      @name = name
      @cash_balance = cash_balance
    end

  end

end
