module Curve21
  module Importer
    # Importer imports data from a CSV and creates record in the application database.
    #
    # = Basic importing
    #   Organisation.import(:from => '/path/to/file.csv')
    #     
    # This will extract data straight from the CSV
    #
    # = Importing from a stream
    # 
    # Importer will also take a raw StringIO from a form POST:
    #   Organisation.import(:from => params[:organisations])
    #
    # = CSV Columns
    #
    # If no columns are specified, Importer will use the first row as column names.
    # To set columns, you can use the columns option:
    #   Organisation.import(:from => '/path/to/file.csv', :columns => ['name','email'])
    #
    # = Column Name Mapping
    #
    # If you have a CSV with column names in the first row that do not correspond with your
    # database columns, you can map them with a hash:
    #   Organisation.import(:from => '/path/to/file.csv', :map => {'Org' => 'name', 'EMail' => 'email'})
    # 
    # This is particularly useful if your CSV is generated automatically from another system that you have no control over.
    #
    # = Associations
    # 
    # Take the row following for example:
    #   "Curve21","South-East England","www.curve21.com","info@curve21.com"
    #
    # 'South-East England' is this organisation's region.  If Organisation has_many :regions then we need
    # a way to look up the region in our database using the name specified in this row.  Importer achieves this
    # using Proc objects:
    #  
    #   Organisation.import(:from => '/path/to/file.csv', :map => {'region' => 'region_id'}, 
    #                               :associations => {'region_id' => lambda {|a| Region.find_by_name(a) } }
    #
    # Currently, this is only designed to support only belongs_to and has_one relationships.
    #
    # = Error handling
    #
    # Error handling uses logger at the moment and warns when an associated record was not found
    #
    #
    
    def import(options)
      if options[:from].is_a?(StringIO)
        csv_data = CSV::Reader.create(options[:from])
      else
        csv_data = CSV.open(options[:from], "r")
      end

      options[:columns] = csv_data.shift if !options[:columns]
    
      rows = []
    
      # loop each raw row
      csv_data.each do |csv_row|
   
        column_count = 0
        row = {}
    
        # loop columns
        options[:columns].each do |column|
        
          # perform any specified mappings
          if options[:map] && options[:map][column]
            column = options[:map][column]
          end
        
          # if this column is not ignored
          if !options[:ignore] || !options[:ignore].include?(column)
        
            # check for cross referenced columns
            if options[:associations] && options[:associations][column]
          
              # get and execute the cross reference proc
              cross_reference_method = options[:associations][column]
              referenced_object = cross_reference_method.call(csv_row[column_count])

              # assign or log error for referenced object
              if referenced_object
                row_value = referenced_object.id
              else
                # TODO: Should log error here
                logger.warn "#{column.humanize} was not found for '#{csv_row[column_count]}'"
              end
            else
              # assign the raw value
              row_value = csv_row[column_count]
            end
        
            # assign the determined row value to this row column
            row[column] = row_value
          end
          # move to the next column
          column_count += 1
        end

        # add row to rows array
        rows << row
      end
 
      create(rows)
    end
  end
end