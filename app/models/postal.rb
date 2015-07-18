require 'CSV'

class Postal < ActiveRecord::Base
  belongs_to :pref
  belongs_to :city

  def self.import
    self.import_postals
    self.import_kokuseis
  end

  def self.import_postals
    file_path = './tmp/KEN_ALL.csv'

    open(file_path, 'r:cp932:utf-8', undef: :replace) do |f|
      csv = CSV.new(f, :headers => :first_row)
      csv.each do |row|
        next if row.header_row?

        table = Hash[[row.headers, row.fields].transpose]

        postal = Postal.find_or_create_by(code: table['code'])
        postal.pref = Pref.find_or_create_by(name: table['pref'])
        postal.city = City.find_or_create_by(name: table['city'])
        postal.city.pref = postal.pref
        postal.city.save!
        postal.lot = table['lot']
        1.upto(6).each do |i|
          postal.send("flag#{i}=", table["flag#{i}"])
        end
        postal.save!
      end
    end
    return 'done'
  end

  def self.import_kokuseis
    file_path = './tmp/001.csv'

    pref_names = Pref.all.map{|pref| pref.name}

    open(file_path, 'r:cp932:utf-8', undef: :replace) do |f|
      csv = CSV.new(f, :headers => :first_row)
      csv.each do |row|

        table = Hash[[row.headers, row.fields].transpose]
        address = table['address']

        puts address

        next if address.match(/^全国/)
        if pref_names.include?(address)
          @pref = Pref.find_by(name: address)
          @pref.population2005 = table['population2005']
          @pref.population2010 = table['population2010']
          @pref.size = table['size']
          @pref.save!
        else
          address = address.gsub(@pref.name, '').gsub(' ', '')
          if @city = City.find_by(name: address, pref_id: @pref.id)
            @city.population2005 = table['population2005']
            @city.population2010 = table['population2010']
            @city.size = table['size']
            @city.save!
          else
            puts address
          end
        end
      end
    end
    return 'done'
  end
end

