module Algotraitor

  # A Market represents the current state of a market: a basket of Stocks and
  # their associated information.
  class Market
    attr_reader :stocks

    def initialize
      @stocks = {}
      
      def @stocks.<<(stock)
        self[stock.symbol] = stock
      end
    end


  end

end
