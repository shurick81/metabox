require 'objspace'
require 'yaml'
require 'json'
require "pp"

require_relative "metabox/version"

METABOX_ROOT = "#{File.dirname(__FILE__)}"

def _include_files(files, is_debug = false) 
  files.each do | file |
    
    file_path = "#{File.dirname(__FILE__)}/#{file}"

    if is_debug
      puts "  - including service file: #{file_path}"
    end

    require file_path
  end
end

def _include_folder_services(folders, is_debug = false) 
  folders.each do | folder |
    # include all 'common' halpers
    Dir.glob("#{File.dirname(__FILE__)}/#{folder}/**/*.rb").each { |file|
      
      if is_debug
        puts "  - including service file: #{file}"
      end

      require file
    }
  end
end

_include_folder_services [ "common" ]

_include_files [ 
  "services/service_container.rb",
  "services/service_base.rb"
]

_include_folder_services [ "documents", "services" ]

module Metabox
  
  class ApiClient < ServiceBase
    
    @os_service = nil
    @task_services = nil

    def initialize
      super

      _init_services
      _init_task_services

      log.info "Initialized Metabox API client"
    end

    def welcome_message
        log.info "Running metabox (beta) with ENV variables:"
        
        env_vars = env_service.get_metabox_variables(raise_on_missing_vars: false)
        env_vars.each { | name, value |
          tmp_value = value

          if name.downcase.include?("key") || name.downcase.include?("password")
            tmp_value = "****************"
          end

          log.debug "#{name}=#{tmp_value}"
        }

        log.info "Running metabox (beta) with params:"
        
        ARGV.each do |a|
          log.debug "#{a}"
        end
    
        log.info "ENV['OS']: #{ENV['OS']}, windows?: #{@os_service.is_windows?}"
    end

    def execute_task(task_name:, params:)
      log.info "Executing Task: [#{task_name}] with params: #{params}"

      task_parts = task_name.split(':')

      service_name = task_parts[0]
      task_name = task_parts[1]

      service = @task_services[service_name]
     
      service.send(task_name, params) 
    end

    def configure_vagrant(config:)
      begin
        vagrant_config_service = get_service_by_name("metabox::vagrant::config::base")
        vagrant_config_service.configure_vagrant_config(config: config)
      rescue => exception 
        log.error "Error while configuring Metabox"
        log.error "#{exception}"

        raise exception
      end
    end

    private 

    def _get_document_service
      Metabox::ServiceContainer.instance.get_service_by_name("metabox::tasks:document")
    end 

    def _init_services
      @os_service = Metabox::ServiceContainer.instance.get_service_by_name("os")
    end

    def _init_task_services
      @task_services = {}

      services = get_services(Metabox::TaskServiceBase)

      services.each do | service |
        log.verbose "Regestering task service: #{service.name} -> #{service.rake_alias}"
        @task_services[service.rake_alias] = service
      end
   
    end

  end

end
