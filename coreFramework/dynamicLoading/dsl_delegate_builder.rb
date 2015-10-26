require 'delegate'

module DSL
  def build(*args, &block)
    base = self.new(*args, &block)
    delegator_klass = self.const_get("DSLDelegator")
    delegator = delegator_klass.new(base)
    delegator.instance_eval(&block)
    base
  end

  def dsl(&block)
    delegator_klass = Class.new(SimpleDelegator, &block)
    self.const_set("DSLDelegator", delegator_klass)
  end
end

class ModuleLoader

  def self.new(db)
    @@instance ||= super(db)
  end

  def self.new!(db)
    @@instance = super(db)
  end

  def initialize(db)
    @db = db
  end

  # open source file and build its source code
  def load(path, *options)
  end

  # build source code
  def build(code)
    @loaded_module = ModuleBuilder.instance_eval code #{ @db }
  end

  private

  class ModuleBuilder
    extend DSL

    def self.method_missing(m, *args, &block)
      self.build(m, *args, &block).build
    end

    def initialize(name)
      @name = name
      self
    end

    def build
      LoadedModule.new(@name, @usage, @author, @desc, @run).extend (@module || Module.new)
    end

    def set_usage(&b) end
    def set_author(&b) @author = b end
    def set_run(&b) @run = b end
    def set_impl(&b)
      puts "set_impl called"
      # @module.module_exec $c
      # @module.module_exec b.call
      @module = Module.new &b # not tested yet
      @impl = b
    end
    def set_desc(&b) @desc = b end

    dsl do
      def usage(&block) self.set_usage &block end
      def author(&block) self.set_author &block end
      def run(&block) self.set_run &block end
      def impl(&block) self.set_impl &block end
      def description(&block) self.set_desc &block end
    end

  end # !ModuleBuilder

  class LoadedModule
    def initialize(name, usage, author, desc, run, impl = nil)
      methods_naming = "__cp_%{arg}"
      ["name", "usage", "author", "desc", "run"].each do |arg|
        method_name = methods_naming % {arg: arg}
        cur_var = binding.local_variable_get(arg)
        arg_is_block = cur_var.respond_to? :call
        puts "creating method: #{method_name}"
        if arg_is_block
          self.define_singleton_method(method_name, cur_var)
        else
          self.define_singleton_method(method_name) do cur_var end
        end
      end # !each
      self
    end # !initialize

    # i can get this delegator out of this class
    # i can make this class create the methods in several
    #   steps, not like the initilize methodo of its actual
    #   outer class
    # class LoadedModuleInformationsDelegator < SimpleDelegator
    # end

    # same for the db_conn
    # db_conn = Struct.new(:ip, :port).new("0.0.0.0", "42")
  end # !LoadedModule

end

## testing
fakeModule1 =
"fakeModule1 do
  description {
    \"This is a nice description of this fake module\"
  }
  author { \"Jean-Guillaume Buret\" }
  usage { 'Just run it!' }
  run { SubClassInFakeModule1.new }
  impl {
    class SubClassInFakeModule1
        def initialize
          puts 'hello world (self.class.name)'
        end
      end

    class SubClassInFakeModule2
    end
  }
end"
db_conn = Struct.new(:ip, :port).new("0.0.0.0", "42")
f_m1 = ModuleLoader.new(db_conn).build(fakeModule1)
puts f_m1.__cp_name
f_m1.__cp_run
