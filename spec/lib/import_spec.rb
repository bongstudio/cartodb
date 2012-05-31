# coding: UTF-8

require 'spec_helper'

describe CartoDB::Importer do
  
    context "import tables from files" do
        context "csv standard tests" do
          it "should import file twitters.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/twitters.csv"
            table.save.reload
            table.name.should match(/^twitters/)
            table.rows_counted.should == 7

            check_schema(table, [
              [:cartodb_id, "integer"], [:url, "text"], [:login, "text"], 
              [:country, "text"], [:followers_count, "text"],  
              [:created_at, "timestamp without time zone"], [:updated_at, "timestamp without time zone"],
              [:the_geom, "geometry", "geometry", "point"]
            ])
            row = table.records[:rows][0]
            row[:url].should == "http://twitter.com/vzlaturistica/statuses/23424668752936961"
            row[:login].should == "vzlaturistica "
            row[:country].should == " Venezuela "
            row[:followers_count].should == "211"
          end
          it "should import ngoaidmap_projects.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/ngoaidmap_projects.csv"
            table.save
            table.reload
            table.name.should == 'ngoaidmap_projects'
            table.rows_counted.should == 1864
          end
          it "should import and then export file twitters.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/twitters.csv"
            table.save.reload
            table.name.should match(/^twitters/)
            table.rows_counted.should == 7
    
            # write CSV to tempfile and read it back
            csv_content = nil
            zip = table.to_csv
            file = Tempfile.new('zip')
            File.open(file,'w+') { |f| f.write(zip) }
    
            Zip::ZipFile.foreach(file) do |entry|
              entry.name.should == "twitters_export.csv"
              csv_content = entry.get_input_stream.read
            end
            file.close
    
            # parse constructed CSV and test
            parsed = CSV.parse(csv_content)
            parsed[0].should == ["cartodb_id", "country", "followers_count", "login", "url", "created_at", "updated_at", "the_geom"]
            parsed[1].first.should == "1"
          end
          it "should import file import_csv_1.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/import_csv_1.csv"
            table.save
            table.reload
            table.name.should == 'import_csv_1'

            table.rows_counted.should == 100
            row = table.records[:rows][6]
            row[:cartodb_id] == 6
            row[:id].should == "6"
            row[:name_of_species].should == "Laetmonice producta 6"
            row[:kingdom].should == "Animalia"
            row[:family].should == "Aphroditidae"
            row[:lat].should == "0.2"
            row[:lon].should == "2.8"
            row[:views].should == "540"
          end
          it "should import file import_csv_2.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/import_csv_2.csv"
            table.save
            table.reload
            table.name.should == 'import_csv_2'

            table.rows_counted.should == 100
            row = table.records[:rows][6]
            row[:cartodb_id] == 6
            row[:id].should == "6"
            row[:name_of_species].should == "Laetmonice producta 6"
            row[:kingdom].should == "Animalia"
            row[:family].should == "Aphroditidae"
            row[:lat].should == "0.2"
            row[:lon].should == "2.8"
            row[:views].should == "540"
          end
          it "should import file flights-bad-encoding.csv" do
            table = new_table
            table.import_from_file = "#{Rails.root}/db/fake_data/flights-bad-encoding.csv"
            table.save
    
            table.rows_counted.should == 791
            row = table.record(1)
            row[:vuelo].should == "A31762"
          end
          it "should handle an empty file empty_file.csv" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "empty_table"
            table.import_from_file = "#{Rails.root}/db/fake_data/empty_file.csv"
            lambda {
              table.save
            }.should raise_error
    
            tables = user.run_query("select relname from pg_stat_user_tables WHERE schemaname='public'")
            tables[:rows].should_not include({:relname => "empty_table"})
          end
          # It has strange line breaks
          it "should import file arrivals_BCN.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/arrivals_BCN.csv"
            table.save
            table.reload
            table.name.should == 'arrivals_bcn'
            table.rows_counted.should == 3855
          end
          it "should import file clubbing.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/clubbing.csv"
            table.save
            table.reload
            table.name.should == 'clubbing'
            table.rows_counted.should == 1998
          end

          it "should import file short_clubbing.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/short_clubbing.csv"
            table.save
            table.reload
            table.name.should == 'short_clubbing'
            table.rows_counted.should == 78
          end
  
          it "should import ngos_aidmaps.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/ngos_aidmaps.csv"
            table.save
            table.reload
            table.name.should == 'ngos_aidmaps'
            table.rows_counted.should == 85
          end

          it "should import estaciones.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/estaciones.csv"
            table.save
            table.reload
            table.name.should == 'estaciones'
            table.rows_counted.should == 30
          end
  
          it "should import estaciones2.csv" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/estaciones2.csv"
            table.save
            table.reload
            table.name.should == 'estaciones2'
            table.rows_counted.should == 30
          end

          it "should import CSV file csv_no_quotes.csv" do
            user = create_user
            table = new_table :name => nil, :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/csv_no_quotes.csv"
            table.save.reload
    
            table.name.should == 'csv_no_quotes'
            table.rows_counted.should == 8406    
          end
  
          it "should import a CSV file with a the_geom column in GeoJSON format" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/cp_vizzuality_export.csv"
            table.save
        
            table.rows_counted.should == 19235
          end
  
        end
        context "xls standard tests" do
          it "should import file ngos.xlsx" do
            user = create_user
            table = new_table :name => nil
            table.user_id = user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/ngos.xlsx"
            table.save
            table.reload
            table.name.should == 'ngos'

            check_schema(table, [
              [:cartodb_id, "integer"], [:organization, "text"], [:website, "text"], [:about, "text"],
              [:organization_s_work_in_haiti, "text"], [:calculation_of_number_of_people_reached, "text"],
              [:private_funding, "text"], [:relief, "text"], [:reconstruction, "text"],
              [:private_funding_spent, "text"], [:spent_on_relief, "text"], [:spent_on_reconstruction, "text"],
              [:usg_funding, "text"], [:usg_funding_spent, "text"], [:other_funding, "text"], [:other_funding_spent, "text"],
              [:international_staff, "text"], [:national_staff, "text"], [:us_contact_name, "text"], [:us_contact_title, "text"],
              [:us_contact_phone, "text"], [:us_contact_e_mail, "text"], [:media_contact_name, "text"],
              [:media_contact_title, "text"], [:media_contact_phone, "text"], [:media_contact_e_mail, "text"],
              [:donation_phone_number, "text"], [:donation_address_line_1, "text"], [:address_line_2, "text"],
              [:city, "text"], [:state, "text"], [:zip_code, "text"], [:donation_website, "text"], 
              [:created_at, "timestamp without time zone"], [:updated_at, "timestamp without time zone"],
              [:the_geom, "geometry", "geometry", "point"]
            ])
            table.rows_counted.should == 76
          end
        end
        context "shp standard tests" do
          it "should import SHP1.zip" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/SHP1.zip"
            #table.importing_encoding = 'LATIN1'
            table.save
    
            table.name.should == "esp_adm1"
          end
        end
        context "osm standard tests" do
          it "should import guinea.osm.bz2" do
            table = new_table :name => nil
            #table.import_from_file = "#{Rails.root}/db/fake_data/EjemploVizzuality.zip"
            table.import_from_file = "#{Rails.root}/db/fake_data/guinea.osm.bz2"
            table.save
            table.rows_counted.should == 308
            table.name.should == "vizzuality"
          end
        end
        context "import exceptions tests" do
          it "should import reserved_names.csv" do
            user = create_user
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/reserved_names.csv"
            table.save.reload
    
            table.name.should == 'reserved_names'
            table.rows_counted.should == 2
          end
          it "should import a CSV file with a column named cartodb_id" do
            user = create_user
            table = new_table :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/gadm4_export.csv"
            table.save.reload
            check_schema(table, [
              [:cartodb_id, "number"], [:id_0, "string"], [:iso, "string"], 
              [:name_0, "string"], [:id_1, "string"], [:name_1, "string"], [:id_2, "string"], 
              [:name_2, "string"], [:id_3, "string"], [:name_3, "string"], [:id_4, "string"], 
              [:name_4, "string"], [:varname_4, "string"], [:type_4, "string"], [:engtype_4, "string"], 
              [:validfr_4, "string"], [:validto_4, "string"], [:remarks_4, "string"], [:shape_leng, "string"], 
              [:shape_area, "string"], [:latitude, "string"], [:longitude, "string"], [:center_latitude, "string"], 
              [:the_geom, "geometry", "geometry", "point"], [:center_longitude, "string"], 
              [:created_at, "date"], [:updated_at, "date"]
            ], :cartodb_types => true)
          end
        end
        context "post import processing tests" do
          it "should add a point the_geom column after importing a CSV" do
            table = new_table :name => nil
            table.import_from_file = "#{Rails.root}/db/fake_data/twitters.csv"
            table.save.reload
            table.name.should match(/^twitters/)
            table.rows_counted.should == 7
            check_schema(table, [
              [:cartodb_id, "integer"], [:url, "text"], [:login, "text"], 
              [:country, "text"], [:followers_count, "text"], [:field_5, "text"], 
              [:created_at, "timestamp without time zone"], [:updated_at, "timestamp without time zone"], [:the_geom, "geometry", "geometry", "point"]
            ])
    
            row = table.records[:rows][0]
            row[:url].should == "http://twitter.com/vzlaturistica/statuses/23424668752936961"
            row[:login].should == "vzlaturistica "
            row[:country].should == " Venezuela "
            row[:followers_count].should == "211"
          end

          it "should not drop a table that exists when upload fails" do
            user = create_user
            table = new_table :name => 'empty_file', :user_id => user.id
            table.save.reload
            table.name.should == 'empty_file'
    
            table2 = new_table :name => nil, :user_id => user.id
            table2.import_from_file = "#{Rails.root}/db/fake_data/empty_file.csv"
            lambda {
              table2.save
            }.should raise_error
    
            user.in_database do |user_database|
              user_database.table_exists?(table.name.to_sym).should be_true
            end
          end

          it "should not drop a table that exists when upload does not fail" do
            user = create_user
            table = new_table :name => 'empty_file', :user_id => user.id
            table.save.reload
            table.name.should == 'empty_file'
    
            table2 = new_table :name => 'empty_file', :user_id => user.id
            table2.import_from_file = "#{Rails.root}/db/fake_data/csv_no_quotes.csv"
            table2.save.reload
            table2.name.should == 'csv_no_quotes'
    
            user.in_database do |user_database|
              user_database.table_exists?(table.name.to_sym).should be_true
              user_database.table_exists?(table2.name.to_sym).should be_true
            end
          end

          it "should remove the user_table even when phisical table does not exist" do
            user = create_user
            table = new_table :name => 'empty_file', :user_id => user.id
            table.save.reload
            table.name.should == 'empty_file'

            user.in_database do |user_database|
              user_database.drop_table(table.name.to_sym)
            end
    
            table.destroy
            Table[table.id].should be_nil
          end
  
          # Not supported by cartodb-importer v0.2.1
          pending "should escape reserved column names" do
            user = create_user
            table = new_table :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/reserved_columns.csv"
            table.save.reload
    
            table.schema.should include([:_xmin, "number"])
          end

          it "should raise an error when creating a column with reserved name" do
            table = create_table
            lambda {
              table.add_column!(:name => "xmin", :type => "number")
            }.should raise_error(CartoDB::InvalidColumnName)
          end

          it "should raise an error when renaming a column with reserved name" do 
            table = create_table
            lambda {
              table.modify_column!(:old_name => "name", :new_name => "xmin")
            }.should raise_error(CartoDB::InvalidColumnName)
          end
      
          it "should add a cartodb_id serial column as primary key when importing a file without a column with name cartodb_id" do
            user = create_user
            table = new_table :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/gadm4_export.csv"
            table.save.reload
            user = User.select(:id,:database_name,:crypted_password).filter(:id => table.user_id).first
            table_schema = user.in_database.schema(table.name)
    
            cartodb_id_schema = table_schema.detect {|s| s[0].to_s == "cartodb_id"}
            cartodb_id_schema.should be_present
            cartodb_id_schema = cartodb_id_schema[1]
            cartodb_id_schema[:db_type].should == "integer"
            cartodb_id_schema[:default].should == "nextval('#{table.name}_cartodb_id_seq'::regclass)"
            cartodb_id_schema[:primary_key].should == true
            cartodb_id_schema[:allow_null].should == false
          end
  
          it "should copy cartodb_id values to a new cartodb_id serial column when importing a file which already has a cartodb_id column" do
            user = create_user
            table = new_table :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/with_cartodb_id.csv"
            table.save.reload
    
            check_schema(table, [
              [:cartodb_id, "number"], [:name, "string"], [:the_geom, "geometry", "geometry", "point"], 
              [:invalid_the_geom, "string"], [:created_at, "date"], [:updated_at, "date"]
            ], :cartodb_types => true)
    
            user = User.select(:id,:database_name,:crypted_password).filter(:id => table.user_id).first
            table_schema = user.in_database.schema(table.name)
            cartodb_id_schema = table_schema.detect {|s| s[0].to_s == "cartodb_id"}
            cartodb_id_schema.should be_present
            cartodb_id_schema = cartodb_id_schema[1]
            cartodb_id_schema[:db_type].should == "integer"
            cartodb_id_schema[:default].should == "nextval('#{table.name}_cartodb_id_seq'::regclass)"
            cartodb_id_schema[:primary_key].should == true
            cartodb_id_schema[:allow_null].should == false
    
            # CSV has this data:
            # 3,Row 3,2011-08-29 16:18:37.114106,2011-08-29 16:19:07.61527,
            # 5,Row 5,2011-08-29 16:18:37.114106,2011-08-29 16:19:16.216058,
            # 7,Row 7,2011-08-29 16:18:37.114106,2011-08-29 16:19:31.380103,
    
            # cartodb_id values should be preserved
            rows = table.records(:order_by => "cartodb_id", :mode => "asc")[:rows]
            rows.size.should == 3
            rows[0][:cartodb_id].should == 3
            rows[0][:name].should == "Row 3"
            rows[1][:cartodb_id].should == 5
            rows[1][:name].should == "Row 5"
            rows[2][:cartodb_id].should == 7
            rows[2][:name].should == "Row 7"
    
            table.insert_row!(:name => "Row 8")
            rows = table.records(:order_by => "cartodb_id", :mode => "asc")[:rows]
            rows.size.should == 4
            rows.last[:cartodb_id].should == 8
            rows.last[:name].should == "Row 8"
          end
  
          it "should make sure it converts created_at and updated at to date types when importing from CSV" do
            user = create_user
            table = new_table :user_id => user.id
            table.import_from_file = "#{Rails.root}/db/fake_data/gadm4_export.csv"
            table.save.reload
            schema = table.schema(:cartodb_types => true)
            schema.include?([:updated_at, "date"]).should == true
            schema.include?([:created_at, "date"]).should == true
          end  
          it "should normalize strings if there is a non-convertible entry when converting string to number" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "elecciones2008"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_string_to_number.csv"
            table.save    

            table.modify_column! :name=>"f1", :type=>"number", :old_name=>"f1", :new_name=>nil
    
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == 1
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == 2
            table.sequel.select(:f1).where(:test_id => '3').first[:f1].should == nil
            table.sequel.select(:f1).where(:test_id => '4').first[:f1].should == 1234
            table.sequel.select(:f1).where(:test_id => '5').first[:f1].should == 45345
            table.sequel.select(:f1).where(:test_id => '6').first[:f1].should == -41234
            table.sequel.select(:f1).where(:test_id => '7').first[:f1].should == 21234.2134
            table.sequel.select(:f1).where(:test_id => '8').first[:f1].should == 2345.2345
            table.sequel.select(:f1).where(:test_id => '9').first[:f1].should == -1234.3452
            table.sequel.select(:f1).where(:test_id => '10').first[:f1].should == nil
            table.sequel.select(:f1).where(:test_id => '11').first[:f1].should == nil
            table.sequel.select(:f1).where(:test_id => '12').first[:f1].should == nil                                
          end
  
          it "should normalize string if there is a non-convertible entry when converting string to boolean" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "my_precious"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_string_to_boolean.csv"
            table.save    
    
            # configure nil column
            table.sequel.where(:test_id => '11').update(:f1 => nil)                              
    
            # configure blank column
            table.sequel.insert(:test_id => '12', :f1 => "")                              
    
            # update datatype
            table.modify_column! :name=>"f1", :type=>"boolean", :old_name=>"f1", :new_name=>nil
    
            # test
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '3').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '4').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '5').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '6').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '7').first[:f1].should == true
            table.sequel.select(:f1).where(:test_id => '8').first[:f1].should == false
            table.sequel.select(:f1).where(:test_id => '9').first[:f1].should == false
            table.sequel.select(:f1).where(:test_id => '10').first[:f1].should == false
            table.sequel.select(:f1).where(:test_id => '11').first[:f1].should == nil
            table.sequel.select(:f1).where(:test_id => '12').first[:f1].should == nil    
          end
  
          it "should normalize boolean if there is a non-convertible entry when converting boolean to string" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "my_precious"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_boolean_to_string.csv"
            table.save    
            table.modify_column! :name=>"f1", :type=>"boolean", :old_name=>"f1", :new_name=>nil    
            table.modify_column! :name=>"f1", :type=>"string", :old_name=>"f1", :new_name=>nil
    
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == 'true'                              
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == 'false'                              
          end

          it "should normalize boolean if there is a non-convertible entry when converting boolean to number" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "my_precious"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_boolean_to_string.csv"
            table.save    
            table.modify_column! :name=>"f1", :type=>"boolean", :old_name=>"f1", :new_name=>nil    
            table.modify_column! :name=>"f1", :type=>"number", :old_name=>"f1", :new_name=>nil
    
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == 1                              
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == 0                              
          end
  
          it "should normalize number if there is a non-convertible entry when converting number to string" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "my_precious"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_number_to_string.csv"
            table.save    
            table.modify_column! :name=>"f1", :type=>"number", :old_name=>"f1", :new_name=>nil    
            table.modify_column! :name=>"f1", :type=>"string", :old_name=>"f1", :new_name=>nil
    
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == '1'                              
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == '2'                              
          end
  
          it "should normalize number if there is a non-convertible entry when converting number to boolean" do
            user = create_user
            table = new_table
            table.user_id = user.id
            table.name = "my_precious"
            table.import_from_file = "#{Rails.root}/spec/support/data/column_number_to_boolean.csv"
            table.save    
            table.modify_column! :name=>"f1", :type=>"number", :old_name=>"f1", :new_name=>nil    
            table.modify_column! :name=>"f1", :type=>"boolean", :old_name=>"f1", :new_name=>nil
    
            table.sequel.select(:f1).where(:test_id => '1').first[:f1].should == true                              
            table.sequel.select(:f1).where(:test_id => '2').first[:f1].should == false                              
            table.sequel.select(:f1).where(:test_id => '3').first[:f1].should == true                              
            table.sequel.select(:f1).where(:test_id => '4').first[:f1].should == true                                  
          end
        end
      end
  context "original tests" do
    it "should raise an error if :import_from_file option is blank" do
      lambda { 
        CartoDB::Importer.new 
      }.should raise_error("import_from_file value can't be nil")
    end
  
  
    it "should get the table name from the options" do
      importer = create_importer 'clubbing.csv', 'prefered_name'
      result   = importer.import!
    
      # Assertions
      result.name.should          == 'prefered_name'
      result.rows_imported.should == 1998
      result.import_type.should   == '.csv'
    end
  
  
    it "should remove the table from the database if an exception happens" do
      importer = create_importer 'empty.csv'
    
      # Assertions
      lambda { importer.import! }.should raise_error    
      @db.tables.should_not include(:empty)    
    end
  
  
    # TODO: Is this really the intended behaviour??
    it "should keep first imported table when importing again with same name" do
      importer = create_importer 'clubbing.csv', 'testing'
      result   = importer.import!

      # initial assertion
      result.import_type.should == '.csv'
    
      # second creation should fail with exception
      importer = create_importer 'empty.csv', 'testing'
      lambda { importer.import! }.should raise_error
  
      # Assert has first import
      @db.tables.should include(:testing)
    end


  
    it "should suggest a new table name of the format _n if the previous table exists" do
      # import twice
      importer = create_importer 'clubbing.csv', 'clubs'
      result   = importer.import!
    
      # have to recreate to set up the general file harnesses
      importer = create_importer 'clubbing.csv', 'clubs'
      result   = importer.import!
    
      # Assert new duplicate
      result.name.should          == 'clubs_1'
      result.rows_imported.should == 1998
      result.import_type.should   == '.csv'
    end
  
  
    it "should sanitize column names" do
      importer = create_importer 'twitters.csv', 'twitters'
      result   = importer.import!
    
      # grab column names from twitters table
      columns          = @db.schema(:twitters).map{|s| s[0].to_s}    
      expected_columns = ["url", "login", "country", "followers_count"]    
    
      # Assert correct column names are added
      (expected_columns - columns).should be_empty
    end
  
    pending "should escape reserved column names" do
      importer = create_importer 'reserved_columns.csv', 'reserved_columns'
      result   = importer.import!

      # grab columns from reserved_columns table    
      columns = @db.schema(:reserved_columns).map{|s| s[0].to_s}
      expected_columns = ["url","login","country","followers_count", "_xmin"]

      # Assert reserved columns are excaped
      (expected_columns - columns).should be_empty
    end
  
    # Filetype specific tests 
    describe "#ZIP" do
      it "should import CSV even from a ZIP file" do
        importer = create_importer 'pino.zip'
        result   = importer.import!

        # Assertions
        result.name.should          == 'data'
        result.rows_imported.should == 4
        result.import_type.should   == '.csv'
      end
  
      it "should import CSV even from a ZIP file with the given name" do
        importer = create_importer 'pino.zip', "table123"
        result   = importer.import!

        # Assertions
        result.name.should          == 'table123'
        result.rows_imported.should == 4
        result.import_type.should   == '.csv'
      end
    end
  
    describe "#CSV" do
      it "should import a CSV file in the given database in a table named like the file" do
        importer = create_importer 'clubbing.csv', 'clubsaregood'
        result = importer.import!

        result.name.should          == 'clubsaregood'
        result.rows_imported.should == 1998
        result.import_type.should   == '.csv'
      end
    
      it "should import Food Security Aid Map_projects.csv" do
        importer = create_importer 'Food Security Aid Map_projects.csv'
        result = importer.import!

        result.name.should          == 'food_security_aid_map_projects'
        result.rows_imported.should == 827
        result.import_type.should   == '.csv'
      end
    
      it "should import world_heritage_list.csv" do
        importer = create_importer 'world_heritage_list.csv'
        result = importer.import!

        result.name.should          == 'world_heritage_list'
        result.rows_imported.should == 937
        result.import_type.should   == '.csv'
      end

      # NOTE: long import, takes *ages* so commented
      # it "should import cp_vizzuality_export.csv" do
      #   importer = create_importer 'cp_vizzuality_export.csv'
      #   result = importer.import!
      # 
      #   result.name.should          == 'cp_vizzuality_export'
      #   result.rows_imported.should == 19235
      #   result.import_type.should   == '.csv'
      # end
    
      # Not supported by cartodb-importer ~ v0.2.1
      # File in format different than UTF-8
      pending "should import estaciones.csv" do
        importer = create_importer 'estaciones.csv'
        result = importer.import!

        result.name.should          == 'estaciones'
        result.rows_imported.should == 29
        result.import_type.should   == '.csv'
      end
    
      it "should import estaciones2.csv" do
        importer = create_importer 'estaciones2.csv'
        result = importer.import!

        result.name.should          == 'estaciones2'
        result.rows_imported.should == 30
        result.import_type.should   == '.csv'
      end
    
      it "should import CSV with latidude/logitude" do
        importer = create_importer 'walmart.csv'      
        result = importer.import!

        result.name.should == 'walmart'
        result.rows_imported.should == 3176
        result.import_type.should == '.csv'
      end

      it "should import CSV with lat/lon" do
        importer = create_importer 'walmart_latlon.csv', 'walmart_latlon'      
        result = importer.import!

        result.name.should == 'walmart_latlon'
        result.rows_imported.should == 3176
        result.import_type.should == '.csv'
      end

      it "should CartoDB CSV export with latitude & longitude columns" do
        importer = create_importer 'CartoDB_csv_export.zip', 'cartodb_csv_export'                  
        result = importer.import!
      
        result.name.should == 'cartodb_csv_export'
        result.rows_imported.should == 155
        result.import_type.should == '.csv'

        # test auto generation of geom from lat/long fields
        res = @db[:cartodb_csv_export].select{[x(the_geom), y(the_geom), latitude, longitude]}.limit(1).first
        res[:x].should == res[:longitude].to_f
        res[:y].should == res[:latitude].to_f
      end
  
      it "should CartoDB CSV export with the_geom in geojson" do
        importer = create_importer 'CartoDB_csv_multipoly_export.zip', 'cartodb_csv_multipoly_export'
        result = importer.import!

        result.name.should == 'cartodb_csv_multipoly_export'
        result.rows_imported.should == 601
        result.import_type.should == '.csv'
      
        # test geometry returned is legit
        g = '{"type":"MultiPolygon","coordinates":[[[[1.7,39.1],[1.7,39.1],[1.7,39.1],[1.7,39.1],[1.7,39.1]]]]}'
        @db[:cartodb_csv_multipoly_export].get{ST_AsGeoJSON(the_geom,1)}.should == g
      end
    
      it "should import CSV file with lat/lon column" do
        importer = create_importer 'facility.csv', 'facility'
        result = importer.import!

        result.name.should == 'facility'
        result.rows_imported.should == 541
        result.import_type.should == '.csv'
      
        # test geometry is correct
        res = @db["SELECT x(the_geom),y(the_geom) FROM facility WHERE prop_id=' Q448 '"].first
        res.should == {:x=>-73.7698, :y=>40.6862}
      end
  
      it "should import CSV file with columns who are numbers" do
        importer = create_importer 'csv_with_number_columns.csv', 'csv_with_number_columns'
        result = importer.import!

        result.name.should == 'csv_with_number_columns'
        result.rows_imported.should == 177

        result.import_type.should == '.csv'      
      end
    end
  
    describe "#XLSX" do
      it "should import a XLSX file in the given database in a table named like the file" do
        importer = create_importer 'ngos.xlsx'
        result = importer.import!

        result.name.should          == 'ngos'
        result.rows_imported.should == 76
        result.import_type.should   == '.xlsx'
      end
    end
  
    describe "#KML" do
      it "should import KML file rmnp.kml" do
        importer = create_importer 'rmnp.kml'
        result = importer.import!

        result.name.should          == 'rmnp'
        result.rows_imported.should == 1
        result.import_type.should   == '.kml'
      end
    
      it "should import KML file rmnp.zip" do
        importer = create_importer 'rmnp.zip', "rmnp1"
        result = importer.import!

        result.name.should          == 'rmnp1'
        result.rows_imported.should == 1
        result.import_type.should   == '.kml'
      end

      it "should import KMZ file rmnp.kmz" do
        importer = create_importer 'rmnp.kmz', "rmnp2"      
        result = importer.import!

        result.name.should          == 'rmnp2'
        result.rows_imported.should == 1
        result.import_type.should   == '.kml'
      end
    end

    describe "#GeoJSON" do
      it "should import GeoJSON file simple.json" do
        importer = create_importer 'simple.json'
        result = importer.import!

        result.name.should          == 'simple'
        result.rows_imported.should == 11

        result.import_type.should   == '.json'
      end

      it "should import GeoJSON file geojson.geojson" do
        importer = create_importer 'geojson.geojson'
        result = importer.import!

        result.name.should          == 'geojson'
        result.rows_imported.should == 4

        result.import_type.should   == '.geojson'
      end
      
      pending "should import GeoJSON files from URLs with non-UTF-8 chars converting if needed" do
        url = {:import_from_url => "https://raw.github.com/gist/1374824/d508009ce631483363e1b493b00b7fd743b8d008/unicode.json", :suggested_name => 'geojson_utf8'}
        importer = CartoDB::Importer.new @db_opts.reverse_merge(url)
        result = importer.import!

        @db[:geojson_utf8].get(:reg_symbol).should == "In here -> ® <-- this here"
      end      
    end
  
    describe "#SHP" do
      it "should import a SHP file in the given database in a table named like the file" do
        importer = create_importer 'EjemploVizzuality.zip'
        result   = importer.import!

        columns = @db.schema(:vizzuality).map{|s| s[0].to_s}        
        expected_columns = %w(gid subclass x y length area angle name pid lot_navteq version_na vitesse_sp id nombrerest tipocomida)

        result.name.should          == 'vizzuality'
        result.rows_imported.should == 11
        result.import_type.should   == '.shp'
      
        @db.tables.should include(:vizzuality)
        (expected_columns - columns).should be_empty
      end
    
      it "should import SHP file TM_WORLD_BORDERS_SIMPL-0.3.zip" do
        importer = create_importer 'TM_WORLD_BORDERS_SIMPL-0.3.zip'
        result = importer.import!
      
        result.name.should          == 'tm_world_borders_simpl_0_3'
        result.rows_imported.should == 246
        result.import_type.should   == '.shp'
      end
      
      it "should import SHP file TM_WORLD_BORDERS_SIMPL-0.3.zip but set the given name" do
        importer = create_importer 'TM_WORLD_BORDERS_SIMPL-0.3.zip', 'borders'
        result = importer.import!

        result.name.should          == 'borders'
        result.rows_imported.should == 246
        result.import_type.should   == '.shp'
      end
    end
    
    describe "#GPX file" do
      it "should import GPX file" do
        importer = create_importer 'route2.gpx'                  
        result = importer.import!
      
        result.should_not           == nil
        result.name.should          == 'route2'
        result.rows_imported.should == 822
        result.import_type.should   == '.gpx'
      end
    end    
    
    
    pending "#GTIFF" do
      it "should import a GTIFF file in the given database in a table named like the file" do
        importer = create_importer 'GLOBAL_ELEVATION_SIMPLE.zip'      
        result = importer.import!
      
        result.name.should          == 'global_elevation_simple'
        result.rows_imported.should == 1500
        result.import_type.should   == '.tif'
      end
    end  
    
    describe "Natural Earth Polygons" do
      it "should import Natural Earth Polygons" do
        importer = create_importer '110m-glaciated-areas.zip', 'glaciers'                  
        result = importer.import!
      
        result.name.should          == 'glaciers'
        result.rows_imported.should == 11
        result.import_type.should   == '.shp'
      end
    end  
  
    describe "Import from URL" do
      it "should import a shapefile from NaturalEarthData.com" do
        url = {:import_from_url => "http://www.nacis.org/naturalearth/10m/cultural/10m_parks_and_protected_areas.zip"}
        importer = CartoDB::Importer.new @db_opts.reverse_merge(url)
        result = importer.import!

        @db.tables.should include(:_10m_us_parks_point)
        result.name.should          == '_10m_us_parks_point'
        result.rows_imported.should == 312
        result.import_type.should   == '.shp'
      end
    end    
  
  
    describe "Import from user specific files" do
    
      it "should import a shapefile from Simon" do
        importer = create_importer 'simon-search-spain-1297870422647.zip'                  
        result = importer.import!
      
        result.rows_imported.should == 601
        result.import_type.should   == '.shp'
      end

      it "should import this KML ZIP file" do
        importer = create_importer 'states.kml.zip'
        result = importer.import!

        result.rows_imported.should == 56
        result.import_type.should   == '.kml'
      end
  
      it "should import CartoDB SHP export with lat/lon" do
        importer = create_importer 'CartoDB_shp_export.zip', 'cartodb_shp_export'
        result = importer.import!

        result.name.should == 'cartodb_shp_export'
        result.rows_imported.should == 155
        result.import_type.should == '.shp'
      
        # test geometry is correct
        res = @db[:cartodb_shp_export].select{[x(the_geom),y(the_geom)]}.first
        res.should == {:x=>16.5607329, :y=>48.1199611}
      end
        
    end  
  end
  
  
  
  ##################################################
  # configuration & helpers for tests
  ##################################################
  before(:all) do
    @db = CartoDB::ImportDatabaseConnection.connection
    @db_opts = {:database => "cartodb_importer_test", 
                :username => "postgres", :password => '',
                :host => 'localhost', 
                :port => 5432}
  end
  
  after(:all) do
    CartoDB::ImportDatabaseConnection.drop
  end
  
  def file file
    File.expand_path("../../support/data/#{file}", __FILE__)    
  end
  
  def create_importer file_name, suggested_name=nil
    # sanity check
    throw "filename required" unless file_name
        
    # configure opts    
    opts = {:import_from_file => file(file_name)}
    opts[:suggested_name] = suggested_name if suggested_name.present?
    
    # build importer
    CartoDB::Importer.new opts.reverse_merge(@db_opts)
  end        
  def check_schema(table, expected_schema, options={})
    table_schema = table.schema(:cartodb_types => options[:cartodb_types] || false)
    schema_differences = (expected_schema - table_schema) + (table_schema - expected_schema)
    schema_differences.should be_empty, "difference: #{schema_differences.inspect}"
  end                            
end


