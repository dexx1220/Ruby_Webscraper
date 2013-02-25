require 'nokogiri'
require 'open-uri'

page_url = "http://toronto.en.craigslist.ca/apa/"
page = Nokogiri::HTML(open(page_url))
link = page.css('body.toc blockquote#toc_rows p.row a')
rate = page.css('body.toc blockquote#toc_rows p.row span.itemph')
place = page.css('body.toc blockquote#toc_rows p.row span.itempn font')
$postings = []

#Put listings data into an array to be used later
link.each_with_index do |i, idx|
  temp_arr = []
  temp_arr << i.text if i.text != nil
  temp_arr << rate[idx].text if rate[idx] != nil
  temp_arr << place[idx].text if place[idx] != nil
  $postings << temp_arr 
end

#Method to list the apartments in a cleaner/neater way
def list_apt(arr)
  for i in (0...arr.length)
    puts "#{i+1}. #{arr[i][0]}"
    puts arr[i][1]
    puts arr[i][2]
    puts ""
  end
end

#Method to find highest-priced apartment(s)
def highest_price
  has_price = 0
  has_price = $postings.select{|p| p[1][/(?<=\$)\d+/].to_i >= 1}
  pricy_post = has_price.max {|a,b| a[1][/(?<=\$)\d+/].to_i <=> b[1][/(?<=\$)\d+/].to_i}
  pricy_price = pricy_post[1][/(?<=\$)\d+/].to_i
  pricy_ads = has_price.select{|i| i[1][/(?<=\$)\d+/].to_i == pricy_price}
  list_apt(pricy_ads)
end

#Method to find lowest-priced apartment(s)
def lowest_price
  has_price = 0
  has_price = $postings.select{|p| p[1][/(?<=\$)\d+/].to_i >= 1}
  cheap_post = has_price.min {|a,b| a[1][/(?<=\$)\d+/].to_i <=> b[1][/(?<=\$)\d+/].to_i}
  cheap_price = cheap_post[1][/(?<=\$)\d+/].to_i
  cheap_ads = has_price.select{|i| i[1][/(?<=\$)\d+/].to_i == cheap_price}
  list_apt(cheap_ads)
end

#Method to find apartment(s) with largest sqft.
def biggest_area
  max_post = 0
  max_post = $postings.max {|a,b| a[1][/\d+(?=ft)/].to_i <=> b[1][/\d+(?=ft)/].to_i}
  max_area = max_post[1][/\d+(?=ft)/].to_i
  max_ads = $postings.select{|p| p[1][/\d+(?=ft)/].to_i == max_area}
  list_apt(max_ads)
end

#Method to find apartment(s) with smallest sqft.
def smallest_area
  has_area = 0
  has_area = $postings.select{|p| p[1][/\d+(?=ft)/].to_i >= 1}
  tiny_post = has_area.min{|a,b| a[1][/\d+(?=ft)/].to_i <=> b[1][/\d+(?=ft)/].to_i}
  tiny_area = tiny_post[1][/\d+(?=ft)/].to_i
  tiny_ads = has_area.select{|i| i[1][/\d+(?=ft)/].to_i == tiny_area}
  list_apt(tiny_ads)
end

#Method to find apartment(s) with most rooms
def most_rooms
  has_info = 0
  has_info = $postings.select{|p| p.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/]}
  max_post = has_info.max{|a,b| a.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i <=> b.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i}
  max_room = max_post.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i
  max_room_ads = has_info.select{|p| p.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i == max_room}
  list_apt(max_room_ads)
end

#Method to find apartment(s) with least rooms
def least_rooms
  has_info = 0
  has_info = $postings.select{|p| p.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/]}
  min_post = has_info.min{|a,b| a.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i <=> b.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i}
  min_room = min_post.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i
  min_room_ads = has_info.select{|p| p.to_s.downcase[/\d+(?=bedroom)|\d+(?=br)/].to_i == min_room}
  list_apt(min_room_ads)
end

#Apartment search method that accepts the following optional parameters:
# 1) p_cap (price cap) 2) p_floor (price floor) 3) r_cap (cap the max number of rooms)
# 4) r_floor (minimum number of rooms) 5) a_cap (cap the max sqft) 
# 6) a_floor (minimum sqft required)
# For example, find_apt(p_cap: 2000, r_floor: 2, a_floor: 1000) will search for
# apartments that have max price of $2000, minimum of 2 rooms, and minimum of
# 1000 sqft.
def find_apt(options = {})
  ads = $postings
  options.each do |k,v|
    case k
    when :p_cap
      ads = ads.select{|i| i[1][/(?<=\$)\d+/].to_i <= v}
    when :p_floor
      ads = ads.select{|i| i[1][/(?<=\$)\d+/].to_i >= v}
    when :r_cap
      ads = ads.select{|i| i.to_s.downcase[/\d+(?=br)|\d+(?=bedroom)/].to_i <= v}
    when :r_floor
      ads = ads.select{|i| i.to_s.downcase[/\d+(?=br)|\d+(?=bedroom)/].to_i >= v}
    when :a_cap
      ads = ads.select{|i| i[1][/\d+(?=ft)/].to_i <= v}
    when :a_floor
      ads = ads.select{|i| i[1][/\d+(?=ft)/].to_i >= v}
    else
      puts "#{k} is not in options list"
    end
  end
  list_apt(ads)
end

find_apt(p_cap: 2000, r_floor: 2, a_floor: 1000)