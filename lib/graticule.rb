
$:.unshift(File.dirname(__FILE__))      

require 'active_support' 

require 'graticule/location'
require 'graticule/geocoder'
require 'graticule/geocoders/bogus'
require 'graticule/geocoders/rest'
require 'graticule/geocoders/google'
require 'graticule/geocoders/yahoo'
require 'graticule/geocoders/geocoder_us'
require 'graticule/geocoders/meta_carta'