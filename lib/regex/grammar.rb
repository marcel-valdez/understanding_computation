require_relative './pattern.rb'
require 'treetop'

dir = File.dirname(__FILE__)

Treetop.load(dir + '/grammar')