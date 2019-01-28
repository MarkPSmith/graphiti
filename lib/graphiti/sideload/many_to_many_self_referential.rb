class Graphiti::Sideload::ManyToManySelfReferential < Graphiti::Sideload::HasMany

  def initialize(name,opts)
    super(name,opts)
    @through_primary_key = opts[:through_primary_key]
  end

  def infer_resource_class
    parent_resource.class
  end

  def infer_primary_key
    parent_resource.model.reflections[parent_reflection.options[:through].to_s].options[:foreign_key]
  end

  def through_primary_key
    @through_primary_key ||= infer_primary_key
  end

  def type
    :many_to_many_self_referential
  end

  def through
    foreign_key.keys.first
  end

  def true_foreign_key
    foreign_key.values.first 
  end

  def base_filter(parents)
    { true_foreign_key => ids_for_parents(parents).join(',') }
  end

  def infer_foreign_key
    raise 'You must explicitly pass :foreign_key for many-to-many relationships, or override in subclass to return a hash.'
  end

  def performant_assign?
    false
  end

  def assign_each(parent, children)
    result = []
    children.each do |child|
      parent.send(through).each do |pc|
        result << child if child.id == pc.id
      end
    end
    result
  end
end
