/obj/structure/boulder
	name = "boulder"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	material = /decl/material/solid/stone/sandstone
	material_alteration = MAT_FLAG_ALTERATION_COLOR | MAT_FLAG_ALTERATION_NAME
	var/excavation_level = 0
	var/datum/artifact_find/artifact_find
	var/last_act = 0

/obj/structure/boulder/Initialize(var/ml, var/_mat, var/coloration)
	. = ..()
	icon_state = "boulder[rand(1,6)]"
	if(coloration)
		color = coloration
	excavation_level = rand(5, 50)

/obj/structure/boulder/Destroy()
	QDEL_NULL(artifact_find)
	return ..()

/obj/structure/boulder/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/depth_scanner))
		var/obj/item/depth_scanner/C = I
		C.scan_atom(user, src)
		return

	if(istype(I, /obj/item/measuring_tape))
		var/obj/item/measuring_tape/P = I
		user.visible_message("<span class='notice'>\The [user] extends \the [P] towards \the [src].</span>", "<span class='notice'>You extend \the [P] towards \the [src].</span>")
		if(do_after(user, 15))
			to_chat(user, "<span class='notice'>\The [src] has been excavated to a depth of [src.excavation_level]cm.</span>")
		return

	if(istype(I, /obj/item/pickaxe))
		var/obj/item/pickaxe/P = I

		if(last_act + P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		to_chat(user, "<span class='warning'>You start [P.drill_verb] [src].</span>")

		if(!do_after(user, P.digspeed))
			return

		to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
		excavation_level += P.excavation_amount

		if(excavation_level > 200)
			//failure
			user.visible_message("<span class='warning'>\The [src] suddenly crumbles away.</span>", "<span class='warning'>\The [src] has disintegrated under your onslaught, any secrets it was holding are long gone.</span>")
			qdel(src)
			return

		if(prob(excavation_level))
			//success
			if(artifact_find)
				var/spawn_type = artifact_find.artifact_find_type
				var/obj/O = new spawn_type(get_turf(src))
				if(istype(O, /obj/structure/artifact))
					var/obj/structure/artifact/X = O
					if(X.my_effect)
						X.my_effect.artifact_id = artifact_find.artifact_id
				src.visible_message("<span class='warning'>\The [src] suddenly crumbles away.</span>")
			else
				user.visible_message("<span class='warning'>\The [src] suddenly crumbles away.</span>", "<span class='notice'>\The [src] has been whittled away under your careful excavation, but there was nothing of interest inside.</span>")
			qdel(src)

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		var/obj/item/pickaxe/P = (locate() in H.get_inactive_held_items())
		if(istype(P))
			src.attackby(P, H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)
