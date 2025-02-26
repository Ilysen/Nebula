/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = "{'materials':4,'engineering':3}"
	max_amount = 10
	amount = 10
	material = /decl/material/solid/metal/steel
	matter = list(/decl/material/solid/glass = MATTER_AMOUNT_REINFORCEMENT)

/obj/item/stack/nanopaste/attack(mob/living/M, mob/user)
	if (!istype(M) || !istype(user))
		return 0
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
			R.adjustBruteLoss(-15)
			R.adjustFireLoss(-15)
			R.updatehealth()
			use(1)
			user.visible_message("<span class='notice'>\The [user] applied some [src] on [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if (istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = GET_EXTERNAL_ORGAN(H, user.get_target_zone())

		if(!S)
			to_chat(user, "<span class='warning'>\The [M] is missing that body part.</span>")
			return

		if(BP_IS_BRITTLE(S))
			to_chat(user, "<span class='warning'>\The [M]'s [S.name] is hard and brittle - \the [src] cannot repair it.</span>")
			return

		if(S && S.is_robotic() && S.hatch_state == HATCH_OPENED)
			if(!S.get_damage())
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
			else if(can_use(1))
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				S.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				use(1)
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste on [user != M ? "[M]'s [S.name]" : "[S]"] with [src].</span>",\
				"<span class='notice'>You apply some nanite paste on [user == M ? "your" : "[M]'s"] [S.name].</span>")
