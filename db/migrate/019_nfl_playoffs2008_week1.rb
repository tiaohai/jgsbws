require "migration_helpers"
class NflPlayoffs2008Week1 < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
   #               0      1        2    3         4        5         6               7                      8                      9                    10                     11                  12        13        14            15          16             17               18
   #            year,month,day,hour, home, away, spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, total, probover, homeml, awayml, homescore, awayscore
    dataa        = [[2009,01,03,13,"San Diego Chargers","Indianapolis Colts",1.0,0.505877706274839,0.433186998131478,0.0609352955936823,0.566813001868521,0.39216105560188,0.0410259425295988,51.0,0.271027238626923,106,-116,23,17],
    [2009,01,03,16,"Arizona Cardinals","Atlanta Falcons",2.0,0.318599561326309,0.624835844558899,0.0565645941147916,0.415429888224478,0.550370689493127,0.0341994222823939,51.0,0.380777026283429,115,-125,30,24],
    [2009,01,04,13,"Miami Dolphins","Baltimore Ravens",3.0,0.315970259684758,0.623473067999503,0.0605566723157383,0.450866166506246,0.49044639951577,0.0586874339779841,37.5, 0.630831291844097,168,-178,9,27],
    [2009,01,04,16,"Minnesota Vikings","Philadelphia Eagles",3.0,0.316044060312903,0.623217332349572,0.0607386073375251,0.316044060312903,0.623217332349572,0.060738607337525,42,0.41233333,142,-152,14,26]]
    #            g.date.year, g.date.month, g.date.day, hour, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home"].offstrength, z[g.away"].defstrength, z[g.away"].offstrength, z[g.home"].defstrength, weeklimit, g.overunder, probtotalover
#  dataa        = [[2008, 01, 20, 15, "New England Patriots", "San Diego Chargers", 21, 12, -14.5, 0.686873057339006, 0.260034038205111, 0.0530929044558831, 0.137863545765475, 0.862136454234524, 0.0, 29.2869528808627, 22.2869947869283, 55.1828434916, -23.466115073, 51.9876882542, -26.248552847, 20, 49.0, 0.435405276106059], [2008, 01, 20, 18, "Green Bay Packers", "N.Y. Giants", 20, 23, -7.0, 0.693448165355458, 0.253762153310129, 0.0527896813344127, 0.384804382425624, 0.554767625314688, 0.0604279922596872, 28.4897027975167, 21.2470986381971, 50.2659726222, -24.487476721, 46.0664236447, -24.819325006, 20, 42.0, 0.691970333646334]]
    teamleague   = League.find_by_name("National Football League")
    betthreshold = 11.0 / 21.0
    dataa.each{|d|
      begin
        home_id = Team.find_by_name(d[4]).id
      rescue
        raise "no such team as "+d[4] if home_id.nil?
      end
      begin
        away_id = Team.find_by_name(d[5]).id
      rescue
        raise "no such team as "+d[5] if away_id.nil?
      end
      p = Prediction.new
      p["game_date_time"]          = Time.local(d[0], d[1], d[2], d[3])
      p["league"]                  = teamleague
      p["season"]                  = 1
      p["week"]                    = 18
      p["home_team_id"]            = home_id
      p["away_team_id"]            = away_id
      p["spread"]                  = d[6]
      p["predicted_home_score"]    = -1
      p["predicted_away_score"]    = -1
      p["actual_home_score"]       =  d[17]
      p["actual_away_score"]       = d[18]
      p["joe_guys_bet"]            = nil
      p["joe_guys_bet"]            = home_id if d[10] > betthreshold
      p["joe_guys_bet"]            = away_id if d[11] > betthreshold
      p["joe_guys_bet_amount"]     = 0
      p["joe_guys_bet_amount"]     = 22 unless p["joe_guys_bet"].nil? 
      p["joe_guys_bet_amount_won"] = 0
      p["prob_home_win_su"]        = d[7]
      p["prob_away_win_su"]        = d[8]
      p["prob_push_su"]            = d[9]
      p["prob_home_win_ats"]       = d[10]
      p["prob_away_win_ats"]       = d[11]
      p["prob_push_ats"]           = d[12]
      p["game_total"]              = d[13]
      p["prob_game_over_total"]    = d[14]
      p["moneyline_home"] = d[15]
      p["moneyline_away"] = d[16]
      p["moneyline_bet"] = home_id if mlconv(d[15],d[7])
      p["moneyline_bet"] = away_id if mlconv(d[16],d[8])
      p.save!
      }
  end

  def self.down
  end
end
