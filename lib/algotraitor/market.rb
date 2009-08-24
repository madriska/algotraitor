module Algotraitor

  # A Market represents the current state of a market: a basket of Stocks and
  # their associated information.
  class Market
    attr_reader :stocks, :participants

    def initialize
      # Automatically index stocks by their symbol
      @stocks = {}
      def @stocks.<<(stock)
        self[stock.symbol] = stock
      end

      # Index participants by their ID (assigned at startup)
      @participants = {}
      def @participants.<<(participant)
        self[participant.id] = participant
      end
    end

    # Returns a hash mapping stock symbols to current prices.
    def stock_prices
      @stocks.inject({}) do |hash, (symbol, stock)|
        hash[symbol] = stock.price
        hash
      end
    end



  end

end
