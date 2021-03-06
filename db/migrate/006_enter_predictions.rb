class EnterPredictions < ActiveRecord::Migration
  def self.up
    preda            = IO.readlines(File.dirname(__FILE__) + '/../../public/nflpicks.txt')
=begin
      t.column :game_date_time,          :datetime
      t.column :league,                  :integer
      t.column :week,                    :integer, :default=>0
      t.column :home_team_id,            :integer
      t.column :away_team_id,            :integer
      t.column :spread,                  :float
      t.column :predicted_home_score,    :integer, :default=>-1
      t.column :predicted_away_score,    :integer, :default=>-1
      t.column :actual_home_score,       :integer, :default=>-1
      t.column :actual_away_score,       :integer, :default=>-1
      t.column :joe_guys_bet,            :integer
      t.column :joe_guys_bet_amount,     :integer, :default=>10
      t.column :joe_guys_bet_amount_won, :integer
=end
    weekv    = 0
    timehour = 0
    timemin  = 0
    pick     = ""
    datev    = 0
    dayv     = 0
    monthv   = 0
    yearv    = 0
    # now to add all the NFL predictions as we have the leagues and the teams
    teamleague       = League.find_by_name("National Football League")
    preda.each{|p|
=begin
      *week 2
      16/9/07,Jacksonville Jaguars,Atlanta Falcons,13,7,-10.5
      Jacksonville Jaguars
      time 1300
=end
      # check for week
      # # puts "p is "
      # puts p.inspect  if p.include?("Washington Redskins,Chicago Bears")
   #   sleep 1 if p.include?("Washington Redskins,Chicago Bears")
      next if p.include?("*note")
      weekv    = p[6..-1].to_i if p.include?("*week")
      # 0123456
      # *week 2
      # # puts "weekv"            if p.include?("*week")
      # # puts weekv              if p.include?("*week")
      next                    if p.include?("*week")
      next                    if p.include?("*time")
      # check for time
      timehour = p[5,2].to_i  if p.include?("time")
      timemin  = p[7,2].to_i  if p.include?("time")
       # puts "time is "+p       if p.include?("time")
       # puts "timehour"         if p.include?("time")
       # puts timehour           if p.include?("time")
       # puts "timemin"          if p.include?("time")
       # puts timemin            if p.include?("time")
      next                    if p.include?("time")
      # check for pick
      pick  = p.chomp       unless p.include?(",")
  #    # puts "pick is "+pick  unless p.include?(",")
      next             unless p.include?(",")
      # ok if here a standard game result with spread
      #    0        1          2      3 4    5 
      # 16/9/07,Jacksonville,Atlanta,13,7,-10.5
      # puts p.inspect  if p.include?("Washington Redskins,Chicago Bears")
  #    sleep 1 if p.include?("Washington Redskins,Chicago Bears")
      res    = p.split(",")
      # # puts "split p"
      # # puts res.inspect
      dataa  = res[0].split("/")
      # # puts dataa.inspect
      dayv   = dataa[0].to_i
      monthv = dataa[1].to_i
      yearv  = dataa[2].to_i + 2000
      # # puts "seeking >"+res[1].chomp+"< in Teams"
      home   = Team.find_by_name(res[1].chomp).id
      # # puts "result is "+home.to_s
      # # puts "seeking >"+res[2].chomp+"< in Teams"
      away   = Team.find_by_name(res[2].chomp).id
      # # puts "result is "+away.to_s
      homescore = res[3].to_i
      awayscore = res[4].to_i
      spread    = res[5].to_f
      pred   = Prediction.new
      
      # puts "gonna do it "  if p.include?("Washington Redskins,Chicago Bears")
      # puts "#{yearv} #{monthv} #{dayv} #{timehour} #{timemin}"
      # puts Time.local(yearv, monthv, dayv, timehour, timemin).inspect
 #     sleep 30 if p.include?("Washington Redskins,Chicago Bears")
      pred.game_date_time          = Time.local(yearv, monthv, dayv, timehour, timemin)
      # puts Time.local(yearv, monthv, dayv, timehour, timemin).zone
      pred.league                  = teamleague
      pred.week                    = weekv
      pred.home_team_id            = home
      pred.away_team_id            = away
      pred.spread                  = spread
      pred.actual_home_score       = homescore
      pred.actual_away_score       = awayscore
      pred.joe_guys_bet            = Team.find_by_name(pick).id unless pick.empty?
      pred.joe_guys_bet            = 0                              if pick.empty?
      pick   = ""
      winamt = -22
      winamt = 20 if pred.joe_guys_bet == home and (homescore + spread) > awayscore
      winamt = 20 if pred.joe_guys_bet == away and (homescore + spread) < awayscore
      winamt = 0  if                               (homescore + spread) == awayscore or pred.joe_guys_bet == 0
      pred.joe_guys_bet_amount_won = winamt
      # puts pred.inspect  if p.include?("Washington Redskins,Chicago Bears")
  #    sleep 30 if p.include?("Washington Redskins,Chicago Bears")
      raise "no save" unless pred.save
    }
  end

  def self.down
  end
end
