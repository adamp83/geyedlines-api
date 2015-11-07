class Drug < ActiveRecord::Base

  def dose_parsed
    return "" if self.dose.blank?

    # Remove whitespace etc.
    html = HTMLEntities.new.decode(self.dose[5..-1].strip).squish

    # Remove parentheses and contents
    #html = html.gsub(/\s*\(.+\)/, "").squish
    html = remove_brackets(html)

    # Replace common things with medical abbreviations
    html = html.gsub("By mouth,", "PO")
    html = html.gsub("By rectum,", "PR")
    html = html.gsub("intramuscular", "IM")
    html = html.gsub("intravenous", "IV")

    html = html.gsub(" micrograms", "mcg")
    html = html.gsub(" mg", "mg")
    html = html.gsub(" g ", "g ")

    html = html.gsub("once daily", "OD")
    html = html.gsub("when necessary", "PRN")
    html = html.gsub(" hours", "h")
    html = html.gsub(" weeks", "wks")
    html = html.gsub(" days", "d")
    html = html.gsub("; child under 16 years not recommended", "")

    html = html.gsub(/\s*child under 18 years see bnf for children/, "")
    html = html.gsub("Adult over 18 years, ","")

    html = html.gsub(" ;",";")
    html = html.strip

    # Specific drugs
    html = html.gsub("; child 2 months 60mg for post-immunisation pyrexia, repeated once after 4–6h if necessary; otherwise under 3 months see bnf for children; 3–6 months 60mg, 6 months–2 years 120mg, 2–4 years 180mg, 4–6 years 240mg, 6–8 years 240–250mg, 8–10 years 360–375mg, 10–12 years 480–500mg, 12–16 years 480–750mg; these doses may be repeated every 4–6h PRN  By IV infusion over 15 minutes, adult and child over 50 kg, 1g every 4–6h, max. 4g daily; adult and child 10–50 kg, 15mg/kg every 4–6h, max. 60mg/kg daily; neonate and child less than 10 kg see bnf for children PR adult and child over 12 years 0.5–1g every 4–6h to a max. of 4g daily; child under 3 months see bnf for children, 3 months–1 year 60–125mg, 1–5 years 125–250mg, 5–12 years 250–500mg; these doses may be repeated every 4–6h as necessary  For full joint committee on vaccination and immunisation recommendation on post-immunisation pyrexia, see section 14.1", "")

    html
  end

  def cautions_parsed
    return "" if self.cautions.blank?

    html = HTMLEntities.new.decode(self.cautions[9..-1].strip).squish
    html = html.gsub("Cautions", "").squish
    html = remove_brackets(html)

    html = html.gsub(" ;",";")
    html = html.strip
    #html = html.gsub(/\s*\(.+\)/, "").squish


    html
  end

  # Add a flag for drugs with an age limit e.g. don't use in under 16
  def age_limit
    str = /child under 16 years not recommended/
    if dose.match(str) || cautions.match(str)
      return 16
    else
      return nil
    end
  end

  # # Match the cautions to ICD10 codes and get rid of everything else
  # def check_icd10
  #   icd10 = File.open("#{Rails.root}/public/icd10.txt")
  #   #icd10s = icd10.collect{|a| HTMLEntities.new.decode(a).squish.split(" ")[1..-1].join(' ')}
  #   icd10s = icd10.collect{|a| a.to_s}# a.squish.split(" ")[1..-1].join(' ')}
  #
  #   cs = []
  #   icd10s.each do |code|
  #     begin
  #       if self.cautions.downcase.match(ERB::Util.url_encode(code.downcase))
  #         cs << code
  #       end
  #     rescue
  #     end
  #   end
  #   cs
  # end

  


  private
  def remove_brackets(string)
    x = string.dup
    while x.gsub!(/\([^()]*\)/,""); end
    x
  end



end
