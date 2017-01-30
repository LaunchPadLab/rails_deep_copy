module RailsDeepCopy
  class Duplicate

    attr_accessor :associations, :id_hash

    def initialize(object_to_duplicate, options = {})
      @object_to_duplicate = object_to_duplicate
      @new_object = @object_to_duplicate.dup
      @changes = options[:changes] || {}
      @associations_to_build = options[:associations] || default_associations
      @associations_to_avoid = options[:exclude_associations] || []
      @skip_validations = options[:skip_validations] || true
      @id_hash = options[:id_hash] || {}
      @changes.merge!(@id_hash)
      @duplicated_objects = options.fetch(:duplicated_objects, [])
      setup_associations
    end

    def self.create(object_to_duplicate, options = {})
      Duplicate.new(object_to_duplicate, options).execute
    end

    def default_associations
      @new_object.class::DUPLICABLE_ASSOCIATIONS rescue []
    end

    def all_associations
      associations = @object_to_duplicate.class.reflect_on_all_associations
      return associations unless @associations_to_build.any? || @associations_to_avoid.any?
      if @associations_to_build.any?
        associations.find_all{|association| @associations_to_build.include?(association.name)}
      else
        associations.find_all{|association| !@associations_to_avoid.include?(association.name)}
      end
    end

    def duplicable_associations
      # duplicable association types: :has_one, :has_one :through, :has_many
      # not duplicable: :has_many :through, :belongs_to
      all_associations.find_all do |association|
        should_keep = [:has_many, :has_one].include?(association.macro)
        should_keep = false if association.macro == :has_many && association.options.keys.include?(:through)
        should_keep
      end
    end

    def sort_through_associations
      through_associations = []
      # associations with :through should be last in iteration to make sure IDs are set appropriately
      associations.each do |association|
        if association.options.keys.include?(:through)
          through_associations << association
          @associations.delete(association)
        end
      end
      @associations = (@associations << through_associations).flatten
    end

    def setup_associations
      @associations = duplicable_associations
      sort_through_associations
    end

    def implement_new_object_differences
      defaults = @new_object.class::DUPLICABLE_DEFAULTS rescue false
      hash = defaults ? defaults.merge(@changes) : @changes
      hash.each do |attribute, value|
        @new_object.send("#{attribute}=", value) if @new_object.attributes.include?(attribute.to_s)
      end
    end

    def new_object_id_field
      "#{@new_object.class.name.underscore}_id".to_sym
    end

    def validate?
      !@skip_validations
    end

    def update_id_hash
      @id_hash[new_object_id_field] = @new_object.id
    end

    def remove_id_from_id_hash
      @id_hash.delete(new_object_id_field)
    end

    def execute
      implement_new_object_differences
      @new_object.save(:validate => validate?) && update_id_hash
      @duplicated_objects << @new_object
      associations.each do |association|
        objects = [@object_to_duplicate.send(association.name)].flatten.compact
        objects.each do |obj|
          # recursively create child objects and assign IDs
          Duplicate.create(obj, id_hash: id_hash, duplicated_objects: @duplicated_objects)
        end
      end
      # done with children - remove ID from ID hash
      remove_id_from_id_hash
      @duplicated_objects.first
    end

  end
end
