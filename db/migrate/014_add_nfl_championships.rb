class AddNflChampionships < ActiveRecord::Migration
 # g.date.year, g.date.month, g.date.day, hour, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home"].offstrength, z[g.away"].defstrength, z[g.away"].offstrength, z[g.home"].defstrength, weeklimit, g.overunder, probtotalover
 
  def self.up
    #                  0             1          2        3            4                  5             6            7           8          9            10            11           12              13           14       15       16             17                      18                      19                     20                  21          22            23
    #            g.date.year, g.date.month, g.date.day, hour, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home"].offstrength, z[g.away"].defstrength, z[g.away"].offstrength, z[g.home"].defstrength, weeklimit, g.overunder, probtotalover
    dataa        = [[2008, 01, 20, 15, "New England Patriots", "San Diego Chargers", 21, 12, -14.5, 0.686873057339006, 0.260034038205111, 0.0530929044558831, 0.137863545765475, 0.862136454234524, 0.0, 29.2869528808627, 22.2869947869283, 55.1828434916, -23.466115073, 51.9876882542, -26.248552847, 20, 49.0, 0.435405276106059], [2008, 01, 20, 18, "Green Bay Packers", "N.Y. Giants", 20, 23, -7.0, 0.693448165355458, 0.253762153310129, 0.0527896813344127, 0.384804382425624, 0.554767625314688, 0.0604279922596872, 28.4897027975167, 21.2470986381971, 50.2659726222, -24.487476721, 46.0664236447, -24.819325006, 20, 42.0, 0.691970333646334]]
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
      p["week"]                    = d[21]
      p["home_team_id"]            = home_id
      p["away_team_id"]            = away_id
      p["spread"]                  = d[8]
      p["predicted_home_score"]    = d[15]
      p["predicted_away_score"]    = d[16]
      p["actual_home_score"]       = d[6]
      p["actual_away_score"]       = d[7]
      p["joe_guys_bet"]            = nil
      p["joe_guys_bet"]            = home_id if d[21]==1  or d[22]==1
      p["joe_guys_bet"]            = away_id if d[21]==-1  or d[22]==-1
      p["joe_guys_bet_amount"]     = 22
      p["joe_guys_bet_amount_won"] = 0
      p["prob_home_win_su"]        = d[9]
      p["prob_away_win_su"]        = d[10]
      p["prob_push_su"]            = d[11]
      p["prob_home_win_ats"]       = d[12]
      p["prob_away_win_ats"]       = d[13]
      p["prob_push_ats"]           = d[14]
      p["game_total"]              = d[22]
      p["prob_game_over_total"]    = d[23]
      p.save!
      }
  end

  def self.down
  end
end
