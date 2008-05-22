ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  
  cattr_accessor :classes_cache
  @@classes_cache = {}
  @@all_setup = false

  def setup_for_fixs
 	Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures/", "tournaments")
	ApplicationController.new.load_tournament_database(Tournament.find(:first, :order => 'id desc'))  	
	@@all_setup = true
  end
  
  def load_our_fixtures(*table_names)
  	if not @@all_setup
  		setup_for_fixs
  	end
  	
  	fixtures = {}
  	table_names = table_names.flatten.collect{|t| t.to_s}
  	table_names.each do |table_name|
  		unless @@classes_cache[table_name].nil?
  			klas = @@classes_cache[table_name]
  		else
  			begin
  				klas = eval(table_name.classify)
  			rescue 
  				classes = Dir.entries(RAILS_ROOT + "/app/models").select{|d| d.include? ".rb"}.collect{|f| File.basename(f, ".rb").classify}
  				klas_names = classes.select{|f| (eval("#{f}.table_name") rescue false) == table_name}
  				klas_name = klas_names.blank? ? table_name.classify : klas_names.first
  				klas = eval(klas_name)
  			end
  			@@classes_cache[table_name] = klas
  		end
  		fixtures[table_name] = Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures/", table_name, {table_name.to_sym => klas.name}){klas.connection}
  	end
  	fixtures.each_pair do |table_name, fixs|
  		Fixtures.instantiate_fixtures(self, table_name, fixs)
  	end	
  end
end

module ActionController::Assertions::ModelAssertions
	def assert_not_valid(record)
		clean_backtrace do 
			assert !(record.valid?), "Record should not be valid."
		end
	end
end
