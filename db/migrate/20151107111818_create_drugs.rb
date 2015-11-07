require 'open-uri'
class CreateDrugs < ActiveRecord::Migration
  def change
    create_table :drugs do |t|
      t.string :name, :code
      t.text :data, :dose, :cautions
      t.boolean :elderly, default: false
      t.timestamps null: false
    end

    # Load data from json
    file = File.read("#{Rails.root}/public/bnfcodes.json")
    json = JSON.parse(file)
    json.each do |item|
      begin
        html = open("http://www.openbnf.org/result/#{ERB::Util.url_encode(item['name'])}")
        html_doc = Nokogiri::HTML(html.read)
        html_doc.encoding = 'utf-8'
        dose = html_doc.css('h2').detect{|a| a.text == 'Dose'}.parent.text
        cautions = html_doc.css('h2').detect{|a| a.text == 'Cautions'}.parent.text

        dose = dose[5..-1].gsub("\n        ", "").strip
        cautions = cautions[9..-1].gsub("\n        ", "").strip
      rescue
        html_doc = ""
        dose = ""
        cautions = ""
      end
      Drug.create!(
        name: item["name"],
        code: item["code"],
        data: html_doc,
        dose: dose,
        cautions: cautions
      )
    end

    # Now check for the 'elderly' attribute
    elderly = File.open("#{Rails.root}/public/elderly.txt")
    elderly = elderly.read.split("\r").collect{|a| a.upcase}

    elderly.each do |e|
      Drug.where(name: e).all.each{|a| a.update_attribute(:elderly, true)}
    end
  end
end
