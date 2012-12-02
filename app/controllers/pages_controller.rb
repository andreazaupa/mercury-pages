class PagesController < ApplicationController
  layout :pages_layout
  helper_method :page_name

  def page_name
    "pages/#{params[:id]}".split('/').join('-')
  end

  def show
    render_page_template(params[:id])
  end

  def method_missing(m, *args, &block)
    render_page_template(m)
  end

  private

  def render_page_template(path)
    t = "pages/#{path}"
    begin
      render :template => t
    rescue ActionView::MissingTemplate => e
      raise Rails.env.development? ? e : ActionController::RoutingError.new(t)
    end    
  end

  def pages_layout
    if params[:layout] == 'false'
      false
    elsif params[:layout].present?
      params[:layout]
    else
      'application'
    end
  end
end
