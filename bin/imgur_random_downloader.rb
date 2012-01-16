######################################################
#   Imgur_random_downloader
#   
#   © KNowicki 2012
######################################################
# encoding: utf-8

require 'rubygems'
require "bundler/setup"
require 'open-uri'



#   Statistics for better randomization setup
class Stat
    def initialize
        @successes = 0
        @fails = 0
        @lengths = []
    end

    def add_success(length)
        @successes += 1
        @lengths << length
    end

    def add_fail
        @fails += 1
    end

    def get_result
        "Result: #{shots_accuracy}% of successful shots!
Average filename length: #{average_fname_length}"
    end

private
    def shots_accuracy
        ((@successes.to_f/(@fails + @successes))*100).round(3)
    end

    def average_fname_length
        if @lengths.count > 0
            sum = 0.0
            @lengths.each { |length| sum += length }
            return (sum / @lengths.count).round(2)
        else
            "_unknown_yet_"
        end
    end
end


#   Geting image and storing it in /download
#   use Benchmark class
class Agent
    attr_reader :stats

    def initialize
        @stats = Stat.new
    end

public
    def get_image(uri)
        begin
            res = open(uri)
            if res.size > 700
                open(make_name(uri, res.content_type), 'wb') { |file| file << res.read }
                @stats.add_success(exclude_pattern_ext(uri).length)
            else
                @stats.add_fail
            end
        rescue
            puts 'err.'
            @stats.add_fail
        end
    end

private
    def current_dir
        File.expand_path(__FILE__, Dir.getwd).gsub(/(bin)+(\/)(\w)+.(rb)$/,"")
    end

    def exclude_pattern_ext(uri)
        uri[/(\w)+.(\w){3}$/].gsub(/.(\w){3}$/, "" )
    end

    def get_original_ext(type)
        type.gsub(/^(\w)+(\/)/,"")
    end

    def make_name(uri, type)
        full_name = "#{exclude_pattern_ext(uri)}.#{get_original_ext(type)}"
        "#{current_dir}download/#{full_name}"
    end
end

#   Randomize uri. 
# Read benchmark stats for better parameters setup.
class Randomizer
    def initialize(base_uri = "http://i.imgur.com/")
        @base_uri = base_uri
        @r = Random.new
    end

    def randomize_uri
        str = random_str
        "#{@base_uri}#{str}.png"
    end

private
    def random_str
        signs =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten;
        string  =  (1..5).map{ signs[@r.rand(signs.length)]  }.join;
    end
end



#   Main loop
rand = Randomizer.new
agent = Agent.new

100.times do
    uri = rand.randomize_uri
    puts uri
    agent.get_image(uri)
end
puts agent.stats.get_result

