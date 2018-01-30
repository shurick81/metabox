require 'logger'

module Metabox
    
    # adding custom log level - verbose
    # https://stackoverflow.com/questions/2281490/how-to-add-a-custom-log-level-to-logger-in-ruby
    class MetaboxLogger < Logger

        SEVS = %w(DEBUG INFO WARN ERROR FATAL VERBOSE)
        def format_severity(severity)
            SEVS[severity] || 'ANY'
        end
        
        def verbose(progname = nil, &block)
            add(5, nil, progname, &block)
        end
    end

    class LogService 

        @log 
        @@instance = nil

        @enabled;

        def name
            "log"
        end

        def initialize
            @enabled = true

            _init_logger
        end

        def enable
            @enabled = true
        end

        def disable
            @enabled = false
        end

        def enabled?
            @enabled == true
        end

        def disabled?
            !enabled?
        end

        def self.instance
            if(@@instance == nil)
                @@instance = ServiceContainer.new
            end

            return @@instance
        end

        def info(message)
            if disabled?
                return
            end

            if !["INFO", "DEBUG"].include? _get_log_level 
                return
            end

            @log.info(message)
        end

        def error(message)
            if disabled?
                return
            end
            
            @log.error(message)
        end

        def warn(message)
            if disabled?
                return
            end

            @log.warn(message)
        end

        def verbose(message)
            if disabled?
                return
            end

            if !["VERBOSE"].include? _get_log_level
                return
            end

            @log.verbose(message)
        end

        def debug(message)
            if disabled?
                return
            end

            if !["DEBUG", "VERBOSE"].include? _get_log_level
                return
            end

            # add one tab for a better debug message readability
            @log.debug("    #{message}")
        end

        private

        def _get_log_level
            _env.fetch('METABOX_LOG_LEVEL', 'INFO')
        end

        def _env
            ENV.to_h
        end

        def _get_color(severity:, message:)
            
            color = _white
        
            case severity
            when "INFO"
                color =  _green
            when "WARNING"
                color =  _yellow
            when "WARN"
                color =  _yellow
            when "DEBUG"
                color =  _light_blue
            when "ERROR"
                color =  _red
            when "VERBOSE"
                color =  _gray
            end

            return color
        end

        def _format_message(severity, datetime, progname, message)
            color_code = _get_color(severity: severity, message: message)
            "\e[#{color_code}m#{datetime} #{severity} #{message}\e[0m\n"
        end

        def _init_logger

            logger = MetaboxLogger.new(STDOUT)

            logger.formatter = proc do |severity, datetime, progname, message|
                _format_message(severity, datetime, progname, message)
            end

            @log = logger
        end

        def _white 
            37
        end
    
        def _red
            31
        end
    
        def _green
            32
        end
    
        def _yellow
            33
        end
    
        def _blue
            34
        end
    
        def _pink
            35
        end
    
        def _light_blue
            36
        end
    
        def _gray
            37
        end
    end

end
        