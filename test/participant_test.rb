require File.dirname(__FILE__) + '/helper'

class ParticipantTest < Test::Unit::TestCase
  
  test "initializer accepts a name and cash balance" do
    participant = Algotraitor::Participant.new("Mickey Mouse", 100.00)
    assert_equal "Mickey Mouse", participant.name
    assert_equal 100.00, participant.cash_balance
  end

end
