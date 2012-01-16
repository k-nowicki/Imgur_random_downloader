######################################################
#   Imgur_random_downloader
#   
#   © KNowicki 2012
######################################################


# encoding: utf-8

require 'rubygems'
require "bundler/setup"
require 'mechanize'
require "timeout"
require 'open-uri'


######################################################
#   Benchmark
#   Statistics for better randomization options
######################################################

class Benchmark    
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


######################################################
#   Agent
#   Geting image and storing it in /download
#   using Benchmark class
######################################################

class Agent
    attr_reader :benchmark

    def initialize
        @agent = Mechanize.new
        @benchmark = Benchmark.new
    end

private
    def current_dir
        File.expand_path(__FILE__, Dir.getwd).gsub(/(bin)+(\/)(\w)+.(rb)$/,"")
    end

    def recognize_origin_ext(uri)   #ext mean extension
        @agent.get(uri).response["content-type"].gsub(/^(\w)+(\/)/,"")
    end

    def fname_exclude_ext(uri)      #ext mean extension
        uri[/(\w)+.(\w){3}$/].gsub(/.(\w){3}$/, "" )
    end

    def make_name(uri)
        "#{current_dir}download/#{fname_exclude_ext(uri)}.#{recognize_origin_ext(uri)}"
    end

public
    def get_image(uri)
        begin
            content = open(uri)
            if content.size > 700
                open(make_name(uri), 'wb') { |file| file << content.read }
                @benchmark.add_success(fname_exclude_ext(uri).length)
            else
                @benchmark.add_fail
            end
        rescue
            puts 'err.'
            @benchmark.add_fail
        end
    end
end

######################################################
#   Randomizer
#   Randomize uri. Read benchmark stats for better 
#                  parameters setup.
######################################################

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




######################################################
#
#   Main loop
######################################################


rand = Randomizer.new
agent = Agent.new

1000.times do
    uri = rand.randomize_uri
    puts uri
    agent.get_image(uri)
    puts agent.benchmark.get_result
end

