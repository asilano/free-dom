module FauxField
  def faux_field(*fields)
    fields.each do |sym, default|
      hash_sym = "#{sym}_hash".to_sym
      class_attribute hash_sym
      send("#{hash_sym}=", Hash.new { |h,k| h[k] = default.duplicable? ? default.dup : default })

      define_method(sym) { self.class.send(hash_sym)[id] }
      define_method("#{sym}=") { |val| self.class.send(hash_sym)[id] = val }
    end
  end
end