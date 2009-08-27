require 'digest/sha2'
require 'thread'

module Algotraitor
  Overdrawn = Class.new(StandardError)
  NoShortSelling = Class.new(StandardError)

  class Participant
    def initialize(id, name, cash_balance)
      @id = id
      @name = name
      @cash_balance = cash_balance
      @portfolio = Hash.new(0)
      @mutex = Mutex.new
      @observers = []
    end

    attr_reader :id, :name, :cash_balance, :portfolio

    def valid_password?(password)
      password == calculate_password
    end

    Secret = "sR5^YFysrOC4H>H"
    def calculate_password
      Digest::SHA2.hexdigest("#{@id}-#{Secret}")[0,8]
    end

    def add_observer(observer)
      @observers << observer
    end

    def delete_observer(observer)
      @observers.delete(observer)
    end

    def buy(stock, quantity)
      execution_price = stock.price

      # Invoke before_trade callbacks and allow them to modify the price.
      @observers.each do |observer|
        if observer.respond_to?(:before_trade)
          result = observer.before_trade(:participant => self, 
                               :stock => stock, 
                               # Price may have been modified by another
                               # observer, so use the current value.
                               :price => execution_price, 
                               :quantity => quantity)
          # If we got a price back, use that as the new price
          execution_price = result.delete(:price) || execution_price
        end
      end

      purchase_price = execution_price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise Overdrawn if purchase_price > @cash_balance
      
      executed_at = nil
      if quantity > 0
        @mutex.synchronize do
          # Serialize the assignment to executed_at so the history is consistent
          executed_at = Algotraitor.timestamp
          @cash_balance -= purchase_price
          @portfolio[stock] += quantity
        end

        @observers.each do |observer|
          if observer.respond_to?(:after_trade)
            observer.after_trade(:participant => self, 
                                 :stock => stock, 
                                 :time => executed_at, 
                                 :price => execution_price,
                                 :quantity => quantity)
          end
        end
      end

      {:price_per_share => execution_price,
       :executed_at     => executed_at}
    end

    def sell(stock, quantity)
      execution_price = stock.price

      # Invoke before_trade callbacks and allow them to modify the price.
      @observers.each do |observer|
        if observer.respond_to?(:before_trade)
          result = observer.before_trade(:participant => self, 
                               :stock => stock, 
                               # Price may have been modified by another
                               # observer, so use the current value.
                               :price => execution_price, 
                               :quantity => quantity)
          # If we got a price back, use that as the new price
          execution_price = result.delete(:price) || execution_price
        end
      end

      sale_price = execution_price * quantity
      raise ArgumentError, "Quantity must be nonnegative" if quantity < 0
      raise NoShortSelling if @portfolio[stock] < quantity

      executed_at = nil
      if quantity > 0
        @mutex.synchronize do
          # Serialize the assignment to executed_at so the history is consistent
          executed_at = Algotraitor.timestamp
          @portfolio[stock] -= quantity
          @cash_balance += sale_price
        end

        @observers.each do |observer|
          if observer.respond_to?(:after_trade)
            observer.after_trade(:participant => self, 
                                 :stock => stock, 
                                 :time => executed_at, 
                                 :price => execution_price, 
                                 :quantity => -quantity)
          end
        end
      end

      {:price_per_share => execution_price,
       :executed_at     => executed_at}
    end

  end

end
