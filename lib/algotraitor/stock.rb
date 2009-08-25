require 'observer'
require 'thread'

module Algotraitor
  
  class Stock
    include Observable

    def initialize(symbol, price)
      @symbol = symbol
      # make sure the price= method is called so it can update observers
      self.price = price
      @mutex = Mutex.new
    end

    attr_reader :symbol, :price

    # Synchronizes access to this stock, so the price can be updated atomically.
    def synchronize(&block)
      @mutex.synchronize(&block)
    end

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
