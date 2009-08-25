$: << File.dirname(__FILE__) + '/../lib'
require 'algotraitor'

require File.dirname(__FILE__) + '/contest'
require 'mocha'

begin
  require 'redgreen'
rescue LoadError
end
