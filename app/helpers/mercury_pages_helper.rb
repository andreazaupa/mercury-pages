module MercuryPagesHelper
  def one_editable_element(*args, &block)
    with_editable_object(*args) do |name, field, e, options|
      options[:id] ||= name
      options[:'data-mercury'] ||= 'full'
      options[:class] = options[:class].to_s + ' editable_element'

      unless e
        e = PageElement.find_by_name(name) # Find a Page Element unless bound to an AR model object
      end
      return empty_editable_tag if (e && !e.online?) || (e.nil? && block.nil?)

      content = e.nil? ? nil : e.send(field)
      tag_content = (e.nil? || content.blank?) && block ? capture(&block) : raw(content)
      if options[:'data-mercury'] == 'image'
        image_tag(content, options)
      else
        content_tag(:span, tag_content, options)
      end
    end
  end

  def many_editable_elements(*args, &block)
    with_editable_object(*args) do |name, field, e, options|
      e = PageElement.find_or_create_by_name(name)
      return empty_editable_tag unless e.online?

      content = ''
      PageItem.find(:all, :conditions => {:page_element_id => e}.merge(options)).each do |i|
        if p = options[i.item_type.underscore.pluralize.to_sym]
          content += render(:partial => p, :object => i.item)
        end
      end
      raw content
    end
  end

  def editor_tag
    link_to(t("mercury_pages.edit"), "/editor" + request.path, id: "mercury-pages-edit-link", class: 'mercury-pages-edit', data: { save_url: mercury_pages_update_path }) if can_edit?
  end

  def admin_tag(*args)
    link_to(t('mercury_pages.manage'), admin_path(*args), class: 'mercury-pages-manage') if can_edit?
  end

  def admin_path(*args)
    if args.nil?
      if defined? RailsAdmin
        rails_admin.dashboard_path
      end
    else
      with_editable_object(*args) do |name, field, e, options|
        if e
          # Bound to an AR model object
          if defined? RailsAdmin
            names = e.class.name.split("::").map { |n| n.underscore }
            # modules = names[0..-2]
            # class_name = names[-1]
            rails_admin.edit_path(names.join('~'), e)
          end
        else
          if defined? RailsAdmin
            rails_admin.edit_path('page_element', PageElement.find_by_name(name))
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
    name = "#{name}-editable"
    yield name, field, e, options
  end

  def empty_editable_tag
    content_tag(:span, nil, :class => 'mercury-pages-empty')
  end
end
