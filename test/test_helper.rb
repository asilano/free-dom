ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'shoulda/rails'
require 'active_support/testing/pending'
#require File.dirname(__FILE__) + "/factories"  

class ActiveSupport::TestCase
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
  self.use_transactional_fixtures = true

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
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def todo
    flunk "test not written"
  end

  # This extension prints to the log before each test.  Makes it easier to find the test you're looking for
  # when looking through a long test log.
  setup :log_test

  # Method to create a game with players in a specified state of readiness
  def stub_game(start = :create_game, stop = :start_game)
    act = false
    
    act = true if start == :create_game
    
    if act
      @game = Factory(:fixed_game)
    end
    
    act = false if stop == :create_game
    act = true if start == :create_users
    
    if act
      @user_alan = Factory(:user)
      @user_bob = Factory(:user, :name => "Bob", :password => "b")
      @user_chas = Factory(:user, :name => "Chas", :password => "c")
      @users = User.all
    end
    
    act = false if stop == :create_users
    act = true if start == :create_players
    
    if act
      @ply_alan = Factory(:player, :user => @user_alan, :game => @game)
      @ply_bob = Factory(:player, :user => @user_bob, :game => @game)
      @ply_chas = Factory(:player, :user => @user_chas, :game => @game)
      @plys = Player.all
    end
    
    act = false if stop == :create_players
    act = true if start == :start_game
    
    if act
      qshuffle([[0,1,2], /start_game/, /player\.rb/])
      @game.players.reload
      @game.start_game
    end
  end
  
  # Method to check that pending actions are set up as expected.
  PA_Stub = Struct.new(:exp_re, :ply_id, :kids)
  
  def assert_pend_acts_like(pattern, actual)
    if pattern.is_a? String
      pattern.gsub!(/^(\s*)>/, "\\1- !ruby/struct:#{PA_Stub.name}")
      pattern.gsub!(/exp_re: /, 'exp_re: !ruby/regexp ')
      pattern = YAML.load(pattern)
    end
    
    if pattern.empty?
      assert_empty actual
      return
    end
    
    roots = actual.select {|pa| !actual.include?(pa.parent)}
    dupe = actual.map {|pa| PendingAction.new(pa.attributes)}
    
    roots.each do |pa|
      valid = false
      pattern.each do |stub|
        if (pa.expected_action =~ stub.exp_re &&
            pa.player_id == stub.ply_id)
          if stub.kids.blank? && pa.children.blank?
            valid = true
          elsif stub.kids.length == pa.children.length
            valid = assert_pend_acts_like(stub.kids, pa.children)
          end
        end
        if valid
          pattern.delete(stub)
          break
        end
      end
      
      assert valid, "expected actions do not match. Expected \n#{pattern.to_yaml}, got \n#{dupe.to_yaml}"
    end
    
    return true
  end
  
  def flatten_params(params, title = nil, result = {})
    params.each do |key, value|
      if value.kind_of?(Hash)
        key_name = title ? "#{title}[#{key}]" : key
        flatten_params(value, key_name, result)
      else
        key_name = title ? "#{title}[#{key}]" : key
        result[key_name] = value
      end
    end
  
    return result
  end
  
  def strip_pa_id(ctrl_hash)
    ctrl_hash.each {|k,v| v.each {|a| a.delete(:pa_id)}}
  end
  
  private

  def log_test
    #if Rails.logger
      # When I run tests in rake or autotest I see the same log message multiple times per test for some reason.
      # This guard prevents that.
    #  unless @already_logged_this_test
    #    Rails.logger.info "\n\nStarting #{@method_name}\n#{'-' * (9 + @method_name.length)}\n"
    #  end
    #  @already_logged_this_test = true
    #end
  end
end


unless Kernel.method_defined? :rand_with_predefined_values
  module Kernel
    @@rand_q = []
    
    def qrand(*queue)
      queue.each do |q|
        @@rand_q << Array(q)
      end
    end
    
    def rand_with_predefined_values(max=nil)
      if @@rand_q.empty?
        rand_without_predefined_values max
      else           
        qd = @@rand_q.shift
        if qd[1] || qd[2]
          bt = nil
          begin
            raise
          rescue Exception => e
            bt = e.backtrace.join('\n')
          end
          if (qd[1].nil? || (qd[1] && bt =~ qd[1])) &&
             (qd[2].nil? || (qd[2] && bt !~ qd[2]))
            return rand_without_predefined_values(max) if qd[0] == "?"
            return qd[0]
          else
            @@rand_q.unshift qd
            return rand_without_predefined_values max
          end
        else
          return rand_without_predefined_values(max) if qd[0] == "?"
          qd[0]
        end
      end
    end
    alias_method_chain :rand, :predefined_values
    
    @@shuffle_q = []
    
    def qshuffle(*queue)
      queue.each do |q| 
        if !q[0].kind_of?(Array) && q[0] != "?"
          q = [q]
        end
        @@shuffle_q << Array(q)
      end
    end  
  end
end

unless Array.method_defined? :shuffle_with_predefined_values
  class Array
    def shuffle_with_predefined_values
      if @@shuffle_q.empty?
        shuffle_without_predefined_values
      else
        qd = @@shuffle_q.shift
        if qd[1] || qd[2]
          bt = nil
          begin
            raise
          rescue Exception => e
            bt = e.backtrace.join(';')          
          end
          if (qd[1].nil? || (qd[1] && bt =~ qd[1])) &&
             (qd[2].nil? || (qd[2] && bt !~ qd[2]))
            return shuffle_without_predefined_values if qd[0] == "?"
            raise "length mismatch" if qd[0].length != length
            return qd[0].map {|ix| self[ix]}
          else
            @@shuffle_q.unshift qd
            return shuffle_without_predefined_values
          end
        else
        return shuffle_without_predefined_values if qd[0] == "?"
          return qd[0].map {|ix| self[ix]}
        end
      end
    end
    alias_method_chain :shuffle, :predefined_values
    
    def shuffle!
      self.replace shuffle
    end
  end
end