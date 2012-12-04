module MercuryPages
  module ActsAsEditor
    extend ActiveSupport::Concern
 
    included do
      include AASM
      aasm do
        state :draft
        state :online, :initial => true
        state :offline
      end

      belongs_to :item, :polymorphic => true
      attr_accessible :item, :id, :created_at, :updated_at

      scope :by_type, lambda { |t| where(:item_type => t) }
      scope :by_list, lambda { |l| where(:list_name => l) }
      scope :valid, lambda { where('(page_elements.valid_from IS NULL OR page_elements.valid_from <= :now) AND (page_elements.valid_until IS NULL OR page_elements.valid_until >= :now)', :now => DateTime.now) }
      scope :published, online.valid
      default_scope order('page_elements.priority, page_elements.id')

      has_foreign_language :title, :description, :content

      if defined? RailsAdmin
        rails_admin do
          configure :list_name, :hidden
        end
      end
    end
 
    module ClassMethods
    end

    def published?
      if item && item.respond_to?(:published)
        item.published?
      else
        now = DateTime.now
        online? && (valid_from.nil? || valid_from <= now) && (valid_until.nil? || valid_until >= D.now)
      end
    end

    def aasm_state_enum
      PageElement.aasm_states_for_select
    end

    def partial_enum
      item && item.respond_to?(:partial_enum) ? item.partial_enum : []
    end

    def to_s
      content
    end

    def method_missing(m, *args, &block)
      if item
        item.send(m, *args, &block)
      else
        super
      end
    end
  end
end
