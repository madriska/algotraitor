module Algotraitor

  # A Market represents the current state of a market: a basket of Stocks and
  # their associated information.
  class Market
    include Roxy::Moxie # proxy love

    def initialize
      @stocks = {}
      @participants = {}
      @extensions = []
    end

    attr_reader :stocks, :participants, :extensions

    def authenticate(id, password)
      (p = @participants[id.to_i]) && p.valid_password?(password)
    end

    def add_stock(stock)
      stock.add_observer(self)
      @stocks[stock.symbol] = stock
    end

    # Enable market.stocks << stock to index stock by symbol
    proxy :stocks do
      def <<(stock)
        proxy_owner.add_stock(stock)
      end
    end

    # Called when a stock price is updated.
    def after_price_change(options)
      @extensions.each do |extension|
        if extension.respond_to?(:after_price_change)
          extension.after_price_change(options)
        end
      end
    end

    def add_participant(participant)
      participant.add_observer(self)
      @participants[participant.id] = participant
    end

    proxy :participants do
      def <<(participant)
        proxy_owner.add_participant(participant)
      end
    end

    def before_trade(options)
      price = options[:price]
      @extensions.each do |extension|
        if extension.respond_to?(:before_trade)
          result = extension.before_trade(options)
          price = result.delete(:price) || price
        end
      end
      {:price => price}
    end

    # Called to notify the Market when a market participant performs a trade.
    def after_trade(options)
      @extensions.each do |extension|
        if extension.respond_to?(:after_trade)
          extension.after_trade(options)
        end
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
