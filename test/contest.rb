# Copyright (c) 2009 Damian Janowski and Michel Martens for Citrusbyte
#  
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "test/unit"

# Test::Unit loads a default test if the suite is empty, and the only
# purpose of that test is to fail. As having empty contexts is a common
# practice, we decided to overwrite TestSuite#empty? in order to
# allow them. Having a failure when no tests have been defined seems
# counter-intuitive.
class Test::Unit::TestSuite
  unless method_defined?(:empty?)
    def empty?
      false
    end
  end
end

# We added setup, test and context as class methods, and the instance
# method setup now iterates on the setup blocks. Note that all setup
# blocks must be defined with the block syntax. Adding a setup instance
# method defeats the purpose of this library.
class Test::Unit::TestCase
  def self.setup(&block)
    setup_blocks << block
  end

  def setup
    self.class.setup_blocks.each do |block|
      instance_eval(&block)
    end
  end

  def self.context(name, &block)
    subclass = Class.new(self.superclass)
    subclass.setup_blocks.unshift(*setup_blocks)
    subclass.class_eval(&block)
    const_set(context_name(name), subclass)
  end

  def self.test(name, &block)
    define_method(test_name(name), &block)
  end

  class << self
    alias_method :should, :test
    alias_method :describe, :context
  end

private

  def self.setup_blocks
    @setup_blocks ||= []
  end

  def self.context_name(name)
    "Test#{sanitize_name(name).gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
  end

  def self.test_name(name)
    "test_#{sanitize_name(name).gsub(/\s+/,'_')}".to_sym
  end

  def self.sanitize_name(name)
    name.gsub(/\W+/, ' ').strip
  end
end
