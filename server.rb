require 'rubygems'
require 'yaml'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'algotraitor'

config = YAML.load_file(ARGV.first || 'config.yaml')

config['server'].each do |k, v|
  Algotraitor::Server.set k.to_sym, v
end

market = Algotraitor::Market.new

config['stocks'].each do |symbol, stock|
  market.stocks << Algotraitor::Stock.new(symbol, stock['price'])
end

config['participants'].each do |id, participant|
  market.participants << Algotraitor::Participant.new(id, 
                           participant['name'], participant['cash_balance'])
end

# TODO: add extensions here. Starting with a quiescent market for testing.
#market.extensions << Algotraitor::Extension::PriceBumper
market.extensions << Algotraitor::Extension::TradeHistory

Algotraitor::Server.market = market

Algotraitor::Server.run!
