require 'mustache'

module Ruploy
  DEFAULTS = {
    :name         => File.basename(File.expand_path '.'),
    :address      => '127.0.0.1',
    :port         => 3000,
    :directory    => File.expand_path('.'),
    :environment  => 'production',
    :log_file     => '/var/log/rack-$PROCNAME-$PORT.log',
    :pid_file     => '/var/lock/rack-$PROCNAME-$PORT',
    :user         => 'www-data',
    :dependencies => 'apache2',
    :server_type  => 'thin'
  }

  class << self
    def get_config(args, opts)
      config = DEFAULTS.merge(opts)

      unless opts[:use_defaults]
        config.merge! (config.keys - opts.keys).inject({}) { |h, key|
          h[key] = ask("#{key} ") { |q| q.default = DEFAULTS[key] }
          h
        }
      end

      config[:options]   = '--daemonize'
      config[:options]  << " #{args.join(' ')}" if args.any?
      config[:proc_name] = config[:name].gsub(/\W/, '_').squeeze('_').downcase

      return config
    end

    def generate_init_file(config, independant=false)
      ruploy_init  = File.expand_path('../../data/ruploy-init.mustache', __FILE__)
      ruploy_base  = File.expand_path('../../data/ruploy-base.sh', __FILE__)
      template     = File.read(ruploy_init)
      config       = config.dup

      config[:ruploy_base] = independant ? File.read(ruploy_base) : %Q(. "#{ruploy_base}")

      Mustache.render(template, config)
    end
  end
end
