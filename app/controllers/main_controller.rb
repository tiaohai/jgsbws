class MainController < ApplicationController
# caches_page :index, :nfl, :notdone
Betarray	=	%w(B365H B365D B365A BSH BSD BSA BWH BWD BWA GBH GBD GBA IWH IWD IWA LBH LBD LBA SBH SBD SBA WHH WHD WHA SJH SJD SJA VCH VCD VCA BbMxgt2p5 BbMxlt2p5 BbAvgt2p5 BbAvlt2p5 GBgt2p5 GBlt2p5 B365gt2p5 B365lt2p5)
Betnames = ['Bet365 home win odds -> EV -> $bankroll', 'Bet365 draw odds -> EV -> $bankroll', 'Bet365 away win odds -> EV -> $bankroll',  'Blue Square home win odds -> EV -> $bankroll', 'Blue Square draw odds -> EV -> $bankroll', 'Blue Square away win odds -> EV -> $bankroll',  'Bet&Win home win odds -> EV -> $bankroll', 'Bet&Win draw odds -> EV -> $bankroll', 'Bet&Win away win odds -> EV -> $bankroll',  'Gamebookers home win odds -> EV -> $bankroll', 'Gamebookers draw odds -> EV -> $bankroll', 'Gamebookers away win odds -> EV -> $bankroll',  'Interwetten home win odds -> EV -> $bankroll', 'Interwetten draw odds -> EV -> $bankroll', 'Interwetten away win odds -> EV -> $bankroll',  'Ladbrokes home win odds -> EV -> $bankroll', 'Ladbrokes draw odds -> EV -> $bankroll', 'Ladbrokes away win odds -> EV -> $bankroll',  'Sporting Odds home win odds -> EV -> $bankroll', 'Sporting Odds draw odds -> EV -> $bankroll', 'Sporting Odds away win odds -> EV -> $bankroll',  'Sportingbet home win odds -> EV -> $bankroll', 'Sportingbet draw odds -> EV -> $bankroll', 'Sportingbet away win odds -> EV -> $bankroll',  'Stan James home win odds -> EV -> $bankroll', 'Stan James draw odds -> EV -> $bankroll', 'Stan James away win odds -> EV -> $bankroll',  'Stanleybet home win odds -> EV -> $bankroll', 'Stanleybet draw odds -> EV -> $bankroll', 'Stanleybet away win odds -> EV -> $bankroll',  'VC Bet home win odds -> EV -> $bankroll', 'VC Bet draw odds -> EV -> $bankroll', 'VC Bet away win odds -> EV -> $bankroll',  'William Hill home win odds -> EV -> $bankroll', 'William Hill draw odds -> EV -> $bankroll', 'William Hill away win odds -> EV -> $bankroll']

def wrap(str, wrapper='td')
	return "<#{wrapper}>#{str}</#{wrapper}>"
end

def index
end

def makscr
	bth	=	{}
	Betarray.each_with_index{|s,	bai|
		bth[s]	=	Betnames[bai]
	}
	puts params
#	raise
	lid		=	params['league']
	pid		=	params['id'].to_i
	sid		=	League.find_by_short_league(lid).id
	lname	=	League.find_by_short_league(lid).name
	preds	=	Prediction.find_all_by_league(sid)
	pred		=	[]
	puts 'filtering data for season'
	preds.each{|p|
		pred	<<	p	if	p.season	==	pid	&&	!p.soccer_bet.nil?
	}
#	puts "preds.inspect #{preds.inspect}"
	puts
#	puts "pred.last.inspect #{pred.last.inspect}"
	puts "season #{pid} league id #{sid} pred length #{pred.length}"
#	raise
	beta		=	[]
#	nc	=	0
	sbh		=	{}
	th		=	{}
	puts 'building team name hash, list of played bets and soccer hash'
	pred.each{|p|
#		nc	+=	1	if p.soccer_bet.nil?
		th[p.home_team_id]		=	Team.find(p.home_team_id).name	unless	th.has_key?(p.home_team_id)
		th[p.away_team_id]		=	Team.find(p.away_team_id).name	unless	th.has_key?(p.away_team_id)
		next if p.soccer_bet.nil?
#		puts p.soccer_bet
		s	=	SoccerBet.find(p.soccer_bet)
		sbh[p.soccer_bet]	=	s
		raise if s.nil?
#		puts s.inspect
#		puts s.to_a.inspect
		Betarray.each{|k,	v|
#			puts b
			beta	<<	k	if	!s[k].nil?	&&	!beta.include?(k)
		}
	}
#	puts nc	if	nc	>	0
#	sleep 10	if	nc	>	0
	puts beta.inspect
#	raise
	# now that we have a list of all used bets - create table for them
	bankroll	=	100.0
	bet		=	4.0
	fdate	=	pred[0].game_date_time
	ldate		=	pred.last.game_date_time
	outstr	=	"<h2>#{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")}</h2> Starting bankroll $#{bankroll.commify} - Bet is $#{bet}<br>"
	outstr	+=	'<table border="1"><th>'
	beta.each{|b|
		outstr	+=	wrap(bth[b])
	}
	outstr		+=	'</th><br>'
	plen			=	pred.length.commify
	sumhash		=	{}
	oldweek		=	pred.first.week
	pred.each_with_index{|p,	pi|
		sumhash,	outstr,	oldweek	=	summarytime(p.week,	oldweek,	sumhash,	beta,	outstr)
		puts
		puts "done #{pi.commify} of #{plen}"
		puts 'building bets'
		abotg	=	0.0	# amount bet on this game is zero - must bet max 4 % on any one game 
		s		=	sbh[p.soccer_bet] # SoccerBet.find(p.soccer_bet)
		ht		=	th[p.home_team_id]
		awt		=	th[p.away_team_id]
		eva		=	[]
		tmpstr		=	''
		begin
			outstr	+=	'zzzzzzzzzzzzzzzzz' # for replacement later
			tmpstr	=	Tr+wrap("aaaaaaaaaaaaGame #{(pi+1).commify} - "+p.game_date_time.strftime("%B %d %Y  ")+' - '+ht+' '+p.actual_home_score.to_s+' - '+awt+' '+p.actual_away_score.to_s+' -> $bbbbbbbbbbb' + (bet == 4 ? '' : " Bet is $#{bet.r2}"))
		rescue
			raise "outstr #{outstr.inspect}"
		end
		beta.each{|b|
			eva	<<	[b,	(s[b+'_ev'].nil? ? 0.0 : s[b+'_ev'])]	# unless	s[b].nil?
		}
#		puts eva.inspect
		eva.sort!{|a,	b|	b[1]<=>a[1]}
#		sleep 10
		eva2		=	[]
		
#		bet		=	bankroll	*	Fpc
#		bet		=	4.0	if	bet	<	4.0
#		bet		=	100	if	bet	>	100
		
		eva.each{|e|	#	now do from best down
			b	=	e[0]
			begin
#				if (s[b+'_ev']	>	1.0) && (abotg == 0 || ((abotg + bet) <= (bankroll * 0.04))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
				if (e[1]	>	1.0) && (abotg == 0 || ((abotg + bet) <= (bankroll * Fpc))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
					eva2		<<	e[0]
					abotg	+=	bet
				else
					break
				end
			rescue
#				raise "b #{b} s.inspect #{s.inspect}"
			end
		}
#		puts
#		puts "eva.inspect #{eva.inspect}"
#		puts
#		puts "eva2.inspect #{eva2.inspect}"
#		puts
#		puts "beta.inspect #{beta.inspect}"
#		raise
		puts 'playing bets'
		gt				=	0.0	#	game total
		beta.each{|b|
			if	s[b].nil?
				outstr	+=	wrap('')	# spacer
			else
				odiv		=	nil
				if	eva2.include?(b)
#				if (s[b+'_ev']	>	1.0) && (abotg == 0 || ((abotg + bet) <= (bankroll * 0.04))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
					# bet on this game - how did we do?
					abotg	+=	bet
					gres		=	0		if	p.actual_home_score	>	p.actual_away_score
					gres		=	1		if	p.actual_home_score	<	p.actual_away_score
					gres		=	2		if	p.actual_home_score	==	p.actual_away_score
					betdraw	=	false
					bethome	=	nil
					bookie	=	b
					odds		=	s[b]
					bl		=	bookie.last
					bethome	=	true		if	bl	==	'H'
					bethome	=	false	if	bl	==	'A'
					betdraw	=	true		if	bl	==	'D'
					if (!betdraw	&&	bethome.nil?)
						# maybe > < 2.5 bet
						raise "bookie #{bookie}" if !bookie.include?('>')	&&	!bookie.include?('<')
						gt25	=	((homescore+awayscore)	>	Tpf)
						if	(gt25	&&	bookie.include?('>'))	||	(gt25	&&	bookie.include?('<'))
							odiv		=	Gdiv
							bankroll	+=	bet	*	odds
							sumhash	=	maintsh(sumhash,	bookie,	bet	*	odds)
							gt		+=	bet	*	odds
						else
							odiv		=	Rdiv
							bankroll	-=	bet
							gt		-=	bet
							sumhash	=	maintsh(sumhash,	bookie,	-bet)
						end
					else
						if	(gres	==	0	&&	bethome &&	!betdraw)	||	(gres	==	1	&&	!bethome &&	!betdraw)	||	(gres	==	2	&&	betdraw)
							odiv		=	Gdiv
							bankroll	+=	bet	*	odds	
							gt		+=	bet	*	odds
							sumhash	=	maintsh(sumhash,	bookie,	bet	*	odds)
						else
							odiv		=	Rdiv
							bankroll	-=	bet
							gt		-=	bet
							sumhash	=	maintsh(sumhash,	bookie,	-bet)
						end
					end
					outstr	+=	wrap(odiv+s[b].to_s+' -> '+s[b+'_ev'].to_s+"<br> -> $#{bankroll.r2.commify}"+'</div>')
				else
					outstr	+=	wrap(s[b].to_s+' -> '+s[b+'_ev'].to_s+"<br> -> $#{bankroll.r2.commify}")
				end
			end
		}	#	next bet
		outstr			+=	'</tr>'
		# now to process the game total
		tmpstr.gsub!('aaaaaaaaaaaa',	Gdiv)	if	gt	>	0.0
		tmpstr.gsub!('aaaaaaaaaaaa',	Rdiv)	if	gt	<	0.0
		tmpstr.gsub!('aaaaaaaaaaaa',	Ydiv)	if	gt	==	0.0
		outstr.gsub!('zzzzzzzzzzzzzzzzz',	tmpstr)
		outstr.gsub!('bbbbbbbbbbb',	gt.r2.commify)
	}	#	next prediction
	sumhash,	outstr,	oldweek	=	summarytime(oldweek+1,	oldweek,	sumhash,	beta,	outstr,	true)
	yt			=	0.0
	yc			=	0
	beta.each{|b|
		begin
			yt	+=	sumhash['year'+b]
		rescue
#			raise "b is #{b}"
		end
		begin
			yc	+=	sumhash['yearcount'+b]
		rescue
#			raise "b is #{b}"
		end
	}
	outstr		+=	Tr+"<td>Season Total - #{yc.commify} bets -> $#{yt.r2.commify} </td>"
	beta.each{|b|
		begin
			div		=	Gdiv	if	sumhash['year'+b]	>	0
			div		=	Rdiv	if	sumhash['year'+b]	<	0
			outstr	+=	wrap(div	+	sumhash['yearcount'+b].commify	+	((sumhash['yearcount'+b] > 1) ? ' bets -> $' : ' bet -> $' )	+	sumhash['year'+b].r2.commify	+	'</div>')
		rescue
			outstr	+=	Na
		end
	}
	outstr			+=	Tre
	outstr			+=	'</table>'
	@main			=	{}
	@main['pad']		=	false
	@main['heading']	=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	@main['desc']		=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	uta				=	[]
	th.each{|k,	v|
		uta			<<	v
	}
	bma				=	[]
	beta.each{|b|
		bma			<<	bth[b]
	}
	@main['content']	=	"#{lname} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - #{uta.sort.join(',')} - #{bma.sort.join(',')}"
	@main['rollwith']	=	outstr
	render :template=>"main/main.rhtml"
end

def soccer
	sa		=	IO.readlines("public/soccer seasons.txt")
	#	build table with season years across the top and league names down the left side
#	puts sa.inspect
#	raise
	# build year list
	yh		=	{}	#	year hash
	years	=	[]
	sa.each{|y|
		ta	=	y.split(',')
		yh[[ta[0],	ta[1]]]	=	ta[2]
		years	<<	ta[1].to_i
	}
	puts yh.inspect
#	raise
	years.uniq!
	years.sort!
	puts years.inspect
#	raise
	outstr	=	'<h2>Soccer Matrix<h2><br><table border = "1">'
	outstr	+=	"<th>"
	years.each{|y|outstr	+=	wrap(y)}
	outstr	+=	"</th>"
	
	lh	=	{}
	
	sa.each{|s|
		ta				=	s.split(',')
		lname			=	''
		lid				=	0
		if lh.has_key?(ta[0])
			lname		=	lh[ta[0]][0]
			lid			=	lh[ta[0]][1]
		else
			@slo		=	League.find_by_short_league(ta[0])
			lname		=	@slo.name
			lid			=	@slo.id
			slo			=	nil
			lh[ta[0]]		=	[lname,	lid]
		end
	}
	puts lh.inspect
#	raise

	la	=	lh.sort{|a,	b|a[0]<=>b[0]}
	puts la.inspect
#	raise
	la.each{|l|
		outstr	+=	"<tr>#{wrap(l[1][0])}"
#		puts l
#		raise
		years.each{|y|
#			puts y
			keyy	=	[l[0],	y.to_s]
			puts "keyy #{keyy.inspect}"
			if yh.has_key?(keyy)
				puts yh[keyy].inspect
				keyy2	=	l[0]+'^'+y.to_s
#				puts "keyy2 #{keyy2}"
#				sleep 1
				ss		=	Sum.find_by_key(keyy2)
				outstr2	=	"<div id='yellow'>No Betting Info</div>"
				div		=	"<div id='yellow'>$"
				div		=	"<div id='red'>$"	if	!ss.nil?	&&	ss.amount	<	0.0
				div		=	"<div id='green'>$"	if	!ss.nil?	&&	ss.amount	>	0.0
				outstr2	=	div+ss.amount.r2.commify+'</div>'	unless	ss.nil?
				#	 <a href="/main/main/2008?league=5">Joe Guy's 2008 NCAA Basketball Season</a><br>
				ls		=	'<a href="/main/makscr/'+"#{yh[keyy].chomp}?league=#{l[0]}"+'"'+">"+outstr2+'</a>'
				outstr	+=	wrap(ls)
			else
				outstr	+=	wrap('')
			end
		}
		outstr	+=	"</tr><br>\n"
	}
	outstr		+=	"</table>"
	puts yh.inspect
	puts outstr.inspect
#	raise
	@main			=	{}
	@main['pad']		=	false
	@main['desc']		=	"Joe Guy's Amazing Soccer Predictions"
	@main['content']	=	"Joe Guy's Amazing Soccer Predictions"
	@main['rollwith']	=	outstr
	render :template=>"main/main.rhtml"
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
			winprob	=	0.62			if year == 2008
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
=begin
=end
end
