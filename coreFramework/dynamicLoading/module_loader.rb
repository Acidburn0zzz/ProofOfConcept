require 'delegate'
require 'thread'

class CopyPeste

  private

  def initialize
    @db_conn = Database::Connection.new
    @db_wrap = Database::Wrapper.new(@db_conn)
    test_impl # TEST
    nil
  end

  # TEST
  def test_impl
    mod = ModuleLoading::Loader.load("fake_module1.rb", @db_wrap)
    puts mod.name
    puts mod.usage
    puts mod.run
    mod.save_object
  end

  module Database
    class Connection; end
    class Wrapper
      def initialize(*args) end
      def save_object() puts "saved object in db" end # TEST
    end
  end

  module ModuleLoading
    class Loader
      # Turns a source file of an analysis module into a usable object
      #
      # @return [LoadedModule]
      #   instance of LoadedModule -(delegator of)- instance of LoadingModule
      #   instance of LoadingModule -(extends dynamic module)- -(delegator of)- db_wrap
      def self.load(path, db_wrap)
        (@@mutex ||= Mutex.new).lock

        @@loading_module = LoadingModule.new(db_wrap)
        self.instance_eval(File.read path)
        loaded_module = LoadedModule.new(@@loading_module)

        @@mutex.unlock
        loaded_module
      end

      def self.method_missing(meth, *args, &blk)
        self.new(meth).instance_eval &blk if block_given?
      end

      private

      def self.new(*args)
        super(*args)
      end

      def initialize(name)
        set_name { name }
        self
      end

      def set_impl(&block)
        @@loading_module.extend Module.new(&block)
      end

      def method_missing(meth, *args, &block)
        meth_suffix = meth.to_s.match(/^set_(.*)/)
        return super if meth_suffix.nil?
        meth_suffix = meth_suffix.captures.first
        @@loading_module.define_singleton_method(meth_suffix, &block)
      end

      module DSL
        def usage(&block) set_usage(&block) end
        def author(&block) set_author(&block) end
        def run(&block) set_run(&block) end
        def impl(&block) set_impl(&block) end
        def description(&block) set_description(&block) end
      end # !DSL

      include DSL
    end

    class LoadedModule < SimpleDelegator; end
    class LoadingModule < SimpleDelegator; end
  end

end

CopyPeste.new
