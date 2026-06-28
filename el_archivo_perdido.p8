pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main + mundo

function _init()
	mundo_actual=1

	cam_x=0
	cam_y=0

	enemigos={}
	jefe=nil
	proyectiles_jefe={}
	proyectiles_jugador={}

	cargar_mundo(1)
	cargar_enemigos()
	cargar_jefe()

	jug=make_jugador()

	estado="titulo"

	intro_t=0
	escena_intro=1

	dialogo_lineas={}
	dialogo_i=1
	dialogo_accion=nil

	calle_dialogo_hecho=false
	plaza_dialogo_hecho=false
	gym_dialogo_hecho=false
	plaza_derrotado=false
	gym_derrotado=false

	tiempo_juego=0
	tiempo_limite=60*60*8
	motivo_derrota=""
	musica_actual=-1

	intro_escenas={
		{
			map_x=0,
			map_y=0,
			map_w=16,
			map_h=9,
			texto="mi cuarto..."
		},
		{
			map_x=17,
			map_y=0,
			map_w=30,
			map_h=10,
			texto="pase por la calle..."
		},
		{
			map_x=49,
			map_y=0,
			map_w=29,
			map_h=10,
			texto="estuve en la plaza..."
		},
		{
			map_x=79,
			map_y=0,
			map_w=29,
			map_h=10,
			texto="tengo que recuperarlo"
		}
	}

	tocar_musica(1)
end


function _update()
	if estado=="titulo" then
		update_titulo()

	elseif estado=="intro_pensando" then
		update_intro_pensando()

	elseif estado=="intro_paneo" then
		update_intro_paneo()

	elseif estado=="dialogo" then
		update_dialogo()

	elseif estado=="jugando" then
		update_jugando()

	elseif estado=="final" then
		update_final()

	elseif estado=="game_over" then
		update_game_over()
	end
end


function _draw()
	cls(0)

	if estado=="titulo" then
		camera()
		draw_titulo()

	elseif estado=="intro_paneo" then
		camera()
		dibujar_intro_mundo()
		draw_intro_paneo()

	else
		dibujar_mundo()

		for e in all(enemigos) do
			e.drw()
		end

		if jefe!=nil then
			jefe.drw()
		end

		for p in all(proyectiles_jefe) do
			p.drw()
		end

		for p in all(proyectiles_jugador) do
			p.drw()
		end

		jug.drw()

		camera()

		if estado=="intro_pensando" then
			draw_intro_pensando()

		elseif estado=="dialogo" then
			draw_dialogo()

		elseif estado=="jugando" then
			draw_jugando()

		elseif estado=="final" then
			draw_final()

		elseif estado=="game_over" then
			draw_game_over()
		end
	end

	camera()
end


function update_jugando()
	actualizar_tiempo()

	if estado!="jugando" then
		return
	end

	jug.upd()

	revisar_dialogo_calle()
	revisar_dialogo_plaza()
	revisar_dialogo_gym()

	if estado!="jugando" then
		return
	end

	for e in all(enemigos) do
		e.upd()
	end

	if jefe!=nil then
		jefe.upd()
	end

	for p in all(proyectiles_jefe) do
		p.upd()
	end

	for p in all(proyectiles_jugador) do
		p.upd()
	end

	revisar_fin_jefe()
end


function cargar_mundo(n)
	mundo_actual=n

	if n==1 then
		mundo={
			map_x=0,
			map_y=0,
			map_w=16,
			map_h=9,

			x_min=8,
			x_max=108,
			y_min=27,
			y_max=46,

			entrada_x=16,
			entrada_y=40,

			puerta_x=98,
			puerta_y=27,
			puerta_w=10,
			puerta_h=19,

			destino=2
		}

	elseif n==2 then
		mundo={
			map_x=17,
			map_y=0,
			map_w=30,
			map_h=10,

			x_min=8,
			x_max=219,
			y_min=35,
			y_max=54,

			entrada_x=16,
			entrada_y=48,

			puerta_x=0,
			puerta_y=0,
			puerta_w=0,
			puerta_h=0,

			destino=3
		}

	elseif n==3 then
		mundo={
			map_x=49,
			map_y=0,
			map_w=29,
			map_h=10,

			x_min=0,
			x_max=216,
			y_min=48,
			y_max=48,

			entrada_x=24,
			entrada_y=48,

			puerta_x=0,
			puerta_y=0,
			puerta_w=0,
			puerta_h=0,

			destino=0
		}

	elseif n==4 then
		mundo={
			map_x=79,
			map_y=0,
			map_w=29,
			map_h=10,

			x_min=0,
			x_max=216,
			y_min=48,
			y_max=48,

			entrada_x=24,
			entrada_y=48,

			puerta_x=0,
			puerta_y=0,
			puerta_w=0,
			puerta_h=0,

			destino=0
		}
	end
end


function mover_camara()
	cam_x=0
	cam_y=0

	if mundo.map_w>16 then
		cam_x=jug.x-64

		local max_cam=(mundo.map_w*8)-128

		cam_x=mid(0,cam_x,max_cam)
	end
end


function dibujar_mundo()
	mover_camara()

	camera(cam_x,cam_y)

	map(
		mundo.map_x,
		mundo.map_y,
		0,
		0,
		mundo.map_w,
		mundo.map_h
	)
end


function esta_en_puerta(j)
	if mundo.destino==0 then
		return false
	end

	if mundo_actual==2 then
		return false
	end

	return j.x>=mundo.puerta_x
	and j.x<=mundo.puerta_x+mundo.puerta_w
	and j.y>=mundo.puerta_y
	and j.y<=mundo.puerta_y+mundo.puerta_h
end


function ir_a_mundo(n)
	cargar_mundo(n)
	cargar_enemigos()
	cargar_jefe()

	proyectiles_jugador={}
	proyectiles_jefe={}

	jug.x=mundo.entrada_x
	jug.y=mundo.entrada_y

	tocar_musica(1)

	if n==2 then
		dialogo_entrada_calle()

	elseif n==3 then
		estado="jugando"

	elseif n==4 then
		estado="jugando"

	else
		estado="jugando"
	end
end


function revisar_cambio_mapa(j)
	if mundo_actual==2 and j.x>=mundo.x_max then
		ir_a_mundo(3)
	end
end


function revisar_dialogo_plaza()
	if mundo_actual!=3 then
		return
	end

	if plaza_dialogo_hecho then
		return
	end

	if jefe==nil or jefe.muerto then
		return
	end

	local dx=jug.x-jefe.x
	local dy=jug.y-jefe.y

	if dx<0 then
		dx=-dx
	end

	if dy<0 then
		dy=-dy
	end

	if dx<52 and dy<18 then
		plaza_dialogo_hecho=true

		jug.x=96
		jug.y=48

		jefe.x=138
		jefe.y=48
		jefe.mira=-1
		jefe.dir=-1

		dialogo_entrada_plaza()
	end
end


function revisar_dialogo_gym()
	if mundo_actual!=4 then
		return
	end

	if gym_dialogo_hecho then
		return
	end

	if jefe==nil or jefe.muerto then
		return
	end

	local dx=jug.x-jefe.x
	local dy=jug.y-jefe.y

	if dx<0 then
		dx=-dx
	end

	if dy<0 then
		dy=-dy
	end

	if dx<52 and dy<18 then
		gym_dialogo_hecho=true

		jug.x=96
		jug.y=48

		jefe.x=140
		jefe.y=48
		jefe.mira=-1
		jefe.dir=-1

		dialogo_entrada_gym()
	end
end


function revisar_fin_jefe()
	if mundo_actual==3 and jefe!=nil and jefe.muerto and not plaza_derrotado then
		plaza_derrotado=true
		dialogo_derrota_plaza()
	end

	if mundo_actual==4 and jefe!=nil and jefe.muerto and not gym_derrotado then
		gym_derrotado=true
		dialogo_derrota_gym()
	end
end
-->8
-- intro

function update_titulo()
	if btnp(4) or btnp(5) then
		estado="intro_pensando"
		intro_t=0
	end
end


function draw_titulo()
	rectfill(0,0,127,127,0)

	print("el archivo",42,24,11)
	print("perdido",50,34,11)

	print("recupera el pendrive",22,56,7)
	print("antes de la defensa",24,66,7)

	print("flechas: moverse",28,86,6)
	print("x: golpear/disparar",18,96,6)
	print("x+abajo: defensa",24,106,6)

	if flr(time()*2)%2==0 then
		print("z/x para empezar",30,118,10)
	end
end


function empezar_juego()
	cargar_mundo(1)
	cargar_enemigos()
	cargar_jefe()

	proyectiles_jugador={}
	proyectiles_jefe={}

	jug.x=mundo.entrada_x
	jug.y=mundo.entrada_y
	jug.vida=jug.vida_max

	tiempo_juego=0
	motivo_derrota=""

	iniciar_dialogo({
		{"yo","mi pendrive","no esta...",nil},
		{"yo","manana defiendo","el proyecto.",nil},
		{"yo","recuerdo haber","pasado por la plaza.",nil},
		{"yo","pero antes pase","por la calle principal.",nil},
		{"yo","tengo que buscar","alguna pista.",nil}
	},nil)
end


function update_intro_pensando()
	intro_t+=1

	if btnp(5) then
		empezar_juego()
		return
	end

	if intro_t>240 then
		intro_t=0
		estado="intro_paneo"
		escena_intro=1
	end
end


function draw_intro_pensando()
	print("...",jug.x-cam_x+6,jug.y-cam_y-10,7)

	rectfill(5,96,122,124,0)
	rect(5,96,122,124,7)

	if intro_t<80 then
		print("donde esta el",13,104,7)
		print("pendrive?",13,114,7)

	elseif intro_t<160 then
		print("no puede ser...",13,104,7)
		print("manana es la defensa",13,114,7)

	else
		print("tengo que pensar",13,104,7)
		print("donde estuve...",13,114,7)
	end

	print("x para saltar",67,88,6)
end


function update_intro_paneo()
	intro_t+=1

	if btnp(5) then
		empezar_juego()
		return
	end

	if intro_t>180 then
		intro_t=0
		escena_intro+=1

		if escena_intro>#intro_escenas then
			empezar_juego()
		end
	end
end


function camara_intro(esc)
	local max_cam=(esc.map_w*8)-128

	if max_cam<0 then
		max_cam=0
	end

	local p=(intro_t-20)/140

	p=mid(0,p,1)

	return max_cam*p
end


function dibujar_intro_mundo()
	local esc=intro_escenas[escena_intro]
	local cx=camara_intro(esc)

	camera(cx,0)

	map(
		esc.map_x,
		esc.map_y,
		0,
		0,
		esc.map_w,
		esc.map_h
	)
end


function draw_intro_paneo()
	local esc=intro_escenas[escena_intro]

	camera()

	rectfill(4,104,124,124,0)
	rect(4,104,124,124,7)

	print(esc.texto,10,112,7)
	print("x para saltar",67,94,6)
end
-->8
-- dialogos

function iniciar_dialogo(lineas,accion)
	dialogo_lineas=lineas
	dialogo_i=1
	dialogo_accion=accion
	estado="dialogo"
end


function update_dialogo()
	if btnp(4) or btnp(5) then
		dialogo_i+=1

		if dialogo_i>#dialogo_lineas then
			local acc=dialogo_accion

			dialogo_lineas={}
			dialogo_i=1
			dialogo_accion=nil

			if acc=="ir_gym" then
				ir_a_mundo(4)

			elseif acc=="final" then
				estado="final"
				tocar_musica(-1)
				sfx(10,2)

			else
				estado="jugando"
				tocar_musica(1)
			end
		end
	end
end


function draw_dialogo()
	camera()

	rectfill(3,88,124,124,0)
	rect(3,88,124,124,7)

	local t=dialogo_lineas[dialogo_i]

	print(t[1],8,94,11)

	if t[2]!=nil then
		print(t[2],8,104,7)
	end

	if t[3]!=nil then
		print(t[3],8,112,7)
	end

	if t[4]!=nil then
		print(t[4],8,120,7)
	end

	print("z/x",104,116,6)
end


function dialogo_entrada_calle()
	iniciar_dialogo({
		{"yo","la calle principal...",nil,nil},
		{"yo","si pase por aca,","alguien vio algo.",nil},
		{"yo","voy a preguntarle","a ese estudiante.",nil}
	},nil)
end


function dialogo_estudiante_calle()
	iniciar_dialogo({
		{"yo","che, vos estabas","cerca de la plaza?",nil},
		{"estudiante","depende...","sos el del pendrive?",nil},
		{"yo","si.","lo viste?",nil},
		{"estudiante","vi al placero","levantar algo.",nil},
		{"yo","entonces tengo que","ir a la plaza.",nil},
		{"estudiante","no tan rapido.","primero pasa",nil},
		{"estudiante","por nosotros.",nil,nil}
	},nil)
end


function dialogo_entrada_plaza()
	iniciar_dialogo({
		{"yo","la plaza...","aca lo perdi.",nil},
		{"placero","vos sos","el estudiante?",nil},
		{"yo","si.","viste un pendrive?",nil},
		{"placero","lo encontre...","pero se lo di",nil},
		{"placero","a alguien mas.",nil,nil},
		{"yo","a quien?",nil,nil},
		{"placero","primero demostra","que lo necesitas.",nil}
	},nil)
end


function dialogo_derrota_plaza()
	iniciar_dialogo({
		{"placero","esta bien, basta.",nil,nil},
		{"placero","se lo di","al jefe del gym.",nil},
		{"yo","por que","al gym?",nil},
		{"placero","odia a los","estudiantes.",nil},
		{"placero","dijo que no iban","a defender nada.",nil},
		{"yo","entonces voy","al gym.",nil}
	},"ir_gym")
end


function dialogo_entrada_gym()
	iniciar_dialogo({
		{"jefe gym","asi que viniste.",nil,nil},
		{"yo","dame mi","pendrive.",nil},
		{"jefe gym","esto?","lo encontre tirado.",nil},
		{"yo","lo necesito.","manana defiendo.",nil},
		{"jefe gym","si era tan","importante...",nil},
		{"jefe gym","no lo hubieras","perdido.",nil},
		{"yo","cometi un error,","pero voy a",nil},
		{"yo","arreglarlo.",nil,nil},
		{"jefe gym","entonces","demostralo.",nil}
	},nil)
end


function dialogo_derrota_gym()
	iniciar_dialogo({
		{"jefe gym","basta...","me ganaste.",nil},
		{"jefe gym","capaz no sos","tan irresponsable.",nil},
		{"yo","solo queria","mi pendrive.",nil},
		{"jefe gym","tomalo.","esta intacto.",nil},
		{"yo","gracias.",nil,nil},
		{"jefe gym","anda.","llega a esa",nil},
		{"jefe gym","defensa.",nil,nil},
		{"yo","todavia estoy","a tiempo.",nil}
	},"final")
end


function update_final()
	if btnp(4) or btnp(5) then
		_init()
	end
end


function draw_final()
	camera()

	rectfill(0,0,127,127,0)

	print("pendrive recuperado",22,42,11)
	print("la defensa sigue viva",18,56,7)
	print("gracias por jugar",28,76,6)
	print("z/x para reiniciar",25,102,5)
end


function actualizar_tiempo()
	tiempo_juego+=1

	if tiempo_juego>=tiempo_limite then
		perder_juego("tiempo")
	end
end


function danar_jugador(c)
	if estado!="jugando" or jug.defendiendo then
		return
	end

	jug.vida-=c

	if jug.vida<=0 then
		jug.vida=0
		perder_juego("vida")
	else
		sfx(11,2)
	end
end


function perder_juego(m)
	motivo_derrota=m
	estado="game_over"
	proyectiles_jefe={}
	proyectiles_jugador={}

	tocar_musica(-1)
	sfx(3,2)
end


function update_game_over()
	if btnp(4) or btnp(5) then
		_init()
	end
end


function draw_game_over()
	camera()

	rectfill(0,0,127,127,0)

	print("perdiste",47,34,8)

	if motivo_derrota=="tiempo" then
		print("se acabo el tiempo",26,56,7)
		print("empezo la defensa",24,70,6)
	else
		print("sin vidas",46,56,7)
		print("perdiste el pendrive",18,70,6)
	end

	print("z/x reiniciar",34,104,5)
end


function tiempo_restante_texto()
	local r=tiempo_limite-tiempo_juego

	if r<0 then
		r=0
	end

	local s=flr(r/60)
	local m=flr(s/60)

	s=s%60

	if s<10 then
		return m..":0"..s
	end

	return m..":"..s
end


function tocar_musica(n)
	if musica_actual==n then
		return
	end

	musica_actual=n

	if n==1 then
		sfx(12,3)
	else
		sfx(-1,3)
	end
end
-->8
-- jugador

function make_jugador()
	local j={}

	j.ancho=16
	j.alto=16

	j.x=mundo.entrada_x
	j.y=mundo.entrada_y

	j.z=0
	j.vz=0
	j.gravedad=0.35
	j.salto=4.2

	j.vel=1

	j.spr=1
	j.spr_parado=1

	j.mira=1

	j.anim_t=0
	j.moviendo=false

	j.accion="normal"
	j.accion_t=0
	j.atq_cd=0
	j.defendiendo=false
	j.danio=1

	j.vida=3
	j.vida_max=3

	j.upd=function()
		j.moviendo=false

		local quiere_defensa=btn(5) and btn(3)

		if jefe!=nil and not jefe.muerto and (mundo_actual==3 or mundo_actual==4) then
			if jefe.x<j.x then
				j.mira=-1
			else
				j.mira=1
			end
		end

		if btn(0) then
			j.x-=j.vel
			j.moviendo=true

			if mundo_actual!=3 and mundo_actual!=4 then
				j.mira=-1
			end
		end

		if btn(1) then
			j.x+=j.vel
			j.moviendo=true

			if mundo_actual!=3 and mundo_actual!=4 then
				j.mira=1
			end
		end

		if mundo_actual!=3 and mundo_actual!=4 then
			if btn(2) then
				j.y-=j.vel
				j.moviendo=true
			end

			if btn(3) and not quiere_defensa then
				j.y+=j.vel
				j.moviendo=true
			end
		end

		if mundo_actual==4 then
			if btnp(2) and j.z<=0 then
				j.vz=j.salto
				sfx(13,0)
			end

			if j.z>0 or j.vz>0 then
				j.z+=j.vz
				j.vz-=j.gravedad

				if j.z<0 then
					j.z=0
					j.vz=0
				end
			end
		else
			j.z=0
			j.vz=0
		end

		j.x=mid(mundo.x_min,j.x,mundo.x_max)
		j.y=mid(mundo.y_min,j.y,mundo.y_max)

		revisar_cambio_mapa(j)

		if j.atq_cd>0 then
			j.atq_cd-=1
		end

		if j.accion_t>0 then
			j.accion_t-=1
		else
			j.accion="normal"
			j.defendiendo=false
		end

		if quiere_defensa then
			j.accion="defensa"
			j.defendiendo=true
			j.accion_t=2

		elseif btnp(5) and j.atq_cd<=0 then
			if mundo_actual==3 or mundo_actual==4 then
				disparar_jugador(j)
			else
				sfx(0,0)
			end

			j.accion="punio"
			j.defendiendo=false
			j.accion_t=10
			j.atq_cd=18
		end

		if j.moviendo then
			animar_jugador(j)
		else
			if j.accion=="normal" then
				j.spr=j.spr_parado
				j.anim_t=0
			end
		end

		if esta_en_puerta(j) and btnp(4) then
			ir_a_mundo(mundo.destino)
		end
	end

	j.drw=function()
		local flip=false

		if j.mira==-1 then
			flip=true
		end

		local dy=j.y-j.z

		if j.z>0 then
			ovalfill(j.x+3,j.y+13,j.x+13,j.y+16,5)
		end

		if j.accion=="punio" then
			spr(14,j.x,dy,2,2,flip,false)

		elseif j.accion=="defensa" then
			spr(37,j.x,dy,3,2,flip,false)

		else
			spr(j.spr,j.x,dy,2,2,flip,false)
		end
	end

	return j
end


function animar_jugador(j)
	j.anim_t+=1

	if j.anim_t>31 then
		j.anim_t=0
	end

	if j.anim_t<8 then
		j.spr=3

	elseif j.anim_t<16 then
		j.spr=33

	elseif j.anim_t<24 then
		j.spr=3

	else
		j.spr=35
	end
end


function golpe_jugador(j,e)
	if j.accion!="punio" then
		return false
	end

	local gx=j.x+14

	if j.mira==-1 then
		gx=j.x-6
	end

	local gy=j.y-j.z+4
	local gw=8
	local gh=10

	return chocan(
		gx,gy,gw,gh,
		e.x+3,e.y+3,10,10
	)
end
-->8
-- enemigo estudiante

function cargar_enemigos()
	enemigos={}

	if mundo_actual==2 then
		add(enemigos,make_estudiante(70,48,45,95))
		add(enemigos,make_estudiante(125,48,105,150))
		add(enemigos,make_estudiante(185,48,165,210))
	end
end


function revisar_dialogo_calle()
	if mundo_actual!=2 then
		return
	end

	if calle_dialogo_hecho then
		return
	end

	local e=enemigos[1]

	if e==nil or e.muerto then
		return
	end

	local dx=jug.x-e.x
	local dy=jug.y-e.y

	if dx<0 then
		dx=-dx
	end

	if dy<0 then
		dy=-dy
	end

	if dx<22 and dy<14 then
		calle_dialogo_hecho=true

		jug.x=e.x-26
		jug.y=e.y

		e.x=jug.x+26
		e.y=jug.y

		e.mira=-1
		e.dir=-1

		e.atacando=false
		e.golpeado=false
		e.spr=40

		dialogo_estudiante_calle()
	end
end


function make_estudiante(x,y,x_min,x_max)
	local e={}

	e.x=x
	e.y=y
	e.y_base=y

	e.ancho=16
	e.alto=16

	e.vel=0.22

	e.dir=1
	e.mira=1

	e.x_min=x_min
	e.x_max=x_max

	e.calle_min=8
	e.calle_max=219
	e.y_min=35
	e.y_max=54

	e.spr=40
	e.anim_t=0

	e.golpeado=false
	e.golpe_t=0

	e.atacando=false
	e.atq_t=0

	e.vida=2
	e.vida_max=2
	e.muerto=false

	e.golpe_cd=0

	e.upd=function()
		if e.muerto then
			return
		end

		if mundo_actual==2 and not calle_dialogo_hecho then
			return
		end

		if e.golpe_cd>0 then
			e.golpe_cd-=1
		end

		if e.atacando then
			e.atq_t-=1
			e.spr=42

			if e.atq_t<=0 then
				e.atacando=false
				e.spr=40
			end

			return
		end

		if e.golpeado then
			e.golpe_t-=1
			e.spr=12

			if e.golpe_t<=0 then
				e.golpeado=false
				e.spr=40
			end

			return
		end

		if golpe_jugador(jug,e) then
			e.vida-=jug.danio
			e.golpeado=true
			e.golpe_t=15
			e.spr=12

			if e.vida<=0 then
				e.muerto=true
			end

			return
		end

		local dx=jug.x-e.x
		local dy=jug.y-e.y

		local distx=dx
		local disty=dy

		if distx<0 then
			distx=-distx
		end

		if disty<0 then
			disty=-disty
		end

		if distx<90 and disty<35 then
			if dx<0 then
				e.mira=-1
				e.dir=-1
			elseif dx>0 then
				e.mira=1
				e.dir=1
			end
		end

		if distx<9 and disty<8 then
			if e.golpe_cd<=0 then
				e.golpe_cd=55
				e.atacando=true
				e.atq_t=12
				e.spr=42

				sfx(0,0)
				danar_jugador(1)
			else
				e.spr=40
			end

			return
		end

		if distx<90 and disty<35 then
			if distx>8 then
				if dx<0 then
					e.x-=e.vel*1.6
				elseif dx>0 then
					e.x+=e.vel*1.6
				end
			end

			if disty>4 then
				if dy<0 then
					e.y-=e.vel
				elseif dy>0 then
					e.y+=e.vel
				end
			end

			e.x=mid(e.calle_min,e.x,e.calle_max)
			e.y=mid(e.y_min,e.y,e.y_max)

		else
			e.x+=e.vel*e.dir

			if e.dir==-1 then
				e.mira=-1
			else
				e.mira=1
			end

			if e.x<=e.x_min then
				e.x=e.x_min
				e.dir=1
				e.mira=1
			end

			if e.x>=e.x_max then
				e.x=e.x_max
				e.dir=-1
				e.mira=-1
			end

			if e.y<e.y_base-1 then
				e.y+=0.15
			elseif e.y>e.y_base+1 then
				e.y-=0.15
			end
		end

		animar_estudiante(e)
	end

	e.drw=function()
		if e.muerto then
			return
		end

		local flip=false

		if e.mira==1 then
			flip=true
		end

		spr(e.spr,flr(e.x),flr(e.y),2,2,flip,false)
	end

	return e
end


function animar_estudiante(e)
	e.anim_t+=1

	if e.anim_t>47 then
		e.anim_t=0
	end

	if e.anim_t<12 then
		e.spr=8

	elseif e.anim_t<24 then
		e.spr=40

	elseif e.anim_t<36 then
		e.spr=10

	else
		e.spr=40
	end
end


function golpea_de_frente(e,j)
	local dx=j.x-e.x
	local dy=j.y-e.y

	if dx<0 then
		dx=-dx
	end

	if dy<0 then
		dy=-dy
	end

	return dx<9 and dy<8
end


function chocan(ax,ay,aw,ah,bx,by,bw,bh)
	return ax<bx+bw
	and ax+aw>bx
	and ay<by+bh
	and ay+ah>by
end
-->8
-- jefe plaza / gym

function cargar_jefe()
	jefe=nil
	proyectiles_jefe={}

	if mundo_actual==3 then
		jefe=make_jefe_plaza(150,48)

	elseif mundo_actual==4 then
		jefe=make_jefe_gym(150,48)
	end
end


function make_jefe_plaza(x,y)
	local b={}

	b.tipo="plaza"
	b.x=x
	b.y=y

	b.ancho=16
	b.alto=16

	b.vel=0.45
	b.dir=-1
	b.mira=-1

	b.x_min=92
	b.x_max=180

	b.vida=5
	b.vida_max=5
	b.muerto=false

	b.golpeado=false
	b.golpe_t=0

	b.defendiendo=false
	b.def_t=0
	b.def_cd=0

	b.disparo_t=20
	b.rafaga=0
	b.rafaga_t=0

	b.anim_t=0
	b.spr_piernas=89

	b.upd=function()
		if b.muerto then
			return
		end

		if mundo_actual==3 and not plaza_dialogo_hecho then
			return
		end

		if jug.x<b.x then
			b.mira=-1
		else
			b.mira=1
		end

		if b.def_cd>0 then
			b.def_cd-=1
		end

		if b.golpeado then
			b.golpe_t-=1

			if b.golpe_t<=0 then
				b.golpeado=false
			end

			return
		end

		local dist=jug.x-b.x

		if dist<0 then
			dist=-dist
		end

		if dist<70 then
			b.x+=b.vel*b.mira
		else
			b.x+=b.vel*b.dir
		end

		if b.x<=b.x_min then
			b.x=b.x_min
			b.dir=1
		end

		if b.x>=b.x_max then
			b.x=b.x_max
			b.dir=-1
		end

		b.anim_t+=1

		if b.anim_t>31 then
			b.anim_t=0
		end

		if b.anim_t<16 then
			b.spr_piernas=89
		else
			b.spr_piernas=91
		end

		if b.def_t>0 then
			b.def_t-=1

			if b.def_t<=0 then
				b.defendiendo=false
			end
		end

		if dist<60 and b.def_t<=0 and b.def_cd<=0 then
			b.defendiendo=true
			b.def_t=26
			b.def_cd=45
		end

		if not b.defendiendo then
			if b.rafaga>0 then
				b.rafaga_t-=1

				if b.rafaga_t<=0 then
					disparar_jefe(b)
					b.rafaga-=1
					b.rafaga_t=8
				end
			else
				b.disparo_t-=1

				if b.disparo_t<=0 then
					b.rafaga=flr(rnd(3))+1
					disparar_jefe(b)
					b.rafaga-=1
					b.rafaga_t=8
					b.disparo_t=35+rnd(20)
				end
			end
		end
	end

	b.drw=function()
		local flip=false

		if b.mira==-1 then
			flip=true
		end

		spr(75,b.x,b.y,2,1,flip,false)
		spr(b.spr_piernas,b.x,b.y+8,2,1,flip,false)

		if b.defendiendo and not b.muerto then
			local mx=b.x-14

			if b.mira==1 then
				mx=b.x+18
			end

			spr(77,mx,b.y,2,1,flip,false)
			spr(93,mx,b.y+8,2,1,flip,false)
		end
	end

	return b
end


function make_jefe_gym(x,y)
	local b={}

	b.tipo="gym"
	b.x=x
	b.y=y

	b.ancho=24
	b.alto=16

	b.vel=1.35
	b.vel_cerca=1.65

	b.dir=-1
	b.mira=-1

	b.x_min=16
	b.x_max=204

	b.vida=8
	b.vida_max=8
	b.muerto=false

	b.golpeado=false
	b.golpe_t=0

	b.defendiendo=false
	b.def_t=0
	b.def_cd=0

	b.estado="normal"

	b.t=0
	b.anim_t=0

	b.aura_t=0
	b.aura_cd=0

	b.invul_t=0

	b.carga_cd=45
	b.carga_t=0
	b.cargando=false
	b.cargando_t=0
	b.carga_dir=-1
	b.recupera_t=0
	b.golpe_carga=false

	b.upd=function()
		if b.muerto then
			return
		end

		if mundo_actual==4 and not gym_dialogo_hecho then
			return
		end

		if b.invul_t>0 then
			b.invul_t-=1
		end

		if jug.x<b.x then
			b.mira=-1
		else
			b.mira=1
		end

		if b.golpeado then
			b.golpe_t-=1

			if b.golpe_t<=0 then
				b.golpeado=false
			end
		end

		b.t+=1
		b.anim_t+=1

		if b.anim_t>31 then
			b.anim_t=0
		end

		if b.estado=="normal" then
			if b.t>70 then
				b.estado="pre_transformando"
				b.t=0
				b.anim_t=0
			end

			return
		end

		if b.estado=="pre_transformando" then
			if b.t>55 then
				b.estado="transformando"
				b.t=0
				b.anim_t=0
			end

			return
		end

		if b.estado=="transformando" then
			if b.t>45 then
				b.estado="transformado"
				b.t=0
				b.anim_t=0
			end

			return
		end

		if b.recupera_t>0 then
			b.recupera_t-=1
			return
		end

		if b.carga_t>0 then
			b.carga_t-=1

			if b.carga_t<=0 then
				b.cargando=true
				b.cargando_t=46
				b.carga_dir=b.mira
				b.golpe_carga=false

				sfx(6,2)
			end

			return
		end

		if b.cargando then
			b.cargando_t-=1
			b.x+=4*b.carga_dir

			if b.x<=b.x_min then
				b.x=b.x_min
				b.cargando=false
				b.recupera_t=10
				b.carga_cd=42
			end

			if b.x>=b.x_max then
				b.x=b.x_max
				b.cargando=false
				b.recupera_t=10
				b.carga_cd=42
			end

			if not b.golpe_carga then
				if hit_jefe_gym(b) then
					danar_jugador(1)
					b.golpe_carga=true
				end
			end

			if b.cargando_t<=0 then
				b.cargando=false
				b.recupera_t=10
				b.carga_cd=42
			end

			return
		end

		if b.carga_cd>0 then
			b.carga_cd-=1
		end

		if b.aura_cd>0 then
			b.aura_cd-=1
		end

		if b.aura_t>0 then
			b.aura_t-=1

			if hit_jefe_gym(b) then
				danar_jugador(1)
			end

			return
		end

		local dist=jug.x-b.x

		if dist<0 then
			dist=-dist
		end

		if dist>18 and b.carga_cd<=0 then
			b.carga_t=16
			b.carga_dir=b.mira
			return
		end

		if dist<=15 and b.aura_cd<=0 then
			b.aura_t=12
			b.aura_cd=28
			return
		end

		if dist<=15 and b.aura_cd>0 then
			b.x-=1.4*b.mira

			if b.carga_cd<=10 then
				b.carga_t=10
				b.carga_dir=b.mira
			end
		else
			local v=b.vel

			if dist<80 then
				v=b.vel_cerca
			end

			b.x+=v*b.mira
		end

		if b.x<=b.x_min then
			b.x=b.x_min
			b.dir=1
		end

		if b.x>=b.x_max then
			b.x=b.x_max
			b.dir=-1
		end
	end

	b.drw=function()
		local flip=false

		if b.mira==-1 then
			flip=true
		end

		if not b.muerto and b.invul_t>0 and b.invul_t%6<3 then
			return
		end

		if b.estado=="normal" then
			spr(128,b.x,b.y,2,1,flip,false)

			if b.anim_t<16 then
				spr(144,b.x,b.y+8,2,1,flip,false)
			else
				spr(176,b.x,b.y+8,2,1,flip,false)
			end

		elseif b.estado=="pre_transformando" then
			spr(162,b.x,b.y,2,1,flip,false)
			spr(178,b.x,b.y+8,2,1,flip,false)

		elseif b.estado=="transformando" then
			spr(165,b.x,b.y,2,1,flip,false)
			spr(181,b.x,b.y+8,2,1,flip,false)

		else
			if b.anim_t<16 then
				spr(131,b.x,b.y,3,2,flip,false)
			else
				spr(168,b.x,b.y,3,2,flip,false)
			end

			if not b.muerto and b.carga_t>0 then
				if b.carga_t%8<4 then
					spr(133,b.x+8,b.y,2,2,flip,false)
				else
					spr(135,b.x+8,b.y,2,2,flip,false)
				end

				print("!",b.x-cam_x+11,b.y-cam_y-8,8)
			end

			if not b.muerto and (b.aura_t>0 or b.invul_t>0) then
				if b.anim_t%8<4 then
					spr(133,b.x+8,b.y,2,2,flip,false)
				else
					spr(135,b.x+8,b.y,2,2,flip,false)
				end
			end
		end
	end

	return b
end


function hit_jefe_gym(b)
	if jug.z>5 then
		return false
	end

	return chocan(
		b.x+5,b.y+4,14,10,
		jug.x+4,jug.y-jug.z+4,8,9
	)
end


function jefe_intenta_cubrirse()
	if jefe==nil or jefe.muerto then
		return
	end

	if jefe.tipo=="gym" then
		return
	end

	if jefe.def_cd>0 or jefe.defendiendo then
		return
	end

	if rnd(1)<0.7 then
		jefe.defendiendo=true
		jefe.def_t=24
		jefe.def_cd=50
	end
end


function disparar_jefe(b)
	local p={}

	p.tipo="escoba"
	p.x=b.x
	p.y=b.y+8
	p.vel=1.6*b.mira
	p.ancho=8
	p.alto=8

	if b.mira==-1 then
		p.x=b.x-6
	else
		p.x=b.x+16
	end

	sfx(4,1)

	p.upd=function()
		p.x+=p.vel

		if p.x<0 or p.x>230 then
			del(proyectiles_jefe,p)
			return
		end

		if chocan(p.x,p.y,8,8,jug.x+4,jug.y-jug.z+4,8,10) then
			del(proyectiles_jefe,p)
			danar_jugador(1)
			return
		end
	end

	p.drw=function()
		spr(123,p.x,p.y)
	end

	add(proyectiles_jefe,p)
end
-->8
-- proyectil jugador

function disparar_jugador(j)
	local p={}

	p.x=j.x+16
	p.y=j.y-j.z+7

	p.vel=2*j.mira
	p.ancho=8
	p.alto=8

	if j.mira==-1 then
		p.x=j.x-8
	end

	p.upd=function()
		p.x+=p.vel

		if p.x<cam_x-8 or p.x>cam_x+136 then
			del(proyectiles_jugador,p)
			return
		end

		if jefe!=nil and not jefe.muerto then
			local jw=jefe.ancho or 16
			local jh=jefe.alto or 16

			if jefe.tipo=="gym" then
				if jefe.estado!="transformado" then
					if chocan(p.x,p.y,8,8,jefe.x,jefe.y,jw,jh) then
						sfx(5,2)
						del(proyectiles_jugador,p)
					end

					return
				end

				if jefe.invul_t>0 then
					if chocan(p.x,p.y,8,8,jefe.x,jefe.y,jw,jh) then
						sfx(5,2)
						del(proyectiles_jugador,p)
					end

					return
				end
			end

			if jefe.defendiendo and jefe.tipo!="gym" then
				local mx=jefe.x-14

				if jefe.mira==1 then
					mx=jefe.x+18
				end

				if chocan(p.x,p.y,8,8,mx,jefe.y,16,16) then
					sfx(5,2)
					del(proyectiles_jugador,p)
					return
				end
			end

			if chocan(p.x,p.y,8,8,jefe.x,jefe.y,jw,jh) then
				jefe.vida-=1
				jefe.golpeado=true
				jefe.golpe_t=12

				sfx(11,2)

				if jefe.tipo=="gym" then
					jefe.invul_t=45
				end

				del(proyectiles_jugador,p)

				if jefe.vida<=0 then
					jefe.muerto=true
				end

				return
			end
		end
	end

	p.drw=function()
		spr(124,p.x,p.y)
	end

	sfx(4,1)
	add(proyectiles_jugador,p)
	jefe_intenta_cubrirse()
end
-->8
-- hud

function draw_jugando()
	camera()

	dibujar_vidas()

	local t=tiempo_restante_texto()
	local tx=50-(#t*2)

	print(t,tx,2,7)

	if mundo_actual==1 and esta_en_puerta(jug) then
		print("presiona z",70,118,7)
		print("z",jug.x-cam_x+6,jug.y-cam_y-10,7)

	elseif mundo_actual==2 then
		if not calle_dialogo_hecho then
			print("habla con el estudiante",2,118,6)
		else
			print("x golpe / x+abajo defensa",2,118,6)
		end

	elseif mundo_actual==3 then
		print("x dispara / x+abajo defensa",2,118,6)

	elseif mundo_actual==4 then
		print("arriba salta / x dispara",2,112,6)
		print("x+abajo defensa",2,120,6)
	end
end


function dibujar_vidas()
	dibujar_vida_jugador()
	dibujar_vida_enemigo()
end


function dibujar_vida_jugador()
	for i=1,jug.vida_max do
		local x=2+(i-1)*7

		if i<=jug.vida then
			rectfill(x,2,x+4,6,8)
		else
			rect(x,2,x+4,6,5)
		end
	end
end


function dibujar_vida_enemigo()
	local ene=enemigo_actual()

	if ene==nil then
		return
	end

	for i=1,ene.vida_max do
		local x=126-(i*7)

		if i<=ene.vida then
			rectfill(x,2,x+4,6,8)
		else
			rect(x,2,x+4,6,5)
		end
	end
end


function enemigo_actual()
	if jefe!=nil and not jefe.muerto then
		return jefe
	end

	for e in all(enemigos) do
		if not e.muerto then
			return e
		end
	end

	return nil
end
__gfx__
00000000000dddddd0000000000dddddd000000000000000000ddddddd000000000000099999900000000009999990007700099999907700000dddddd0000000
0000000000dddd555000000000dddd55500000000000000000dddd55550000000000000fff9999000000000fff99990007000ffff999000000dddd5550000700
0070070000ddd555a000000000ddd555a00000000000000000ddd5555a00000000000008fff9990000000008fff9990070000ff8ff99070000ddd555a0000000
0007700000ddff555ff0000000ddff555ff000000000009000dddf5555ff0000000000ffffff9900000000ffffff99007700ffffff99000000ddff555ff00000
0007700000dddffff000000000dddffff0000000000000900ddddfffff0000000000000ffff799000000000ffff799000000008ff799700000dddffff0000770
0070070000dddfffe000000000dddfffe0000000000009000ddddffffe0000000000000efff999000000000efff9990000000efff999000000dddfffe0077700
00000000000000ff00000000000000ff00000000000009900000000ff000000000000000ff00000000000000ff0000000ffff57555ff0700000000ff00000770
00000000099a999cc0000000099a999cc000000000009900999a999cc0000000000000055755000000000005575500000ffff57577fff000099a999ccffff000
000000000999cccffc0000000999cccffc00000000000000999ccccfff4000000000000ff57700000000000ff577000000005577750fff000999cccffffff007
0000000009a9cccffc00000009a9cccffc0000000009099999accccfff4000000000000ff57500000000000ff5750000700057575000ff0009a9cccffffff077
0000000009999c9ccc00000009999c9ccc0000000090900099cccc9ccc90000000000005577500000000000557750000000555750070000009999c9ccc000000
0000000009a999cccc00000009a999cccc0000000000999099cc99cccc9000000000000555570000000000055557000000aaaaaa7077070009a999cccc070700
00000000009991111000000000999111100000000000099099999111100000000000000aaaaa00000000000aaaaa00000aaa00aa000700000099911110077770
00000000000001110000000000011001100000000000090000011001110000000000000aa00aa0000000067aa0aa00000aa00aa0070070000001100111007077
000000000000077500000000000770077000000000000000002770007700000000000007700770000000006700a7600007700770070000000027700077000000
00000000000002225000000000022202220000000000000000222000222000000000006660666000000000060066000066606660077000000002220022200000
00000000000dddddd0000000000dddddd0000000000dddddd0000000000000000000000999999000000000099999900000000000077011155510000000000000
0000000000dddd555000000000dddd555000000000dddd5550000000000000000000000fff9999000000000fff99990000000000000666d15551100000000000
0000000000ddd555a000000000ddd555a000000000ddd555a00000000000000000000008fff9990000000008fff9990000000000706ffffd1555510000000000
0000000000ddff555ff0000000ddff555ff0000000ddff555ff0000a00000000000000ffffff9900000000ffffff99000000000007ffffffd155551000000000
0000000000dddffff000000000dddffff000000000dddffff00009000a0000000000000ffff799000000000ffff799000000000077f80f80fd15510000000000
0000000000dddfffe000000000dddfffe000000000dddfffe00990a0000000000000000efff9990007a7000efff999000000000007f80f80f677600000000000
00000000000000ff00000000000000ff00000000000000ff000999990009000000000000ff00000000777000ff00000700000000067ffffff677700000000000
00000000099a999cc0000000099a999cc000000000000cccc0999999990000000000000557550000a07077055755ff700000000006f55efff515100000000000
000000000999cccffc0000000999cccffc0000000000cccffff99a99900a00000000000ff5770000070a0ffff577ff0700000000006fffff5155100000000000
0000000009a9cccffc00000009a9cccffc0000000000cccfff0f99999a0000000000000ff5750000a0770ffff57500700000000000066d551555100000000000
0000000009999c9ccc00000009999c9ccc0000000000ccccccff99a9909000000000000557750000707070055775000000000000005511115555510000000000
0000000009a999cccc00000009a999cccc00000000000ccccc999999900000000000000555570000070770055557000000000000055155555551551000000000
00000000009991111000000000999111100000000000011110009999000a00000000000a5aaa0000000a000aaaaa00000000000005514a944445551000000000
000000000001100117200000000110011100000000011001172009a9909000000000000a5aaa00000000000aa00aa00000000000015555555555110000000000
00000000002770007220000000277000770000000022700072209990000000000000000dda770000000000077007700000000000000111111111000000000000
000000000002200022000000000222002220000000022000220090a000000000000000dd66660000000000666066600000000000000066200662000000000000
077011155510000077701115551007770005555550000000000555555000000000000000000000000000000000a33a3a33a00000000000044400000000000000
000666d155511000000666d155511007005555fff0000000005555fff000000000000000000000000000000000a33a3a30000000000300444403000000000000
706ffffd15555100006ffffd1555510000555fff3000000000555fff3000000000000000000000000000000000a33ff570000000000000454403000000000000
07ffffffd155551006ffffffd155551000555fffff00000000555fffff00000000000000000000000000000000555fffff000000000000455400300000000000
77f80f80fd15510077f80f80fd15510000555ffff000000000555ffff000000000000000000000000000000000555ffff0000000000000445400000000000000
07f80f80f677600007f80f80f677607000555fffe000000000555fffe000000000000000000000000000000000555fffe0000000003300444403000000000000
067ffffff677700006fffff8f6777077000000ff00000000000000ff00000000000000000000000000000000000000ff00000000000000444400030000000000
06f55efff515100006fffefff5151000000077787444000000007778744000000000000000000000000000000000333330000000000000444400030000000000
006fffff51551000706fff8f5855107707707ff87444f00000007ff8744f00000000000000003ff3300000000000affaaff00000000000445400030000000000
00066d551555100000066d551555800707007ff87444f00000007ff8744f0000000000000000affa4440000000003ff334400000000000445400000000000000
0055111155555100005511115855510070007ff774440000000077777440000000000000000033333040000000003fffff440000003000445403003000000000
0551555555515510055155555558577070007777700000000000777770000000000000000000aaaaa04400040000aaaaa0044047000004444400000000000000
05511111155555100551115155555570000066666000000000006665600000000000000000006665600444470000666660004447000004544400000000000000
01551111555511000155111155551100000666066000000000006665600000000000000000006665600004770006660660000477000445544000000000000000
0061111111110000006111111111707000077007700000000000776dd0000000000000000000776dd00047700007700770000470044444440030330000000000
00662000662000000066200066207700000666066600000000006666dd0000000000000000006666dd0000000006660666000470444444003000000000000000
00000000077011155510000000000000000555555000000000055555500000000000000000000000000000000000000000000000000000000000000000000000
00000000000666d15551100000000000005555fff0000000005555fff00000000a00000000000000000000000000000000000000000000000000000000000000
00000000706ffffd155551000000000000555fff3000770000555fff300000000a0a000000000000000000000000000000000000000000000000000000000000
0000000007ffffffd15555100000000000555fffff07000000555fffff0000777700a00000000000000000000000000000000000000000000000000000000000
0000000077f80f80fd1551000000000000555ffff000000700555ffff00007700077700000000000000000000000000000000000000000000000000000000000
0000000007f80f80f67760000000000000555fffe000077700555fffe00000550770000000000000000000000000000000000000000000000000000000000000
00a00000067ffffff677700000000000000000ff00000000000000ff000000000000a00000000000000000000000000000000000000000000000000000000000
a00a000006f55efff51510000000000000007778704444000000777874444444a077770000000000000000000000000000000000000000000000000000000000
aaa0ff55555fffff515510000000000000707ff87ff7770000007ff87f4444440770000000003ff33ff000aa0a44400007700000000000000000000000000000
000aaf5555566d55155510000000000007007ffffff4440000007ffffff44444000770007770affaa440aaa00000000000009976000000000000000000000000
00aa000055551111555551000000000070707ffffff7770000007ffffff44444a077000000703fffff44000044a4440007000000000000000000000000000000
aa00ff5555515555555155100000000070707777774444000000777777444444077000000000aaaaa0044047000000000003337c000000000000000000000000
0aa0ff5555555555555555100000000007006666600007700000666660007777700000000770666660a0444794000a4400000000000000000000000000000000
0aa0a0000155555555551100000000000006660660007700000666566000000700a70000000666066aa004770094400007770000000000000000000000000000
a00aa000000111111111000000000000000770077000700000077007700000000a00700077777007707a047094000000000eeee7500000000000000000000000
00000000000066200662000000000000000666066607000000066606660000000000000000766606660004700094400007700000000000000000000000000000
000555555000000000007770007077aa000000000008800000000000000a88888880000077000007000007070000000000000000000000000000000000000000
005555fff000000000777007777007888000000000008aaaaa8888000000aaa88888880001110111111000000000000000000000000000000000000000000000
00555fff30000000000077700000000888000000000000aa8aa08880000000aaa88a888001110111111011100000000000000000000000000000000000000000
00555fffff000000770000700555555088a000000070000888aaa8080000000888888a8a01110111111001000000000000000000000000000000000000000000
00555ffff000000007700000055555550880000000770000088888080007700008aa888a01110001100001000000000000000000000000000000000000000000
00555fffe000000070770055555888850a80000000077000000088a000007777000aa88800100071100011100000000000000000000000000000000000000000
000000ff077700007700005558888885008000000000000077000aa80770000770000aaa70107001100000000000000000000000000000000000000000000000
0000555557770000070005555888e835008000000000000000000a880077770077000a8877107701107111100000000000000000000000000000000000000000
00005fffff7f00000770558555500800088000000000000777000a880700000000700a8807100701107011000000000000000000000000000000000000000000
00005fffff7f0000000055888850000088a000000000770000000088077700000000008807100701107011000000000000000000000000000000000000000000
00005555577700000770555588880000aa000000007770000000008a0007777777000a8800100771107111100000000000000000000000000000000000000000
00005555577700000000555555888000aa800000007000007700a88a000000000000aa8a01110071107000000000000000000000000000000000000000000000
00006666600000000000666660088aa80a8000000000000070008888000777777000a8aa01110001107000000000000000000000000000000000000000000000
0000fffdf00000000770888088000aa8a080000000007700000a8aa800007700000a8aa801110111111070070000000000000000000000000000000000000000
0000fffdf00000000700888008800a8a800000000007700000888a080077770000888a8a71110111111070700000000000000000000000000000000000000000
00006666dd600000000066660666088880000000000000000aaa0a88077000000aaaaaaa70000111111070770000000000000000000000000000000000000000
00000000000000000a05555550070000000000000a055555500700000000000000007770007077aa000000000000000000000000000000000000000000000000
00000000000000000755558880077700000000000c555588800c7700000000000077700777700788800000000000000000000000000000000000000000000000
0000000000000000aa5558883007a70000000000ac555888300ca700000000000000777000000008880000000000000000000000000000000000000000000000
0000000000000000775558888800a7a000000000cc555888880cc7a000000000770000700555555088a000000000000000000000000000000000000000000000
0000000000000000a7555888800007a000000000cc5558888000ccc0000000000770000005555555088000000000000000000000000000000000000000000000
000000000000000077555888e00007a0000000007c555888e00007c00000000070770055555888850a8000000000000000000000000000000000000000000000
0000000000777000a7770088077700aa00000000ac77008807770cca000000007700005558888885008000000000000000000000000000000000000000000000
000055555fff0000077055555777000000000000cc70555557770c0000000000070005555888e835008000000000000000000000000000000000000000000000
00005fffffff0000a77058888870a07000000000c7a058888870a0c0000000000770558555500800088000000000000000000000000000000000000000000000
00005fffffff0000aa705888887000aa00000000cc705888887000ca00000000000055888850000088a000000000000000000000000000000000000000000000
0000555550070000a70055555777070000000000ac705555577707c0000000000770555588880000aa0000000000000000000000000000000000000000000000
00005555507770007700555550aa077700000000aca0555550aa0cc7000000000000555555888000aa8000000000000000000000000000000000000000000000
00006666600000007a0066666077700000000000cca0666660777c00000000000008866660088aa80a8000000000000000000000000000000000000000000000
000fff0ff0000000070888088000707000000000a770880088007c70000000000888800880000aa8a08000000000000000000000000000000000000000000000
000ff00ff000000007a880088000a07700000000a77088000880cc77000000000880000880000a8a800000000000000000000000000000000000000000000000
0006660666000000a0a666066600a00000000000a0a066600666a000000000000666600666600888800000000000000000000000000000000000000000000000
000000770600000000777700000000004444444488888888bbbbbbbb111111114444444488444488bb4444bb1144441107000000700000000033330003333b00
000000776660600007676770000000604770000488888888bbbbbbbb111111114aa55aa488444488bb4444bb1144441100070700700070000333b330333333b0
777777770600000077777776000600004770000488888888bbbbbbbb111111114aa55aa488444488bb4444bb11444411000000000000000033b333333bb33330
777777770000000066767677000000004000080488888888bbbbbbbb111111114555555488444488bb4444bb1144441155555550660070073333333bb33b3330
007000770000000077777767000000004008088488888888bbbbbbbb111111114555555488445488bb4454bb114454115555555666600000b333b33333333300
777777770000006077667767000000004088888488888888bbbbbbbb111111114aa55aa488444488bb4444bb11444411aa55aa560060000033b3333304044000
777777770000066607767770060000604888888488888888bbbbbbbb111111114aa55aa488444488bb4444bb11444411aa55aa56066600000333333000444000
777777770000006000777700000000004444444488888888bbbbbbbb111111114444444488444488bb4444bb114444115555555600a000000044450000044000
444444444444444455555555999999999999999999444499999999999977779966666666555555555555555566666666aa55aa56000000000003000000000000
400000044000076454444444922225999999999999444499999999997773577767777776555555555555555557575757aa55aa5600000000003bb00000000000
407000044070076454444444444444444444444499444499999999997b7777576777777655555555555555556767676777777776777777770033300000000000
400007044000077454444444444444444444444499444499999999997b73377767777776555555555555555567676767777777767777777703bbbb0000000000
400000044070000454444444444499999999444499445499999999997b7775576777777655555555555555556666666655575576700070000333330000000000
40000004400000045444444449944444444449949944449999999999777777776777777655555555555555555757575777777776777777773bbbbbb000000000
400700044000000454444444499499999999499499444499999999997bb7b7776777777655555555aaaaaaaa6767676777777776777777770333330000000000
40000004400007045444444449949999999949949944449999999999777777776666666655555555aaaaaaaa6767676755555666665555550004000000000000
4000000440000004544444459999999999999999444111114444444477777777333333330000000000000000000000000766d070000000000000000000000000
40000704400700045444444559599999999999994441115546cc444477777777333333330000000000000003000000000666d070000000000000000000000000
40000004400000045444554555599999999999994447777746c64444777777771133133300000000000000333000000005161070000000005555555555555555
40700004400000045444554557777777777777554444444446cc4444777777772211213100000000000000b3b000000005555444000000005444444444444445
40000704400000045444444555777777777777554467744446cc4444777777772422221200000000000000b3330000005d65d540000000005442244244424445
4000000440070704544444455599999999999955446764444488888477777777424242220000000000000b33b330000006dd5000000000005422222222222245
4000000440000004544444455591919999999955446774444488855477777777242424240000000000000b33333000000d65d000000000005442422224242245
444444444444444455555555559797999999995544677444447777747777777742424242000000000000b3b33333000005005000000000005422222242242225
44444444544444440000000055555555444444443333cccc3333cccc77cccccc3333cc77000b30000000b333b333000000000000007777005422424222442245
444444445444444400000000544444453333cccc3333cccc3333cccc77cccccc3333cc7700bbb300000b3bb33333300000000000007777005424422242224245
444444445444444400000000544444453333cccc3333cccc7733cc7777cccccc3333cc7700b33300000b33333b31300000000000007777005424444422244245
444444445444444400000000544444453333cccc3333cccc7777777777777777777777770033330000b3b3b33333330000000000007777005444444444444445
44444444544444440000000054444445cccc3333cccc333377cc337777cccccccccc33770bbbbb3000b333b133b3130000000000007777005444444444444445
44444444544444440000000054444445cccc3333cccc333377cc337777cccccccccc3377033333300b3b3b333133333000000000007777000000005550000000
44444444544444440000000054444445cccc3333cccc3333cccc333377cccccccccc3377033343300b33b313b331111000000000007777000000004440000000
44444444555555550000000054444445cccc3333cccc3333cccc333377cccccccccc337700044000000000044000000000000000007777000000004440000000
__map__
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c700c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c70000c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c700c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c70000000000000000000000000000000000000000
c7d6d6d6d6d6d6d6d6d6d6d6d6d6d6c700c7c3c3c3c1c3c3c1c3c3c1c3c1c3c1c3c3c3c3c3c1c3c3c1c3c3c1c3c1c70000c7c1c3c3c1c3c3c1c3c3c3c1c1c3c3c1c3c3c3c3c3c1c3c3c3c1c3c3c700c7c7c5d9d9d9d9d9c5c5c5c5c5c5c6c6c6c6c6c6c6c6c6c6c6c6c6c6c70000000000000000000000000000000000000000
c7d6c2d6d6d6c4d6d6d0d1d6d6d6d6c700c7c3c3c1c3c1c3c3c3c3c3c3c2c3c8c7c8c3c3c1c3c1c3c8d6d6c8c3c1c70000c7c3c3c3c3c3c3c3c3c3c1c3c3c3c1c3c3c3c3c1c3c2c1c3c1c3c3c1c700c7c7c5d9c5c5c5c5c5c5d9d9d9c5c5c6d9d9d9c6c6d9d9c6c6d9d9c6c70000000000000000000000000000000000000000
c7d6d6d6d6d6d6d6d6e0e1d6d2f3d6c700c7c5c5c5c3c3c3c7c7c6c6c3c1c3c7c7c7c5c5c5c3c3c3c8d6d6c8c1c1c70000c7c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c1c1c3c3c1c3c3c1c700c7c7c5d9c5d9d9d9c5c5c5c5d9d9d9d9d9c6c6c6c6d9c6d9d9c6d9c6c70000000000000000000000000000000000000000
c7e3e4d6d6d6d3d4d6d6d6d6f1e2d7c700c7c8c5c8cccdc3c8c7c6c8cccdc3c8c7c8c8c5c8c3c3c3c8d6d6c8c3c3c70000c7c3c3c3c3c3c1c3c3ecc1c3c3c3c3c1c3c3c1c3c3c3c3c3c3c3c1c3c700c7c7c5d9c5c5d9d9c5c5c5c5c5d9d9d9c6c6c6c6c6d9c6c6c6c6d9c6c70000000000000000000000000000000000000000
c7f0f0f0f0f0e5f0e6f0f0f0f0f0f0c700c7c5c9c5dcddc0c7cbcac6dcddddc7cbc7c5c9c5c0c0c0d6d5d5d6c0c0c70000c7c1c3c1c3c3c3c3c1d9c3c3c3c1c1c3c3c1c3c3c3c3c3c1c1c3c3c3c700c7c7c5d9d9d9d9d9c5c5c5c5c5c5d9c6c6c6c6c6c6d9c6c6c6c6d9c6c70000000000000000000000000000000000000000
c7f0f0f0f0f0f0f0f0f0f0f0f0f0f0c700c7d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c70000c7eeefeaebc3c3c1d9d9d9c3c3c3c3eaebc1c1c1c3c3c3eaebc3c3c1c700c7c7f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4c70000000000000000000000000000000000000000
c7f0f0f0f0f0f0f0f0f0f0f0f0f0f0c700c7d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8c70000c7fefffafbcec3dbdbdbdbdbc3cec3fafbdec1cec1cfc3fafbc3c3c1c700c7cbf5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c70000000000000000000000000000000000000000
c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c700c7dadad9dadad9dadad9dadad9dadad9dadadad9dadad9dadad9dadad9c70000c7e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8c700c7c7f5f7f8f5f5f5f5f5f5f5f6f5f7f8f5f5f5f5f5f5f6f5f5f5f5f5c70000000000000000000000000000000000000000
0000000000000000000000000000000000c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c70000c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c700c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c70000000000000000000000000000000000000000
__sfx__
0001000030620316203262033620346263562735627356273662036620366243662403624366240362413724167241a7241d724356243462408624336253362523626326263162631620306202f6202f6202d620
0019022012250102501f2501a2501c2501a2501c2501d2501d2501d2501d25018010180101a0101c0101a010180101c0101a010180101c0101a0001a0001a0001c0001a000180001c0001a00018000200001f000
0010001b2b3502b3502b3502a3502a3502935022350243502735028350293502a3502b3502b3502c3502c3502b3502a3502a35029350283502835027350263502435022350203500435003350000000000000000
001000000001024450234502345023450224502245022450214502145020450204501f4501f4501f4501d4501b4501a4501945017450164501445012450104500e4500b450094500745005450034500145000450
00010000194502955027550255502455023550225503155021550205501f5501f5501d5501d5502f5501c5501b5501a55019550185502e55017550165502e55015550145501355013550125501c0501155010550
000600000a7500375027700267002670026700257002570024700247002570025700132000f2002320023200232002220021200202001e2001d20018200262002d20029200080000800009000090000800005000
000600000041000410014100141002410024100341003410044100441004420054500545006450064500745007450096500d65000000000000000000000000000000000000000000000000000000000000000000
001000002a25028250272502525023250212501f2501c2501925015250122500f2500d2500a2500925007250052500325004250002500025000000000002b2500000000000000000000007250000000000000000
000900002b35024350203501e3501b350183501635013350103500e3500c3500b3500935007350063500535004350043500435004350053500635007350093500b3500d350103501535008350093500b3503b350
000700001f1501f1501f1502015020150201502215022150221502215021150221502215022150221502215022150221502215022150221502315024150251502615026150261502615027150271502815029150
01080000183501a3501c3501d35000000000001c3501d3501f3502335023350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001705013050170501105010050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000160c0200e020100200e02000000000000c0200e020100200e02000000000001502013020110201302000000000001502013020110201302000000000000000000000000000000000000000000000000000
010500000e05010050110500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002505024050230502305022050220502205021050210502105021050200502005020050200502705027050270502705027050280502805028050290502c05000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001d050190502955028550265502655026550265502655025550245502355022550215501f5501d5501b550195501755015550135501155011550115501255015550195503955038550385503755000000
__music__
01 0a054344
00 01424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 090a4344

