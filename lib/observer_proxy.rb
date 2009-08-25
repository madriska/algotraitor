# Ruby's Observable will only call the #update method on the watching object.
# This is fine when you have dedicated observers, but if you have lightweight
# objects that watch for different events, you can use an ObserverProxy to 
# translate the method names to those of your choice.
#
#   def something_changed(*args)
#     # do something...
#   end
#
#   observed.add_observer(ObserverProxy.new(self, :something_changed))
#
class ObserverProxy
  def initialize(object, method)
    @object, @method = object, method
  end

  def update(*args, &block)
    @object.send(@method, *args, &block)
  end
end
