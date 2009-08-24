$: << File.dirname(__FILE__) + '/../lib'
require 'algotraitor'

require File.dirname(__FILE__) + '/contest'

begin
  require 'redgreen'
rescue LoadError
end
