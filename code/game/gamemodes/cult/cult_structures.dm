/obj/structure/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon = 'icons/obj/structures/pylon.dmi'
	icon_state = "pylon"
	var/isbroken = 0
	light_power = 0.5
	light_range = 13
	light_color = "#3e0000"

/obj/structure/cult/pylon/attack_hand(mob/M)
	SHOULD_CALL_PARENT(FALSE)
	attackpylon(M, 5)
	return TRUE

/obj/structure/cult/pylon/attack_generic(var/mob/user, var/damage)
	attackpylon(user, damage)

/obj/structure/cult/pylon/attackby(obj/item/W, mob/user)
	attackpylon(user, W.force)

/obj/structure/cult/pylon/proc/attackpylon(mob/user, var/damage)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(!isbroken)
		if(prob(1+ damage * 5))
			user.visible_message(
				"<span class='danger'>[user] smashed the pylon!</span>",
				"<span class='warning'>You hit the pylon, and its crystal breaks apart!</span>",
				"You hear a tinkle of crystal shards."
				)
			user.do_attack_animation(src)
			playsound(get_turf(src), 'sound/effects/Glassbr3.ogg', 75, 1)
			isbroken = 1
			set_density(0)
			icon_state = "pylon-broken"
			set_light(0)
		else
			to_chat(user, "You hit the pylon!")
			playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	else
		if(prob(damage * 2))
			to_chat(user, "You pulverize what was left of the pylon!")
			qdel(src)
		else
			to_chat(user, "You hit the pylon!")
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)


/obj/structure/cult/pylon/proc/repair(mob/user)
	if(isbroken)
		to_chat(user, "You repair the pylon.")
		isbroken = 0
		set_density(1)
		icon_state = "pylon"
		set_light(13, 0.5)

/obj/structure/cult/pylon/get_artifact_scan_data()
	return "Tribal pylon - subject resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."

/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult/pillar
	name = "Pillar"
	desc = "This should not exist."
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	unacidable = 1
	anchored = TRUE
	var/spawnable = null

/obj/effect/gateway/active
	light_range=5
	light_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat,
		/mob/living/simple_animal/hostile/creature,
		/mob/living/simple_animal/hostile/faithless
	)

/obj/effect/gateway/active/cult
	light_range=5
	light_color="#ff0000"
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult
	)

/obj/effect/gateway/active/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/create_and_delete), rand(30,60) SECONDS)


/obj/effect/gateway/active/proc/create_and_delete()
	var/t = pick(spawnable)
	new t(src.loc)
	qdel(src)

/obj/effect/gateway/active/Crossed(var/atom/A)
	if(!istype(A, /mob/living))
		return

	var/mob/living/M = A

	if(M.stat != DEAD)
		if(M.HasMovementHandler(/datum/movement_handler/mob/transformation))
			return

		M.handle_pre_transformation()

		if(iscultist(M)) return
		if(!ishuman(M) && !isrobot(M)) return

		M.AddMovementHandler(/datum/movement_handler/mob/transformation)
		M.icon = null
		M.overlays.len = 0
		M.set_invisibility(101)

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				qdel(Robot.mmi)
		else
			for(var/obj/item/W in M)
				M.drop_from_inventory(W)
				if(istype(W, /obj/item/implant))
					qdel(W)

		var/mob/living/new_mob = new /mob/living/simple_animal/corgi(A.loc)
		new_mob.a_intent = I_HURT
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		to_chat(new_mob, "<B>Your form morphs into that of a corgi.</B>")//Because we don't have cluwnes
