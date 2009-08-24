module Algotraitor
  
  class Stock
    attr_reader :symbol, :price
    # may modify price= to do something significant.
    attr_writer :price

    def initialize(symbol, price)
      @symbol = symbol
      # make sure the price= method is called; it may do something significant
      # in the future.
      self.price = price
    end
  end

end
