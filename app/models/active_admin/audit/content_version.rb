module ActiveAdmin
  module Audit
    class ContentVersion < PaperTrail::Version
      serialize :object, coder: VersionSnapshot
      serialize :object_changes, coder: VersionSnapshot

      serialize :additional_objects, coder: VersionSnapshot
      serialize :additional_objects_changes, coder: VersionSnapshot

      def self.ransackable_associations(auth_object = nil)
        []
      end

      def self.ransackable_attributes(auth_object = nil)
        ['additional_objects','additional_objects_changes','created_at','event','id','id_value','item_id','item_type','object','object_changes','whodunnit',]
      end

      def object_changes
        ignore = %w(id created_at updated_at)
        super.reject { |k, _| ignore.include?(k) }
      end

      def object_snapshot
        object.materialize(item_class)
      end

      def additional_objects_snapshot
        additional_objects.materialize(item_class)
      end

      def object_snapshot_changes
        object_changes.materialize(item_class)
      end

      def additional_objects_snapshot_changes
        additional_objects_changes.materialize(item_class)
      end

      def who
        Audit.configuration.user_class_name.to_s.classify.constantize.find_by(id: whodunnit)
      end

      def item_class
        item_type.constantize
      rescue NameError
        ActiveRecord::Base
      end

      def item
        super
      rescue NameError
        nil
      end
    end
  end
end
