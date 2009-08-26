require 'thread'

module Algotraitor
  
  class Stock

    def initialize(symbol, price)
      @symbol = symbol
      @mutex = Mutex.new
      @observers = []
      # make sure the price= method is called so it can update observers
      self.price = price
    end

    def add_observer(observer)
      @observers << observer
    end

    def delete_observer(observer)
      @observers.delete(observer)
    end

    attr_reader :symbol, :price

    # Synchronizes access to this stock, so the price can be updated atomically.
    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    # Updates the stock price and notifies observers.
    def price=(new_price)
      if @price != new_price
        @observers.each do |observer|
          if observer.respond_to?(:after_price_change)
            observer.after_price_change(:stock => self, 
              :time => Algotraitor.timestamp, 
              :old_price => @price, 
              :new_price => new_price)
          end
        end
      end
      @price = new_price
    end
  end

end
