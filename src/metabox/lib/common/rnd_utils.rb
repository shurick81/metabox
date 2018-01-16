
class RndUtils

    def self.get_random_string
        (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    end
    
end