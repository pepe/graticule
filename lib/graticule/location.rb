module Graticule
  
  # A geographic location
  class Location
    attr_accessor :latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision, :warning
    alias_method :city, :locality
    alias_method :state, :region
    alias_method :zip, :postal_code
    
    # if latitude is string both latitude and longitude are converted to float
    def initialize(attrs = {})
      attrs = parse_strings(attrs) if attrs[:latitude].is_a? String
      attrs.each do |key,value|
        instance_variable_set "@#{key}", value
      end
      self.precision ||= :unknown
    end
    
    def attributes
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision].inject({}) do |result,attr|
        result[attr] = self.send(attr) unless self.send(attr).blank?
        result
      end
    end
    
    def blank?
      attributes.except(:precision).empty?
    end
    
    # Returns an Array with latitude and longitude.
    def coordinates
      [latitude, longitude]
    end
    
    def ==(other)
      other.respond_to?(:attributes) ? attributes == other.attributes : false
    end
    
    # Calculate the distance to another location.  See the various Distance formulas
    # for more information
    def distance_to(destination, options = {})
      options = {:formula => :haversine, :units => :miles}.merge(options)
      "Graticule::Distance::#{options[:formula].to_s.titleize}".constantize.distance(self, destination, options[:units])
    end
    
    # Where would I be if I dug through the center of the earth?
    def antipode
      Location.new :latitude => -latitude, :longitude => longitude + (longitude >= 0 ? -180 : 180)
    end
    alias_method :antipodal_location, :antipode
    
    def to_s(options = {})
      options = {:coordinates => false, :country => true}.merge(options)
      result = ""
      result << "#{street}\n" if street
      result << [locality, [region, postal_code].compact.join(" ")].compact.join(", ")
      result << " #{country}" if options[:country] && country
      result << "\nlatitude: #{latitude}, longitude: #{longitude}" if options[:coordinates] && [latitude, longitude].any?
      result
    end

    private 
    # parses string latitude to float
    def parse_strings(attrs)
      [:latitude, :longitude].each do |sym|
        attrs[sym] = degree_to_float(attrs[sym])
      end
      return attrs
    end

    # parses string in degrees, minutes and seconds to int
    def degree_to_float(str)
      data = str.match(/(\d{1,2})°(\d{1,2})'(\d{1,2}.\d{1,3})"([N|S|E|W])/)
      raise 'Bad format' unless data
      res = data[1].to_i + (data[2].to_f * 1/60.0) + (data[3].to_f * 1/3600)
      res = -res if data[4].match(/S|W/)
      res = ((res * 1e5).round)/1e5 # round it to 5 places
      return res
    end
    
  end
end
