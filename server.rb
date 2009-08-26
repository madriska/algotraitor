require 'rubygems'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'algotraitor'

# TODO: replace with seed data
market = Algotraitor::Market.new
market.stocks << Algotraitor::Stock.new('ABC', 10.00)
market.participants << Algotraitor::Participant.new(1, 'Brad', 1000.00)

Algotraitor::Server.market = market

Algotraitor::Server.run!
