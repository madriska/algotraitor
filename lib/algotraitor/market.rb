module Algotraitor

  # A Market represents the current state of a market: a basket of Stocks and
  # their associated information.
  class Market
    attr_reader :stocks

    def initialize
      @stocks = {}
      
      # Automatically index stocks by their symbol
      def @stocks.<<(stock)
        self[stock.symbol] = stock
      end
    end

    def stock_prices
      @stocks.inject({}) do |hash, (symbol, stock)|
        hash[symbol] = stock.price
        hash
      end
    end



  end

end
