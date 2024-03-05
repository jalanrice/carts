pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--downward
--by glenn cagle

--todo
-- hit redbug sound?

-- extra life pickups
-- use map to draw background
-- music
-- enemy patterns
-- new backgrounds
-- new enemies/obstacles
-- 	beams
--  ore blocks
-- bosses
-- give later hats animations/particles
--  propeller spinning
--  halo inertia
--  fire particles
--  groucho eye roll
--  physics
--   snake
--   knight feather
--   jester
--   scholar tassle
--   pikmin?
--   elf and santa?
--   valkyrie wing flap?
-- weapon pickups

--changelog
-- added unbreakable blocks
-- deeper areas are not quite as crowded
-- hat flies off when you die
-- added redbug explosion sound
-- added shop transition animation

--audio channels
-- 3: sliding

function _init()
	setup()
	
	dpal=split("0,1,1,2,1,13,6,4,4,9,3,13,1,13,14")
	fade_perc=0
	
	dirx,diry=split"1,0,-1,0",split"0,-1,0,1"
	
	cartdata("mrwiz_downward_2")
	highscore=dget(0)
	total_money=dget(1)
	hat=dget(2)
	
	bought={}
	for i=0,7 do
		local byte=peek(0x5e0c+i)
		for j=0,7 do
			bought[i*8+j]=byte%2==1
			byte=flr(byte>>1)
		end
	end
	bought[0]=true
	new_hats=0
	
	--load custom font
	poke(0x5600,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,63,63,63,63,63,63,0,0,0,63,63,63,0,0,0,0,0,63,51,63,0,0,0,0,0,51,12,51,0,0,0,0,0,51,0,51,0,0,0,0,0,51,51,51,0,0,0,0,48,60,63,60,48,0,0,0,3,15,63,15,3,0,0,62,6,6,6,6,0,0,0,0,0,48,48,48,48,62,0,99,54,28,62,8,62,8,0,0,0,0,24,0,0,0,0,0,0,0,0,0,12,24,0,0,0,0,0,0,12,12,0,0,0,10,10,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,12,0,12,0,0,54,54,0,0,0,0,0,0,54,127,54,54,127,54,0,8,62,11,62,104,62,8,0,0,51,24,12,6,51,0,0,14,27,27,110,59,59,110,0,12,12,0,0,0,0,0,0,24,12,6,6,6,12,24,0,12,24,48,48,48,24,12,0,0,54,28,127,28,54,0,0,0,12,12,63,12,12,0,0,0,0,0,0,0,12,12,6,0,0,0,62,0,0,0,0,0,0,0,0,0,12,12,0,32,48,24,12,6,3,1,0,62,99,115,107,103,99,62,0,24,28,24,24,24,24,60,0,63,96,96,62,3,3,127,0,63,96,96,60,96,96,63,0,51,51,51,126,48,48,48,0,127,3,3,63,96,96,63,0,62,3,3,63,99,99,62,0,127,96,48,24,12,12,12,0,62,99,99,62,99,99,62,0,62,99,99,126,96,96,62,0,0,0,12,0,0,12,0,0,0,0,12,0,0,12,6,0,48,24,12,6,12,24,48,0,0,0,30,0,30,0,0,0,6,12,24,48,24,12,6,0,30,51,48,24,12,0,12,0,0,30,51,59,59,3,30,0,0,0,62,96,126,99,126,0,3,3,63,99,99,99,63,0,0,0,62,99,3,99,62,0,96,96,126,99,99,99,126,0,0,0,62,99,127,3,62,0,124,6,6,63,6,6,6,0,0,0,126,99,99,126,96,62,3,3,63,99,99,99,99,0,0,24,0,28,24,24,60,0,48,0,56,48,48,48,51,30,3,3,51,27,15,27,51,0,12,12,12,12,12,12,56,0,0,0,99,119,127,107,99,0,0,0,63,99,99,99,99,0,0,0,62,99,99,99,62,0,0,0,63,99,99,63,3,3,0,0,126,99,99,126,96,96,0,0,62,99,3,3,3,0,0,0,62,3,62,96,62,0,12,12,62,12,12,12,56,0,0,0,99,99,99,99,126,0,0,0,99,99,34,54,28,0,0,0,99,99,107,127,54,0,0,0,99,54,28,54,99,0,0,0,99,99,99,126,96,62,0,0,127,112,28,7,127,0,62,6,6,6,6,6,62,0,1,3,6,12,24,48,32,0,62,48,48,48,48,48,62,0,12,30,18,0,0,0,0,0,0,0,0,0,0,0,30,0,12,24,0,0,0,0,0,0,62,127,103,103,127,103,103,0,63,127,103,63,103,103,63,0,62,127,103,7,103,127,62,0,63,127,103,103,103,127,63,0,127,127,7,31,7,127,127,0,127,127,7,31,7,7,7,0,62,127,7,119,103,127,62,0,103,103,103,127,127,103,103,0,127,127,28,28,28,127,127,0,127,127,96,96,103,127,62,0,103,103,103,127,63,103,103,0,7,7,7,7,7,127,127,0,54,127,127,127,103,103,103,0,103,111,127,127,119,103,103,0,62,127,103,103,103,127,62,0,63,127,103,103,127,63,7,0,62,127,103,103,55,127,110,0,63,127,103,103,63,127,103,0,62,127,7,62,96,103,62,0,127,127,28,28,28,28,28,0,103,103,103,103,103,127,62,0,103,103,103,111,126,60,24,0,103,103,103,127,127,127,54,0,103,103,103,62,62,103,103,0,103,103,127,62,28,28,28,0,127,127,56,28,14,127,127,0,56,12,12,7,12,12,56,0,8,8,8,0,8,8,8,0,14,24,24,112,24,24,14,0,0,0,110,59,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,65,99,127,93,93,119,62,0,62,99,99,119,62,65,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,38,95,95,127,62,28,0,34,119,127,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,103,99,103,62,65,62,0,62,127,93,93,127,99,62,0,24,120,8,8,8,15,7,0,62,99,107,99,62,65,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,115,99,115,62,65,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,119,99,99,62,65,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,107,119,107,62,65,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))
	
	coin_patterns={}
	--|
	new_coin_pattern(
		split("0,0,0,0,0"),
		split("0,8,16,24,32")
	)
	--x
	new_coin_pattern(
		split("0,16,8,0,16"),
		split("0,0,8,16,16")
	)
	--+
	new_coin_pattern(
		split("8,0,8,16,8"),
		split("0,8,8,8,16")
	)
	--\
	new_coin_pattern(
		split("0,4,8,12,16"),
		split("0,8,16,24,32")
	)
	--\
	new_coin_pattern(
		split("16,12,8,4,0"),
		split("0,8,16,24,32")
	)
	--v
	new_coin_pattern(
		split("0,8,16,24,32"),
		split("0,4,8,4,0")
	)
	--^
	new_coin_pattern(
		split("0,8,16,24,32"),
		split("8,4,0,4,8")
	)
	
	bug_hp=split"1,2"
	bug_spd=split".2,.5"
	bug_spr={
		split"16,17",
		split"32,33,34,35,36,37,38,39",
	}
	bug_gibs={
		split"18,19,20,21",
		split"48,49,50,51",
	}
	bug_shot_cols={
		split"3,11,7",
		split"2,8,9",
	}
	bug_bulpops={
		split"25,26,27,28",
		split"41,42,43,44",
	}
	bug_upd={
		update_greenbug,
		update_redbug_fly,
	}
	
	hat_names=split("tophat,ronald,mickey,devil,viking,knight,valkyrie,bat ears,big ears,conehead,ponytail,goku,super,gnome,scholar,crown,flame,flower,cactus,bow,picomin,soldier,maverick,shades,rambo,jack,skull,pirate,alien,bear,froggyman!!!!!!!!!!!!!!!!!!!!!!!!!!,poopoo???,aaaaaa,emotes,beybefdjd,loveiscool,????????????????????????????????????/,eeeeeeeeee,uwcuwcuwcu,fwce cumwcum,qcumcuq,wcumcmwcm,ceumunwc,micunucwc,yhrujcujcrujcruc,cuncrjnc,miotumtmmi9iumi,wcui,svujn,fuefjefuef,cmmdjdsk,dhdf,kk,??????????????,?,?,?,unknown,???,?????,?,?,?")
	hat_names[0]="no cap"
	
	unlock_depths=split("0,100,100,100,200,200,200,300,300,300,400,400,400,500,500,500,500,600,600,600,600,700,700,700,700,800,800,800,800,900,900,900,900,1000,1000,1000,1000,1000,1100,1100,1100,1100,1100,1200,1200,1200,1200,1200,1300,1300,1300,1300,1300,1400,1400,1400,1400,1400,1500,1500,1500,1500,1500,")
	unlock_depths[0]=0
	
	hat_prices=split"25,35,35,40,50,50,50,75,75,75,90,90,100,60,70,80,100,110,110,110,125,120,125,125,130,145,145,145,150,160,160,160,175,165,165,170,175,180,190,190,190,190,200,225,225,235,235,250,270,270,280,290,300,340,355,370,385,400,420,440,460,480,500"
	hat_prices[0]=0
	
	sel=hat
	buy_hold=0
	shop_offset=0
	shop_slide=-128
	
	blink=split"6,6,6,6,13,5,13"
	blink2=split"10,10,10,10,9,2,9"
	
	--debug=true
end

function _update()
	upd()
	⧗+=1
end

function _draw()
	camera((rnd()-.5)*shake,
		(rnd()-.5)*shake)
	if shake>0 then
		shake*=.8
	end
	if shake<.5 then
		shake=0
	end

	drw()
	
	--fade back in
	if fade_perc>0 then
		fade_perc=max(fade_perc-0.04,0)
		do_fade()
	end
	
	--debug
	if debug then
		print("bullets:"..#bullets,
			1,10,10)
		print(" blocks:"..#blocks,
			1,16,10)
		print("   bugs:"..#bugs,
			1,22,10)
		print("  coins:"..#coins,
			1,28,10)
		print(" e_buls:"..#e_bullets,
			1,34,10)
		print("  parts:"..#parts,
			1,40,10)
		print("b_parts:"..#back_parts,
			1,46,10)
	end
end

function setup()
	⧗=0
	
	upd=update_start
	drw=draw_start
	
	next_upd=update_game
	next_drw=draw_game
	
	started=false
	
	fall=0
	max_fall=4
	bkg_offset=0
	depth=0
	lives=3
	max_lives=lives
	inv⧗=0
	wall_slide=false
	money=0
	--hat=128+flr(rnd(64))
	
	shake=0
	butt_lock=0
	scroll_y=128
	
	hud_y=-7
	
	웃={
		x=8,
		y=33,
		w=4,
		h=6,
		ox=2,
		oy=0,
		flp=false,
		dx=0
	}
	
	bullets={}
	cooldown=0
	
	blocks={}
	block_debt=0
	block⧗=0
	
	bugs={}
	bug⧗=0
	bug_spawn={1,1}
	
	coins={}
	
	e_bullets={}
	e_shot⧗=0
	
	parts={}
	back_parts={}
end
-->8
--updates

function update_gravity()
	if fall<max_fall then
		fall+=0.2
	else
		fall=max_fall
	end
	
	if fall>0 and 웃.y>=40 then
		웃.y=40
		bkg_offset+=fall
		if upd!=update_start then
			bkg_offset%=32
			for b in all(blocks) do
				b.y-=fall
				if b.y<-8 then
					del(blocks,b)
				end
			end
			for c in all(coins) do
				c.y-=fall
				if c.y<-80 then
					del(coins,c)
				end
			end
			for b in all(e_bullets) do
				b.y-=fall
				if b.y<-8 then
					del(e_bullets,b)
				end
			end
		end
		if upd!=update_dead then
			depth+=fall
			if depth>=#bug_spawn*1600 then
				add(bug_spawn,2)
			end
		end
	else
		웃.y=max(웃.y+fall,-8)
	end
end

function update_bullets()
	for b in all(bullets) do
		b.y+=6
		if b.y>128 then
			del(bullets,b)
		end
	end
	
	for b in all(e_bullets) do
		b.x+=b.dx
		b.y+=b.dy
		
		if ⧗%4==0 then
			add_drop(b)
		end
		
		if b.x>106 or b.x<14 then
			sfx(8)
			b.dx*=-.5
			b.dy*=-.5
			add_bulpop(b.x,b.y,
				bug_bulpops[b.typ])
			del(e_bullets,b)
		end
		
		if inv⧗<⧗
		and collision(b,웃) then
			hit웃()
			sfx(8)
			add_bulpop(b.x,b.y,
				bug_bulpops[b.typ])
			del(e_bullets,b)
		end
	end
end

function update_bugs()
	for b in all(bugs) do
		if b.hp<=0 then
			del(bugs,b)
			add_gib(bug_gibs[b.typ],b.x,b.y)
		else
			b:upd()
		end
	end
	
	if e_shot⧗<=⧗ then
		local shooter=rnd(bugs)
		if shooter
		and shooter.typ==1
		and shooter.y>웃.y+8
		and shooter.y<89 then
			shoot(shooter)
			e_shot⧗=⧗+90
		end
	end
end

function update_greenbug(b)
		if b.y>88 then
			b.y+=(88-b.y)/8
		end
		if b.y<89 then
			b.y-=b.spd
		end
		if b.y<웃.y then
			b.spd+=0.1
		end
		if b.y<-8 then
			del(bugs,b)
		end
end

function update_redbug_fly(b)
	if abs(웃.x-b.x)>1 then
		b.x+=sign(웃.x-b.x)
	end
	if b.y>88 then
		b.y+=(88-b.y)/8
	end
	if b.y<89 then
		b.y-=b.spd
	end
	if b.y<48 then
		explode(b,8)
		del(bugs,b)
	end
	if b.hp<2 then
		b.upd=update_redbug_pop
		b.pop⧗=⧗+30
	end
end

function update_redbug_pop(b)
	if ⧗>b.pop⧗ then
		explode(b,8)
		sfx(21)
		del(bugs,b)
	end
end

function update_game()
	shop_slide=-128

	update_gravity()
	update_bugs()
	update_bullets()
	
	--horizontal movement
	if btn(⬅️) then
		웃.dx=max(웃.dx-.5,-2)
		웃.flp=true
	elseif btn(➡️) then
		웃.dx=min(웃.dx+.5,2)
		웃.flp=false
	elseif upd==update_game then
		웃.dx/=1.5
	end
	웃.x+=웃.dx
	
	--wall sliding
	wall_slide=false
	if 웃.x<15-웃.ox then
		wall_slide="left"
		웃.x=15-웃.ox
		웃.dx=0
		fall=min(fall,max_fall/2)
		add_dust(웃.x,웃.y,3)
	end
	if 웃.x>104+웃.ox then
		wall_slide="right"
		웃.x=104+웃.ox
		웃.dx=0
		fall=min(fall,max_fall/2)
		add_dust(웃.x+8,웃.y,3)
	end
	if wall_slide
	and fall>0
	and upd!=update_dead then
		sfx(6,3) --whoosh noise
	else
		sfx(-1,3)
	end
	
	--shooting
	cooldown-=1
	if btnp(❎) or btnp(🅾️) then
		if cooldown<0 then
			fall=-2
			add(bullets,{
				x=웃.x,
				y=웃.y+6,
				w=6,
				h=8,
				ox=1,
				oy=0,
			})
			muzzle(웃,3,8,4)
			muzzle(웃,4,8,4)
			cooldown=8
			sfx(0)
		end
	end
	
	--spawning
	if block⧗<=depth then
		if rnd(block_debt+depth/1600)<block_debt then
			add_blocks(block_debt,rnd(88)+16,128)
			--block_debt=0
		else
			block_debt+=1
		end
		block⧗=depth+max(
			(1-depth/8000)*128,1)
	end
	
	if bug⧗<=⧗ then
		sfx(10)
		add_bug(rnd(bug_spawn),rnd(88)+16,128)
		bug⧗=⧗+90
	end
	
	--look for a coin group at
	--the current depth
	local coin_seen=false
	for c in all(coins) do
		if mid(-10,c.y,128)==c.y then
			coin_seen=true
		end
	end
	
	if #coins==0 then
		add_coins()
	end
	
	--collisions	
	for bul in all(bullets) do
		for bug in all(bugs) do
			if collision(bul,bug) then
				del(bullets,bul)
				add_bulpop(bul.x,bul.y-1,
					{9,10,11,12})
				bug.hp-=1
				sfx(3)
			end
		end
		
		for block in all(blocks) do
			if collision(bul,block) then
				del(bullets,bul)
				add_bulpop(bul.x,bul.y-1,
					{9,10,11,12})
				if block.s==68 then
					del(blocks,block)
					for i=0,4 do
						add_dust(block.x,block.y)
					end
					sfx(9)
				else
					sfx(19)	
				end
			end
		end
	end
	
	for c in all(coins)do
		c.frame=(c.frame+.3)%#c.anim
		if coin_seen then
			c.y+=2
			if collision(c,웃) then
				del(coins,c)
				money+=1
				add_coin_part(c.x+4,c.y+4)
				sfx(13)
			end
		end
	end
	
	if inv⧗<⧗ then
		for b in all(blocks) do
			if collision(웃,b) then
				if b.s==68 then
					del(blocks,b)
					for i=0,4 do
						add_dust(b.x,b.y)
					end
					sfx(9)
				else
					sfx(19)
				end
				hit웃()
			end
		end
	
		for bug in all(bugs) do
			if collision(웃,bug) then
				hit웃()
			end
		end
	end
	
	--show the hud
	if hud_y<.5 then
		hud_y+=(1-hud_y)/4
	else
		hud_y=1
	end
end

function update_dead()
	update_gravity()
	update_bugs()
	update_bullets()
	
	if (btnp(🅾️) or btnp(❎))
	and butt_lock<⧗ then
		total_money+=money
		highscore=max(highscore,flr(depth/8))
		setup()
		fade_out(.06,5)
		sfx(-1,3)
	end
end

function update_start()
	shop_slide=max(shop_slide-12,-128)

	if started then
		update_gravity()
		웃.x+=(60-웃.x)/16
	elseif butt_lock<⧗ then
		if btnp(❎) or btnp(🅾️) then
			fall=-3
			started=true
			sfx(12)
			next_upd=update_game
			next_drw=draw_game
		elseif btnp(➡️) then
			fall=-3
			started=true
			sfx(12)
			next_upd=update_credits
			next_drw=draw_credits
		elseif btnp(⬅️) then
			upd=update_shop
			drw=draw_start
		end
	end
	
	if depth>=178 then
		upd=next_upd
		drw=next_drw
		⧗=-1
		inv⧗=-1
		bkg_offset%=32
		fillp()
	end
end

function update_credits()
	update_gravity()
	
	if (btnp(🅾️) or btnp(❎))
	and butt_lock<⧗ then
		total_money+=money
		setup()
		fade_out(.06,5)
		sfx(-1,3)
		return
	end
	
	if ⧗==0 then
		add_credit("\14down",40,16)
	elseif ⧗==5 then
		add_credit("\14ward",46,22)
		
	elseif ⧗==35 then
		add_credit("created by",50,16)
	elseif ⧗==40 then
		add_credit("\14glenn",54,22)
	elseif ⧗==45 then
		add_credit("\14cagle",60,28)
	
	elseif ⧗==90 then
		add_credit("play my games on",60,16)
	elseif ⧗==95 then
		add_credit("\14lexa",66,22)
	elseif ⧗==100 then
		add_credit("\14loffle",72,28)
	elseif ⧗==105 then
		add_credit("and",79,34)
	elseif ⧗==110 then
		add_credit("\14itch",84,40)
	elseif ⧗==125 then
		add_credit("i'm misterwizard01",90,46,10)
	elseif ⧗==130 then
		add_credit("on both",96,52,10)
	
	elseif ⧗==205 then
		add_credit("special thanks to",80,16)
	elseif ⧗==210 then
		add_credit("\14lazy",86,22,12)
	elseif ⧗==215 then
		add_credit("\14devs",92,28,12)
	elseif ⧗==220 then
		add_credit("academy",98,34,12)
	elseif ⧗==225 then
		add_credit("and its community",104,40)
	
	elseif ⧗==300 then
		add_credit("and",90,16)
	elseif ⧗==305 then
		add_credit("\14you",95,22)
	elseif ⧗==310 then
		add_credit("for playing",102,28)
	elseif ⧗==315 then
		add_credit("♥",108,34,8)
		
	elseif ⧗==515 then
		--add_credit("⬆️⬇️⬅️➡️❎➡️⬅️⬇️⬆️🅾️",108,34)
	elseif ⧗>750 then
		setup()
		fade_out(.06,5)
	end
end

function update_shop()
	shop_offset*=.6
	if abs(shop_offset)<.01 then
		shop_offset=0
	end
	
	shop_slide=min(0,shop_slide+12)
	
	if btnp(⬇️) then
		sel=min(sel+1,63)
		shop_offset=1
		buy_hold=0
		sfx(14)
	elseif btnp(⬆️) then
		sel=max(sel-1,0)
		shop_offset=-1
		buy_hold=0
		sfx(14)
	elseif btnp(➡️) then
		upd=update_start
		drw=draw_start
		buy_hold=0
	elseif btn(❎) or btn(🅾️) then
		if bought[sel] then
			if hat!=sel then
				hat=sel
				dset(2,hat)
				sfx(17)
			end
		elseif highscore>=unlock_depths[sel]
		and total_money>=hat_prices[sel] then
			if not btn_prev then
				sfx(15,0)
			end
			
			if buy_hold>30 then
				bought[sel]=true
				total_money-=hat_prices[sel]
				buy_hold=0
				
				--save the bought hat
				for i=0,7 do
					local byte=0
					for j=0,7 do
						byte>>=1
						if bought[i*8+j] then
							byte|=128
						end
					end
					poke(0x5e0c+i,byte)
				end
				
				--save the new money value
				dset(1,total_money)
			else
				buy_hold+=1
			end
		elseif not btn_prev then
			sfx(18)
		end
		btn_prev=true
	else
		if btn_prev and buy_hold>0 then
			sfx(16,0)
		end
		buy_hold=max(0,buy_hold-1)
		btn_prev=false
	end
end
-->8
--draws

function draw_player()
	if inv⧗<⧗ or ⧗%8>4 then
		local 웃spr=fall>0 and 0 or 1
		if wall_slide then
			웃spr=2
		end
		if lives<=0 then
			웃spr=3
		end
		if not started then
			웃spr=4
		end
		
		palt(0,false)
		palt(12,true)
		spr(웃spr,웃.x,웃.y,
			1,1,웃.flp)
		palt()
			
		--hat
		if lives>0 then
			local xoff=웃.flp and -1 or 1
			spr(hat+128,웃.x+xoff,
				웃.y-5,1,1,웃.flp)
		end
	end
	
	for b in all(bullets) do
		spr(13,b.x,b.y)
	end
	
	for b in all(e_bullets) do
		circfill(b.x+3,b.y+3,b.r,b.cols[1])
		circfill(b.x+3+b.dx/3,b.y+3+b.dy/3,b.r*2/3,b.cols[2])
		circfill(b.x+3+b.dx/2,b.y+3+b.dy/2,b.r/3,b.cols[3])
	end
end

function draw_game()
	--background
	cls()
	for i=0,19 do
		pal(2,0)
		pal(4,1)
		pal(9,2)
		spr(81,24,i*8-bkg_offset/4)
		spr(81,32,i*8-bkg_offset/4)
		spr(82,40,i*8-bkg_offset/4)
		spr(80,80,i*8-bkg_offset/4)
		spr(81,88,i*8-bkg_offset/4)
		spr(81,96,i*8-bkg_offset/4)
		pal()
		
		pal(2,1)
		pal(4,2)
		pal(9,4)
		spr(81,8,i*8-bkg_offset/2)
		spr(81,16,i*8-bkg_offset/2)
		spr(82,24,i*8-bkg_offset/2)
		spr(80,96,i*8-bkg_offset/2)
		spr(81,104,i*8-bkg_offset/2)
		spr(81,112,i*8-bkg_offset/2)
		pal()
		
		spr(81,0,i*8-bkg_offset)
		spr(82,8,i*8-bkg_offset)
		spr(80,112,i*8-bkg_offset)
		spr(81,120,i*8-bkg_offset)
	end
	
	--background particles
	for ◆ in all(back_parts) do
		◆:upd()
	end
	
	--sprites
	draw_player()
		
	for b in all(blocks) do
		ospr(b.s,b.x,b.y,15)
	end
	for b in all(blocks) do
		spr(b.s,b.x,b.y)
	end
	
	for b in all(bugs) do
		if b.pop⧗
		and (b.pop⧗-⧗)%8<4 then
			pal(split"7,7,7,7,7,7,7,7,7,7,7,7,7,7,7")
		end
		local s=bug_spr[b.typ]
		spr(s[flr(⧗%#s)+1],
			b.x,b.y)
		pal()
	end
	
	for c in all(coins) do
		spr(c.anim[flr(c.frame)+1],
			c.x,c.y)
	end
	
	--particles
	for ◆ in all(parts) do
		◆:upd()
	end
	
	--hud
	for i=0,max_lives-1 do
		spr(i<lives and 14 or 15,
			i*9+1,hud_y)
	end
	
	rectfill2(101,hud_y-2,27,9,13)
	rectfill2(102,hud_y-1,25,7,5)
	print("$",103,hud_y,10)
	printr("88888",127,hud_y,1)
	printr(money,127,hud_y,10)
	
	if drw!=draw_dead then
		oprintc(flr(depth/8).."M",
			64,hud_y,6,0)
	end
	--printc(fall,64,10,6)
end

function draw_dead()
	draw_game()
	
	local y=28
	print("\14you died",32,y,6)
	
	printc("your body will reach",
		64,y+24,6)
	printc("the bottom without you.",
		64,y+32,6)
		
	local score=flr(depth/8)
	printc("died at "..score.."M",
		64,y+48,6)
	
	if new_hats>0 then
		rrectfill2(90,y+43,38,15,1)
		print(new_hats.." hats",96,y+44,blink2[flr(⧗/4)%#blink2+1])
		print("unlocked!",92,y+52,blink2[flr(⧗/4)%#blink2+1])
	elseif score>highscore then
		rrectfill2(94,y+43,22,15,1)
		print("new",100,y+44,blink2[flr(⧗/4)%#blink2+1])
		print("best!",96,y+52,blink2[flr(⧗/4)%#blink2+1])
	end
	
	print("stashed:",32,y+62,6)
	print("$",72,y+62,10)
	printr(total_money,
		96,y+62,10)
		
	print("grabbed:",32,y+68,6)
	print("+",68,y+68,6)
	print("$",72,y+68,10)
	printr(money,96,y+68,10)
	
	line(30,y+74,96,y+74,6)
	
	print("total:",32,y+76,6)
	print("$",72,y+76,10)
	printr(total_money+money,
		96,y+76,10)
		
	rrectfill2(12,119,103,7,1)
	printc("press 🅾️ or ❎ to restart",
		64,120,blink[flr(⧗/4)%#blink+1])
end

function draw_start()
	cls(12)
	pal()
	
	fillp()
	rectfill2(0,56-bkg_offset,128,24,13)
	rectfill2(0,80-bkg_offset,128,24,1)
	rectfill2(0,104-bkg_offset,128,280,0)
	
	fillp(▒)
	rectfill2(0,48-bkg_offset,128,8,13)
	rectfill2(0,72-bkg_offset,128,8,1)
	rectfill2(0,96-bkg_offset,128,8,0)
	
	fillp(░)
	rectfill2(0,42-bkg_offset,128,6,13)
	rectfill2(0,64-bkg_offset,128,8,1)
	rectfill2(0,88-bkg_offset,128,8,0)
	
	pal(2,0)
	pal(4,1)
	pal(9,2)
	map(32,0,128+shop_slide,40-bkg_offset/4)
	map(32,8,128+shop_slide,128+40-bkg_offset/4)
	
	pal(2,1)
	pal(4,2)
	pal(9,4)
	map(16,0,128+shop_slide,40-bkg_offset/2)
	map(16,8,128+shop_slide,128+40-bkg_offset/2)
	
	pal()
	map(0,0,128+shop_slide,40-bkg_offset)
	map(0,8,128+shop_slide,128+40-bkg_offset)
	map(0,8,128+shop_slide,192+40-bkg_offset)
	map(0,8,128+shop_slide,256+40-bkg_offset)
	
	local y=12-depth
	print("\14down",48+128+shop_slide,y,6)	
	print("\14ward",48+128+shop_slide,y+8,6)	
	
	printc("deepest: "..highscore.."M",
		64+128+shop_slide,y+20,6)
		
	print("⬅️",2.9+sin(⧗/20)+128+shop_slide,y-11,6)
	print("shop",11+128+shop_slide,y-11,6)
	if new_hats>0 then
		print("new hats!",1+128+shop_slide,y-5,blink2[flr(⧗/4)%#blink2+1])
	end
	
	print("➡️",119.1-sin(⧗/20)+128+shop_slide,y-11,6)
	printr("credits",118+128+shop_slide,y-11,6)
	
	fillp()
	if not started then
		rectfill2(18+128+shop_slide,120,91,5,1)
		rectfill2(19+128+shop_slide,119,89,7,1)
		printc("press 🅾️ or ❎ to jump",
			64+128+shop_slide,120,blink[flr(⧗/4)%#blink+1])
	end
	
	draw_player()
	
	map(48,0,shop_slide,40)
	
	print("\14shop",48+shop_slide,8,6)
	
	local yoff=-6
	--background
	rrectfill2(4+shop_slide,22+yoff,120,102,9)
	rrectfill2(5+shop_slide,23+yoff,118,100,10)
	rrectfill2(6+shop_slide,24+yoff,116,98,0)
	
	--selection indicator
	rrectfill2(8+shop_slide,61+yoff,112,24,1)
	rrectfill2(89+shop_slide,66+yoff,buy_hold,13,13)
	
	--items
	clip(6+shop_slide,24+yoff,116,98)
	for i=-3,3 do
		local ind,y=sel+i,
			(i+shop_offset)*24+yoff
		if ind>=0 and ind<64 then
			rrectfill2(10+shop_slide,62+y,22,22,6)
			rrectfill2(11+shop_slide,63+y,20,20,0)
			
			local sx,sy,n,unlocked=
				ind%16*8,64+flr(ind/16)*8,
				hat_names[ind],
				highscore>=unlock_depths[ind]
			
			if not unlocked then
				for i=1,15 do
					pal(i,6)
				end
				n="???"
			end
			
			sspr(sx,sy,8,8,12+shop_slide,66+y,16,16)
			print(n,36+shop_slide,70+y,6)
			pal()
			
			local textx=119+shop_slide
			if bought[ind] then
				if hat==ind then
					printr("equipped",textx,70+y,13)
				else
					printr("equip",textx,70+y,6)
				end
			elseif unlocked then
				printr("buy for",textx,67+y,6) 
				printr("$"..hat_prices[ind],119,73+y,6)
			else
				printr("unlock at",textx,67+y,13) 
				printr(unlock_depths[ind].."M",119,73+y,13)
			end
		end
	end
	clip()
	
	--money
	print("$"..total_money,1+shop_slide,1,10)

	--button prompts
	print("➡️",119.1-sin(⧗/20)+shop_slide,1,6)
	printr("title",118+shop_slide,1,6)
	
	if highscore>=unlock_depths[sel]
	and hat!=sel then
		local prompt="hold 🅾️ or ❎ to buy"
		if bought[sel] then
			prompt="press 🅾️ or ❎ to equip"
		end
		rrectfill2(12+shop_slide,119,103,7,1)
		printc(prompt,64+shop_slide,120,
			blink[flr(⧗/4)%#blink+1])
	end
	
	if not started then
		palt(0,false)
		spr(4,128+8+shop_slide,33)
		pal()
		spr(hat+128,128+9+shop_slide,33-5)
	end
end

function draw_credits()
	draw_game()

	rrectfill2(12,119,103,7,1)
	printc("press 🅾️ or ❎ to restart",
		64,120,blink[flr(⧗/4)%#blink+1])
end
-->8
--sprites

function add_block(s,x,y)
	add(blocks,{
		s=s,
		x=x,
		y=y,
		w=8,
		h=8,
		ox=0,
		oy=0,
	})
end

function add_bug(typ,x,y,upd)
	add(bugs,{
		typ=typ,
		hp=bug_hp[typ],
		x=x,
		y=y,
		w=8,
		h=8,
		ox=0,
		oy=0,
		spd=bug_spd[typ],
		upd=bug_upd[typ],
	})
end

function add_coins()
	local pat=rnd(coin_patterns)
	local x,y=
		16+rnd(96-pat.width),128
	for i=1,#pat do
		add(coins,{
			x=x+pat[i].x,
			y=y+pat[i].y,
			w=8,
			h=8,
			ox=0,
			oy=0,
			anim={57,58,59,60},
			frame=i,
		})
	end
end

function shoot(bug)
	local dx,dy=normalize(
		웃.x-bug.x,웃.y-bug.y)
	local b={
		typ=bug.typ,
		x=bug.x,
		y=bug.y-4,
		w=2,
		h=2,
		ox=2,
		oy=2,
		dx=2*dx,
		dy=2*dy,
		cols=bug_shot_cols[bug.typ],
		r=3,
	}
	--account for camera scroll
	if 웃.y==40 and fall>0 then
		b.dy+=fall
	end
	
	add(e_bullets,b)
	sfx(4)
	for i=0,9 do
		add_drop(b)
	end
end

function explode(bug,n)
	for i=0,n-1 do
	local spd=rnd(2)+1
	local b={
			typ=bug.typ,
			x=bug.x,
			y=bug.y-4,
			w=2,
			h=2,
			ox=2,
			oy=2,
			dx=spd*sin(i/n),
			dy=spd*cos(i/n),
			cols=bug_shot_cols[bug.typ],
			r=3,
		}
		add(e_bullets,b)
		add_drop(b)
		add_drop(b)
	end

	for i=0,4 do
		add_gib(bug_gibs[bug.typ],
			bug.x,bug.y)
	end
	muzzle(bug,4,4,16,7)
	shake=4
end

function hit웃()
	fall=0
	if upd!=update_dead then
		inv⧗=⧗+60
		lives-=1
		shake=10

		if lives<=0 then
			upd=update_dead
			drw=draw_dead
			butt_lock=⧗+30
			--sfx(8,2) --dead whooshing
			sfx(11)
			add_hat_part()
			
			local score=flr(depth/8)
			new_hats=count_hats(score)-count_hats(highscore)
			if score>highscore then
				dset(0,score)
			end
			dset(1,total_money+money)
		else
			sfx(7)
		end
	end
end

function new_coin_pattern(xs,ys)
	local pat,width={},0
	for i=1,#xs do
		add(pat,{x=xs[i],y=ys[i]})
		width=max(width,xs[i]+8)
	end
	pat.width=width
	add(coin_patterns,pat)
end

function add_blocks(n,x,y)
	local cand={{x,y}}
	for i=1,n do
		local pick=rnd(cand)
		--if not pick then return end
		local px,py=pick[1],pick[2]
		add(occ,pick)
		del(cand,pick)
		if block_debt>5 and rnd()>.5 then
			add_block(69,px,py)
			block_debt-=5
		else
			add_block(68,px,py)
			block_debt-=1
		end
		--add to the frontier
		for d=1,4 do
			local nx,ny,found=
				px+dirx[d]*8,py+diry[d]*8
			if ny>=y then
				for b in all(blocks) do
					if b.x==nx and b.y==ny then
						found=true
					end
				end
				for c in all(cand) do
					if c[1]==nx and c[2]==ny then
						found=true
					end
				end
				if not found then
					add(cand,{nx,ny})
				end
			end
		end
	end
end
-->8
--tools

function sign(n)
	if (n==0) return 0
	return sgn(n)
end

function collision(a,b)
	local a⬅️,a➡️,a⬆️,a⬇️,
							b⬅️,b➡️,b⬆️,b⬇️=
							a.x+a.ox,a.x+a.ox+a.w,
							a.y+a.oy,a.y+a.oy+a.h,
							b.x+b.ox,b.x+b.ox+b.w,
							b.y+b.oy,b.y+b.oy+b.h
	if a➡️<=b⬅️ or a⬅️>=b➡️
	or a⬇️<=b⬆️ or a⬆️>=b⬇️ then
		return
	end
	return true
end

function measure(s)
	local total,w=0,4
	if sub(s,1,1)=="\14" then
		s=sub(s,2)
		w=8
	end
	
	for i=1,#(s.."") do
		total+=w
		if ord(sub(s,i,i))>122 then
			total+=w
		end
	end
	return total
end

function oprintc(t,x,y,c,oc)
	for ox=-1,1 do
		for oy=-1,1 do
			printc(t,x+ox,y+oy,oc)			
		end
	end
	
	--[[
	printc(t,x-1,y,oc)
	printc(t,x+1,y,oc)
	printc(t,x,y-1,oc)
	printc(t,x,y+1,oc)
	]]
	
	printc(t,x,y,c)
end

function printc(t,x,y,c)
	print(t,x-measure(t)/2,y,c)
end

function printr(t,x,y,c)
	print(t,x-measure(t),y,c)
end

function rectfill2(x,y,w,h,c)
	if w>0 and h>0 then
		rectfill(x,y,x+w-1,y+h-1,c)
	end
end

--fades what's already drawn
function do_fade()
	local p,kmax,col,k=flr(mid(0,
		fade_perc,1)*100)
	for j=1,15 do
		col=j
		kmax=flr((p+j*1.46)/22)
		for	k=1,kmax do
			col=dpal[col]
		end
		pal(j,col,1)
	end
end

--fade to black
function fade_out(spd,_wait)
	if (not spd) spd=0.04
	if (not _wait) _wait=0
	repeat
		fade_perc=min(fade_perc+spd,1)
		do_fade()
		flip()
	until fade_perc==1
	wait(_wait)
end

function wait(t)
	for i=0,t do
		flip()
	end
end

function normalize(x,y)
	local len=sqrt(x*x+y*y)
	if len>0 then
		return x/len,y/len
	else
		return x,y
	end
end

function ospr(s,x,y,c)
	for i=1,15 do
		pal(i,c)
	end
	
	spr(s,x-1,y)
	spr(s,x+1,y)
	spr(s,x,y-1)
	spr(s,x,y+1)
	
	pal()
	--spr(s,x,y)
end

function circfill2(x,y,r,c)
	r=flr(r*2)/2
	if r%1==0 then
		circfill(x,y,r,c)
	else
		circfill(x-.5,y-.5,r,c)
		circfill(x-.5,y+.5,r,c)
		circfill(x+.5,y+.5,r,c)
		circfill(x+.5,y-.5,r,c)
	end
end

function rrectfill2(x,y,w,h,c,r)
	x2,y2=x+w-1,y+h-1
	if x2<x or y2<y then
		return
	end
	r=r or 1
	r=mid(0,r,w-2)
	r=mid(0,r,h-2)
	
	--corners
	circfill(x+r, y+r, r,c)
	circfill(x2-r,y+r, r,c)
	circfill(x+r, y2-r,r,c)
	circfill(x2-r,y2-r,r,c)
	
	--the rest
	rectfill(x,  y+r,x2,  y2-r,c)
	rectfill(x+r,y,  x2-r,y2  ,c)
end

function count_hats(score)
	local ret=0
	for i=0,#unlock_depths-1 do
		if score>=unlock_depths[i] then
			ret+=1
		end
	end
	return ret
end
-->8
--partilces

function gib_update(◆)
	◆.age+=1

	--update position
	◆.x+=◆.dx
	◆.y+=◆.dy
	
	◆.dx/=1.05 --air resistance
	if ◆.dy<1 then --gravity
		◆.dy+=1
	end
	--account for camera scroll
	if 웃.y==40 and fall>0 then
		◆.y-=fall
	end
	
	if ◆.y<-8 then
		del(parts,◆)
	end
end

function float_update(◆)
	◆.age+=1
	◆.x+=◆.dx
	◆.y+=◆.dy
	
	◆.dx/=1.1
	◆.dy/=1.1
	
	if 웃.y==40 and fall>0 then
		◆.y-=fall
	end
end

function add_flash(x,y,r,c)
	add(parts,{
		x=x,
		y=y,
		r=r,
		c=c or 6,
		upd=function(◆)
			circfill(◆.x,◆.y,◆.r,◆.c)
			◆.r-=1
			if ◆.r<=0 then
				del(parts,◆)
			end
		end
	})
end

function muzzle(sprite,ox,oy,r,c)
	add(parts,{
		sprite=sprite,
		ox=ox,
		oy=oy,
		r=r,
		c=c or 7,
		upd=function(◆)
			circfill(◆.sprite.x+ox,
				◆.sprite.y+oy,◆.r,◆.c)
			◆.r-=1
			if ◆.r>4 then
				◆.r/=2
			end
			if ◆.r<=0 then
				del(parts,◆)
			end
		end
	})
end

function add_gib(s,x,y)
	for i=0,4 do
		add(parts,{
			sprite=rnd(s),
			x=x,
			y=y,
			dx=(rnd()-.5)*3,
			dy=(rnd()-.5)*3,
			fx=rnd({true,false}),
			fy=rnd({true,false}),
			age=rnd(20),
			upd=function(◆)
				spr(◆.sprite,◆.x,◆.y,
					1,1,◆.xf,◆.fy)
				gib_update(◆)
				if ◆.age>40 then
					add_blood(◆.x,◆.y,5)
					del(parts,◆)
				end
			end
		})
	end
	
	add_blood(x,y,10)
end

function add_blood(x,y,n)
	for i=1,n do
		add(parts,{
			x=x,
			y=y,
			dx=(rnd()-.5)*3,
			dy=(rnd()-.5)*3,
			age=rnd(20),
			upd=function(◆)
				pset(◆.x,◆.y,8)
				gib_update(◆)
				if ◆.age>30 then
					del(parts,◆)
				end
			end
		})
	end
end

function add_dust(x,y,age)
	add(parts,{
		x=x,
		y=y,
		dx=(rnd()-.5)*3,
		dy=(rnd()-.5)*3,
		r=rnd()*2+4,
		age=rnd(5)+(age or 0),
		upd=function(◆)
			local c
			if ◆.age>10 then
				fillp(░)
			elseif ◆.age>5 then
				fillp(▒)
			else
				fillp()
			end
			if ◆.age>12 then
				c=7
			elseif ◆.age>7 then
				c=15
			else
			 c=9
			end
			circfill(◆.x,◆.y,◆.r,c)
			fillp()
			
			float_update(◆)
			
			◆.r-=.2
			if ◆.r<0 then
				del(parts,◆)
			end
		end
	})
end

function add_bulpop(x,y,anim)
	add(parts,{
		x=x,
		y=y,
		frame=0,
		anim=anim,
		upd=function(◆)
			spr(◆.anim[flr(◆.frame)+1],
				◆.x,◆.y)
			◆.frame+=0.7
			if ◆.frame>=#◆.anim then
				del(parts,◆)
			end
		end
	})
end

function add_drop(bul,vscale)
	vscale=vscale or 1
	add(back_parts,{
		x=bul.x+rnd(4)+2,
		y=bul.y+rnd(4)+2,
		dx=(rnd()-.5)+bul.dx/2*vscale,
		dy=(rnd()-.5)+bul.dy/2*vscale,
		r=rnd()+1.5,
		age=rnd(5),
		cols=bul.cols,
		upd=function(◆)
			circfill2(◆.x,◆.y,◆.r,◆.cols[1])
			circfill2(◆.x+◆.dx/2,
				◆.y+◆.dy/2,◆.r/2,◆.cols[2])
			if ◆.age>10 then
				◆.r-=.5
			end
			◆.age+=1
			
			◆.x+=◆.dx
			◆.y+=◆.dy
			
			◆.dx/=1.1
			◆.dy/=1.1
			
			if 웃.y==40 and fall>0 then
				◆.y-=fall
			end
			
			if ◆.r<0 then
				del(back_parts,◆)
			end
		end
	})
end

function add_coin_part(x,y)
	for i=1,10 do
		add(parts,{
			x=x,
			y=y,
			dx=(rnd()-.5)*3,
			dy=rnd()*3,
			age=rnd(10),
			upd=function(◆)
	--			if ◆.age%4<2 then
					circfill(◆.x,◆.y,1,
						rnd({10,10,9,9,7}))
			--	end
				
				float_update(◆)
				◆.x+=sin(◆.age/8)
				
				if ◆.age>20 then
					del(parts,◆)
				end
			end
		})
	end
end

function add_credit(text,y1,y2,c)
	c=c or 6
	add(parts,{
		text=text,
		y=y1+88,
		y1=y1,
		y2=y2,
		spd=0.4,
		upd=function(◆)
			oprintc(text,64,◆.y,c,1)
			if ◆.y>◆.y1 then
				◆.y+=(◆.y1-◆.y)/8
				--do it again coz i'm too
				--lazy to simplify it
				◆.y+=(◆.y1-◆.y)/8
			end
			if ◆.y<◆.y1+1.5 then
				◆.y-=◆.spd
			end
			if ◆.y<◆.y2 then
				◆.spd+=0.2
			end
			if ◆.y<-8 then
				del(parts,◆)
			end
		end
	})
end

function add_hat_part()
	local xoff=웃.flp and 4 or -4
	add(parts,{
		x=웃.x+xoff,
		y=웃.y,
		upd=function(◆)
			spr(hat+128,◆.x,◆.y,1,1,
				웃.flp)
			◆.y+=2
			if 웃.y==40 and fall>0 then
				◆.y-=fall
			end
		end
	})
end
__gfx__
ccffffcc66ffffccccffffcc66ff8fccccffffcc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c76f76ccc7df7dc6c76f76ccc7df7dccc76f76c0000000000000000000000000000000000066600000666000006660000066600000666000880088000000000
66ffffcc66ffffcc66ffffcc66ffffcc66ffffcc000000000000000000000000000000000000400000004000000040000000000000004000088e8880000e8000
cf1111fc6f1111fccf1111fc6f1181fccf1111fc00000000000000000000000000000000000040000000400000000000000000000000400008ee888008e00880
cf1111fccf1111fccf111188cc1811fccf1111fc0000000000000000000000000000000000004000000040000000000000000000000040000088880000880000
cf111177cf1111fcc4111155cf181877cf1111770000000000000000000000000000000000066600000000000000000000000000000666000008800000008000
c4dccd55c4dccdccc7dccd77c4dccd55c4dccd550000000000000000000000000000000000000000000000000000000000000000000060000000000000000000
c7dccd88c7dccdccccccccccc7dccd88c7dccd880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000
04000000004000000000000000000000004000000000000000000000000000000000000000066600000666000000000000000000000000000000000000000000
47466660047466660000666600000000047400000000000000000000000000000000000000004000000040000000400000000000000000000000000000000000
07600060007600060000000000060006007000000000000000000000000000000000000000004000000040000000400000000000000000000000000000000000
00666660000666660000000000066666000000000000006600000000000000000000000000004000000040000000400000000000000000000000000000000000
00606060000606060000000000000000000000000000060600000000000000000000000000066600000666000006660000066600000000000000000000000000
00666660000666660000000000000000000000000006666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000
0b5bb5b00bbbbbb00b5bb5b00bbbbbb00b5bb5b00bbbbbb00b5bb5b00bbbbbb00000000000066600000666000000000000000000000000000000000000000000
0b5555b00b5555b00b5555b00b5555b00b5555b00b5555b00b5555b00b5555b00000000000004000000040000000400000000000000000000000000000000000
0bb55bb00bb55bb00bb55bb00bb55bb00bb55bb00bb55bb00bb55bb00bb55bb00000000000004000000040000000400000000000000000000000000000000000
05533550055335500553355005533550055335500553355005533550055335500000000000004000000040000000400000000000000000000000000000000000
055b3550055b3550055b3550055b3550055b3550055b3550055b3550055b35500000000000066600000666000006660000066600000000000000000000000000
0bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb00bbbbbb00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b5bb0000b5b00000b5b00000b5bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b550000000088800b0055b00b5505000000000000000000000000000000000000aaa00000aa000000a0000000aa0000000000000000000000000000
000000b00bb500000bb057500b005b000b005000000000000000000000000000000000000099a000009a000000a00000009a0000000000000000000000000000
0000000000000000000088800003000000000000000000000000000000000000000000000009a000000a000000a00000000a0000000000000000000000000000
055b305000003550055b355005000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb00bb0bbb00bbbbbb0000b0bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4464446d4464446d444444440000000044444444556ddd6d00000000000000000000000055555555555555550000000000000000000000000220022000000000
44744444447444444644d4440000000046744444d676ddd700000000000000000000000055555555555555550000000000000000008888002880088202000020
4444444444444444444444440000000045555444d5555675000000000000000000000000555555555555555500000000000aa000088998802800008200000000
444dd444444dd444464dd44400000000445dd544d65dd55500000000000000000000000055555555555555550000000000a77a00089aa9800009900000022000
4447444444474444444444440000000044475544d55755dd00000000000000000000000055555555555555550000000000a77a00089aa9800009900000022000
5677d7645677d7645644d444000000004477d4445644d766000000000000000000000000555555555555555500000000000aa000088998802800008200000000
dd444444dd44444444644444000000004d654444d44445d600000000000000000000000055555555555555550000000000000000008888002880088202000020
4d4474444d4474444444464400000000444444444444444400000000000000000000000055555555555555550000000000000000000000000220022000000000
4464446d444444444444444400000000556ddd6d556ddd6d00000000000000000000000055555555555555550000000000000000000000000000000000000000
44744444444444444444444400000000d676ddd7d676ddd700000000000000000000000055555555555555550000000000000000000000000000000000000000
44444444444444754444447400000000d5555675d555567500000000000000000000000055555555555555550000000000000000000000000000000000000000
444dd444464dd554444d444400000000d65dd555d65dd55500000000000000000000000055555555555555550000000000000000000000000000000000000000
4447444444445444444444dd00000000d55755ddd55755dd00000000000000000000000055555555555555550000000000000000000000000000000000000000
5677d7645644444444444444000000005677d7665677d76600000000000000000000000055555555555555550000000000000000000000000000000000000000
dd444444dd6455444444444400000000dd6555d6dd6555d600000000000000000000000055555555555555550000000000000000000000000000000000000000
4d4474444d65764644447644000000005d6576565d65765600000000000000000000000055555555555555550000000000000000000000000000000000000000
444444444444444444444444000000000000000000000000000000004464446d4444444400000000000000000000000000000000000000000000000000000000
44444444444444444444444400000000000000000000000000000000447444444644d44400000000000000000000000000000000000000000000000000000000
44444475444444754444447400000000000000000000000000000000444444444444444400000000000000000000000000000000000000000000000000000000
464dd554464dd554444d444400000000000000000000000000000000444dd444464dd44400000000000000000000000000000000000000000000000000000000
4444544444445444444444dd00000000000000000000000000000000444744444444444400000000000000000000000000000000000000000000000000000000
564444445644444444444444000000000000000000000000000000005677d7645644d44400000000000000000000000000000000000000000000000000000000
dd645544dd6455444444444400000000000000000000000000000000dd4444444464444400000000000000000000000000000000000000000000000000000000
4d6576464d65764644447644000000000000000000000000000000004d4474444444464400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444754444447400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000464dd554444d444400000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000044445444444444dd00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000564444444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000dd6455444444444400000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000004d6576464444764400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000bbbbbbbb556ddd6d5555555e51c555c100000000bbbbbb33bbbbbb33bbbbbb3300000000
00000000000000000000000000000000000000000000000000000000bbb9bbbbd676ddd7525555525c55555c0e7ee7e0bb3bbbb3bb3bbbb3bb3bbbb30e7ee7e0
000000000000000000000000044444400000000000000000000000009b99b9b9d5555675522555555555c55507177170b55b355bb55b355bbb5b35bb07c77c70
00000000ccccc00000225200040440400aaaaa007777700077e2e00099999999d65dd55555555255555c15550e7ee7e0b55b355bbbbb3bbbb55b355b0e7ee7e0
00000000ccccc00005422520040000400aaaaa00777770007e2e700099999999d55755dd55552e555555555502222220bbb55bbbbbb55bbbbbb55bbb02222220
00000000c0c0c00005200220000000000a0a0a0070707000e0e0e000999999995677d7665e5555555c5555c502252520b355553bb355553bb355553b02252520
00000000c000c00002000040000000000a000a00700070002000200099999999dd6555d65225552e51155c1502222220b35b353bb35b353bb35b353b02222220
00000000000000000000000000000000000000000000000000000000999999995d657656555555555555555500000000bbbbbbbbbbbbbbbbbbbbbbbb00000000
00000000bbbbbb33bbbbbb33bbbbbb3355555555555555555555555555555555555555555555555555555555bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33
0e7ee7e0bb3bbbb3bb3bbbb3bb3bbbb358555585515555155b5555b552555525595555955e5555e558585855bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3bb3bbbb3
07877870b88b388bbbbb3bbbbb8b38bb5558855555511555555bb5555552255555599555555ee55555555555b66b366bbbbb3bbbbb6b36bbbaab3aabbaab3aab
0e7ee7e0b88b388bb88b388bb88b388b558558555515515555b55b55552552555595595555e55e5555555555b66b366bb66b366bb66b366bbaab3aabbbbb3bbb
02222220bbb88bbbbbb88bbbbbb88bbb55555555555555555555555555555555555555555555555585858585bbb66bbbbbb66bbbbbb66bbbbbbaabbbbbbaabbb
02252520b388883bb388883bb388883b56655665566556655665566556655665566556655665566556655665b366663bb366663bb366663bb3aaaa3bb3aaaa3b
02222220b38b383bb38b383bb38b383b57755775577557755775577557755775577557755775577557755775b36b363bb36b363bb36b363bb3ab3a3bb3ab3a3b
00000000bbbbbbbbbbbbbbbbbbbbbbbb55555555555555555555555555555555555555555555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbb335555555555555555555555555555555555555555555555555555555555555555000000000000000000000000eeeeeeee000000000008800000666600
bb3bbbb355555555b335533b55555555555555555725527557255275555555555555555500cccc0000bbbb0000006000eeeeeeee000990000089980006666560
bbab3abb533553353b3553b3555555555b3553b5572552755725527557255275555555550c1cc1c00b3bb3b000067600e55ee55e000990000089980006665660
baab3aab53b55b3533b55b3333b55b3333b55b33555555555555555555555555572552750cc11cc00bb33bb000677760e57ee75e000440000008800006666660
bbbaabbb555bb555555bb555555bb555555bb555555555555050050555555555572552750cc11cc00bb33bb006777600eeeeeeee000440000004400006666660
b3aaaa3b55b33b5555bbbb5555bbbb5555bbbb55555555555000000555555555555555550cc11cc00bb33bb067676000eeeffeee000440000004400006dddd60
b3ab3a3b5535535555bbbb5555bbbb5555bbbb55555555555050050555555555555555550c1cc1c00b3bb3b006760000eeeffeee000440000004400006666660
bbbbbbbb555555555555555555555555555555555555555555555555555555555555555500cccc0000bbbb0000600000eeeeeeee000000000000000000000000
0066660000666600006666000066660089ab3c12289ab3c11c3ba9820004900000094000bbbbb7bbbb33b7bb0004400000044000bbbbbb33bbbbbb33bbbbbb33
0666656006666560066665600666656089ab3c121289ab3cc3ba98210049440000449400bbbb7e7bb3bb7e7b0004400000044000bb3bbbb3bb3bbbb3bb3bbbb3
0666566006665660066656600666566089ab3c12c1289ab33ba9821c0494444004444940b7bbb7bbb7bbb7bb009aaa00009ae200bccb3ccbbbbb3bbbbbcb3cbb
0666666006666660066666600666666089ab3c123c1289abba9821c349444444444444947e7bbbbb7e7bbb3b099aaaa0099e2ea0bccb3ccbbccb3ccbbccb3ccb
0666666006666660066666600666666089ab3c12b3c1289aa9821c3b9444444444444449b7bbbbbbb7bb33bb0aaaaaa00ae2eae0bbbccbbbbbbccbbbbbbccbbb
06cccc60068888600677776006bbbb6089ab3c12ab3c12899821c3ba44444444444444440bb4b0b00bb4b0b00aaaaaa00e2eae20b3cccc3bb3cccc3bb3cccc3b
0666666006666660066666600666666089ab3c129ab3c128821c3ba9444444444444444400b4400000b490000aaaaaa002eae2e0b3cb3c3bb3cb3c3bb3cb3c3b
0000000000000000000000000000000089ab3c1289ab3c1221c3ba980000000000000000000440000009400000aaaa0000ae2e00bbbbbbbbbbbbbbbbbbbbbbbb
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
66666666000000000000000066666677666666600000000000000000000000006666666000000000000000000000000000000000000000000000000000000000
66666666000000000000000066666667666666600000000000000000000000006666666000000000000000000000000000000000000000000000000000000000
66766766000000000000000067777667666000000000000000000000000000000066600000000000000000000000000000000000000000000044000000000000
66666666000000000000000067777667666660000000000000000000000000000066600000000000000000000000000000000000000000000022220000000400
66777766000000000000000067777667666000000000000000000000000000000066600000000000000000000000000000000000600000600444444000044400
66666666000000000000000067777667666666600000000000000000000000006666666000000000000000000000000000000000660000600000000000400000
66777766000000000000000066777667666666600000000000000000000000006666666000000000000000000000000000000000000000000000000000000000
66777766000000000000000066666677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660000000000000000666666000000000000000000666006600000000066600660000000006660066000000000000000000000000000000000
66666666666666660000000000000000666666600000000000000000666006600000000066600660000000006660066000000000000000000000000000000000
66777766667777660000000000000000666006600000000000000000666006600000000066600660000000006666666000000000000000000000000000000000
66777766667777660000000000000000666006600000000000000000666006600000000066666660000000000666660000000000000000000000000000000000
66777766667777660000000000000000666666000000000000000000666006600000000066666660000000000066600000000000000000000000000000000000
66777766667777660000000000000000666666600000000000000000666666600000000066666660000000000066600000000000000000000000000000000000
66777766666666660000000000000000666006600000000000000000066666000000000006606600000000000066600000000000000000000000000000000000
66777766666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666666ccc66666cc666cc66c666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc6666666c6666666c666cc66c6666c66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66c666cc66c666cc66c6666666ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66c666cc66c6666666c6666666ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66c666cc66c6666666c666c666ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc6666666c6666666c6666666c666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666666ccc66666ccc66c66cc666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66cc66666cc666666cc666666cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66c6666666c6666666c6666666ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc666cc66c666cc66c666cc66c666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc6666666c666cc66c666cc66c666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc6666666c6666666c666666cc666cc66ccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc6666666c6666666c6666666c6666666ccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc66c66cc666cc66c666cc66c666666cccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccd7d7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccd1d1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccddddccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc88a88ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc668a866cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccdd8a8ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccaacaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccaacaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
22c22c2222c22c1111c11c1111c11c0000c00c0000c00cccccccccccccccccccccccccccccccccccccc00c0000c00c0000c11c1111c11c1111c22c2222c22c22
9429924994299224421441244214411221022012210220ccdcccdcccdcccdcccdcccdcccdcccdcccdc0220122102201221144124421441244229924994299249
42444422429449212122221121422410101111001021120cccdcccdcccdcccdcccdcccdcccdcccdcc02112001011110011422411212222112294492242444422
22444429224444241122221411222212001111020011110cdcccdcccdcccdcccdcccdcccdcccdcccd01111020011110201222214112222141244442922444429
9244429492444242412221424122212120111021201110dcccdcccdcccdcccdcccdcccdcccdcccdcc01110212011102121222142412221424244429492444294
4424224444242222221211222212111111010011110100ccdcccdcccdcccdcccdcccdcccdcccdccc020100111101001114121122221211222924224444242244
24424422244244211221221112212210011011000110110cccdcccdcccdcccdcccdcccdcccdcccdc011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd00111022001110221122214411222144224442992244429
4942229449422242242111422421112112100021121000cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd022000211210002114411142242111422992229449422294
4429924444299222221441222214411111022011110220dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc02112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd01111020011110201222214112222141244442922444429
9244429492444242412221424122212120111021201110cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc01110212011102121222142412221424244429492444294
4424224444242222221211222212111111010011110100dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdc010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110dcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110dddddddddddddddddddddddddddddddddd00111022001110221122214411222144224442992244429
4942229449422242242111422421112112100021121000dddddddddddddddddddddddddddddddddd022000211210002114411142242111422992229449422294
4429924444299222221441222214411111022011110220dddddddddddddddddddddddddddddddddd010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120dddddddddddddddddddddddddddddddddd02112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110dddddddddddddddddddddddddddddddddd01111020011110201222214112222141244442922444429
9244429492444242412221424122212120111021201110ddddddddddddddddddddddddddddddddddd01110212011102121222142412221424244429492444294
4424224444242222221211222212111111010011110100dddddddddddddddddddddddddddddddddd010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110ddddddddddddddddddddddddddddddddd011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110d1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd100111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210001ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1d022000211210002114411142242111422992229449422294
4429924444299222221441222214411111022011110220dd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1dd02112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110d1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd101111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011101ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1dd01110212011102121222142412221424244429492444294
4424224444242222221211222212111111010011110100dd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1d011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d100111022001110221122214411222144224442992244429
4942229449422242242111422421112112100021121000d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102201d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d010220111102201112144122221441222429924444299244
429449224294492121422411214224101021120010211201d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d02112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d101111020011110201222214112222141244442922444429
9244429492444242412221424122212120111021201110d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d01110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101001d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d010100111101001112121122221211222424224444242244
244244222442442112212211122122100110110001101101d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110111111111111111111111111111111111100111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210001111111111111111111111111111111111022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102201111111111111111111111111111111111010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120111111111111111111111111111111111102112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110111111111111111111111111111111111101111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011101111111111111111111111111111111111101110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101001111111111111111111111111111111111010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110111111111111111111111111111111111011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110101110111011101110111011101110111000111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210000111011101110111011101110111011101022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102201101110111011101110111011101110111010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120111011101110111011101110111011101102112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110101110111011101110111011101110111001111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011100111011101110111011101110111011101101110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101001101110111011101110111011101110111010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110111011101110111011101110111011101011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110101010101010101010101010101010101000111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210001010101010101010101010101010101010022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102200101010101010101010101010101010101010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120010101010101010101010101010101010102112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110101010101010101010101010101010101001111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011101010101010101010101010101010101010101110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101000101010101010101010101010101010101010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110010101010101010101010101010101010011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110000000000000000000000000000000000000111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210000000000000000000000000000000000000022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102200000000000000000000000000000000000010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120000000000000000000000000000000000002112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110000000000000000000000000000000000001111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011100000000000000000000000000000000000001110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101000000000000000000000000000000000000010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110000000000000000000000000000000000011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110000000000000000000000000000000000000111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210000000000000000000000000000000000000022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102200000000000000000000000000000000000010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120000000000000000000000000000000000002112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110000000000000000000000000000000000001111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011100000000000000000000000000000000000001110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101000000000000000000000000000000000000010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110000000000000000000000000000000000011011000110110012212211122122112442442224424422
92244429922444244112221441122212200111022001110000000000000000000000000000000000000111022001110221122214411222144224442992244429
49422294494222422421114224211121121000211210000000000000000000000000000000000000022000211210002114411142242111422992229449422294
44299244442992222214412222144111110220111102200000000000000000000000000000000000010220111102201112144122221441222429924444299244
42944922429449212142241121422410102112001021120000000000000000000000000000000000002112001021120011422411214224112294492242944922
22444429224444241122221411222212001111020011110000000000000000000000000000000000001111020011110201222214112222141244442922444429
92444294924442424122214241222121201110212011100000000000000000000000000000000000001110212011102121222142412221424244429492444294
44242244442422222212112222121111110100111101000000000000000000000000000000000000010100111101001112121122221211222424224444242244
24424422244244211221221112212210011011000110110000000000000000000000000000000000011011000110110012212211122122112442442224424422

__map__
4142494949494949494949494949404141414142494949494949494940414141414141414142494900004041414141414141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5152494949494949494949494949505151515152494949494949494950515151515151515152494900005051515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949494949494949494949494949494949494949494949494949494949494949494949494949494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
480300003007330053300432f0332e0332d0232b0232a023290132501306613046130361301613006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
640400002e143243532b153211431f3431c333241531f333173231c133123130731303313023030e3030e3030530311303113031130310303103030e3030e3031130311303113031130310303103030e3030e303
00020000250501e030180500f0400604002030130201404014020130201104002030031200000024000057000470004700112000000010200000000e200306001120000000112000000010200000000e20000000
0402000004560045602615024150201501c1501b1501a15019150171501615014150121500e1500d1500050000500005000050000500005000050000500005000050000500005000050000500005000050000500
10020000037200b030090400b0500e0500f060120601406017070190701a0701b0701c0701c0701c0701c0601c0601c0601c0501c0401c0301c0101c050007001c0501d0501d0501d05000700007000070000700
cc0300200412005130041200412004120041200412004120041300412005120051200512005120041200412004120041200412004130061200512004120041200413005120061200412004130051200512005120
c00100000364003640036400364003640036400364003640036400364003640036400364003640036400364003640036400364003640036400364003640036400364003640036400364003640036400364003640
6004000026060210601c0501905018050180601805018050190500805008040070400604004050020500005003400034000340003400034000340003400034000340003400034000340003400034000340000400
900200001f16017140141201311011110101100f1100e1200c1200a13009130081400615000100001000010000100000000000000000000000000000000000000000000000000000000000000000000000000000
900300001d1531c1451b1531b1531a17319165181531813317153171631514514155141631414513153131530c6450c6030060300603006030060300603006030060300603006030060300603006030060300603
500600000a15307163051630a17308173081730517309163081630515309133051130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
60080000191501e14021140231402515025150231501f1401a140141300a1500b15019150221402214022140211401e1401a14016140111400e1400b140091400614006140004000040000400000000000000000
00030000301702e1602a1402713024120221201f1201c1201a120171301613014140121400f1500e1600d1700c1700b1500010000100001000010000100001000010000100001000010000100001000010000100
000200003515032150280502e150260502c1501e3601e3501e3501d3501c3401c3401b34019330183201732000510005000050000500005000050000500005000050000500005000050000500005000050000500
000200001052013540005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600000904109041090410a0410a0410a0410b0410b0410b0410c0510c0510d0510e0510f05110051120511405116061180611a0611d0611f06100000370603040037060300003706037065244000000000000
0006000010560105610f5610e5510c551095510654104541035310253101521015210000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000400001e33023320003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
05040000121401214012140001000c1400c1400c1400c100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000100001d6501b6601c5401e53039230392303923039220392203922039220392203922039210392103921039210392103921039210000000000000000000000000000000000000000000000000000000000000
c00100003866037600316402f6502f6000c1400a13008140071400614005130051300513004130031200312002120021200211002110021100211002110021100211003110031100311002110011100111000110
3202000024670226700110003171031710317103171031710317103161031610316103161021610216102161011510115101151011510c1000c10016100161001610015100151001510015100091000010000101
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0a00000567511210112301121010240102100e2500e2101122011210112301121010240102100e2500e2100567511210112301121010240102100e2500e2101122011210112301121010240102100e2500e210
030a0000057710473104701112000000010200000000e2003067500000000001120000000102000000024000057710473104701112000000010200000000e200306751120000000112000000010200000000e200
__music__
03 20214344
00 40404344

