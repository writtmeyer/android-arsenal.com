require 'sinatra'
require 'yaml'
require 'set'

set :public_folder, 'public'

class Data
    @@pcount = 0
    @@categories = Hash.new { |h, k| h[k] = [] }
    
    def self.pcount
        @@pcount
    end

    def self.categories
        @@categories
    end
    
    def self.init
        if @@pcount == 0
            data = YAML.load_file("projects.yml")['categories']
            data.each do |d|
                d['name'].split(',').each do |c|
                    projects = d['projects']
                    @@pcount += projects.size
                    @@categories[c.strip].concat(projects)
                end
            end
        end
    end
end

class Application < Sinatra::Base
    @@index = nil
    
    configure do
        use Rack::Deflater
    end
 
    not_found do
        erb :not_found
    end

    get "/" do
        if @@index.nil?
            Data::init
            @categories = Data::categories
            @pcount = Data::pcount
            @@index = erb :index
        end
        @@index
    end
    
end
