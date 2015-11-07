class QueriesController < ApplicationController

  def index
    q = params[:query]
    #render json: "Searching for #{q}"

    @drug = Drug.where(name: q.upcase).first
    @drug = Drug.where(["drugs.name LIKE ?", "%#{q}%"]).first if @drug.nil?

    if @drug
      render json: {
        type: 'drug',
        name: @drug.name,
        dose: @drug.dose_parsed,
        cautions: @drug.cautions_parsed,
        age_limit: @drug.age_limit
      }
    else
      render nothing: true
    end
  end

end
