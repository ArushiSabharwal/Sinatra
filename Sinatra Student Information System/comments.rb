require 'dm-timestamps'
# require 'dm-core'
# require 'dm-migrations'
#DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/hw3.db")

class Comment
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  property :comment, Text, :required => true
  property :created_at, DateTime
end

DataMapper.finalize
