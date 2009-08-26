Dir['vendor/*'].each do |dir|
  $LOAD_PATH.unshift(File.directory?(lib = File.join(dir, 'lib')) ? lib : dir)
end

require 'roxy'

module Algotraitor

  def self.timestamp
    (Time.now.to_f * 100).to_i
  end

end

require 'algotraitor/stock'
require 'algotraitor/market'
require 'algotraitor/participant'
require 'algotraitor/server'

