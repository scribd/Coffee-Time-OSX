#!/usr/bin/env ruby

require 'net/http'

latest_coffee = Net::HTTP.get(URI.parse("http://coffeetime.heroku.com/coffees"))
exit if latest_coffee == "No Coffee Yet"

name, time = latest_coffee.split(/\n/)
time = time.to_i

if Time.now.to_i - time < 32  then
  full_name = `dscl . -read /Users/#{ENV['USER']} RealName`.split(/\n\s?/).last
  if full_name != name then
    system "/Users/#{ENV['USER']}/Library/Application Support/Coffee Time/growlnotify", '-n', "Coffee Time".inspect,
           '-m', "#{name} says it's coffee time!",
           '-a', "Coffee Time",
           '-p', '1',
           '--sticky',
           '-d', 'ItsCoffeeTime',
           "It's Coffee Time!"
  end
end
