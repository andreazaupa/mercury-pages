module Mercurypages
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def generate_models
      generate 'model', 'page_element name:string list_name:string item_id:integer item_type:string title:string description:string content:text aasm_state:string priority:integer valid_from:datetime valid_until:datetime'
      inject_into_file 'app/models/page_element.rb', :before => "end" do <<-RUBY

  include MercuryPages::ActsAsEditor

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
