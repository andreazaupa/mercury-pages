module Mercurypages
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def generate_models
      generate 'model', 'page_element name:string element_type:string title:string description:string content:text aasm_state:string priority:integer valid_from:datetime valid_until:datetime'
      inject_into_file 'app/models/page_element.rb', :before => "end" do <<-RUBY
  attr_accessible :aasm_state, :content, :description, :name, :priority, :title
  include AASM
  aasm do
    state :draft
    state :online, :initial => true
    state :offline
  end

  has_many :page_items
  scope :by_type, lambda { |t| where(:element_type => t) }
  scope :published, lambda { online.where('(page_elements.valid_from IS NULL OR page_elements.valid_from <= :now) AND (page_elements.valid_until IS NULL OR page_elements.valid_until >= :now)', :now => DateTime.now) }

  default_scope order('page_elements.priority, page_elements.id')
  has_foreign_language :title, :description, :content

  def aasm_state_enum
    PageElement.aasm_states_for_select
  end

  if defined? RailsAdmin
    rails_admin do
      list do
        field :name
        field :aasm_state
        field :title
      end
    end
  end
RUBY
      end

      generate 'model', 'page_item page_element:references item_id:integer item_type:string aasm_state:string priority:integer'
      inject_into_file 'app/models/page_item.rb', :before => "end" do <<-RUBY
  include AASM
  aasm do
    state :draft, :initial => true
    state :online
    state :offline
  end

  attr_accessible :page_element_id
  belongs_to :item, :polymorphic => true
  default_scope order('page_items.priority, page_items.id')

  def aasm_state_enum
    PageItem.aasm_states_for_select
  end
RUBY
      end
    end

    def generate_helpers
      inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base\n" do <<-RUBY
  include Mercury::Authentication
  helper_method :can_edit?
RUBY
      end
    end

    def generate_javascripts
      append_to_file 'app/assets/javascripts/mercury.js', <<-RUBY

jQuery(window).on('mercury:ready', function() { 
  var link = $('#mercury_iframe').contents().find('#mercury-pages-edit-link');
  var data = link.data('save-url')
  if(data) {
    Mercury.saveUrl = data;
    link.hide();
  }
});

jQuery(window).on('mercury:saved', function() { 
  window.location = window.location.href.replace(/\\/editor\\//i, '/');
});
RUBY
      gsub_file 'app/assets/javascripts/mercury.js', 'dataAttributes: []', "dataAttributes: ['activerecord-class', 'activerecord-field', 'activerecord-id']"
    end
  end
end
