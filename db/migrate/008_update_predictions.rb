class UpdatePredictions < ActiveRecord::Migration
  def self.up
    # read the C:\Ruby Source\RS\nfl games prediction stats.txt file and update all the corresponding games in predictions with the data therein
    preda = IO.readlines(File.dirname(__FILE__) + '/../../public/nfl games prediction stats.txt')
    #  0 1 2     3     4            5                   6               7           8           9        10          11       12
    # datestr, home, away, estimatedhomescore, estimatedawayscore, probhomewin, probawaywin, spread, probcover, probunder, sourcee
    #  0   1   2          3                4              5                     6               7                   8          9         10              11                    12
    # 2007,12,17,Minnesota Vikings,Chicago Bears, 17.327377981238637, 18.700008240657745,0.4443765976727831,0.5556234023272169,0,0.4443765976727828,0.5556234023272165,c:/soccerdata/td/10 September 2007/National Football League Football Report.txt
    savecount = 0
    preda.each_with_index{|l, i|
	    next if i < 1
      la = l.split(",")
   #  puts l.inspect
   #  puts la[0]
   #  puts la[1]
   #  puts la[2]
      # datee   = Date.new(la[0],la[1],la[2])
      home_id = Team.find_by_name(la[3]).id
   #  puts "home_id"
   #  puts home_id.inspect
      away_id = Team.find_by_name(la[4]).id
   #  puts "away_id"
   #  puts away_id.inspect
      sqlstr  = "SELECT * from predictions WHERE predictions.home_team_id = #{home_id} AND predictions.away_team_id = #{away_id}"
   #  puts sqlstr
      @pred   = Prediction.find_by_sql(sqlstr)
   #  puts @pred.inspect
      unless @pred.empty?
     #  puts "@pred not empty "
        @pred.reject!{|g|
#                 #  puts "g[0].inspect"
 #                #  puts g[0].inspect
                 #  puts 'g["game_date_time"].inspect'
                 #  puts g["game_date_time"].inspect
                 #  puts 'g["game_date_time"].year'
                 #  puts g["game_date_time"].year
                 #  puts 'g["game_date_time"].month'
                 #  puts g["game_date_time"].month
                 #  puts 'g["game_date_time"].day'
                 #  puts g["game_date_time"].day
                 #  puts "la[0].inspect"
                 #  puts la[0].inspect
                 #  puts "la[1].inspect"
                 #  puts la[1].inspect
                 #  puts "la[2].inspect"
                 #  puts la[2].inspect
                         g["game_date_time"].year  != la[0].to_i or 
                         g["game_date_time"].month != la[1].to_i or 
                         g["game_date_time"].day   != la[2].to_i
        }
        unless @pred.empty?
          @pred.each{|prd|
         #  puts prd.inspect
            la = l.split(",")
         #  puts "la.inspect"
         #  puts la.inspect
         #  puts "l.inspect"
         #  puts l.inspect
         #  puts "la[5].inspect"
         #  puts la[5].inspect
         #  puts "la[5].strip.to_i"
         #  puts la[5].strip.to_i
         #  puts "prd.inspect"
         #  puts prd.inspect
  #       #  puts 'prd["predicted_home_score"]'
   #      #  puts prd['predicted_home_score']
         #  puts "methods "+prd.methods.inspect
#            prd.each{|k,v|
 #          #  puts "key is   "+k.inspect
  #         #  puts "value is "+v.inspect
   #           }
            prd["predicted_home_score"] = la[5].strip.to_i
            prd["predicted_away_score"] = la[6].strip.to_i
            prd["prob_home_win_su"]     = la[7].strip.to_f
            prd["prob_away_win_su"]     = la[8].strip.to_f
            prd["prob_push_su"]         = (1.0 - la[7].strip.to_f - la[8].strip.to_f)
            prd["prob_home_win_ats"]    = la[10].strip.to_f
            prd["prob_away_win_ats"]    = la[11].strip.to_f
            prd["prob_push_ats"]        = (1.0 - la[10].strip.to_f - la[11].strip.to_f)
         #   puts
         #  puts "* * * * * * * * * * * * * * * * saving * * * * * * * * * * * * * * "
         #   puts
            prd.save
            savecount += 1
          } # @pred.each{|prd|
        else # @pred empty
       #  puts "@pred empty "
        end
      else
     #  puts "@pred empty "
      end
   #  puts "********************************************************************"
#      puts
    } # next data line
 #  puts "savecount is "+savecount.to_s
  end

  def self.down
  end
end
