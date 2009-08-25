require 'observer'

module Algotraitor
  
  class Stock
    include Observable

    def initialize(symbol, price)
      @symbol = symbol
      # make sure the price= method is called so it can update observers
      self.price = price
    end

    attr_reader :symbol, :price

    # Updates the stock price and notifies observers.
    def price=(new_price)
      if @price != new_price
        changed
        notify_observers(self, Time.now, @price, new_price)
      end
      @price = new_price
    end
  end

end
