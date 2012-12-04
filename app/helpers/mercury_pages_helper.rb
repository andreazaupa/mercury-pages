module MercuryPagesHelper
  def editable_element(*args, &block)
    with_editable_object(*args) do |name, field, e, options|
      options[:id] ||= "#{name}#{MercuryPages::EDITABLE_SUFFIX}"
      options[:'data-mercury'] ||= 'full'
      options[:class] = options[:class].to_s + ' editable-element' if can_edit?

      unless e
        e = PageElement.find_by_name(name) # Find a Page Element unless bound to an AR model object
      end
      offline = e.respond_to?(:'published?') ? !e.published? : false
      return empty_editable_tag if offline || (e.nil? && block.nil?)

      content = e.nil? ? nil : e.send(field)
      tag_content = (e.nil? || content.blank?) && block ? capture(&block) : raw(content)
      if options[:'data-mercury'] == 'image'
        image_tag(tag_content, options)
      else
        content_tag(:span, tag_content, options)
      end
    end
  end

  def editable_list(*args)
    with_editable_object(*args) do |name, field, e, options|
      content = ''
      params = options.delete(:find) || {}
      params[:conditions] = (params[:conditions] || {}).merge(:list_name => name)
      PageElement.find(:all, params).each do |pe|
        if p = options[pe.item_type.underscore.pluralize.to_sym]
          content += render(:partial => p, :object => pe.item) if pe.item
        else
          content += render(:partial => e || 'page_element', :object => pe.item || pe)
        end
      end
      content_tag(:span, raw(content), :class => 'editable_list')
    end
  end

  def editor_tag
    link_to(t("mercury_pages.edit"), "/editor" + request.path, id: "mercury-pages-edit-link", class: 'mercury-pages-edit', data: { save_url: mercury_pages_update_path }) if can_edit?
  end

  def admin_tag(&block)
    content_tag(:span, class: 'mercury-pages-manage', &block) if can_edit?
  end

  def admin_path(*args)
    if args.nil?
      if defined? RailsAdmin
        rails_admin.dashboard_path
      end
    else
      with_editable_object(*args) do |name, field, e, options|
        action = options.delete(:action) || 'edit'
        e ||= PageElement.find_by_name(name)
        clazz = e ? e.class.name : name.to_s
        if defined? RailsAdmin
          names = clazz.split("::").map { |n| n.underscore }
          # modules = names[0..-2]
          # class_name = names[-1]
          full_name = names.join('~')
          case action
          when 'new'
            rails_admin.new_path(full_name, options.merge(clazz => {:list_name => options.delete(:list_name)}))
          when 'delete' then rails_admin.delete_path(full_name, e, options)
          else
            rails_admin.edit_path(full_name, e, options)
          end
        end
      end
    end
  end

  private

  def with_editable_object(*args)
    args ||= []
    options = args.extract_options!
    e = args[0]
    field = options[:field] || 'content'
    if e.is_a?(ActiveRecord::Base)
      name = "activerecord-#{e.class.name.underscore}-#{e.id}-#{field}"
      options[:'data-activerecord-class'] = e.class.name
      options[:'data-activerecord-id'] = e.id
    else
      e = nil
      name = args[0] || "#{controller_name}-#{action_name}"
    end
    options[:'data-activerecord-field'] = field if field != 'content'
    name = "#{name}-#{options[:part]}" unless options[:part].blank?
    yield name, field, e, options
  end

  def empty_editable_tag
    content_tag(:span, nil, :class => 'mercury-pages-empty')
  end
end
