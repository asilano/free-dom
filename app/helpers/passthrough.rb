module Passthrough
  def passthrough(*methods)
    methods.each do |method|
      ## make sure the argument is the right type.
      raise ArgumentError if not method.is_a?(Symbol)
      method_str = method.to_s
      self.class_eval("def #{method_str}(*args) ; self.class.#{method_str}(*args) ; end")
    end
  end
end
