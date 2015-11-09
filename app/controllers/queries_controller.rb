require 'open-uri'
class QueriesController < ApplicationController

  # If needed, allow people to request keywords
  def keywords
    get_keywords
    render json: @keywords
  end

  def index
    begin

      # Query from Glass
      q = params[:query]
      puts "Q=#{q}"

      # Drug only!
      # results = AlchemyAPI.search(:entity_extraction, text: q)
      # puts results
      # results = results.select{|a| a['type'] == 'Drug'}
      # qs = results.collect{|a| a['text']}

      results = AlchemyAPI.search(:keyword_extraction, text: q)
      puts(results)
      qs = results.collect{|a| a['text']}

      # For now just use the first one...
      q = qs.first

      puts("Parsed Q=#{q}")

      # Pick out keywords from query
      get_keywords
      q = @keywords.detect{|a| a.upcase == q.upcase}
      q = @keywords.detect{|a| a.upcase.match(q.upcase)} if q.nil?

      # Look for user-defined prompts
      @prompt = UserPrompt.where(["lower(keyword) = ?", q.downcase]).first
      if @prompt
        render json: {
          type: 'prompt',
          title: @prompt.keyword,
          body: @prompt.body
        }
      else
        # Look for drugs/conditions etc.
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
    rescue
      render nothing: true
    end

  end

  private
  def get_keywords
    @keywords = Drug.all.collect{|a| a.name.upcase} +
      Condition.all.collect{|a| a.name.upcase} +
      UserPrompt.all.collect{|a| a.keyword}
  end

end




      # Identify keywords from Alchemy API
      #alchemy_url = "http://gateway-a.watsonplatform.net/calls/text/TextGetRankedNamedEntities?apikey=0ff972c7d8e641817b6cdc9d080198b08fad43b9&text=#{ERB::Util.url_encode(q)}&outputMode=json"
      #alchemy_url = "http://gateway-a.watsonplatform.net/calls/text/TextGetRankedNamedEntities?apikey=0ff972c7d8e641817b6cdc9d080198b08fad43b9&text=#{ERB::Util.url_encode(q)}&outputMode=json"
      #puts open(alchemy_url)
      #json = JSON.load(open(alchemy_url))
      #puts json

      # url = URI.parse(alchemy_url)
      # req = Net::HTTP::Get.new(url.to_s)
      # res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
      # puts res.body
