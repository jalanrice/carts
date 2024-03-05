pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--candy land survival
--by bandd

--todo: eh.
function _init()
	--global variables
 local_time=0
 --options menu
 music_flag,drums_flag,stat_flag=true,false,false
 version="1.0.2"
 pattern_s=0 
 menuitem(1,"toggle music",toggle_music)
	menuitem(2,"drums only",toggle_drums)
	menuitem(3,"show stats",show_stats)
 -----------------
 pal(14,0)
 pal(15,12+128,1)
 pal(13,1+128,1)
 pal(1,1,1)
 -----------------
 init_states()
 init_mouse()
end

function _update()
 cls(0) 
 update_states()
end

function _draw()
	draw_states()
end
-->8
--tools
--print to center with shadow
function print_b_c(t,x,y,c1,c2)
	local _x=x-#t*2
	print(t,_x+1,y,c2)
	print(t,_x-1,y)
	print(t,_x,y+1)
	print(t,_x,y-1)
	print(t,_x,y,c1)
end

--get direction from cords
function get_dir(x1,y1,x2,y2)
	return atan2(x2-x1,y2-y1)
end

--get direction from objects
function get_dir_(a,b)
	return atan2(b.x-a.x,b.y-a.y)
end


function get_dist_n(a,b,n)
 local x=abs(a.x-b.x)
 local y=abs(a.y-b.y)
 if x+y<n*1.5 then
	 local  _d=sqrt(x*x+y*y)
  return _d<n and _d or n
 else
 	return n
 end 
end

function col(a,b,r)
 local x=abs(a.x-b.x)
 if x>r then return false end
 local y=abs(a.y-b.y)
 if y>r then return false end
 return (x*x+y*y)<r*r 
end

function player_col(e,e_d,dir)
 if p_invuln_c<1 then
 	if col(_p,e,4) then
 		add_popnum(64,64,"you cant catch me!!",5)
 		add_shake(38)
 		p_take_damage(e_d,dir,true)	
		end
 end 
end

function exp_range(xp,n)
	if abs(xp.x-64)<n and 
   	abs(xp.y-64)<n then 
	 return true 
	else
		return false
	end
end

function add_shake(n)
 shake=n
end

function update_shake()
 shake=max(shake-1,0)
	shk_x=(rnd(2)-1)*shake*0.5
 shk_y=(rnd(2)-1)*shake*0.5  
end

function local_time_cal()
	local_time=time()
end

function rpd(d,rd)
 local _dir=rnd(1)
	local _rad=d+flr(rnd(rd))
	local x=64+cos(_dir)*_rad
	local y=64+sin(_dir)*_rad
	return unpack({x,y})
end

function get_inputs()
 --register last inputs
 for x=1,8 do
 	p_i_last[x]=p_inputs[x]
 end
 local wasd=split("4,7,26,22,0,40")
 --register current inputs
 for x=1,6 do
 	p_inputs[x]=btn(x-1) or stat(28,wasd[x])
 end
 --asing direction values
 for x=1,4 do
		if p_inputs[x] then
		 p_i_data[x]=1
		else
			p_i_data[x]=0
		end
	end
end

function get_down(x)
	return p_inputs[x] and not p_i_last[x]
end

--mouse click and drag
--code by otto_piramuthu
function init_mouse()
 poke(0x5f2d,1)
	mouse_down_before=false
	mx,my,drag_x,drag_y=0,0,0,0
	drag_limit,drag_angle,drag_magnitude=6,0,0
end

function get_mouse()
 mx,my=stat(32),stat(33)
 mx=min(max(mx,0),250)
 my=min(max(my,0),128)
end

function update_mouse()
	get_mouse()
	if not mouse_down_before and lclick() then
		drag_x=mx
		drag_y=my
	end
	--update last mouse
	mouse_down_before=lclick()
	local dx = mx-drag_x
	local dy = my-drag_y
	drag_angle=atan2(dx,dy)
	drag_magnitude=min(sqrt(dx*dx+dy*dy),drag_limit)
end

function lclick()
 local l=stat(34)&1!=0
	return l
end

function draw_joystick()
	if lclick() then
		circfill(drag_x,drag_y,4,12)
		for x=0,drag_magnitude do
			circfill(
				drag_x+x*cos(drag_angle),
				drag_y+x*sin(drag_angle),
				1,15)
		end	
		circfill(
		drag_x+drag_magnitude*cos(drag_angle),
		drag_y+drag_magnitude*sin(drag_angle),2,7)
	end
end

function draw_cursor()
	spr(1,mx,my)
end

function global_beat()
 return stat(56)%80<12 and 1 or 0
end

function toggle_music()
	if music_flag then
		music_flag=false
		music(-1)
	else
	 music_flag=true
		if state==1 then
		 music(32)
		end
		if state==2 then
		 music(pattern_s,3)
		end
	end
end

function toggle_drums()
	if drums_flag then
		drums_flag=false
		pattern_s=0
	else
		drums_flag=true
		pattern_s=32
	end
	if music_flag then
		if state==1 then
		 music(32)
		end
		if state==2 then
		 music(pattern_s,3)
		end
	end
end

--count or reset
function c_or_r(c,n)
	if c>n then
		return 0
	else
		return c+1
	end
end

--starting characters
function init_start_chars()
 chars={}
 char_names={
  "the aprentice",
  "the purifier",
  "the stormcaller",
  "the possessed",
  "the moonkin"
 }
 selector=1
	for x=0,4 do
		local _c={
		 s=16*x
		}
		add(chars,_c)
	end
	c_ba,c_bs=0,0
	c_w1,c_w2,c_w3,c_w4,c_w5=false
	c_l_alt,c_b_alt,c_o_alt=false
end

function char_selected()
	c_spr=14+selector*2 
	--apprentice wizard 
	if selector==1 then
		c_w5=true
	end
	--arcane priest
	if selector==2 then
		c_w1=true
	end
	--lightning sorceror
	if selector==3 then
		c_w3=true
		c_l_alt=true
		c_ba=5
	end
	--hellblood spellbade
	if selector==4 then
		c_w4=true
		c_b_alt=true
		c_ba=5
		c_bs=0.2
	end
	--moonkin
	if selector==5 then
		c_w2=true
		c_o_alt=true
		c_bs=0.2
	end
end

function selector_m(n)
	selector+=n
	if selector>5 then
		selector=1
	end
	if selector<1 then
		selector=5
	end
end

function return_tomenu()
	if btnp(5) then
		state,menu_state,selector=1,1,1
	 s_init[2]()	
	 init_start_chars()
	end
end

function show_stats()
	stat_flag=not stat_flag
end

function draw_stats()
	if stat_flag then
	 local s=split"p_spd,p_hp_r,p_armor,p_invuln_f,p_xp_double,p_xp_radius"
  for i=0,#s-1 do
   local x=4+flr(i/3)*32
   local y=98+i%3*9,6
   spr(106+i,x,y)
  	print(_ENV[s[i+1]],x+10,y+2,15) 
  end
	end
end
-->8
--gamestates
function init_states()
	--statemachine index
	state=1
	--list of init functions
	s_init={init_menu,init_game}
	--list of update functions
	s_update={update_menu,update_game}
	--list of draw functions  
	s_draw={draw_menu,draw_game}
	--init input lists
	p_i_last,p_inputs,p_i_data={},{},{}
	--init menu
	s_init[state]()
	music(32)
end

function update_states()
 get_inputs() 
	s_update[state]()
end

function draw_states()
	s_draw[state]()
end

function init_menu()
	init_start_chars()
	menu_state=1
end

function update_menu() 
 local_time_cal()
 if menu_state==1 then
 	if btnp(5) or (lclick() and not mouse_down_before) then
 		menu_state=2
		end
 else
	 if menu_state==2 then
			if btnp(5) then
				start_game()
			end
			if get_down(5) then
				menu_state=1
			end
			if get_down(1) then
				selector_m(-1)
			end
			if get_down(2) then
				selector_m(1)
			end
			if lclick() and not mouse_down_before then
				if mx<48 then 
				 if my<24 then
				  menu_state=1
				 else
				  selector_m(-1)
     end		
				end
				if mx>96 then
					selector_m(1)
				end
				if mx>52 and mx<84 then
					if my>32 and my<96 then
						start_game()
					end
				end 
			end
		end
	end
	update_mouse()
end

function start_game()
	state=2
	char_selected()
	s_init[state]()	
end

function draw_menu()
 local _b=global_beat()
 if menu_state==1 then
 	map(96,0,0,0+_b)
		print("start",54,95+_b,7)
		print("❎",60,103+_b,7)
 end
	if menu_state==2 then
	 local _spr=14+selector*2+_b
	 print("choose",64-12,32+_b,7)
		spr(15,24-_b,64)
		spr(03,96+_b,64)
		spr(_spr,60,64)
		spr(31,8-_b,8)
		print(version,4,120+_b,1)
		print_b_c(char_names[selector],64,96+_b,7,0)
	end
	draw_cursor()
end

function init_game()
	--init functions
	init_ui()
	init_player()
	init_weapons()
	init_enemies()
	init_powerups()
	init_beacons()
	init_diffman()
 --music
 if state==2 and music_flag then
 	music(pattern_s,0,1+2)
 end
 --map functions
 map_x,map_y=0,0
 --light radius
 death_r,dither_r,light_r=0,68,56
 --victory
 victory_c=0
end

function update_game()
 if p_hp>0 and bss_hp>0 then
	 if not p_leveling then 
	  update_shake()
	  update_player()
		 update_weapons()
		 update_enemies()
		 update_exp()
		 update_beacons()
		 update_ui()
		 update_shockwave()
		 update_diffman()
		 --update map
		 map_x+=p_sx
	  map_y+=p_sy
	 else
	 	update_powerups()
	 end
	 local_time_cal()
	end
 update_mouse()
 --death screen
 if death_r>312 then
 	return_tomenu()
 end
 if bss_hp<=0 then
 	victory_c+=1
 	if victory_c==15 then
 		music(-1)
		end 	
 	update_shockwave()
 	if victory_c%8==0 
 	 and victory_c<200 then
 	 sfx(3,2) 
 	 add_shockwave(
 	 	rnd(128),rnd(128),32,8)
 	end
 end
end

function draw_game()
 --draw level
 --light affect by health
 --also a "breathing" effect
 local _h=1+(p_hp_m/(p_hp+10))
 local _t=sin(time()*0.25*_h)*(_h*0.5)
 --draw circles
 circfill(64,64,100,0)
 fillp(░)
 circfill(64,64,dither_r+_t-shake*2,13)
 fillp()
 circfill(64,64,light_r+_t-shake*3,1)
 --beacon radius
 draw_beacons_r()
 draw_shockwave()
 draw_lightnings()
 --draw scrolling map
 for i=0,2 do
 	for j=0,2 do
 		map(0,0,
 		map_x%128+128*i-128,
 		map_y%128+128*j-128)
		end
 end 
 if not p_leveling then
	 draw_joystick()
 end
 draw_exp()
 draw_weapons_u()
 draw_enemies()
 draw_beacons_b()
 draw_boss()
 draw_player()
 draw_beacons_o()
 draw_weapons_o()
 draw_fireballs()
 draw_ui()
 draw_beacons_dir()
 draw_player_hp()
 draw_time(112,8,true)
 draw_stats()
 local weapons=get_weapons()
 if p_leveling then
 	draw_powerups()
 else
 	draw_player_xp()
 end
 --victory
 if victory_c>120 then
  local _v=(victory_c-120)*2
 	circfill(bss_x,bss_y,_v,0)
 	if music_flag 
 	 and victory_c==300 then
 		sfx(30)
		end
 	if victory_c>250 then
 	 texts=
 		print_b_c(
 		"you are victorius!",
 		64,48,7,0)
 		print_b_c(
 		"the hellspawn are no more!",
 		64,64,7,0)
 		print_b_c(
 		"doom: "..(doom+difficulty),
 		64,92,7,0)
 		print_b_c(
 		"level: "..p_level,
 		64,102,7,0)
 		draw_time(64,112)
 		return_tomenu()
		end
 else
 	--death
	 if p_hp==0 then
	 	dither_r-=1
	 	light_r-=1
	  if light_r < 16 then
	  	rectfill(0,63-death_r,127,64+death_r,0)
	   death_r=min(350,death_r+2)
	   if death_r==80 then
	    if music_flag then
	    	music(32)
	    end 	
	   end
	  end
	  if death_r>80 then
	   print_b_c("game over",
		   64,56,7,0)
		  if death_r>160 then
		   draw_time(64,65) 
		   if death_r>232 then
		   	print_b_c(
		   	"doom :"..(doom+difficulty),
		   	64,74,7,0)
		   	if death_r>312 then
		   		print_b_c("❎ : restart",
		   	 64,83,7,0)
		   	 print(version,4,120,1)
						end
		   end
		  end
		 end
	 end
 end
 --draw cursor above all
 draw_cursor() 
end
-->8
--player
function init_player()
	--player aim direction
	_p={x=64,y=64}
	--health stats
	p_hp,p_hp_m,p_hp_r=100,100,0.1
	p_hp_r_a,p_regen_c=0,0
	--invuln frames
	p_invuln_f=30+c_ba
	p_invuln_c=0 --invuln counters
	--direction
	p_dir,p_dx,p_dy,p_sx,p_sx=0,0,0,0,0
	--other stats
	p_armor=0+c_ba
	p_spd=1.5+c_bs
	--level stats
	p_level,p_xp,p_xp_nextlevel,p_xp_double,p_xp_radius=unpack(split"1,0,0,0,28")
	calc_level_ex()
	p_leveling=false
 --animation variable
	p_s,p_flip=1,false	
	p_spr=c_spr
end

function update_player()
 --get direction (joystick check)
 get_direction()
 --set direction for movement
	set_direction()
	--regen update
	update_regen()
	--animation loop
 animate_player()
 --invulnerability counters
 p_invuln_c=max(p_invuln_c-1,0)
end

function get_direction()
 if lclick() then
  if drag_magnitude>1 then
  	p_dx=-cos(drag_angle)
	  p_dy=-sin(drag_angle)
  else
  	p_dx=0
  	p_dy=0
  end		
	else
		p_dx=p_i_data[1]-p_i_data[2]
		p_dy=p_i_data[3]-p_i_data[4]
	end
end

function set_direction()
 --get input and determine
 --direction
	p_sx,p_sy=p_dx,p_dy
	--set speed of each
	if abs(p_sx)==abs(p_sy) then
	 p_sx*=p_spd*0.7
	 p_sy*=p_spd*0.7
	else
		p_sx*=p_spd
	 p_sy*=p_spd
	end	
end

function update_regen()
	p_regen_c+=1 
	if p_regen_c>29 then
		p_regen_c=0
		p_hp_r_a+=p_hp_r
		if p_hp_r_a>1 then
			p_hp+=flr(p_hp_r_a)
			p_hp=min(p_hp,p_hp_m)
			p_hp_r_a-=flr(p_hp_r_a)
			add_popnum(64,56,"♥",10,true)
		 sfx(06,3)
		end
	end
end

--player take damage
---d is dmg
---i is boolean for iframes
function p_take_damage(d,i)
 sfx(2,3)
 local _d=d-p_armor
 if _d<ceil(d*0.4) then 
 	_d=ceil(d*0.4)
 end
	p_hp=max(p_hp-max(1,d-p_armor),0)
	if (i) p_invuln_c=p_invuln_f
end

function animate_player()
	--animation control
	if p_sx!=0 or p_sy!=0 then
		p_s+=1
	else
		p_s=0
	end
end

function draw_player()
	if not p_flip then
		if(p_sx>0)p_flip=true
	else
		if(p_sx<0)p_flip=false
	end
 --draw player
 if (p_invuln_c/2%2<1) then
  --spr(16+ceil(p_s*0.35%4),60,60,1,1,p_flip)
  draw_player_shadow()
  spr(p_spr+flr(p_s*0.35%2),
  60,60,
  1,1,p_flip)
 end
end

function draw_player_shadow()
 pal(12,0)
 pal(7,0)
 local _s=p_spr+flr(p_s*0.35%2)
	spr(_s,59,60,1,1,p_flip)
 spr(_s,61,60,1,1,p_flip)
 spr(_s,60,59,1,1,p_flip)
 spr(_s,60,61,1,1,p_flip)
 pal(12,12)
 pal(7,7)
end

-------------------------
--experience functions
-------------------------

function drop_exp(_x,_y,_xp)
 if #xp_list>135 then return end
	local _e={
	 x=_x,
	 y=_y,
		xp=_xp,
		d=600
	}
	add(xp_list,_e)
end

function update_exp()
	for xp in all(xp_list) do	 	 
	 if xp.d<=0 then
	 	del(xp_list,xp)
  else
   xp.d-=1
		 if exp_range(xp,p_xp_radius) then
		  local _dir=get_dir(64,64,xp.x,xp.y)
			 xp.x-=cos(_dir)*3
				xp.y-=sin(_dir)*3
			 if exp_range(xp,2) then
			  p_gain_xp(1)
			  sfx(1,2)
			 	del(xp_list,xp)		 	
	   end
	  else
	  	xp.x+=p_sx
	   xp.y+=p_sy
   end
	 end
	end
end

function draw_exp()
	for xp in all(xp_list) do
	 if exp_range(xp,64) then
	  local _b=xp.d<60 and xp.d%3<1
	  if not _b then
   	spr(2,xp.x-2,xp.y-3)
   end
  end		
	end
end

function calc_level_ex()
 local _xp=(p_level*p_level*0.45)+3
	p_xp_nextlevel=_xp
end

function p_gain_xp(n)
 if p_xp_double>0 then
 	local _r=ceil(rnd(100))
 	if _r<=p_xp_double then
 		p_xp+=n*2
 		add_popnum(54,56,"x2 xp",10,true)
		else
			p_xp+=n
		end
 else
 	p_xp+=n
 end	
	if p_xp>=p_xp_nextlevel then
		p_level_up()
	end
end

function p_level_up()
 sfx(4,3)
 if p_hp>0 then
 	p_xp-=p_xp_nextlevel
		p_level+=1	
		generate_powerups()
		p_leveling=true
		calc_level_ex()
		p_invuln_c=30
		if p_level%4==0 then
 	 power_up(
 	 gen_p_up(
 	 	get_random_passive()),
 	 false,
 	 true)
  end
 end
end
-->8
--weapons
function init_weapons()
 weapon_levels={0,0,0,0,0}
	init_cloak (c_w1)
	init_sphere(c_w2)
	init_strike(c_w3)
	init_blade (c_w4)
	init_arrow (c_w5)
	init_level_ups()
end

function update_weapons()
	update_cloak()
	update_sphere()
	update_strike()
	update_blade()
	update_arrow()
end

function draw_weapons_u()
	draw_cloak()
	draw_strike()
end

function draw_weapons_o()
	draw_sphere()
	draw_blade()
	draw_arrow()
end

------------------------
--weapon 1:flame cloak--
------------------------
function init_cloak(_b)
	cloak_state,cloak_id,cloak_r=_b,1,16 --radius
	cloak_d,cloak_t=3,15 --tick rate (b_mem)
	if cloak_state then
		weapon_levels[1]=1
	end
	--fire
	c_fire={}
end

function update_cloak()
 if not cloak_state then return end
	update_fire()
	for e in all(enemies) do
	 local _dam=e_bullet_mem(e,cloak_id)
	 if _dam then
	  if col(_p,e,cloak_r+e.r) then 	
   	e_take_damage(e,cloak_d,cloak_id,cloak_t)
	  end
	 end
	end
	if boss_mem(cloak_id) 
	 and bss_s_a then
		if col(_p,b_pos,cloak_r+10) then
			boss_damaged(cloak_d,cloak_id,cloak_t)
		end
	end
end

function draw_cloak()
 if not cloak_state then return end
 draw_fire()
 local _t=flr((time()*2)%4)+1
 local _l={🐱,⧗,▒,░}
 local _p={12,15,12,15}
	fillp(_l[_t])
	circ(64,64,cloak_r,_p[_t])
	fillp()
end

function cloak_p_up(p)
	if p.st==1 then 
		cloak_r+=p.am return end
	if p.st==2 then 
		cloak_d+=p.am	return end
	if p.st==3 then
		cloak_t-=p.am return end
end

--fire update
function add_fire()
	local _f={
		x=0,
		y=0,
		d=30
	}
	_f.x,_f.y=rpd(8,cloak_r-8)
	add(c_fire,_f)
end

function update_fire()
 add_fire()
	for f in all(c_fire) do
		f.d-=1
		if f.d<0 then
			del(c_fire,f)
		end
		f.y-=0.2
	end
end

function draw_fire()
	for f in all(c_fire) do
		pset(f.x,f.y,f.d>7 and 12 or f.d>3 and 15 or 1)
	end
end



---------------------------
--weapon 2:gravity sphere--
---------------------------

function init_sphere(_b)
	sphere_state,sphere_id=_b,2 --id
	sphere_r,sphere_o=2,12 --orbit radius
	sphere_d,sphere_c=4,2  --count
	sphere_time,sphere_time_counter=0,0
	sphere_alt1=false
	sphere_alt2=c_o_alt
	
	if sphere_state then
		weapon_levels[2]=1
	end
end

function sphere_p_up(p)
	if p.st==1 then 
		sphere_r+=p.am return end
	if p.st==2 then 
		sphere_o+=p.am	return end
	if p.st==3 then
		sphere_d+=sphere_alt2 and p.am+2 or p.am 
		return end
	if p.st==4 then
		sphere_c+=p.am return end
end

function update_sphere()
 if not sphere_state then return end
 sphere_time+=time()-local_time
 for e in all(enemies) do
  local _dam=e_bullet_mem(e,sphere_id)
  if _dam then
   --outer radius
   local _or=sphere_o*1.5+sphere_r+e.r
			local _d=col(_p,e,_or)
			--check if enemy in orbit
			--within outer, ouside inner
			if _d then
			 for x=1,sphere_c do
					local _s=get_sphere_pos(
						x,sphere_alt1,0,sphere_alt2)
					local _dist=sphere_r+e.r
				 _d=col(_s,e,_dist)	
				 if _d then
				  local _f=sphere_alt2 and 3 or 0
		   	e_take_damage(e,sphere_d,sphere_id,15-_f,true)
	    end
				end
	  end
	 end
	end
	if boss_mem(sphere_id) 
	 and bss_s_a then
		for x=1,sphere_c do
			local _s=get_sphere_pos(
				x,sphere_alt1,0,sphere_alt2)
			local _dist=sphere_r+8
		 if col(_s,b_pos,_dist)	then
		  local _f=sphere_alt2 and 3 or 0
		 	boss_damaged(sphere_d,sphere_id,15-_f)
	  end
	 end
	end
end

function draw_sphere()
 if not sphere_state then return end	
	if not sphere_alt1 then
		for y=3,1,-1 do
			for x=1,sphere_c do
			 if sphere_alt2 then
			  fillp(★)
			 	circ(64,64,sphere_o,15)
			 	fillp()
    end
			 local s=
			 	get_sphere_pos(
			 	x,sphere_alt1,y,sphere_alt2)
				circfill(
					s.x,s.y,
					y==1 and sphere_r or 1,
					y>2 and 15 or 12)
			 if y==1 then
			  local _a=flr(sphere_r/2)
			  rectfill(
			  s.x-_a,s.y-_a,
			  s.x+_a,s.y+_a,8)
	   end
			end
		end
	end
end

function get_sphere_pos(i,_a,i2,_b) 
	local _t=sphere_time*0.5
	if _a then _t=_t*.2 end
	if _b then _t=_t*2  end
	if _a and _b then
		_t*=5
	end
	local _f=i/sphere_c--c.division
	if i2 then 
		_f-=i2*0.025+0.025 --trail
	end
	local _r=sphere_o
	if _a then _r*=0.5*sin(sphere_time) end
 if _b then _r*=0.5 end
 local _x=64+sin(_t+_f)*_r
	local _y=64+cos(_t+_f)*_r
	if _b then
	 local _t2=_t*0.1
		_x+=sin(_t2)*sphere_o
	 _y+=cos(_t2)*sphere_o
	end
	local _s={x=_x, y=_y}
	return _s
end

---------------------------
--weapon 3:orbital strike--
---------------------------

function init_strike(_b)
	strike_state,strike_id=_b,3  --id
	strike_r,strike_d=8,8   --damage
	strike_c,strike_cd=1,0
	strike_tm,strike_alt_1=120,c_l_alt
	strikes={}
	if strike_state then
		weapon_levels[3]=1
	end
end

function strike_p_up(p)
	if p.st==1 then 
		strike_r+=p.am return end
	if p.st==2 then 
		strike_d+=p.am	return end
	if p.st==3 then
		strike_c+=p.am return end
	if p.st==4 then
		strike_tm-=p.am return end
	if p.st==5 then
		strike_alt_1=true return end
end

function add_strike(_x,_y,_id)
	local _s={
		x=_x, --posx
		y=_y, --posy
		id=_id,
		d=12 --duration
	}
	add(strikes,_s)
end

function update_strike()
 if not strike_state then return end
 --check cd and add_strike
	if strike_cd<=0 and #enemies>0 then
	 strike_cd=strike_tm
	 for x=1,strike_c do
	  sfx(5)
	  if strike_alt_1 then
	  	add_strike(64,64,x*3)
	  	if bss_s_a and x==1 then
    	add_strike(bss_x,bss_y,x*3)
    end
   else
    if bss_s_a and x==1 then
    	add_strike(bss_x,bss_y,x*3)
    else
	   	local _r=ceil(rnd(#enemies))
				 add_strike(
				  enemies[_r].x,
				 	enemies[_r].y,x*3)
			 end
   end 	
  end
	else
		strike_cd=max(strike_cd-1,0)
	end
	--strike check
	for s in all(strikes) do
	 --check enemies to hit
	 if s.d<11 then
		 for e in all(enemies) do
	  	local _dam=e_bullet_mem(e,strike_id)
		 	if _dam then
		 	 local rad=strike_r
		 	 if strike_alt_1 then
		 	 	rad+=5
     end
					if col(s,e,rad+e.r) then
						e_take_damage(e,strike_d,s.id,30)
					end
				end
		 end
  end 
  --hit boss
  if boss_mem(strike_id) 
   and bss_s_a then
			if col(_p,b_pos,strike_r+12) then
				boss_damaged(strike_d,s.id,30)
			end
		end
	 --move with player
	 s.x+=p_sx
		s.y+=p_sy
	 --clean up
		s.d-=1
		if s.d<=0 then 
			del(strikes,s) 
		end
	end
end

function draw_strike()
 if not strike_state then return end
	for s in all(strikes) do
	 local _c=s.d<4 and 7 or 12
	 fillp(▒)
	 circ(s.x,s.y,strike_r+(8-s.d)*strike_r*0.25,_c)
		fillp()
		for i=-1,1 do
			line(s.x+i,s.y,s.x+i,s.y-256,i==0 and 7 or 12)
		end
		fillp(░)
		circ(s.x,s.y,strike_r,_c)
		fillp()
		circfill(s.x,s.y,strike_r*0.5,_c)	 
	end
end

----------------------------
--weapon 4:returning blade--
----------------------------

function init_blade(_b)
	blade_state=_b
	blade_return=false
	blade_id,blade_r,blade_d,blade_cd,blade_c,blade_s,blade_ts,blade_sf,blade_x,blade_y,blade_dir,blade_frame,blade_ball
  =unpack(split"4,6,4,120,0,2,2,0.05,64,64,0,12,-1")  
	blade_alt1=c_b_alt
	if blade_state then
		weapon_levels[4]=1
	end
end

function blade_p_up(p)
	if p.st==1 then 
		blade_r+=p.am 
		if blade_alt1 then
			blade_r+=2
		end
		return end
	if p.st==2 then 
		blade_d+=p.am
		if	blade_alt1 then
			blade_d+=3
		end
		return end
	if p.st==3 then
		blade_cd-=p.am return end
	if p.st==4 then
	 if blade_alt1 then
	  blade_frame-=1
	 else
	  blade_s+=p.am 
		 blade_ts+=p.am
  end
		return 
	end
	if p.st==5 then
		blade_alt1=true return end
end

function update_blade()
 if not blade_state then return end
 --check if blade is ready
	if blade_c<=0 and #enemies>0 then
		blade_c=blade_cd
		if blade_ball!=-1 and blade_alt1 then
			blade_dir=blade_ball
			blade_ball=-1
		else
			local _r=ceil(rnd(#enemies))
			blade_dir=get_dir(
			 enemies[_r].x,
				enemies[_r].y,
				64,64)
			blade_x=64
		 blade_y=64
		end
		blade_ts=blade_s
		blade_return=false
	else
		blade_c=max(blade_c-1,0)
	end
	--blade movement
	if blade_c>0 then
		if not blade_return then
		 blade_moveout()
		else
		 if blade_alt1 then
		 	futbol_blade()
   else		
			 blade_comeback()
	  end
		end
	end
	--blade collision
	if blade_x!=64 and blade_y!=64 and blade_c>0  then
		--enemy colission
		for e in all(enemies) do
	 	local _dam=e_bullet_mem(e,blade_id)
	 	if _dam then
				if col({x=blade_x,y=blade_y},
					e,blade_r+e.r) then
					e_take_damage(e,blade_d,blade_id,blade_frame,true)
				end
			end		
		end
		--boss collision
		if boss_mem(blade_id) 
		 and bss_s_a then
			if col({x=blade_x,y=blade_y},
				b_pos,blade_r+8) then
				boss_damaged(
					blade_d,
					blade_id,30)
			end
		end
	end	
end

function blade_moveout()
	blade_ts*=1-blade_sf
	blade_x-=cos(blade_dir)*blade_ts-p_sx
	blade_y-=sin(blade_dir)*blade_ts-p_sy
 if blade_c<blade_cd-20 then
 	blade_return=true
 end
end

function blade_comeback()
	if abs(64-blade_x)>2 or
    abs(64-blade_y)>2 then
	 blade_dir=get_dir(64,64,blade_x,blade_y)
	 blade_ts*=1+blade_sf
	 local _x=-p_sx+cos(blade_dir)*blade_ts
	 local _y=-p_sy+sin(blade_dir)*blade_ts
 	blade_x-=_x
	 blade_y-=_y
 else
 	blade_x=64
 	blade_y=64
 end
end

function futbol_blade()
	if col({x=blade_x,y=blade_y},
		_p,blade_r+6) and blade_alt1 then
		blade_c=1
		blade_ball=get_dir(
			blade_x,blade_y,64,64)
	 sfx(07,2)
	 p_invuln_c=12
	end
	blade_x+=p_sx
	blade_y+=p_sy	
end

function draw_blade()
	if blade_x!=64 and blade_y!=64 and blade_c>0 then
		--circ(blade_x,blade_y,blade_r,7)
		local _x=cos(blade_c/10)*blade_r
		local _y=sin(blade_c/10)*blade_r
		local _sx=0
		local _sy=0
		for x=0,4 do
		 _sx=0
		 _sy=0
		 if x==0 then _sx= 1 end
		 if x==1 then _sx=-1 end
		 if x==2 then _sy= 1 end
		 if x==3 then _sy=-1 end
		 pal(12,12)
		 pal(7,7)
		 if x<4 then 
		 	pal(12,12)
		 	pal(7,12)
   end
			line(
				blade_x-_x+_sx,
				blade_y-_y+_sy,
				blade_x+_x+_sx,
				blade_y+_y+_sy,7)
			if blade_alt1 then
			circfill(
			 blade_x-_x+_sx,
			 blade_y-_y+_sy,
			 1,7)
			circfill(
			 blade_x+_x+_sx,
			 blade_y+_y+_sy,
			 1,7)
			else
		 circfill(
			 blade_x-_x*0.5+_sx,
			 blade_y-_y*0.5+_sy,
			 1,7)
			end
		end	
	end
end

-------------------------
--weapon 5:arcane arrow--
-------------------------

function init_arrow(_b)
	arrow_state=_b
	arrow_id,arrow_r,arrow_d,arrow_s,arrow_dur,arrow_ran,arrow_p,arrow_c,arrow_cd=unpack(split"5,2,4,2,24,24,1,0,15") 
	arrows={}
 if arrow_state then
		weapon_levels[5]=1
	end
end

function arrow_p_up(p)
	if p.st==1 then 
		arrow_r+=p.am return end
	if p.st==2 then 
		arrow_d+=p.am	return end
	if p.st==3 then
		arrow_s+=p.am return end
	if p.st==4 then
		arrow_dur+=p.am 
		arrow_ran+=p.am return end
	if p.st==5 then
		arrow_p+=p.am return end
	if p.st==6 then
		arrow_cd-=p.am return end
end

function add_arrow(_d)
	local a={
		x=64,
		y=64,
		d=arrow_dur,
		dir=_d,
		s=arrow_s,
		p=arrow_p
	}
	add(arrows,a)
end

function update_arrow()
 if not arrow_state then return end
 --shoot arrow
	if arrow_c<=0 then
	 --reset cooldown
	 arrow_c=arrow_cd
	 --get the closets enemy
		local _dist=128
  local _dir=-1
		for e in all(enemies) do
			local _d=get_dist_n(_p,e,_dist)
			if _d<_dist then
				_dist=_d
				_dir=get_dir(e.x,e.y,64,64)
			end
		end
		--target boss first
		local bss_dist=get_dist_n(
			_p,{x=bss_x,y=bss_y},
			arrow_ran)		
		if bss_dist<arrow_ran 
		 and bss_s_a then
			_dir=get_dir(
				bss_x,bss_y,64,64)
			add_arrow(_dir)
		else
			--add arrow if in range
			if _dist<arrow_ran then
				add_arrow(_dir)
			end
		end	
	else
		arrow_c=max(arrow_c-1,0)
	end
	--update arrows
	for a in all(arrows) do
	 --move
		a.x-=cos(a.dir)*a.s-p_sx
		a.y-=sin(a.dir)*a.s-p_sy
		--duration & destroy
		a.d-=1
		if a.d<=0 then
			del(arrows,a)
		end
		--boss
		if boss_mem(arrow_id) then
			if col(a,b_pos,
				arrow_r+8) then
				boss_damaged(
					arrow_d,
					arrow_id,
					12)
			end
		end
	end
	--collision
	for e in all(enemies) do
 	local _dam=e_bullet_mem(e,arrow_id)
 	if _dam then
 	 for a in all(arrows) do
				if col(a,e,arrow_r+e.r) then
					e_take_damage(e,arrow_d,arrow_id,arrow_cd,true)
				 a.p-=1
				 if a.p<0 then
				 	del(arrows,a)
     end
				end
   end	
		end		
	end
end

function draw_arrow()
	for a in all(arrows) do
	 local _x=cos(a.dir)*a.s*0.7
		local _y=sin(a.dir)*a.s*0.7
		fillp(░)
		circfill(a.x+_x*2,a.y+_y*2,arrow_r,12)
		fillp()
		circfill(a.x+_x,a.y+_y,arrow_r,12)
		circfill(a.x,a.y,arrow_r,7)
	end
end

------------------------
--levelup! managements--
------------------------
function init_level_ups()
 ---------------------
	-- cloak level ups --
	---------------------
	cloak_lv=split(
	 [[1,1,2,+2 radius
	 1,2,3,+3 damage
	 1,3,1,faster dmg
	 1,1,3,+3 radius
	 1,2,4,+4 damage
	 1,3,2,faster dmg
	 1,1,5,+5 radius
	 1,2,5,+5 damage
	 1,3,2,faster dmg
	 1,1,6,+6 radius
	 1,2,6,+6 damage
	 1,3,3,faster dmg]],"\n")
	cloak_maxed=false
 ----------------------
	-- sphere level ups --
	----------------------
 sphere_lv=split(
  [[2,4,1,more ●
		2,2,4,orbit+
	 2,3,8,+6 damage
	 2,1,1,bigger ●
	 2,4,2,more ●
	 2,2,6,orbit+
	 2,1,1,bigger ●
	 2,3,10,+8 damage
	 2,2,4,orbit+
	 2,4,3,more ●
  2,2,4,orbit+
	 2,3,10,+12 damage]],"\n")
	sphere_maxed=false	
 ----------------------
	-- strike level ups --
	----------------------
 strike_lv=split(
 [[3,1,5,+5 radius
 3,2,8,+8 damage
 3,4,20,+frequency
 3,3,1,+impacts
 3,1,7,+7 radius
	3,2,10,+10 damage
	3,4,25,+frequency
	3,3,1,+impacts
	3,1,9,+9 radius
	3,2,12,+12 damage
	3,4,30,+frequency
	3,3,1,+impacts]],"\n")
	strike_maxed=false
	---------------------
	-- blade level ups --
	---------------------
	blade_lv=split(
		[[4,1,2,+size
		4,2,4,+4 damage
		4,4,1,+speed
		4,3,15,-cooldown
		4,2,6,+6 damage
		4,4,1,+speed
		4,1,2,+size
		4,3,15,-cooldown
		4,4,1,+speed
		4,1,2,+size
		4,2,10,+10 damage
		4,3,15,-cooldown]],"\n")
	blade_maxed=false
	---------------------
	-- arrow level ups --
	---------------------	
	arrow_lv=split(
		[[5,3,2,+speed
		5,2,3,+3 damage
		5,4,12,+range
		5,5,1,+piercing
	 5,6,3,-cooldown
		5,2,4,+4 damage
		5,4,12,+range
		5,1,2,+radius
		5,5,2,+piercing
		5,2,5,+5 damage
	 5,6,3,-cooldown
	 5,6,3,-cooldown]],"\n")
	arrow_maxed=false
end

function get_cloak_next_p_up()
	return cloak_lv[1]
end

function get_sphere_next_p_up()
	return sphere_lv[1]
end

function get_strike_next_p_up()
	return strike_lv[1]
end

function get_blade_next_p_up()
	return blade_lv[1]
end

function get_arrow_next_p_up()
	return arrow_lv[1]
end

function cull_top_p_up(n)
 weapon_levels[n]+=1
	if n==1 then
		del(cloak_lv,get_cloak_next_p_up())
		if (#cloak_lv==0) cloak_maxed=true
	end
	if n==2 then
		del(sphere_lv,get_sphere_next_p_up())
		if (#sphere_lv==0) sphere_maxed=true
	end
	if n==3 then
		del(strike_lv,get_strike_next_p_up())
		if (#strike_lv==0) strike_maxed=true
	end
	if n==4 then
		del(blade_lv,get_blade_next_p_up())
		if (#blade_lv==0) blade_maxed=true 
	end
	if n==5 then
		del(arrow_lv,get_arrow_next_p_up())
		if (#arrow_lv<1) arrow_maxed=true
	end
end
-->8
--enemies
function init_enemies()
	enemies={}
	xp_list={}
end

function add_enemy(_x,_y)
 --enemy declaration
	local e ={
		x=_x,  --starting x
		y=_y,  --starting y
		d=0,   --direction to player
		r=4,   --radius
		s=d_spd, --speed
		hp=d_hp, --hitpoints
		dam=d_dam,--contact damage
		sp=d_s,
		--bullet memory
		bm={}
	}
	add(enemies,e)
end

function cell_angle()
	--offset degree
 --alpha of --0.25-0.3*2
 --4 sections of the circle
	--randomly pick one
	return 0.075+(rnd(1)/10)+(ceil(rnd(4))-1)*0.25
end

function add_enemy_r()
 local x,y=rpd(72,32)
	add_enemy(x,y)
end

function reset_enemy_pos(e)
 e.x,e.y=rpd(128,32)
end

function update_enemies()
	for e in all(enemies) do
	 --reset position if one
		--axis distance is too large
		if abs(64-e.x)>176 or
			abs(64-e.y)>176 then
			reset_enemy_pos(e)
		end
	 --get direction to player
	 e.d=get_dir(64,64,e.x,e.y)
	 --move
	 --player moves enemies
	 e.x-=cos(e.d)*e.s-p_sx
		e.y-=sin(e.d)*e.s-p_sy	
		--check player collide
		player_col(e,e.dam,e.d)
		--reduce frame of memories
		for m in all(e.bm) do
			if (m.f>0) then
				m.f-=1
			else
				del(e.bm,m)
			end
		end
	end
	
	--circ collision push for enemies
	for _x=1, #enemies-1 do
		for _y=_x+1, #enemies do
		 local r=enemies[_x].r+enemies[_y].r
			if col(enemies[_x],enemies[_y],r) then
			 local _dist=get_dist_n(enemies[_x],enemies[_y],10)
			 local _dir =get_dir_(enemies[_x],enemies[_y])
				local _dif =r-_dist
				enemies[_y].x+=cos(_dir)*_dif
				enemies[_y].y+=sin(_dir)*_dif
			end			
		end
	end
end

function e_bullet_mem(e,id)
	--default to take damage
 local take_damage=true	
 --check if enemy has memory 
 if (#e.bm>0) then
  --check for all memories
  for mem in all(e.bm) do
   --if we find the id
   --of this bullet in
   --the memories
 	 if mem.id == id then
 	  --dont take damage
 	 	take_damage=false
   end
  end
 end
 return take_damage
end

function e_take_damage(e,_d,_id,_f,_k)
	e.hp-=_d
	sfx(3,2)
	add_popnum(e.x,e.y,_d,5)	
	if(e.hp<=0) then
	 drop_exp(e.x,e.y,1)
		del(enemies,e)
		return
	else
		if _k then
		 local k_dis=_d
		 if k_dis<e.hp*2 then
		 	k_dis=_d*0.25
   end
			e.x+=cos(e.d)*k_dis
			e.y+=sin(e.d)*k_dis
		end
	end
	local m={
		id=_id,
		f=_f
	}
	add(e.bm,m)
end

function draw_enemies()
	for e in all(enemies) do
	 --flip control
	 local _f=false
	 if (e.x>64) _f=true
	 --recently hit flicker
	 local flick=0
	 if(#e.bm>0) flick=16
	 if(time()%2>0) flick=0
	 --draw
		spr(
			e.sp+time()*8%2+flick,
			e.x-3,e.y-3,1,1,_f)
	end 
end

---------------------
-- beacons of doom --
---------------------

function init_beacons()
	beacons={}
	bcn_counter=30*45
	bcn_timer=30*45
end

function update_beacons()
 --add beacon on timer
 bcn_counter=c_or_r(bcn_counter,bcn_timer)
	if bcn_counter==0 then
		local _b={
			x=0,
			y=0,
			d=30*45,
			r=42,
			c=0
		}
		_b.x,_b.y=rpd(96,32)
		add(beacons,_b)
	end
	--update beacon timer
	for b in all(beacons) do
	 --move
	 b.x+=p_sx
		b.y+=p_sy	
	 --charge
	 local p_in_range=col(_p,b,b.r)
	 if p_in_range then
	 	b.c+=1
	 	if b.c>30*10 then
	 		add_doom()
	 		add_popnum(b.x,b.y,
	 		"+doom!",15,true)
	 		beacon_death(b)
	 		add_shockwave(b.x,b.y,25,8)
	 		del(beacons,b)
	 		sfx(5,2)
			end 	 
  else
		 --duration
			b.d-=1
			if (b.d<0) del(beacons,b)
		end
	end
end

function draw_beacons_r()
	for b in all(beacons) do
	 local _r=42*b.c/(30*10)
		circfill(b.x,b.y,_r,2)
		circ(b.x,b.y,b.r,12)
	end
end

function draw_beacons_dir()
	for b in all(beacons) do		
		local dir=get_dir(64,64,b.x,b.y)
		local x=64+cos(dir)*8
		local y=64+sin(dir)*8
		circfill(x,y,1,0)
		pset(x,y,8)
	end
end

function draw_beacons_b()
	for b in all(beacons) do
	 if b.y<65 then
	 	spr(12,b.x-3,b.y-8+sin(time()))
		 spr(13,b.x-3,b.y-4)
  end	
	end
end

function draw_beacons_o()
	for b in all(beacons) do
	 if b.y>=65 then
	 	spr(12,b.x-3,b.y-8+sin(time()))
		 spr(13,b.x-3,b.y-4)
  end	
	end
end
-->8
--ui
function init_ui()
	init_popnums()
	init_shockwave()
	ig_time=0
 --screen shake
 shake=0
	shk_x=0
	shk_y=0
end

function update_ui()
	update_popnums()
	ig_time+=time()-local_time	
end

function draw_ui()
	draw_popnums()
end

function init_popnums()
	popnums={}
end

function draw_player_hp()
 local _c=shk_x!=0 and 8 or 7
	print_b_c(
	"hp: "..p_hp.."/"..p_hp_m,
	28+shk_x,8+shk_y,_c,0)	
end

function draw_player_xp()
	rectfill(0,0,127,4,5)
	rectfill(1,1,flr(p_xp/p_xp_nextlevel*126),3,12)
	rect(0,0,127,4,7)
	rect(0,4,127,4,6)
end

function add_popnum(_x,_y,_n,_d,_c)
	local _p={
	 x=_x-1, --posx
	 y=_y-2, --posy
		n=_n, --number
		d=_d, --duration
		c=false
	}
	if _c then _p.c=true end
	add(popnums,_p)
end

function update_popnums()
	for p in all(popnums) do
	 p.x+=p_sx+shk_x
		p.y+=p_sy-2+shk_y
		if p.c then
			p.y+=1
		end
		p.d-=1
		if p.d<=0 then 
			del(popnums,p) 
		end
	end
end

function draw_popnums()
	for p in all(popnums) do
	 print_b_c(p.n.."",p.x,p.y,7,0)
	end
end

function draw_time(x,y,s)
 local _c=shk_x!=0 and 8 or 7
	local _x=flr(ig_time)%60
 local _y=(flr(ig_time)-_x)/60
 if not s then _c=7 end
 local at_x=x
 local at_y=y
 if s then 
 	at_x-=shk_x
 	at_y-=shk_y
 end
 if(_x<10) _x="0".._x
 if(_y<10) _y="0".._y 
 print_b_c(_y..":".._x,
 	at_x,at_y,_c,0)
end

function init_shockwave()
	s_wave={}
end

function update_shockwave()
	for s in all(s_wave) do
		s.r+=4
		s.d-=1
		if s.d<=0 then
			del(s_wave,s)
		end
	end
end

function add_shockwave(_x,_y,_d,_c)
	local _s={
	 x=_x,
		y=_y,
		d=_d,
		c=_c,
		r=0
	}
	add(s_wave,_s)
end

function draw_shockwave()
	for s in all(s_wave) do
		circ(s.x,s.y,s.r,s.c)
	end
end
-->8
--powerups
function init_powerups()
 --list for ui interaction
	screen_powerups={}
	--weapons powerups
	wpn_p_ups={
		cloak_p_up,
		sphere_p_up,
		strike_p_up,
		blade_p_up,
		arrow_p_up
	}
 wpn_level={
	 get_cloak_next_p_up,
	 get_sphere_next_p_up,
	 get_strike_next_p_up,
	 get_blade_next_p_up,
	 get_arrow_next_p_up
 }
 wpn_unlock={
 	"0,1,0,flame cloak!",
 	"0,2,0,astral orbit!",
 	"0,3,0,falling star!",
 	"0,4,0,arcane edge!",
 	"0,5,0,magic bolt!"
 }
 --passive powerups
 pass_p_ups={
	 health_p_up,
	 speed_p_up,
	 hp_reg_p_up,
	 armor_p_up,
	 iframe_p_up,
	 double_xp_p_up,
	 radius_xp_p_up
 }
 passives={}
 init_passives()
 --counter (to not spam it)
 p_up_c=0
 --animation sfx
 p_up_t=0
end

function update_powerups()
 p_up_c+=1
 if p_up_c<30 then return end
 --selection with directionals
 for x=1,4 do
 	if p_inputs[x] and not p_i_last[x] then
 		i_sect= x%2>0 and i_sect-1 or i_sect+1
		 if i_sect<1 then i_sect=3 end
		 if i_sect>3 then i_sect=1 end
		end
 end
 --click/touch selection
	if not mouse_down_before and lclick() then
		if mx>=48 and mx<112 then
		 local _s=i_sect
		 i_sect=-1
			if my>=38 and my<54 then
				i_sect=1
			end
			if my>=56 and my<72 then
				i_sect=2
			end
			if my>=74 and my<90 then
				i_sect=3
			end
			if i_sect>0 then
				p_leveling=false
				power_up(
					screen_powerups[i_sect],
					screen_powerups[i_sect].tp<17)
	 		return
			else
				i_sect=_s
			end
		else
			return
		end		
	end
	--❎ selection
	if p_inputs[6] and not p_i_last[6] then
		p_leveling=false
		power_up(
			screen_powerups[i_sect],
			screen_powerups[i_sect].tp<17)
	 return
	end
end

function draw_powerups()
 p_up_t=min(p_up_t+2,100)
 --area
	rectfill(0,32,0+p_up_t*16,96,0)
	line(-1,33,0+p_up_t*16,33,6)
	line(-1,95,0+p_up_t*16,95,6)
	if p_up_t>10 then
		--item bg
		for i=1,3 do
			spr(64,48,20+18*i,2,2)
		end
	end
	--power up sprites
	for x=1,3 do
	 if p_up_t>20+x*3 then
	 	local _x,_y=48,20+18*x
		 local _sm,_spr=0,0
		 local size=1
			local t=screen_powerups[x].tp
			if t<17 then
				size=2
				if t==0 then
				 local st=screen_powerups[x].st
					_spr=64+st*2
				else
					_spr=64+t*2
				end
			else
			 _sm+=4
			 _spr=105-17+t		
			end	
			spr(_spr,_x+_sm,_y+_sm,
				size,size)
			print(screen_powerups[x].tx,
		 	_x+24,_y+5,7)	
  end
	end
	
	--selector and text
	if p_up_t>30 then
	 print_b_c("level "..p_level,20,43,7,0)
 	spr(3,36+flr(time()%2),24+18*i_sect)		
		print("choose!",6,58,7)
		print("❎",14,67,5)
		print("❎",14,66,7)
		
			--icons
		local w=get_weapons()
		local x=0
		for _w in all(w) do
		 spr(6+_w,3+x,80)
		 local l=weapon_levels[_w]
		 print(l>1 and l-1 or "",8+x,85)
			x+=12
		end
	end	
end

--generate
function generate_powerups()
 screen_powerups={}
	--weapon upgrade
	local data_1=obtain_power_slot1()
 add(screen_powerups,gen_p_up(data_1)) 	
	--weapon or passive
	local data_2=obtain_power_slot2()
	for x=1,3 do
		if data_2==data_1 then
			data_2=obtain_power_slot2()
		end
	end	
	if data_2==data_1 then
		data_2=get_random_passive()
	end
 add(screen_powerups,gen_p_up(data_2))
	--passive upgrade
	local data_3=get_random_passive()
	if data_3==data_2 then
		data_3=get_random_passive()
	end
	add(screen_powerups,gen_p_up(data_3))
	i_sect=1
	--reset counter
	p_up_c=0
	p_up_t=0
end

function get_weapons()
	local weapons={}
	if(cloak_state)  add(weapons,1) 
	if(sphere_state) add(weapons,2) 
	if(strike_state) add(weapons,3) 
	if(blade_state) 	add(weapons,4) 
	if(arrow_state)  add(weapons,5) 
	return weapons
end

function get_max_weapons()
	local m_wpn={}
	if(cloak_maxed) add(m_wpn,1) 
	if(sphere_maxed)add(m_wpn,2) 
	if(strike_maxed)add(m_wpn,3) 

	if(blade_maxed) add(m_wpn,4) 
	if(arrow_maxed) add(m_wpn,5) 
	return m_wpn
end

function get_random_passive()
	return passives[ceil(rnd(7))]
end

function obtain_power_slot1()
	--get active weapons
	local weapons=get_weapons()
	local mx_wpns=get_max_weapons()
	--if not weapons available
	--return passive powerup
	if #weapons==#mx_wpns then
		return get_random_passive()
	end
	--you are going too fast
	if p_level>6 and #weapons==1 then
	 return get_random_passive()
	end
	--otherwise randomly pick one
	local _uw={}
	for w in all(weapons) do
	 local bool=true
		for wm in all(mx_wpns) do
		 if w==wm then
		 	bool=false
   end
	 end
	 if bool then
	 	add(_uw,w)
  end
	end
	if #_uw>0 then
		local _w=_uw[ceil(rnd(#_uw))]
		--select next upgrade
		return wpn_level[_w]()
	else
		return get_random_passive()
	end	
end

function get_innactive()
 local iw={}
	if(not cloak_state)  add(iw,1) 
	if(not sphere_state) add(iw,2) 
	if(not strike_state) add(iw,3)
	if(not blade_state)  add(iw,4) 
	if(not arrow_state)  add(iw,5) 
	return iw
end

function obtain_power_slot2()
 --get non active weapons
	inn_wpns=get_innactive()
	local n_iw=#inn_wpns
	--player should recive
	--random new weapon
	if n_iw>2 then
	 --player needs a new weapon
		if p_level>6 and n_iw==4 then
			return 
			 rnd_wpn_unlock(n_iw,
		 	inn_wpns)
		else
			--flip a weighted coin
		 if ceil(rnd(3))>1 then
		 	return 
		  	rnd_wpn_unlock(n_iw,
		 	 inn_wpns)
		 else
			 return get_random_passive()
		 end
		end
	else
  --flip a weighted coin
	 if ceil(rnd(3))>1 then
	 	return obtain_power_slot1()
	 else
		 return get_random_passive()
	 end
	end
end

function rnd_wpn_unlock(n,iw)
	--rng a number among the iw
	local _rn=ceil(rnd(n))
	--get the weapon id
	local _w=iw[_rn]
	--retunr their unlock
	return wpn_unlock[_w]
end

--return table with p_up data
function gen_p_up(_data)
 local data=split(_data,true)
 print(data)
	local _p={
		tp=data[1], --type
		st=data[2], --sub type
		am=data[3], --amount
		tx=data[4]  --text
	}
	return _p
end

--call when activating p_up
function power_up(_p,w,_s)
 if not _s then
  sfx(0,3)
 end
 local _y=60
 if _s then
 	_y=52
 end
 add_popnum(64,_y,_p.tx,15,true)
 if _p.tp==0 then
 	unlock_wpn(wpn_unlock[_p.st])
 else
	 if w then
	  cull_top_p_up(_p.tp)
	 	wpn_p_ups[_p.tp](_p)
	 	return
	 else
	 	pass_p_ups[_p.tp-16](_p.am)
	 end	
	end
end

function unlock_wpn(_tx)
	local _p=gen_p_up(_tx)
	local st=_p.st
	weapon_levels[st]+=1
	if st==1 then
		cloak_state=true
	end
	if st==2 then
		sphere_state=true
	end
	if st==3 then
		strike_state=true
	end
	if st==4 then
		blade_state=true
	end
	if st==5 then
		arrow_state=true
	end
end

----------------------
-- passive powerups --
----------------------

function init_passives()
	--health upgrade
	passives=split(
	[[17,0,20,+20 hp
			18,0,.15,+10% spd
			19,0,.1,+0.1 regen
			20,0,3,+3 armor
			21,0,10,+iframes
			22,0,10,+10% x2 xp
			23,0,2,+2 xp rad]],"\n")
end

function health_p_up(am)
 p_hp+=am
	p_hp_m+=am
end

function speed_p_up(am)
	p_spd+=am
end

function hp_reg_p_up(am)
	p_hp_r+=am
end

function armor_p_up(am)
	p_armor+=am
end

function iframe_p_up(am)
	p_invuln_f+=am
end

function double_xp_p_up(am)
	p_xp_double+=am
end

function radius_xp_p_up(am)
	p_xp_radius+=am
end

-->8
--difficulty management
function init_diffman()
	doom,_enemy_count=0,0
	------dificulty variables
	difficulty,d_counter=0,0
	d_seconds,d_increase=45,1350 --30*45
	------enemy stats
	d_hp,d_dam=8,10
	d_s,d_spd=32,0.4
	------beacons spawner
	old_bx,old_by,summ_counter=0,0,0
	------lightninigs
	lightnings={}
	------boss
	init_boss()
end

function update_diffman()
	--add enemies
 _enemy_count=bss_a and 55 or
 min(80,10+difficulty*8+doom*6)
 if #enemies<_enemy_count then
  add_enemy_r()
 end
 --beacon spawner
 update_summoned()
 update_lightning()
 update_difficulty()
 update_boss()
 --boss
 if ig_time>480 then
 	bss_a=true
 end
end

function update_difficulty()
 d_counter=c_or_r(d_counter,d_increase)
	if d_counter==0 then
		difficulty+=1
		update_d_stats()
	end
end

function update_d_stats()
	d_hp =8+difficulty*3+doom
	d_dam=10+difficulty+doom 
 local _g_diff=difficulty*2+doom
 d_s=_g_diff>21 and 38 or 
 				_g_diff>14 and 36 or 
 				_g_diff> 7 and 34 or 32
 d_spd=min(p_spd-0.4,0.4+(difficulty/20))
end

function add_doom()
	doom+=1
	d_seconds=max(30,45-doom)
	d_increase=30*d_seconds
end

function beacon_death(b)
	old_bx=b.x
	old_by=b.y
	summ_counter=30
end

function update_summoned()
	if summ_counter>0 then
		summ_counter-=1
		if summ_counter%5==1 then
		 local _x,_y=rpd(50-summ_counter,0)
	 	add_enemy(_x,_y)
	 	add_lightning(_x,_y,18)
	 	add_shockwave(_x,_y,8,8)
	 	sfx(05)
		end
	end
end

function update_lightning()
	for l in all(lightnings) do
		--duration
		l.d-=1
		if l.d<0 then
			del(lightnings,l)
		end
		--position
		l.x+=p_sx
		l.y+=p_sy
	end
end

function draw_lightnings()
	for l in all(lightnings) do
		line(l.x,  l.y,l.x  ,-1,8)
		line(l.x-1,l.y,l.x-1,-1,2)
		line(l.x+1,l.y,l.x+1,-1,2)
	end
end

function add_lightning(_x,_y,_d)
	local _l={
	 x=_x,
	 y=_y,
	 d=_d
	}
	add(lightnings,_l)
end
-->8
--boss
function init_boss()
 --active
 bss_a=false
 --boss state
 bss_s,bss_s_c=1,0
 --boss times for each state
 bss_act1,bss_act2,bss_act3=60,300,240
 --boss ai move
 bss_mov,bss_fc=2,0
 --position
 bss_x,bss_y,bss_hp=0,0,8192
	--radius
	bbs_r=8
	--sprite active
	bss_s_a=false
	--sprite number
	bss_spr=44
	--fireballs
	fireballs={}
	--bullet memory
	bss_bm={}
	--referenced position
	b_pos={x=bss_x,y=bss_y}
	bss_ai={boss_ai_s1,boss_ai_s2,boss_ai_s3}
end

function update_boss()	
	if bss_a and bss_hp>0 then	 
	 --movement
	 bss_x+=p_sx
	 bss_y+=p_sy
	 b_pos={x=bss_x,y=bss_y}
	 --machine state
	 boss_state()
		bss_ai[bss_s]()	
	end
	update_fireballs()
	--reduce frame of memories
	for m in all(bss_bm) do
		if (m.f>0) then
			m.f-=1
		else
			del(bss_bm,m)
		end
	end
end

function boss_ai_s1()
	if bss_s_c==1 then
	 bss_x,bss_y=rpd(32,16)
		add_lightning(bss_x,bss_y,8)
	end
	if bss_s_c==8 then
		add_shockwave(bss_x-1,bss_y+8,12,8)
	 bss_s_a=true 
	 add_lightning(bss_x,bss_y,8)
	end
	if bss_s_c==16 then
	 bss_s_a=true 
	 bss_spr=44
	 add_shockwave(bss_x-1,bss_y+8,12,8)
	 add_lightning(bss_x,bss_y,8)
	end
end

function boss_ai_s2() 
	if bss_s_c>=30 then
		if bss_mov==1 then
		 bss_spr=46
			if bss_s_c%6==0 and bss_s_c>60 then
				add_fireball(2,1,3)
				sfx(3,2)
			end
		end
		if bss_mov==2 then
		 bss_spr=46
			if bss_s_c%12==0 and bss_s_c>60 then
				bss_fc+=0.05
				for x=1,6 do
					local _d=x/6+bss_fc
					add_fireball(0.6,2,2,_d)
					sfx(3,2)
				end
			end
		end
	end
end

function boss_ai_s3()
 bss_spr=44
	if bss_s_c==200 then
		add_lightning(bss_x,bss_y,8)
		bss_s_a=false
	end
end

function boss_mem(id)
	--default to take damage
 local take_damage=true	
 --check if enemy has memory 
 if (#bss_bm>0) then
  --check for all memories
  for mem in all(bss_bm) do
   --if we find the id
   --of this bullet in
   --the memories
 	 if mem.id == id then
 	  --dont take damage
 	 	take_damage=false
   end
  end
 end
 return take_damage
end

function boss_damaged(_d,_id,_f)
	if bss_s_a then
		bss_hp-=_d
		sfx(3,2)
		add_popnum(bss_x,bss_y,_d,15)
		local m={
			id=_id,
			f=_f
		}
		add(bss_bm,m)
	end
end

function draw_boss()
 if bss_s_a then
 	spr(bss_spr,bss_x-8,bss_y-8,2,2)
 end	
end

function boss_state()
	bss_s_c+=1
	if bss_s==1 then
		if bss_s_c>bss_act1 then
			bss_s_c=0
			bss_s=2
		end
	end
	if bss_s==2 then
		if bss_s_c>bss_act2 then
			bss_s_c=0
			bss_s=3
		end
	end
	if bss_s==3 then
		if bss_s_c>bss_act3 then
			bss_s_c=0
			bss_s=1
			bss_mov+=1
			if bss_mov>2 then
				bss_mov=1
			end
		end
	end
end

function add_fireball(_s,_t,_r,_d)
	local _f={
	 x=bss_x,
	 y=bss_y,
	 d=0,
	 t=_t,
	 r=_r,
	 dur=30*5,
	 s=_s	 
	}
	if _t==1 then
		_f.d=get_dir(64,64,bss_x,bss_y)
	end
	if _t==2 then
		_f.d=_d
	end
	add(fireballs,_f)
end

function update_fireballs()
	for f in all(fireballs) do
	 player_col(f,ceil(d_dam/2),0)
	 f.dur-=1
	 if f.dur<0 then
	 	del(fireballs,f)
  end
		local _x=p_sx
		local _y=p_sy
		if f.t==1 then
			_x-=cos(f.d)*f.s
			_y-=sin(f.d)*f.s
		end
		if f.t==2 then
		 f.s+=0.01
			_x-=cos(f.d)*f.s
			_y-=sin(f.d)*f.s
		end
		f.x+=_x
		f.y+=_y
	end
end

function draw_fireballs()
	for f in all(fireballs) do
 	circfill(f.x,f.y,f.r+1,0)
		circfill(f.x,f.y,f.r,10)
		circ(f.x,f.y,f.r,8)
	end
end
__gfx__
000000000099490000000000000070000000700000070000000ee00009787890000000c000000000770000000000aaaa000e0000000000007777777700070000
0000000009999990000000000000e7000000e700007e000000ec7e0097878789000f0a000000000088800000000aaaaa00e8e0000000000077777777007e0000
00700700094994900686000000007e7000007e7007e700000ecc77e098787879ac0000f06666666607770000000aaaaa0e888e00000000007777777707e70000
0007700009999990086800000000e7e70000e7e77e7e00000ecccce097878789000800080555655000888000000aaa0ae28888e00e000e00777777777e7e0000
00077000099499900686000000007e7800007e7887e70000ececcece9878787980a00b000656656000077700000a0aaa0e288e00e8eee8e07777777787e70000
0070070009999990000000000000e7500000e750057e0000ec7ee7ce978787890f000f0b06566560000088800700000000e2e0000e888e0077777777057e0000
000000000049940000000000000078000000780000870000ece77ece09787890000c0000055565500000077770007700000e0000e82228e07777777700870000
000000000000000000000000000050000000500000050000ec7ee7ce009999000800b0a006666660000000887007700000000000eeeeeee07777777700050000
09999900099999000999990009999900099999000999990009999900099999000999990009999900000000000000000000000000000000000000000000700000
09989800099898000998980009989800099898000998980009989800099898000998980009989800000000000000000000000000000000000000000007700000
09999900099999000999990009999900099999000999990009999900099999000999990009999900000000000000000000000000000000000000000077707700
09444900094449000944490009444900094449000944490009444900094449000944490009444900000000000000000000000000000000000000000057705770
909a9090909a9090909c9090909c90909098909090989090909b9090909b9090909e9090909e9090000000000000000000000000000000000000000005700770
00999000009990000099900000999000009990000099900000999000009990000099900000999000000000000000000000000000000000000000000000500750
009a9000009a9900009c9000009c99000098900000989900009b9000009b9900009e9000009e9900000000000000000000000000000000000000000007777500
09000900009000000900090000900000090009000090000009000900009000000900090000900000000000000000000000000000000000000000000005555000
000000000000000000b3b0b000b3b0b0004444000044440000b3b30000b3b3000000000000000000000000000000000000000000000000000000000000000000
0b0b0b00000b0b000888888800888888079444400794444003b3b3b003b3b3b00000000000000000000000000000000000000000000000000000000000000000
bbbbbbb00bbbbbb08888858508888585494445454944454503b3b3b003b3b3b00000000000000000000000000000000000000000088880000000000008888000
09995900009595008888888808888888444444444444444403b3535003b353500000000000000000000000000000000000008000888888000000800088888800
09999900009999008888888808888888004444000044440003b3b3b003b3b3b00000000000000000000000000000000000888800888888800088880088888880
09999900009999008888888800888880004444000044440003b3b3b003b3b3b000000000000000000000000000000000088888808888888008888880888888b0
00999000000999000888888000000000004444000044440003b3b3b000b3b3000000000000000000000000000000000088888888888888808888888888888bbb
00090000000090000000000000000000004444000000000000b3b300000000000000000000000000000000000000000088888888888858808888888888885999
000000000000000000b3b0b000b3b0b0004444000044440000b3b30000b3b3000000000000000000000000000000000088888888588888b08888888858888999
0b0b0b00000b0b000888888800888888079444400794444003b3b3b003b3b3b0000000000000000000000000000000008888888888888bbb8888888888888999
bbbbbbb00bbbbbb08888858508888585494445454944454503b3b3b003b3b3b00000000000000000000000000000000088888888888889998888888888888999
09995900009595008888888808888888444444444444444403b3535003b353500000000000000000000000000000000088888888888889998888888888888999
09999900009999008888888808888888064646060646460603b3b3b003b3b3b00000000000000000000000000000000008888888888009990888888888800090
09999900009999008888888800888880666666660666666603b3b3b003b3b3b00000000000000000000000000000000000888888800009990088888880000000
00999000000999000888888000000000606464600064646003b3b3b000b3b3000000000000000000000000000000000000088888800009990008888880000000
00090000000090000000000000000000004444000044440000b3b300000000000000000000000000000000000000000000008888000000900000888800000000
000000000000000009787890097878900000000000000000555666555555555577000000770000000000aaaa0000aaaa00000000000000000000000000000000
07801111111108709787878997878789888880008888800056565556665555558880000088800000000aaaaa000aaaaa00000000000000000000000000000000
08011111111110809878787878787879898987708989800055566656565555550777000007770000000aaaaa000aaaaa00000000000000000000000000000000
00111111111111009787878787878789888880008888800056500556665555500088800000888000000aaa0a000aaa0a00000000000000000000000000000000
01111111111111109878787878787879888887708888800006000556555555000007770000077700000a0aaa000a0aaa00000000000000000000000000000000
01111111111111109787878787878789080800000808000000000556660000000000888000008880070000000700000000000000000000000000000000000000
01111111111111100978787878787890000000000707000000000050550000000000077700000777700077007000770000000000000000000000000000000000
01111111111111100099998787999900007070000707000000000000890000000000008800000088700770007007700000000000000000000000000000000000
011111111111111009787878787878900070700000000000000000089a00000077000007770000000000aaaa0000aaaa00000000000000000000000000000000
011111111111111097878787878787898888807788888000000000089a0000008880000088800000000aaaaa000aaaaa00000000000000000000000000000000
01111111111111109878787878787879898980008989800000000009a00000000777000007770000000aaaaa000aaaaa00000000000000000000000000000000
01111111111111109787878787878789888880778888800000000089a00000000088800000888000000aaa0a000aaa0a00000000000000000000000000000000
00111111111111009878787878787879888880008888800000000089a00000000007770000077700000a0aaa000a0aaa00000000000000000000000000000000
0801111111111080978787899787878908080000080800000000009aa00000000000888000008880070000000700000000000000000000000000000000000000
0780111111110870097878900978789000000000000000000000089aa00000000000077700000777700077007000770000000000000000000000000000000000
0000000000000000009999000099990000000000000000000000089aa00000000000008800000088700770007007700000000000000000000000000000000000
9999999999999999999999999999999999999999999999999999999999999999000000004444444400aaaaa00000080000999900009999900000000000000000
9999999999999999999999999999999999999999999999999999999999999999000000009989899900aaeae00000878000898900009989800787000000000070
9999999999999999999999999999999999999999999999999999999999999999000000004888884477aaaaa00000787000999900779999900878000000007007
9999999999999999999999999999999999999999999999999999999999999999800000009888889900aa99900070070000944900009944400787077778700707
999999999999999999999999999999999999999999999999999999999999999980000000488888440aa6aaaa0787000096666669099a99990000000787800707
9999999999999999999999999999999999999999999999999999999999999999800000009988899977aaaa000878000000666600779999000707077778700707
9999999999999999999999999999999999999999999999999999999999999999800000004448444400a6aa000080000000666600009a99000070070000007007
9999999999998888999999999999999999999999999988889999999999999999000000000000000000a00a000000000000900900009009000707077700000070
99999999998888888988999999999999999999999988888889889999999999990000000000000000000000000000000000000000000000000000000000000000
99999999988800088988899999999999999999999888000889888999999999990000000000000000000000000000000000000000000000000000000000000000
99999999988888000888889999999999999999999888880008888899999999990000000000000000000000000000000000000000000000000000000000000000
999999999088888808888bbb99999999999999999088888808888bbb999999990000000000000000000000000000000000000000000000000000000000000000
999999999000888888888bbb99999999999999999000888888888bbb999999990000000000000000000000000000000000000000000000000000000000000000
999999999880088880888bbbbb999999999999999880088880888bbbbb9999990000000000000000000000000000000000000000000000000000000000000000
999999999888888888888aaabb999999999999999888888888888aaabb9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888808888888aaab9999999999999998888808888888aaab9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888808888aaaa9999999999999998888888808888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888880080888aaaa9999999999999998888880080888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888808888089aaaa9999999999999998888808888089aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999988888808888099aaaa9999999999999988888808888099aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999988880088888999aaaa9999999999999988880088888999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998880888888999aaaa9999999999999998880888888999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999888888889999aaaa9999999999999999888888889999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999988888899999aaaa9999999999999999988888899999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999988888999999aaaa9999999999999999988888999999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
99999999999988899999999aa999999999999999999988899999999aa99999990000000000000000000000000000000000000000000000000000000000000000
99999999999988999999999aa999999999999999999988999999999aa99999990000000000000000000000000000000000000000000000000000000000000000
999999999999999999999999a9999999999999999999999999999999a99999990000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888888808888aaaa9999999999999998888888808888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888880080888aaaa9999999999999998888880080888aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998888808888089aaaa9999999999999998888808888089aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999988888808888099aaaa9999999999999988888808888099aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999988880088888999aaaa9999999999999988880088888999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999998880888888999aaaa9999999999999998880888888999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999888888889999aaaa9999999999999999888888889999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999988888899999aaaa9999999999999999988888899999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
9999999999988888999999aaaa9999999999999999988888999999aaaa9999990000000000000000000000000000000000000000000000000000000000000000
99999999999988899999999aa999999999999999999988899999999aa99999990000000000000000000000000000000000000000000000000000000000000000
99999999999988999999999aa999999999999999999988999999999aa99999990000000000000000000000000000000000000000000000000000000000000000
999999999999999999999999a9999999999999999999999999999999a99999990000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999988889999999999999999999999999999888899999999999999999999999999998888999999999999999900000000000000000000000000000000
99999999998888888988999999999999999999999988888889889999999999999999999999888888898899999999999900000000000000000000000000000000
99999999988800088988899999999999999999999888000889888999999999999999999998880008898889999999999900000000000000000000000000000000
99999999988888000888889999999999999999999888880008888899999999999999999998888800088888999999999900000000000000000000000000000000
999999999088888808888bbb99999999999999999088888808888bbb99999999999999999088888808888bbb9999999900000000000000000000000000000000
999999999000888888888bbb99999999999999999000888888888bbb99999999999999999000888888888bbb9999999900000000000000000000000000000000
999999999880088880888bbbbb999999999999999880088880888bbbbb999999999999999880088880888bbbbb99999900000000000000000000000000000000
999999999888888888888aaabb999999999999999888888888888aaabb999999999999999888888888888aaabb99999900000000000000000000000000000000
9999999998888808888888aaab9999999999999998888808888888aaab9999999999999998888808888888aaab99999900000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999999999999998888888888888aaaa99999900000000000000000000000000000000
9999999998888888888888aaaa9999999999999998888888888888aaaa9999999999999998888888888888aaaa99999900000000000000000000000000000000
9999999998888888808888aaaa9999999999999998888888808888aaaa9999999999999998888888808888aaaa99999900000000000000000000000000000000
9999999998888880080888aaaa9999999999999998888880080888aaaa9999999999999998888880080888aaaa99999900000000000000000000000000000000
9999999998888808888089aaaa9999999999999998888808888089aaaa9999999999999998888808888089aaaa99999900000000000000000000000000000000
9999999988888808888099aaaa9999999999999988888808888099aaaa9999999999999988888808888099aaaa99999900000000000000000000000000000000
9999999988880088888999aaaa9999999999999988880088888999aaaa9999999999999988880088888999aaaa99999900000000000000000000000000000000
9999999998880888888999aaaa9999999999999998880888888999aaaa9999999999999998880888888999aaaa99999900000000000000000000000000000000
9999999999888888889999aaaa9999999999999999888888889999aaaa9999999999999999888888889999aaaa99999900000000000000000000000000000000
9999999999988888899999aaaa9999999999999999988888899999aaaa9999999999999999988888899999aaaa99999900000000000000000000000000000000
9999999999988888999999aaaa9999999999999999988888999999aaaa9999999999999999988888999999aaaa99999900000000000000000000000000000000
99999999999988899999999aa999999999999999999988899999999aa999999999999999999988899999999aa999999900000000000000000000000000000000
99999999999988999999999aa999999999999999999988999999999aa999999999999999999988999999999aa999999900000000000000000000000000000000
999999999999999999999999a9999999999999999999999999999999a9999999999999999999999999999999a999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999900000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999998888999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999888888898899999999999999999999998888888988999999999999000000000000000000000000000000000000000000000000
00000000000000009999999998880008898889999999999999999999988800088988899999999999000000000000000000000000000000000000000000000000
00000000000000009999999998888800088888999999999999999999988888000888889999999999000000000000000000000000000000000000000000000000
0000000000000000999999999088888808888bbb99999999999999999088888808888bbb99999999000000000000000000000000000000000000000000000000
0000000000000000999999999000888888888bbb99999999999999999000888888888bbb99999999000000000000000000000000000000000000000000000000
0000000000000000999999999880088880888bbbbb999999999999999880088880888bbbbb999999000000000000000000000000000000000000000000000000
0000000000000000999999999888888888888aaabb999999999999999888888888888aaabb999999000000000000000000000000000000000000000000000000
00000000000000009999999998888808888888aaab9999999999999998888808888888aaab999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888888888aaaa9999999999999998888888888888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888888888aaaa9999999999999998888888888888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888808888aaaa9999999999999998888888808888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888880080888aaaa9999999999999998888880080888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888808888089aaaa9999999999999998888808888089aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999988888808888099aaaa9999999999999988888808888099aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999988880088888999aaaa9999999999999988880088888999aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998880888888999aaaa9999999999999998880888888999aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999999888888889999aaaa9999999999999999888888889999aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999999988888899999aaaa9999999999999999988888899999aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999999988888999999aaaa9999999999999999988888999999aaaa999999000000000000000000000000000000000000000000000000
000000000000000099999999999988899999999aa999999999999999999988899999999aa9999999000000000000000000000000000000000000000000000000
000000000000000099999999999988999999999aa999999999999999999988999999999aa9999999000000000000000000000000000000000000000000000000
0000000000000000999999999999999999999999a9999999999999999999999999999999a9999999000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999999999999999999999999999999999999999999999000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999999999999999999999999999999999999999999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888888888aaaa9999999999999998888888888888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888888888aaaa9999999999999998888888888888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888888808888aaaa9999999999999998888888808888aaaa999999000000000000000000000000000000000000000000000000
00000000000000009999999998888880080888aaaa9999999999999998888880080888aaaa999999000007770000000000000000000000000000000000000000
00000000000000009999999998888808888089aaaa9999999999999998888808888089aaaa999999000007665000000000000000000000000000000000000000
00000000000000009999999988888808888099aaaa9999999999999988888808888099aaaa999999000007650000000000000000000000000000000000000000
00000000000000009999999988880088888999aaaa9999999999999988880088888999aaaa999999000000500000000000000000000000000000000000000000
00000000000000009999999998880888888999aaaa9999999999999998880888888999aaaa999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000889999aaaa9999999999999999888888889999aaaa999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000899999aaaa9999999999999999988888899999aaaa999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999aaaa9999999999999999988888999999aaaa999999000000000000000000000000000000000000000000000000
000000000000000000000000000000009999999aa999999999999999999988899999999aa9999999000000000000000000000000000000000000000000000000
000000000000000000000000000000009999999aa999999999999999999988999999999aa9999999000000000000000000000000000000000000000000000000
0000000000000000000000000000000099999999a9999999999999999999999999999999a9999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999999999999999999999999999999999999999999999999999999990000000000000000
00000000000000000000000000000000999999999999999999999999999988889999999999999999999999999999888899999999999999990000000000000000
00000000000000000000000000000000898899999999999999999999998888888988999999999999999999999988888889889999999999990000000000000000
00000000000000000000000000000000898889999999999999999999988800088988899999999999999999999888000889888999999999990000000000000000
00000000000000000000000000000000088888999999999999999999988888000888889999999999999999999888880008888899999999990000000000000000
0000000000000000000000000000000008888bbb99999999999999999088888808888bbb99999999999999999088888808888bbb999999990000000000000000
0000000000000000000000000000000088888bbb99999999999999999000888888888bbb99999999999999999000888888888bbb999999990000000000000000
0000000000000000000000000000000080888bbbbb999999999999999880088880888bbbbb999999999999999880088880888bbbbb9999990000000000000000
0000000000000000000000000000000088888aaabb999999999999999888888888888aaabb999999999999999888888888888aaabb9999990000000000000000
00000000000000000000000000000000888888aaab9999999999999998888808888888aaab9999999999999998888808888888aaab9999990000000000000000
00000000000000000000000000000000888888aaaa999999999999999888888800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000888888aaaa999999999999999888888800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000808888aaaa999999999999999888888800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000080888aaaa999999999999999888888000000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000888089aaaa999999999999999888880800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000888099aaaa999999999999998888880800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000888999aaaa999999999999998888008800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000888999aaaa999999999999999888088800000000aa999999999999990000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000007707770777077707770000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000700000000070000700707070700700000000000700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000070000000077700700777077000700000000007000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000707000000000700700707070700700000000070700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000070700000077000700707070700700000000707000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000707800000000000000000000000000000000870700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000075000000000000000000000000000000000057000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000780000000000000000000000000000000000008700000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000500000000000000007777700000000000000000500000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077070770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077707770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077070770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000007777700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999980000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999980000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999980000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999980000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606162000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707172737475767700000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808182838485868700000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909192939495969700000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a1a2a3a4a5a6a700000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2b3b4b5b6b700000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c2c3c4c5c6c7c8c9cacb000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d2d3d4d5d6d7d8d9dadb000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2e3e4e500e7e8000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000005000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000676800000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
4e2300003b0003b0003a0013a00039000380003700001700360043500034005340003300032000320000170031004310003170530000007002e000007002c000317042b000290050070028000007002600000700
507d00003200532007320053200500000251002c00000000000001c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e630000376003460134601346012f600007002860024600246002460025600007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00ce00002460320201202041e2001c200172001620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
967c00002d7042d7042f7043170428104327043470435704377042a10438704231043a7042f1043b7043b704251043c704311043c7043c70431104001043c704251043c704311043a7043a704311043970400104
6e6600002f204252042c204192041b2020f2020b202012020f2020b2021420200202012020120201202012020f2020b2021420200202002020020200202002020f2020b202002020020200202002020020200202
88ff00002a0022f0022f0022f00231000310003100000002310023100231002310023100000002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
0003000019003192011e10422000250001e00019000220001b0001b0001e0001e000220001e000220001e000220001e00022000220001e00022000220001e000220001e000220001e0001e000250000000025000
5c14000030073000051c0051b005133031230512305123050c003280752f075190051b0031c0051a005250052a0032d0052d0052b00529003260050d3750d3750d3730d305160051100514003180052b57521005
5c140020295731e5751f57513005245732557527575015750c0030b5752000525005290032540525405205750c00305405270050747513073146751b07505475064730c075044750447504473044750447503475
5c1400201b5731a57519575135751457315575175751c5751f573181751817518175192731e27520275242752427323275212751d27517273112750d2750f7751177312775147731377511773107711000102201
5c140000327732f7752d7752c7752b7732b7752b7752b7752b7732c7752c7752c7752a0732d075300753107531073300752e0752b0752807325075220752d0752c1732c1752c1752c1752c1732c1752c1752b175
5c14000019173191751917519175191731b0751917519175191732407519175191751917319175191752207519173191751917519175191731917521075191751917319175191752207519173191751917119171
5c080000261732617526175261751d1731e1751e1751e1751d1731d1751d1751c1751c1731b1751a17519175181731717516175151751517317175181751c1751d1731e1751e1751e1751e1731d1751c1751a175
5c0400203d06319145191451914519163191451914519145191631914519145191451916319145191451914519163191451914519145191631914519145191451916319145191451914519463194631946319463
5c010000233731e3751c3751d3751d3731d3751d3751d3751d3731c375193751537515373153751537515375153731437513375113750f3730d3750d3730c3750d3730d3750e3750e37513573135731257312573
8e0500200c0720d0750e0720e0750e0710657507575095750a5750c5720d57510572135751557217575195751a5721c5751f5722157508071090750a0750b0750d0751207216075180721a0751a0711a0751b075
8e0100201157214575165720c7750c7710c7750c7750c7750c7750c772295752b5722d5752d5722c5752c5752c5722b57529572255752357222575205721f5751d5721c5751b5721a5751a5721a5721857517570
8e01002014072170721a0721c0721d0721e07520072210751e0721d0721b072230721907224075240752407224072240722307223072220722107521072200751f0721d0751b0721907518072170751607515071
8e01002014072130721207211072100720d0750d0720f075120721907222072230720c07223075240722407523072220721b07218072160711507214072140721307212072110721107210072100720f0720f075
8e06002012072110721107211072110721307514072150751507217072190721b0721c0721c0751c0721c0751d0721d0721e0722007521072230722407224075240722307221072150750b072060720207100071
860b0000190741b0721d072293722a3722d372210722f37232372333723537235372250722607228072280722b0722c0722e0722f072300723107232072330723b3723b3723b3723c3723d372380723e3723f372
860500001d0721d0721d0721d0721d0721d0721c0721b0721b0721b0721a072180721807217072160721507214072130721207211072100720f0720d0720b072110720a072080720707206072060720507205072
860100003f0721b0721e07222072240722507227072192721c272202722227226272270721a0722707227072260721f2721c2721a2721927217272162721427215072122721127213071102710e2720d2720c272
860500001f0721e0721e0721f0721f0721f0721e0721e072301721e0721e0721e0721e0721e0721e0721d0721d0721d0721d0721d0722d1721d0721d0721d0722817228172281722817228172271722717226172
860200001707217072170721707217072170721707217072170721707218072180721807218072180721807218072180721807218072180721807219072190721907219072190721a0721a0721a0721a0721a072
860700000d172091720d172135721357209172135720817215572071721117218572131720e172071721d57207172081722057209172235710917209172255720917227572091722857229571295732857328573
8e1400000e5750f575185750f575185751057519575105751a5751157520275115751a5751257520175125751a5751917512575192751a575125751a5751957512575195751e1751857515275185751357517575
963a00003107432024330743302433074340243405435054350743602436074370243707437024380543805438074380243807438024380743802438054380543807438024380743802437074370243605436054
97040000281742f12434174281242f1743412407104071042a17431124361742a124311743612407104071042c17433124381742c124331743812407104071042c17433124381742c12433174381240710407104
010c000022174291242e17422124291742e1240110401104241742b12430174241242b174301240110401104261742d12432174261242d1743212401104011042b17432124371742b12432174371240610406104
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c609002012073042430b2430424306343042430b2430424312073042430b2430424306343042430b2430424312073042430b2430424306343042430b2430424312073042430b2430424306343042430b24304243
5d1400200c023012150121501215130230121501215012150c023012150121501215130230121501215012150c023012150121501215130230121501215012150c02301215012150121513023012150121501215
__music__
01 08004544
00 0a004544
00 0b004544
00 09004544
00 0a004544
00 0b004544
00 08004544
00 0c004544
00 080b4544
00 090b0844
00 0c08090a
00 0c0b0a09
00 080b4344
00 0a0c4344
00 0c0a0844
02 0a0c4344
03 08094344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 094a4344

