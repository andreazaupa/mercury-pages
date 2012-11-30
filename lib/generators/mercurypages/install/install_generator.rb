module Mercurypages
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def generate_models
      generate 'model', 'page_element name:string aasm_state:string priority:integer title:string description:string content:text'
      inject_into_file 'app/models/page_element.rb', :before => "end" do <<-RUBY
  include AASM
  aasm do
    state :draft, :initial => true
    state :online
    state :offline
  end

  default_scope order('priority')
  has_foreign_language :title, :description, :content
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
