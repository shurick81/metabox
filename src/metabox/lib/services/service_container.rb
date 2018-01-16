require 'logger'

# include all 'base services'
Dir.glob("#{File.dirname(__FILE__)}/**/*service_base.rb").each { |file|
  require file
}

# include all 'services'
Dir.glob("#{File.dirname(__FILE__)}/**/*_service.rb").each { |file|
  require file
}

module Metabox
    
    class ServiceContainer

        @services
        @@instance = nil
       
        def initialize
            @services = {}
            _init_services(services: @services)
        end

        def self.instance
            if(@@instance == nil)
                @@instance = ServiceContainer.new
            end

            return @@instance
        end

        def register_service(service_type, service_instance)
            @services[service_type] = service_instance
        end

        def get_service_by_name(service_name)
            result =  nil

            @services.each { | key, value | 
                if(value.name == service_name)
                    result = value
                end
            }

            if result == nil 
                raise "Can't find service instance for requested name: #{service_name}"
            end

            result
        end

        def get_service(service_type)

            result =  @services.fetch(service_type, nil)

            if result == nil 
                raise "Can't find service instance for requested type: #{service_type}"
            end

            result
           
        end

        def get_services(service_type)

            result = []

            @services.each { | service, impl |
                if service <= service_type
                    result << impl
                end
            }

            result
        end

        private 

        def _init_services(services:)
            service_classes = _load_classes(parent_class: Metabox::ServiceBase)
           
            service_classes.each do | service_class |
              
                if service_class == Metabox::ApiClient || service_class == Metabox::ServiceContainer 
                    next
                end

                service_instance = service_class.new
                services[service_class] = service_instance
            end

            # register log class manually
            # circular dependency with other services
            services[Metabox::LogService] = LogService.new
        end

        def _load_classes(parent_class:)
            ObjectSpaceUtils.load_metabox_classes(parent_class: parent_class)
        end

    end
end