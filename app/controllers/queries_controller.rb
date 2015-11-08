class QueriesController < ApplicationController

  def index
    q = params[:query]
    #render json: "Searching for #{q}"

    @drug = Drug.where(name: q.upcase).first
    @drug = Drug.where(["drugs.name LIKE ?", "%#{q}%"]).first if @drug.nil?

    # First look for drugs
    if @drug
      render json: {
        type: 'drug',
        name: @drug.name,
        dose: @drug.dose_parsed,
        cautions: @drug.cautions_parsed,
        age_limit: @drug.age_limit,
        elderly: @drug.elderly
      }
    else

      # Check for medical conditions and return guidance if available
      @condition = Condition.where(name: q.upcase).first
      @condition = Condition.where(["conditions.name LIKE ?", "%#{q}%"]).first if @condition.nil?

      if @condition && @condition.guideline
        render json: {
          type: 'condition',
          name: @condition.name,
          title: @condition.guideline[:title],
          url: @condition.guideline[:url]
        }
      else
        render nothing: true
      end
    end
  end

end
