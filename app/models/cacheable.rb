# $Id: cacheable.rb 30 2008-01-24 23:22:27Z kvasir-gsm $

module Cacheable

  module ClassMethods
    def serializes_result_of(*methods)
      @@serialization_column ||= :stats
      serialize @@serialization_column
      for method_name in methods
        create_caching_advice(method_name,@@serialization_column)
      end
    end
    
    def caches_result_of(*methods)
      attr_accessor :cache
      for method_name in methods
        create_caching_advice(method_name,:cache)
      end
    end
    
    def serializes_results_in(column)
      @@serialization_column = column
    end
    
    def create_caching_advice(method_name,column_name)
      old_method_name = "#{method_name}_not_cached"
      alias_method old_method_name,method_name
      
      new_method = Proc.new do |arg|
        column_hash = self[column_name]
        if (column_hash.nil?)
          column_hash = Hash.new
          self[column_name] = column_hash
        end

        if (column_hash[method_name].nil?)
          column_hash[method_name] = Hash.new
        end
        
        newArg = argOrZero(arg)
        if (column_hash[method_name][newArg].nil?)
          column_hash[method_name][newArg] = method(old_method_name).call(arg)
          @changed = true
        end

        column_hash[method_name][newArg]
      end
      
      define_method(method_name,new_method)
    end
  end

  def self.included(in_class)
    in_class.extend(ClassMethods)
  end
  
  def save_if_changed
    save if @changed
  end
  
  def bid(bracket=nil)
    if bracket.nil? then 0
    else bracket.id
    end
  end

  def argOrZero(arg=nil)
    arg.nil? ? 0 : arg
  end
  
end
