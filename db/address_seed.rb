# encoding: utf-8
require 'rubygems'
require 'csv'
require 'nokogiri'
require_relative '../app/controllers/lib/constants'
require_relative '../app/controllers/lib/string'
require_relative '../app/controllers/lib/search'
require '../config/environment'

# Algorithm for importing Tbilisi Addresses #
#
# First, notes
### 1) everything in this file is in tbilisi, so location is established
### 2) all addresses will be IDed according to an existing street in the database, anything that doesn't
####   match a street in the DB will not be added, but we should log and see why
### 3) remember to look for streets, if I hit a locale then it's not a proper match - would be nice to
####   run more precise request (ie with street type etc.)
#
#
# Steps
### 1) 

logFile = File.new("address_seed_log.txt", "w")

for_the_record = Hash.new

street_name = ''
####################################
# Load the Address Points from CSV #
####################################
csvFile = "seed_data/address_points_tbilisi.csv"
@results = CSV.read(csvFile)
@results.shift
puts "Loading Address Points..."
temp = 0
temp2 = []
@results.each do |r|
  logFile.syswrite("#{r[0]}.....                                 ")
  #puts r[1]
  #puts r[2]
  #puts r[20]
  #puts r[21]

  puts ""
  street_name = r[0].georgianize.latinize.georgian_morph('extended') unless r[0] == nil  ## need to review translit/morphing next...
  street_type = r[1]
  street_number = r[2]
  street_lon = r[20]
  street_lat = r[21]

  for_the_record[street_name] = Array.new unless for_the_record.has_key?(street_name)

  if street_name.is_roman_numeral?
    logFile.syswrite(" ---- not added because its a roman numeral\n")
    next
  end

  hit = precision_search('street' => street_name, 'street_type' => street_type, 'settlement' => 'Tbilisi')

  if hit.class == Street && hit
    newAddress = Address.new
    newAddress.number = street_number
    newAddress.lon = street_lon
    newAddress.lat = street_lat
    if newAddress.save
      puts "SUCCESSFULLY ADDED #{street_number} to #{hit.full_name_en}"
      hit.addresses << newAddress
      logFile.syswrite("Street: #{hit.full_name_en}, #{hit.settlement.name_en} ---- added address to DB\n")

      for_the_record[street_name] << street_number

    else
      logFile.syswrite("Problem saving address\n")
    end
  elsif hit.class == Settlement && hit
    logFile.syswrite("Settlement: #{hit.name_en}\n")
  else
    logFile.syswrite("No Matches\n")
  end


  hit = nil
  street_name = ''

  logFile2 = File.new("address_seed_log2.txt", "w")
  for_the_record.each do |k,v|
    logFile2.syswrite("#{k} has addresses ")
    v.each do |a|
      logFile2.syswrite("#{a}, ")
    end
    logFile2.syswrite("\n")
  end
  logFile2.close

  #temp += 1
  #break if temp > 1
  temp2 << r[0] unless temp2.include?(r[0])
  #newRegion = Region.new(:name_en => r[1], :name_ka => r[0].force_encoding("UTF-8"), :lat => Float(r[3]), :lon => Float(r[2]))
  #newRegion.save unless Region.find_by_name_en(r[1])
end
logFile.close
puts temp2.count







