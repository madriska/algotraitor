Dir['vendor/*'].each do |dir|
  $LOAD_PATH.unshift(File.directory?(lib = File.join(dir, 'lib')) ? lib : dir)
end

require 'roxy'
require 'observer_proxy'

require 'algotraitor/stock'
require 'algotraitor/market'
require 'algotraitor/participant'

