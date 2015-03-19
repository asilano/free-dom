module ActsAsTree
  module InstanceMethods
    # Creates a new node which is parent of the current node, and child of
    # the current node's current parent. Siblings of the current node are
    # affected or not according to the :siblings parameter.
    #
    #   Example:
    #   root
    #    \_ child1
    #         \_ subchild1
    #         \_ subchild2
    #
    #   subchild2.insert_parent("name" => "inserted")
    #
    #   root
    #    \_ child1
    #         \_ subchild1
    #         \_ inserted
    #              \_ subchild2
    #
    #   inserted.insert_parent("name" => "adopter", :siblings => true)
    #
    #   root
    #    \_ child1
    #         \_ adopter
    #             \_ subchild1
    #             \_ inserted
    #                  \_ subchild2
    #
    def insert_parent(params)
      reparent_siblings = false
      if params.keys.include?(:siblings)
        reparent_siblings = params.delete(:siblings)
        old_siblings = siblings
      end

      if parent
        inserted = parent.children.build(params)
        self.parent = inserted
      else
        inserted = self.build_parent(params)
      end

      if reparent_siblings
        old_siblings.each {|s| s.parent = inserted}
      end

      inserted
    end

    def insert_parent!(params)
      parent(true)
      parent.children(true) if parent
      reparent_siblings = false
      if params.keys.include?(:siblings)
        reparent_siblings = params[:siblings]
        old_siblings = siblings
      end
      insert_parent(params)
      parent.save!
      save!
      if reparent_siblings
        old_siblings.each {|s| s.save!}
      end

      parent
    end

    # Creates a new node which is child of the current node, and parent of
    # all the current node's current children.
    #
    #   Example:
    #   root
    #    \_ child1
    #         \_ subchild1
    #         \_ subchild2
    #
    #   child1.insert_child("name" => "inserted")
    #
    #   root
    #    \_ child1
    #         \_ inserted
    #              \_ subchild1
    #              \_ subchild2
    #
    def insert_child(params)
      inserted = self.children.build(params)

      children.each {|c| next if c == inserted; c.parent = inserted}

      inserted
    end

    def insert_child!(params)
      children(true)
      inserted = insert_child(params)
      inserted.save!
      children.each {|c| next if c == inserted; c.save!}

      inserted
    end

    # Removes the current node by sliding it out; the node's children
    # are all re-parented to the current node's parent.
    #
    #   Example:
    #   root
    #    \_ child1
    #         \_ subchild1
    #         \_ subchild2
    #
    #   child1.remove
    #
    #   root
    #    \_ subchild1
    #    \_ subchild2
    #
    def slide_out
      children.each do |c|
        c.parent = parent
      end
      self.parent = nil
      self
    end

    def slide_out!
      children(true)
      parent(true)
      slide_out
      children.each do |c|
        c.save!
      end
      save!
      self
    end

    def remove
      slide_out
      self.reload
      self.destroy
    end

    def remove!
      slide_out!
      self.reload
      self.destroy
      save!
    end
  end
end
