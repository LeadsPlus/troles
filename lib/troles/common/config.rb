module Troles::Common
  class Config
    autoload_modules :ValidRoles, :StaticRoles, :Schema, :SchemaHelpers, :ClassMethods

    def self.sub_modules
      [:valid_roles, :static_roles, :schema]
    end

    # include sub-modules as needed
    sub_modules.each do |name|    
      send :include, "Troles::Common::Config::#{name.to_s.camelize}".constantize
    end

    attr_accessor :subject_class, :strategy, :log_on, :generic
    attr_writer   :orm

    # configure Config object with subject class and various options
    def initialize subject_class, options = {}
      raise ArgumentError, "The first argument must be the Class which is the subject of the behavior" unless subject_class.is_a?(Class)
      @subject_class = subject_class

      apply_options! options
    end

    extend ClassMethods

    # Call setter for each key/value pair
    def apply_options! options = {}
      options.each_pair do |key, value| 
        send("#{key}=", value) if self.respond_to?(:"#{key}=")
      end      
    end

    # Configure subject with behavior
    # First apply any remaining options needed
    # Then configure models if configured to do do
    def configure! options = {}
      apply_options! options
      configure_models if auto_config?(:models)
    end

    # is logging on?
    def log_on?
      log_on || Troles::Config.log_on
    end

    # get the auto configuration settings hash
    def auto_config
      @auto_config ||= {}
    end 

    # is a certain type of auto configuration enabled?
    def auto_config? name
      return auto_config[name] if !auto_config[name].nil?
      Troles::Config.auto_config?(name)
    end

    # Get the main field name that is used for the behavior added, fx :troles for roles behavior
    def main_field
      @main_field ||= begin
        default_main_field
      end
    end
    alias_method :role_field, :main_field

    # Set the main field of the behavior
    def main_field= field_name
      name = field_name.to_s.alpha_numeric.to_sym
      raise ArgumentException, "Not a valid field name: #{field_name}"  if !valid_field_name?(name)
      @main_field ||= name
    end
    alias_method :role_field=, :main_field=

    # get the default name of the main field
    # for roles, it depends on the singularity (one or many) of the strategy
    # see (#singularity)
    def default_main_field
      @default_main_field ||= (singularity == :many) ? :troles : :trole
    end
    alias_method :default_role_field, :default_main_field

    # get the orm name
    def orm
      @orm || self.class.default_orm
    end

    # get the singularity (one or many) of the strategy
    def singularity
      @singularity ||= (strategy =~ /_many$/) ? :many : :one
    end

    # is it a generic strategy/orm ?
    def generic?
      return true if orm.nil? || orm == :generic
      @generic.nil? ? false : @generic
    end
  end
end