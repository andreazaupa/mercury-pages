module PagesHelper
  def with_template(t)
    yield
    render :template => t
  end
end
