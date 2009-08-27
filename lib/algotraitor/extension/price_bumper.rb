module Algotraitor
  module Extension
    # Bumps the price up / down to simulate market activity of supply and demand
    module PriceBumper
      extend self

      # Bumps the execution price equivalently to after_trade (amortized over
      # the volume of the trade) to eliminate arbitrage possibilities. An
      # immediate buy/sell pair must have an expected profit of zero, lest an
      # arbitrage race-to-the-bottom ensue!
      def before_trade(options={})
        stock = options[:stock]
        quantity = options[:quantity] # + for buy, - for sell
        vfactor = volume_factor(stock)

        current_price = options[:price]
        total_execution_price = (1..(quantity.abs)).inject(0) do |total, _|
          # We have to stagger the price calculations by one for buy vs. sell,
          # to include the same set of prices when buying as selling.
          if quantity > 0 # buy
            price = current_price
            current_price *= vfactor
            total + price
          else # sell
            total + (current_price /= vfactor)
          end
        end
        average_execution_price = total_execution_price / quantity.abs

        {:price => average_execution_price}
      end

      def after_trade(options={})
        stock = options[:stock]
        quantity = options[:quantity] # + for buy, - for sell
        vfactor = volume_factor(stock)

        stock.synchronize do
          stock.price *= (vfactor ** quantity)
          stock.price += ((rand() - 0.5) * 0.10 * stock.price)
        end
      end

      protected

      # The factor by which buys / sells scale the stock price (per share).
      def volume_factor(stock)
        1.01 + (rand() * 0.0001 * stock.price) + (rand() * 0.0005)
      end

    end
  end
end
