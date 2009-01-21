require 'csv'
require 'importer'

ActiveRecord::Base.send(:extend, Curve21::Importer)