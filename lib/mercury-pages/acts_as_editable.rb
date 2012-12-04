module MercuryPages
  module ActsAsEditable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def acts_as_editable(options = {})
        attr_accessor :list_name
        attr_accessible :id, :created_at, :updated_at, :list_name, :item, :page_element_ids
        has_many :page_elements, :as => :item

        after_create do |i|
          if i.list_name.present?
            PageElement.create(:name => "#{i.list_name}-#{self.class.name.underscore}-#{i.id}", :list_name => i.list_name, :item => self)
          end
        end

        if defined? RailsAdmin
          rails_admin do
            configure :list_name, :hidden
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, MercuryPages::ActsAsEditable
