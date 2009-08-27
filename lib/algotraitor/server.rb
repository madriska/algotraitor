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

    get '/seekrit/balances' do
      content_type 'text/plain'
      "Cash:\n" +
      market.participant_summary.map{|p, s|
        "#{p.name} (#{p.id}): #{s[:cash]} cash, #{s[:stock]} stock, #{s[:total]} total"}.join("\n")
    end

    get '/stocks.json' do
      content_type 'application/json'
      market.stock_prices.to_json
    end

    get '/account.json' do
      content_type 'application/json'
      portfolio = participant.portfolio.inject({}) do |hash, (stock, quantity)|
        hash[stock.symbol] = quantity unless quantity.zero?
        hash
      end
      {'cash_balance' => participant.cash_balance,
       'portfolio'    => portfolio}.to_json
    end

    get '/trade_history.json' do
      content_type 'application/json'
      Algotraitor::Extension::TradeHistory.to_json
    end

    post '/buy/:symbol/:quantity' do |symbol, quantity|
      content_type 'application/json'
      stock = market.stocks[symbol]
      result = participant.buy(stock, quantity.to_i)
      {'price_per_share' => result[:price_per_share],
       'executed_at'     => result[:executed_at]}.to_json
    end

    post '/sell/:symbol/:quantity' do |symbol, quantity|
      content_type 'application/json'
      stock = market.stocks[symbol]
      result = participant.sell(stock, quantity.to_i)
      {'price_per_share' => result[:price_per_share],
       'executed_at'     => result[:executed_at]}.to_json
    end

  end
end
