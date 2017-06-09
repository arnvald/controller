require 'hanami/utils/class_attribute'
require 'hanami/action'
require 'hanami/controller/configuration'
require 'hanami/controller/version'
require 'hanami/controller/error'

# Hanami
#
# @since 0.1.0
module Hanami
  # A set of logically grouped actions
  #
  # @since 0.1.0
  #
  # @see Hanami::Action
  #
  # @example
  #   require 'hanami/controller'
  #
  #   module Articles
  #     class Index
  #       include Hanami::Action
  #
  #       # ...
  #     end
  #
  #     class Show
  #       include Hanami::Action
  #
  #       # ...
  #     end
  #   end
  module Controller
    # Unknown format error
    #
    # This error is raised when a action sets a format that it isn't recognized
    # both by `Hanami::Controller::Configuration` and the list of Rack mime types
    #
    # @since 0.2.0
    #
    # @see Hanami::Action::Mime#format=
    class UnknownFormatError < Hanami::Controller::Error
      # @since 0.2.0
      # @api private
      def initialize(format)
        super("Cannot find a corresponding Mime type for '#{ format }'. Please configure it with Hanami::Controller::Configuration#format.")
      end
    end

    include Utils::ClassAttribute

    # Framework configuration
    #
    # @since 0.2.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.2.0
    #
    # @see Hanami::Controller::Configuration
    #
    # @example
    #   require 'hanami/controller'
    #
    #   Hanami::Controller.configure do
    #     handle_exceptions false
    #   end
    def self.configure
      yield configuration
    end

    # Duplicate Hanami::Controller in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Hanami::Controller
    #
    # @since 0.2.0
    # @api private
    #
    # @example Basic usage
    #   require 'hanami/controller'
    #
    #   module MyApp
    #     Controller = Hanami::Controller.dupe
    #   end
    #
    #   MyApp::Controller == Hanami::Controller # => false
    #
    #   MyApp::Controller.configuration ==
    #     Hanami::Controller.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'hanami/controller'
    #
    #   Hanami::Controller.configure do
    #     handle_exceptions false
    #   end
    #
    #   module MyApp
    #     Controller = Hanami::Controller.dupe
    #   end
    #
    #   module MyApi
    #     Controller = Hanami::Controller.dupe
    #     Controller.configure do
    #       handle_exceptions true
    #     end
    #   end
    #
    #   Hanami::Controller.configuration.handle_exceptions # => false
    #   MyApp::Controller.configuration.handle_exceptions # => false
    #   MyApi::Controller.configuration.handle_exceptions # => true
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # Framework loading entry point
    #
    # @return [void]
    #
    # @since 0.3.0
    def self.load!
      configuration.load!
    end
  end
end
