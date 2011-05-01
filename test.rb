    class SuperKlass  
      def self.exec_later(&block)
        @@block_for_later = block
      end

      def exec_now
        return unless @@block_for_later
        puts "Binding: #{@@block_for_later.binding}"
        instance_eval( &@@block_for_later )
      end
    end

    class ChildKlass < SuperKlass
      exec_later do
        child_method
      end

      def child_method
        puts "Child method called"
      end
    end

    test_klass = ChildKlass.new
    test_klass.exec_now
