class MercuryPagesController < ApplicationController

  def update
    errors = nil
    if params[:content]
      params[:content].keys.each do |name|
        ar_class = params[:content][name][:data][:'activerecord-class'] rescue nil
        ar_field = params[:content][name][:data][:'activerecord-field'] rescue nil
        ar_id = params[:content][name][:data][:'activerecord-id'] rescue nil
        if params[:content][name][:type] == 'image'
          content = params[:content][name][:attributes][:src]
        else
          content = params[:content][name][:value]
        end
        if ar_class && ar_field && ar_id
          @element = ar_class.constantize.find(ar_id)
          @element.send("#{ar_field}=", content)
        else
          @element = PageElement.where(:name => name).first || PageElement.new(:name => name)
          @element.content = content
        end
        @element.save
        errors = @element.errors
      end
    end
    respond_to do |format|
      format.json do
        if errors.empty?
          head :no_content
        else
          render json: errors, status: :unprocessable_entity
        end
      end
    end    
  end
end
