module Algotraitor
  module Extension
    # Bumps the price up / down to simulate market activity of supply and demand
    module PriceBumper
      extend self

      # TODO: define a before_trade callback that bumps the execution price
      # equivalently to after_trade (amortized over the volume of the trade) to
      # eliminate arbitrage possibilities. An immediate buy/sell pair must have
      # an expected profit of zero, lest an arbitrage race-to-the-bottom ensue!

      def after_trade(options={})
        stock = options[:stock]
        quantity = options[:quantity] # + for buy, - for sell
        # TODO: this can become stock-dependent.
        volume_factor = 1.01

        stock.synchronize do
          stock.price *= (volume_factor ** quantity)
        end
      end

    end
  end
end
