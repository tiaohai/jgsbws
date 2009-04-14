class MainController < ApplicationController
# caches_page :index, :nfl, :notdone

def index
end

def main
	year		=	params[:id].to_i
	logger.warn params.inspect
	leagueid	=	params[:league].to_i
	pred		=	Prediction.find_all_by_league(leagueid)
#	logger.warn pred.inspect
	pred.sort!{|a,b|a["game_date_time"]<=>b["game_date_time"]}
	proba	=	[]
	pred.each{|g|
		proba	<<	g.prob_home_win_ats.r2 unless proba.include?(g.prob_home_win_ats.r2)
		proba	<<	g.prob_away_win_ats.r2 unless proba.include?(g.prob_away_win_ats.r2)
		proba	<<	g.prob_game_over_total.r2 unless proba.include?(g.prob_game_over_total.r2)
		proba	<<	(1.0	-	g.prob_home_win_ats).r2 unless proba.include?((1.0	-	g.prob_home_win_ats).r2)
		proba	<<	(1.0	-	g.prob_away_win_ats).r2 unless proba.include?((1.0	-	g.prob_away_win_ats).r2)
		proba	<<	(1.0	-	g.prob_game_over_total).r2 unless proba.include?((1.0	-	g.prob_game_over_total).r2)
	}
#	logger.warn proba.sort.inspect
#	raise
	@main	=	[]
	winprob	=	0.7
	header	=	''
	case leagueid
		when 1 # nfl
			# games run from sept to febuary
			startdate	=	Time.local(year, 'sep', 1) 
			enddate	=	Time.local(year + 1, 'sep', 1) 
			header	=	"<h3>Joe Guy's #{year} National Football League Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays
			gaptitle	=	'Week'
		when 2 # nba
			# games run from Nov to April
			startdate	=	Time.local(year, 'nov', 1) 
			enddate	=	Time.local(year + 1, 'may', 1)
			winprob	=	0.73			if year == 2008
#			winprob	=	11.0 / 21.0	if year == 2008
			winprob	=	11.0 / 21.0	if year == 2007
			header	=	"<h3>Joe Guy's #{year} National Basketball Association Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsperday - 1
			gaptitle	=	'Day'
		when 4 # ncaa football
			# games run from aug to feb
			startdate	=	Time.local(year, 'aug', 1) 
			enddate	=	Time.local(year + 1, 'feb', 1)
			winprob	=	0.8 if year == 2007
			winprob	=	0.8 if year == 2008
			header	=	"<h3>Joe Guy's #{year} NCAA Football Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays - 1
			gaptitle	=	'Week'
		when 5 # ncaa bb
			# games run from Nov to April
			startdate	=	Time.local(year, 'nov', 1) 
			enddate	=	Time.local(year + 1, 'may', 1)
			winprob	=	0.85	unless	year	==	2008
			winprob	=	0.85	if		year	==	2008
			header	=	"<h3>Joe Guy's #{year} NCAA Basketball Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsperday - 1
			gaptitle	=	'Day'
		else
#			logger.warn "main inspect"
#			logger.warn(@main.inspect)
#			logger.warn "main inspect done"
#			raise
		raise "no such league as #{leagueid}"
	end
	newpred	=	[]
	pred.each{|g|
		newpred	<<	g	if	g.game_date_time	>=	startdate	&&	g.game_date_time	<=	enddate
	}
	@main	=	do_season(newpred,	year,	winprob,	header,	gap,	gaptitle, (leagueid	==	5))
end

end
