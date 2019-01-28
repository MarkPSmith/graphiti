class Graphiti::Adapters::ActiveRecord::ManyToManySelfReferentialSideload < Graphiti::Sideload::ManyToManySelfReferential
  def through_table_name
    true_through = parent_resource_class.model.reflections[through.to_s].options[:through].to_s
    @through_table_name ||= parent_resource_class.model.reflections[true_through].klass.table_name
  end

  def through_relationship_name
    foreign_key.keys.first
  end

  def belongs_to_many_filter(scope, value)
    scope
      .includes(through_relationship_name)
      .where(belongs_to_many_clause(value))
  end

  private

  def belongs_to_many_clause(value)
    where = { through_primary_key => value }.tap do |c|
      if polymorphic?
        c[foreign_type_column] = foreign_type_value
      end
    end

    { through_table_name => where }
  end

  def foreign_type_column
    through_reflection.type
  end

  def foreign_type_value
    through_reflection.active_record.name
  end

  def polymorphic?
    !!foreign_type_column
  end

  def through_reflection
    through = parent_reflection.options[:through]
    parent_resource_class.model.reflections[through.to_s]
  end

  def parent_reflection
    parent_model = parent_resource_class.model
    parent_model.reflections[association_name.to_s]
  end

  def infer_foreign_key
    through_class = Object.const_get(through_reflection.options[:class_name])
    key = association_name.to_s
    value = through_class.reflections[parent_reflection.source_reflection_name].options[:foreign_key] 
    
    { key => value }
  end
end
