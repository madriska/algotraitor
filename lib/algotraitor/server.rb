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
    
    get '/stocks.json' do
      content_type 'application/json'
      market.stock_prices.to_json
    end

  end
end
