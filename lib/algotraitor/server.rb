require 'sinatra'
require 'json'

module Algotraitor
  class Server < Sinatra::Base
    set :lock, true

    class << self
      attr_accessor :market
    end

    def market
      self.class.market
    end

    use Rack::Auth::Basic do |username, password|
      market.authenticate(username, password)
    end

    # Current market participant, as authenticated
    def participant
      market.participants[env['REMOTE_USER'].to_i]
    end

    get '/stocks.json' do
      content_type 'application/json'
      market.stock_prices.to_json
    end

    get '/account.json' do
      content_type 'application/json'
      portfolio = participant.portfolio.inject({}) do |hash, (stock, quantity)|
        hash[stock.symbol] = quantity
        hash
      end
      {'cash_balance' => participant.cash_balance,
       'portfolio'    => portfolio}.to_json
    end

    post '/buy/:symbol/:quantity' do |symbol, quantity|
      stock = market.stocks[symbol]
      # body: execution price
      result = participant.buy(stock, quantity.to_i)
      {'price_per_share' => result[:price_per_share],
       'executed_at'     => result[:executed_at]}.to_json
    end

    post '/sell/:symbol/:quantity' do |symbol, quantity|
      stock = market.stocks[symbol]
      # body: execution price
      result = participant.sell(stock, quantity.to_i)
      {'price_per_share' => result[:price_per_share],
       'executed_at'     => result[:executed_at]}.to_json
    end

  end
end
