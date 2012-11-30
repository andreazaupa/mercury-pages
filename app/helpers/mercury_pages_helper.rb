module MercuryPagesHelper
  def editable_tag(*args, &block)
    options = args.extract_options!
    e = args[0]
    f = options[:field] || 'content'
    if e.is_a?(ActiveRecord::Base)
      name = "activerecord"
      options[:'data-activerecord-class'] = e.class.name
      options[:'data-activerecord-field'] = f
      options[:'data-activerecord-id'] = e.id
    else
      e = nil
      name = args[0] || "#{controller_name}-#{action_name}"
      name = "#{name}-#{options[:part]}" unless options[:part].blank?
    end
    name = "#{name}-editable"
    options[:id] ||= name
    options[:'data-mercury'] ||= 'full'

    e ||= PageElement.find_by_name(name)
    return if e.nil? && block.nil?

    content = e.nil? ? nil : e.send(f)
    tag_content = (e.nil? || content.blank?) && block ? capture(&block) : raw(content)
    if options[:'data-mercury'] == 'image'
      image_tag(content, options)
    else
      content_tag(:span, tag_content, options)
    end
  end

  def editable_link
    link_to(t(".mercury_pages_edit_link"), "/editor" + request.path, id: "mercury-pages-edit-link", data: { save_url: mercury_pages_update_path })
  end
end
