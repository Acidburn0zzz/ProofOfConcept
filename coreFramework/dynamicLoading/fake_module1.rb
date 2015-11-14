fakeModule1 do

  description {
    "This is a nice description of this fake module"
  }

  author { "Jean-Guillaume Buret" }

  usage { 'Just run it!' }

  run { SubClassInFakeModule1.new().hello }

  impl {
    class SubClassInFakeModule1
      def initialize(n = 'world')
        @name = n
      end
      def hello
        puts 'hello ' + @name
      end
    end

    class SubClassInFakeModule2
    end
  }

end