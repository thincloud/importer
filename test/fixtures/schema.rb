ActiveRecord::Schema.define do
  create_table :organisations, :force => true do |t|
    t.column "name",           :string
    t.column "telephone",      :string
    t.column "fax",            :string
    t.column "email",          :string
    t.column "website",        :string
    t.column "information",    :text
    t.column "area_id",        :integer
  end
  
  create_table :areas, :force => true do |t|
    t.column "name", :string
  end
end
