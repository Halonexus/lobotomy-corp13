/mob/living/simple_animal/hostile/training_bunny
	name = "Standard Training-Dummy Rabbit?"
	desc = "A rabbit-like training dummy. Should be completely harmless."
	icon = 'ModularTegustation/Teguicons/64x64.dmi'
	icon_state = "Bungal"
	icon_living = "Bungal"
	maxHealth = 1600
	health = 1600
	move_to_delay = 1
	damage_coeff = list(RED_DAMAGE = 0.4, WHITE_DAMAGE = 0.4, BLACK_DAMAGE = 0.4, PALE_DAMAGE = 0.4)
	attack_sound = 'sound/abnormalities/fragment/attack.ogg'
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	faction = list("hostile")
	melee_damage_lower = 30
	melee_damage_upper = 45
	ranged = TRUE
	ranged_cooldown_time = 5
	minimum_distance = 3
	see_in_dark = 7
	vision_range = 12
	aggro_vision_range = 20
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	layer = LARGE_MOB_LAYER
	a_intent = INTENT_HARM
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_HUGE
	melee_damage_type = RED_DAMAGE
	stat_attack = HARD_CRIT
	lose_patience_timeout = 0
	pixel_x = -16

	var/datum/reusable_visual_pool/RVP = null
	var/list/been_hit = list()

	var/can_act = TRUE
	var/can_special = TRUE
	var/current_move = null

	var/spear_range = 3
	var/spear_wait_time = 0
	var/spear_warning_time = 3
	var/spear_time_per_hit = 0.6
	var/spear_cooldown = 0
	var/spear_cooldown_time = 8 SECONDS
	var/spear_hits = 4

	var/split_horizontal_range = 8
	var/split_horizontal_angle = 160
	var/split_horizontal_damage = 300
	var/split_horizontal_cooldown = 0
	var/split_horizontal_cooldown_time = 20 SECONDS
	var/split_horizontal_warning_time = 5 SECONDS

	var/slash_range = 2
	var/slash_count = 5
	var/slash_direction = 1
	var/slash_wait_time = 2.5
	var/slash_warning_time = 2.5
	var/slash_time_per_hit = 1
	var/slash_cooldown = 0
	var/slash_cooldown_time = 8 SECONDS
	var/slash_angle = 45
	var/slash_hitcount = 3

	var/smash_cooldown = 0
	var/smash_cooldown_time = 8 SECONDS
	var/smash_count = 5
	var/list/smash_ranges = list(1, 3)
	var/list/smash_hit_range = list(2, 3)
	var/smash_current_range = 0
	var/smash_wait_time = 4
	var/smash_warning_time = 2
	var/smash_angle = 65

	var/list/to_hit = list()
	var/list/to_hit_telegraphs = list()
	var/need_to_move_telegraphs = FALSE
	var/need_to_hit_on_move = FALSE
	var/current_move_attack_index = 0

	var/gold_rush_charges = 8
	var/gold_rush_damage = 300
	var/gold_rush_cooldown = 0
	var/gold_rush_cooldown_time = 60 SECONDS

	var/combo_hit_count = 12
	var/combo_cooldown = 0
	var/combo_cooldown_time = 15 SECONDS

	var/current_weapon_index = 0
	var/datum/weapon_set/current_weapon_set = null
	var/list/available_weapon_sets = null

	var/warning_time_bonus = 7

/datum/weapon_set
	var/mob/living/simple_animal/hostile/training_bunny/user
	var/list/weapons
	var/iconstate_idle
	var/list/iconstates_weapon_attack
	var/list/iconstates_weapon_special
	var/static/list/damage_type_to_color = list(\
		RED_DAMAGE = "#e72323",\
		WHITE_DAMAGE = "#f0f0f0",\
		BLACK_DAMAGE = "#35265a",\
		PALE_DAMAGE = "#21dbdb"\
	)

/datum/weapon_set/New(mob/living/user, list/weapons, iconstate_idle, list/iconstates_weapon_attack = null, list/iconstates_weapon_special = null)
	src.user = user
	src.weapons = weapons
	src.iconstate_idle = iconstate_idle
	if(iconstates_weapon_attack)
		src.iconstates_weapon_attack = iconstates_weapon_attack
	else
		src.iconstates_weapon_attack = list(iconstate_idle, iconstate_idle, iconstate_idle)
	if(iconstates_weapon_special)
		src.iconstates_weapon_special = iconstates_weapon_special
	else
		src.iconstates_weapon_special = list(iconstate_idle, iconstate_idle)
	return ..()

#define HAS_ON_USE_EFFECT 1
#define HAS_ON_HIT_EFFECT (1 << 1)

/datum/weapon_set/proc/WeaponHitTurf(turf/turf_to_hit, weapon_index)
	var/list/weapons_to_use
	var/is_dual_attack_with_two_weapons = FALSE
	if(weapon_index == 0)
		if(weapons[1] == weapons[2])
			weapons_to_use = list(weapons[1])
		else
			weapons_to_use = weapons
			is_dual_attack_with_two_weapons = TRUE
	else
		weapons_to_use = list(weapons[weapon_index])
	var/list/all_dam_types = list()
	for(var/datum/equiped_weapon/EW in weapons_to_use)
		var/damage = is_dual_attack_with_two_weapons ? EW.damage / 2 : EW.damage
		for(var/dam_type in EW.damage_types)
			all_dam_types += dam_type
			var/list/new_hits = user.HurtInTurfButCooler(turf_to_hit, user.been_hit, damage, dam_type, TRUE, hurt_hidden = TRUE, hurt_objects = TRUE)
			if(EW.effect_flags & HAS_ON_HIT_EFFECT)
				EW.OnHitEffect(user, new_hits)
			user.been_hit += new_hits
	user.RVP.NewSmashEffect(turf_to_hit, 3, damage_type_to_color[pick(all_dam_types)])

/datum/weapon_set/Destroy()
	user = null
	QDEL_LIST(weapons)
	return ..()

/datum/equiped_weapon
	var/name
	var/damage
	var/list/damage_types
	var/effect_flags = 0

/datum/equiped_weapon/proc/OnUseEffect()
	return

/datum/equiped_weapon/proc/OnHitEffect(mob/living/user, list/hit_things)
	return

/datum/equiped_weapon/penitence
	name = "Penitence"
	damage = 40
	damage_types = list(WHITE_DAMAGE)

/datum/equiped_weapon/red_eyes
	name = "Red eyes"
	damage = 40
	damage_types = list(RED_DAMAGE)
	effect_flags = HAS_ON_HIT_EFFECT

/datum/equiped_weapon/hearth
	name = "Hearth"
	damage = 40
	damage_types = list(BLACK_DAMAGE)
	effect_flags = HAS_ON_USE_EFFECT

/datum/equiped_weapon/wrist
	name = "Wrist cutter"
	damage = 40
	damage_types = list(WHITE_DAMAGE)

/datum/equiped_weapon/red_sheet
	name = "Red Sheet"
	damage = 40
	damage_types = list(BLACK_DAMAGE)
	effect_flags = HAS_ON_HIT_EFFECT

/datum/equiped_weapon/wingbeat
	name = "Wingbeat"
	damage = 40
	damage_types = list(RED_DAMAGE)

/datum/equiped_weapon/daredevil
	name = "Daredevil"
	damage = 40
	damage_types = list(PALE_DAMAGE)

/datum/equiped_weapon/melty_eyeball
	name = "Melty Eyeball"
	damage = 40
	damage_types = list(BLACK_DAMAGE)

/datum/equiped_weapon/mimicry
	name = "Mimicry"
	damage = 70
	damage_types = list(RED_DAMAGE)
	effect_flags = HAS_ON_HIT_EFFECT

/datum/equiped_weapon/da_capo
	name = "Da Capo"
	damage = 70
	damage_types = list(WHITE_DAMAGE)

#define NO_RED_SETS RED_DAMAGE
#define NO_WHITE_SETS WHITE_DAMAGE
#define NO_BLACK_SETS BLACK_DAMAGE
#define NO_PALE_SETS PALE_DAMAGE
#define ALL_SETS "all"

/mob/living/simple_animal/hostile/training_bunny/Initialize()
	. = ..()
	RVP = new /datum/reusable_visual_pool(450)
	var/datum/weapon_set/set1 = new(src, list(new /datum/equiped_weapon/penitence, new /datum/equiped_weapon/red_eyes), "Bungal")
	var/datum/weapon_set/set2 = new(src, list(new /datum/equiped_weapon/hearth, new /datum/equiped_weapon/wrist), "Bungal")
	var/datum/weapon_set/set3 = new(src, list(new /datum/equiped_weapon/red_sheet, new /datum/equiped_weapon/wingbeat), "Bungal")
	var/datum/weapon_set/set4 = new(src, list(new /datum/equiped_weapon/daredevil, new /datum/equiped_weapon/melty_eyeball), "Bungal")
	available_weapon_sets = list(\
		NO_RED_SETS = list(set2, set4),\
		NO_WHITE_SETS = list(set3, set4),\
		NO_BLACK_SETS = list(set1),\
		NO_PALE_SETS = list(set1, set2, set3),\
		ALL_SETS = list(set1, set2, set3, set4)\
	)

/mob/living/simple_animal/hostile/training_bunny/Destroy()
	QDEL_NULL(RVP)
	return ..()

/mob/living/simple_animal/hostile/training_bunny/AttackingTarget()
	if(!can_act)
		return
		//..()
	OpenFire()
	return

/proc/ArmorTypeValuePairComparator(list/a, list/b)
	return a[2] - b[2]

/mob/living/simple_animal/hostile/training_bunny/OpenFire()
	if(!can_act || !can_special)
		return

	if(combo_cooldown < world.time)
		combo_cooldown = world.time + combo_cooldown_time
		//check enemy armor
		var/list/target_armor[4]
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			target_armor[1] = list(RED_DAMAGE, H.physiology.red_mod)
			target_armor[2] = list(WHITE_DAMAGE, H.physiology.white_mod)
			target_armor[3] = list(BLACK_DAMAGE, H.physiology.black_mod)
			target_armor[4] = list(PALE_DAMAGE, H.physiology.pale_mod)
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing))
				var/obj/item/clothing/C = H.wear_suit
				target_armor[1][2] *= (1 - C.armor.getRating(RED_DAMAGE) / 100)
				target_armor[2][2] *= (1 - C.armor.getRating(WHITE_DAMAGE) / 100)
				target_armor[3][2] *= (1 - C.armor.getRating(BLACK_DAMAGE) / 100)
				target_armor[4][2] *= (1 - C.armor.getRating(PALE_DAMAGE) / 100)
		else if(ishostile(target))
			var/mob/living/simple_animal/hostile/H = target
			target_armor[1] = list(RED_DAMAGE, H.damage_coeff.red)
			target_armor[2] = list(WHITE_DAMAGE, H.damage_coeff.white)
			target_armor[3] = list(BLACK_DAMAGE, H.damage_coeff.black)
			target_armor[4] = list(PALE_DAMAGE, H.damage_coeff.pale)
		target_armor = sortList(target_armor, GLOBAL_PROC_REF(ArmorTypeValuePairComparator))
		//switch weapons according to target armor
		var/no_armor_differences = TRUE
		if(target_armor.len > 3)
			var/i = target_armor[1][2]
			for(var/j in 2 to 4)
				if(abs(target_armor[j][2] - i) > 0.0001)
					no_armor_differences = FALSE
					break
		if(target_armor.len < 4 || no_armor_differences)
			current_weapon_set = pick(available_weapon_sets[ALL_SETS])
		else
			var/list/first_set = available_weapon_sets[target_armor[1][1]]
			var/list/second_set = available_weapon_sets[target_armor[2][1]]
			var/list/combined_set =  first_set & second_set
			if(combined_set.len > 0)
				current_weapon_set = pick(combined_set)
			else if(first_set.len > 0)
				current_weapon_set = pick(first_set)
			else
				current_weapon_set = pick(available_weapon_sets[ALL_SETS])

		var/datum/equiped_weapon/w1 = current_weapon_set.weapons[1]
		var/datum/equiped_weapon/w2 = current_weapon_set.weapons[2]
		emote("me", 1, "equips [w1.name] and [w2.name]", TRUE)
		//attack
		ComboAttack(target, combo_hit_count, list(PROC_REF(Slash), PROC_REF(Smash), PROC_REF(SpearStab)))
		return
	/*if(gold_rush_cooldown < world.time)
		GoldRushPrepare()
		return*/
	/*if(split_horizontal_cooldown < world.time)
		GreaterSplitHorizontal(target)
		return*/
	/*if(slash_cooldown < world.time)
		Slash(target, slash_count)
		return*/
	/*if(spear_cooldown < world.time)
		SpearStab(target, spear_hits)
		return*/
	/*if(smash_cooldown < world.time)
		Smash(target, smash_count)
		return*/
	return

/mob/living/simple_animal/hostile/training_bunny/Move()
	if(!can_act)
		return
	return ..()

/mob/living/simple_animal/hostile/training_bunny/Moved(atom/OldLoc, Dir)
	. = ..()
	if(need_to_move_telegraphs)
		var/dx = src.x - OldLoc.x
		var/dy = src.y - OldLoc.y
		for(var/obj/effect/reusable_visual/RV in to_hit_telegraphs)
			RV.loc = locate(RV.x + dx, RV.y + dy, RV.z)
	if(need_to_hit_on_move)
		var/turf/T = GetRelativeCoordinateTurf(to_hit[current_move_attack_index])
		if(!T)
			return
		switch(current_move)
			if("slash")
				SlashMoveHit(T)
			if("spear")
				SpearMoveHit(T)

/mob/living/simple_animal/hostile/training_bunny/proc/SlashMoveHit(turf/turf_to_hit)
	if(turf_to_hit.density)
		return
	current_weapon_set.WeaponHitTurf(turf_to_hit, current_weapon_index + 1)
	for(var/turf/TT in get_adjacent_open_turfs(turf_to_hit))
		current_weapon_set.WeaponHitTurf(TT, current_weapon_index + 1)
	playsound(src, 'sound/weapons/fixer/generic/sword2.ogg', 75, TRUE, 5)

/mob/living/simple_animal/hostile/training_bunny/proc/SpearMoveHit(turf/turf_to_hit)
	if(turf_to_hit.density)
		return
	current_weapon_set.WeaponHitTurf(turf_to_hit, current_weapon_index + 1)
	for(var/turf/TT in get_adjacent_open_turfs(turf_to_hit))
		current_weapon_set.WeaponHitTurf(TT, current_weapon_index + 1)

/mob/living/simple_animal/hostile/training_bunny/proc/ComboAttack(atom/attack_target, total_hits, list/possible_attacks)
	var/current_attack_hits = rand(3, 5)
	var/attack = pick(possible_attacks)
	call(src, attack)(attack_target, current_attack_hits, TRUE, total_hits - current_attack_hits)

/mob/living/simple_animal/hostile/training_bunny/proc/KillMovingEffects()
	need_to_move_telegraphs = FALSE
	for(var/obj/effect/reusable_visual/RV in to_hit_telegraphs)
		RVP.ReturnToPool(RV)
	to_hit_telegraphs.Cut()

/mob/living/simple_animal/hostile/training_bunny/proc/Slash(slash_target, slashes_remaining, is_first_slash = TRUE, combo_hits_remaining = 0)
	if(is_first_slash)
		can_special = FALSE
		current_move = "slash"
		slash_cooldown = world.time + slash_cooldown_time
		slash_direction = pick(1, -1)
		current_weapon_index = pick(0, 1)
	if(!slash_target)
		slash_target = target
	var/turf/slash_end_turf = GetRangedTargetTurfMaxMetric(src, slash_target, slash_range, 0)
	var/turf/slash_start_turf = GetRangedTargetTurfMaxMetric(slash_end_turf, src, slash_hitcount - 1, slash_angle * slash_direction)
	slash_direction *= -1
	var/list/turfs_to_hit = getline(slash_start_turf, slash_end_turf)
	for(var/turf/T in turfs_to_hit)
		to_hit += new /datum/relative_coordinates(T.x - src.x, T.y - src.y, src)
		var/obj/effect/reusable_visual/RV = RVP.NewCultSparks(T, 0, "#ff0a0a")
		RV.animate_movement = SLIDE_STEPS
		to_hit_telegraphs += RV
	need_to_move_telegraphs = TRUE

	if(is_first_slash)
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), slash_warning_time + warning_time_bonus - 1)
		SLEEP_CHECK_DEATH(slash_warning_time + warning_time_bonus)
	else
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), slash_warning_time - 1)
		SLEEP_CHECK_DEATH(slash_warning_time)

	var/turf/source_turf = get_turf(src)
	current_weapon_set.WeaponHitTurf(source_turf, current_weapon_index + 1)
	current_move_attack_index = 0
	need_to_hit_on_move = TRUE
	for(var/datum/relative_coordinates/RC in to_hit)
		++current_move_attack_index
		var/turf/T = GetRelativeCoordinateTurf(RC)
		if(!T.density)
			current_weapon_set.WeaponHitTurf(T, current_weapon_index + 1)
			for(var/turf/TT in get_adjacent_open_turfs(T))
				current_weapon_set.WeaponHitTurf(TT, current_weapon_index + 1)
		playsound(src, 'sound/weapons/fixer/generic/sword2.ogg', 75, TRUE, 5)
		SLEEP_CHECK_DEATH(slash_time_per_hit)
	need_to_hit_on_move = FALSE
	QDEL_LIST(to_hit)
	been_hit.Cut()
	if(slashes_remaining > 1)
		current_weapon_index = (current_weapon_index + 1) % 2
		addtimer(CALLBACK(src, PROC_REF(Slash), slash_target, slashes_remaining - 1, FALSE, combo_hits_remaining), slash_wait_time)
	else if(combo_hits_remaining > 0)
		ComboAttack(slash_target, combo_hits_remaining, list(PROC_REF(Smash), PROC_REF(SpearStab)))
	else
		current_move = null
		can_special = TRUE

/mob/living/simple_animal/hostile/training_bunny/proc/Smash(smash_target, smashes_remaining, is_first_smash = TRUE, combo_hits_remaining = 0)
	if(is_first_smash)
		can_special = FALSE
		current_move = "smash"
		smash_cooldown = world.time + smash_cooldown_time
		smash_current_range = pick(0, 1)
	if(!smash_target)
		smash_target = target
	var/turf/smash_target_turf = GetRangedTargetTurfMaxMetric(src, smash_target, smash_ranges[smash_current_range + 1], 0)
	var/turf/smash_side_turf = GetRangedTargetTurfMaxMetric(smash_target_turf, src, smash_hit_range[smash_current_range + 1], smash_angle)
	var/turf/other_side_turf = GetRangedTargetTurfMaxMetric(smash_target_turf, src, smash_hit_range[smash_current_range + 1], -smash_angle)

	var/list/turfs_to_hit = getline(smash_target_turf, smash_side_turf) - smash_target_turf + getline(smash_target_turf, other_side_turf)
	for(var/turf/T in turfs_to_hit)
		to_hit += new /datum/relative_coordinates(T.x - src.x, T.y - src.y, src)
		var/obj/effect/reusable_visual/RV = RVP.NewCultSparks(T, 0, "#ff0a0a")
		RV.animate_movement = SLIDE_STEPS
		to_hit_telegraphs += RV
	need_to_move_telegraphs = TRUE

	if(is_first_smash)
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), smash_warning_time + warning_time_bonus - 1)
		SLEEP_CHECK_DEATH(smash_warning_time + warning_time_bonus)
	else
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), smash_warning_time - 1)
		SLEEP_CHECK_DEATH(smash_warning_time)

	playsound(src, 'sound/weapons/fixer/generic/sword2.ogg', 75, TRUE, 5)
	for(var/datum/relative_coordinates/RC in to_hit)
		var/turf/T = GetRelativeCoordinateTurf(RC)
		if(T.density)
			continue
		current_weapon_set.WeaponHitTurf(T, 0)
		if(smash_current_range > 0)
			for(var/turf/TT in get_adjacent_open_turfs(T))
				current_weapon_set.WeaponHitTurf(TT, 0)
	if(smash_current_range == 0)
		var/turf/T = get_turf(src)
		current_weapon_set.WeaponHitTurf(T, 0)
		for(var/turf/TT in get_adjacent_open_turfs(T))
			current_weapon_set.WeaponHitTurf(TT, 0)
	QDEL_LIST(to_hit)
	been_hit.Cut()
	smash_current_range = (smash_current_range + 1) % 2

	if(smashes_remaining > 1)
		addtimer(CALLBACK(src, PROC_REF(Smash), smash_target, smashes_remaining - 1, FALSE, combo_hits_remaining), smash_wait_time)
	else if(combo_hits_remaining > 0)
		ComboAttack(smash_target, combo_hits_remaining, list(PROC_REF(Slash), PROC_REF(SpearStab)))
	else
		current_move = null
		can_special = TRUE

/mob/living/simple_animal/hostile/training_bunny/proc/SpearStab(spear_target, times_to_spear, is_first_stab = TRUE, combo_hits_remaining = 0)
	if(is_first_stab)
		can_special = FALSE
		spear_cooldown = world.time + spear_cooldown_time
		current_move = "spear"
		current_weapon_index = pick(0, 1)
	if(!spear_target)
		spear_target = target
	var/turf/T3 = GetRangedTargetTurfMaxMetric(src, spear_target, spear_range, 0)
	var/list/turfs_to_hit = getline(src, T3)
	for(var/turf/T in turfs_to_hit)
		to_hit += new /datum/relative_coordinates(T.x - src.x, T.y - src.y, src)
		var/obj/effect/reusable_visual/RV = RVP.NewCultSparks(T, 0, "#ff0a0a")
		RV.animate_movement = SLIDE_STEPS
		to_hit_telegraphs += RV
	need_to_move_telegraphs = TRUE

	if(is_first_stab)
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), spear_warning_time + warning_time_bonus - 1)
		SLEEP_CHECK_DEATH(spear_warning_time + warning_time_bonus)
	else
		addtimer(CALLBACK(src, PROC_REF(KillMovingEffects)), spear_warning_time - 1)
		SLEEP_CHECK_DEATH(spear_warning_time)

	current_move_attack_index = 0
	need_to_hit_on_move = TRUE
	playsound(src, 'sound/weapons/fixer/generic/sword3.ogg', 75, TRUE, 5)
	for(var/datum/relative_coordinates/RC in to_hit)
		++current_move_attack_index
		var/turf/T = GetRelativeCoordinateTurf(RC)
		if(T.density)
			break
		current_weapon_set.WeaponHitTurf(T, current_weapon_index + 1)
		for(var/turf/TT in get_adjacent_open_turfs(T))
			current_weapon_set.WeaponHitTurf(TT, current_weapon_index + 1)
		sleep(spear_time_per_hit)
	need_to_hit_on_move = FALSE
	QDEL_LIST(to_hit)
	been_hit.Cut()

	if(times_to_spear > 1)
		addtimer(CALLBACK(src, PROC_REF(SpearStab), spear_target, times_to_spear - 1, FALSE, combo_hits_remaining), spear_wait_time)
	else if(combo_hits_remaining > 0)
		ComboAttack(spear_target, combo_hits_remaining, list(PROC_REF(Slash), PROC_REF(Smash)))
	else
		current_move = null
		can_special = TRUE

/mob/living/simple_animal/hostile/training_bunny/proc/GreaterSplitHorizontal(main_target)
	can_act = FALSE
	can_special = FALSE
	split_horizontal_cooldown = world.time + split_horizontal_cooldown_time
	if(!main_target)
		main_target = target
	var/turf/T0 = get_turf(main_target)
	var/turf/beam_source = GetRangedTargetTurfMaxMetric(src, T0, 1, 180)
	var/turf/T1 = get_ranged_target_turf_direct(beam_source, T0, split_horizontal_range, split_horizontal_angle / 2 + 10)
	var/turf/T2 = get_ranged_target_turf_direct(beam_source, T0, split_horizontal_range, -split_horizontal_angle / 2 - 10)
	var/datum/beam/B1 = beam_source.Beam(T1, "r_beam", time = split_horizontal_warning_time)
	var/datum/beam/B2 = beam_source.Beam(T2, "r_beam", time = split_horizontal_warning_time)
	B1.visuals.alpha = 0
	B2.visuals.alpha = 0
	animate(B1.visuals, alpha = 200, time = 0.5 SECONDS)
	animate(B2.visuals, alpha = 200, time = 0.5 SECONDS)
	visible_message(span_warning("[src] prepares a devastating attack!"))
	SLEEP_CHECK_DEATH(split_horizontal_warning_time)
	var/list/turfs_to_hit = list()
	for(var/i = 1 to split_horizontal_angle / 10)
		var/turf/T = get_ranged_target_turf_direct(src, T0, split_horizontal_range, (split_horizontal_angle / 2) - ((i - 1) * 10))
		turfs_to_hit = getline(src, T)
		for(var/turf/TT in turfs_to_hit)
			if(TT.density)
				break
			for(var/turf/TTT in RANGE_TURFS(1, TT))
				if(TTT.density)
					continue
				RVP.NewSmashEffect(TTT, 3, "#c9270e")
				been_hit = HurtInTurf(TTT, been_hit, split_horizontal_damage, RED_DAMAGE, null, check_faction = TRUE, hurt_mechs = TRUE, hurt_hidden = TRUE, hurt_structure = TRUE)
		SLEEP_CHECK_DEATH(0.5)
		playsound(src, 'sound/weapons/fixer/generic/sword3.ogg', 75, TRUE, 5)
	been_hit.Cut()
	SLEEP_CHECK_DEATH(2 SECONDS)
	can_act = TRUE
	can_special = TRUE

/datum/relative_coordinates
	var/x
	var/y
	var/atom/movable/center

/datum/relative_coordinates/New(x, y, center)
	src.x = x
	src.y = y
	src.center = center
	return ..()

/proc/GetRelativeCoordinateTurf(datum/relative_coordinates/RC)
	return locate(RC.center.x + RC.x, RC.center.y + RC.y, RC.center.z)

/datum/reusable_visual_pool/proc/NewGoldRushPortal(turf/location, duration = 0, alpha = 255)
	var/obj/effect/reusable_visual/RV = TakePoolElement()
	SET_RV_RETURN_TIMER(RV, duration)
	RV.name = "portal"
	RV.icon = 'ModularTegustation/Teguicons/tegu_effects.dmi'
	RV.icon_state = "manager_shield"
	RV.loc = location
	RV.alpha = alpha
	RV.layer = BYOND_LIGHTING_LAYER
	return RV

/mob/living/simple_animal/hostile/training_bunny/proc/GetLastOpenTurfInDir(turf/start, dir)
	var/turf/T = start
	. = T
	do
		for(var/obj/machinery/door/poddoor/D in T)
			if(D.density)
				return
		. = T
		T = get_open_turf_in_dir(T, dir)
	while(T)

/mob/living/simple_animal/hostile/training_bunny/proc/GoldRushPrepare()
	can_act = FALSE
	can_special = FALSE
	gold_rush_cooldown = world.time + gold_rush_cooldown_time
	var/list/warp_points = GLOB.xeno_spawn + GLOB.department_centers
	var/list/all_paths[gold_rush_charges + 2]
	var/list/portals = list()
	var/turf/T0 = GetLastOpenTurfInDir(get_turf(src), pick(NORTH, SOUTH, EAST, WEST))
	all_paths[1] = getline(src, T0)
	var/obj/effect/reusable_visual/P0 = RVP.NewGoldRushPortal(T0, 0, 0)
	P0.transform = turn(matrix().Scale(3, 1), Get_Angle(P0, src))
	portals += null
	portals += P0
	animate(P0, alpha = 200, time = 3 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(GoldRushTelegraph), all_paths[1])
	for(var/i in 1 to gold_rush_charges)
		var/turf/picked_turf = pick_n_take(warp_points)
		var/turf/T1 = GetLastOpenTurfInDir(picked_turf, NORTH)
		var/turf/T2 = GetLastOpenTurfInDir(picked_turf, SOUTH)
		var/turf/T3 = GetLastOpenTurfInDir(picked_turf, EAST)
		var/turf/T4 = GetLastOpenTurfInDir(picked_turf, WEST)
		var/turf/portal1 = T1
		var/turf/portal2 = T2
		if(T1.y - T2.y < T3.x - T4.x)
			portal1 = T3
			portal2 = T4
		var/obj/effect/reusable_visual/P1 = RVP.NewGoldRushPortal(portal1, 0, 0)
		var/obj/effect/reusable_visual/P2 = RVP.NewGoldRushPortal(portal2, 0, 0)
		P1.transform = turn(matrix().Scale(3, 1), Get_Angle(P1, portal2))
		P2.transform = turn(matrix().Scale(3, 1), Get_Angle(P2, portal1))
		animate(P1, alpha = 200, time = 3 SECONDS)
		animate(P2, alpha = 200, time = 3 SECONDS)
		var/list/path_turfs = list()
		if(prob(50))
			path_turfs = getline(portal1, portal2)
			portals += P1
			portals += P2
		else
			path_turfs = getline(portal2, portal1)
			portals += P2
			portals += P1
		INVOKE_ASYNC(src, PROC_REF(GoldRushTelegraph), path_turfs)
		all_paths[i + 1] = path_turfs
		for(var/turf/TT in path_turfs)
			warp_points -= TT
		sleep(5)
	var/turf/end_department = pick(GLOB.department_centers)
	T0 = GetLastOpenTurfInDir(end_department, pick(NORTH, SOUTH, EAST, WEST))
	all_paths[all_paths.len] = getline(T0, end_department)
	var/obj/effect/reusable_visual/P_end = RVP.NewGoldRushPortal(T0, 0, 0)
	P_end.transform = turn(matrix().Scale(3, 1), Get_Angle(P_end, end_department))
	portals += P_end
	portals += null
	animate(P_end, alpha = 200, time = 3 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(GoldRushTelegraph), all_paths[all_paths.len])
	addtimer(CALLBACK(src, PROC_REF(GoldRushCharge), all_paths, portals), 7 SECONDS)

/mob/living/simple_animal/hostile/training_bunny/proc/GoldRushTelegraph(list/path)
	for(var/turf/T in path)
		RVP.NewCultSparks(T)
		sleep(0.5)

/mob/living/simple_animal/hostile/training_bunny/proc/GoldRushCharge(list/paths, list/portals)
	for(var/list/L in paths)
		RVP.ReturnToPool(popleft(portals))
		for(var/turf/T in L)
			if(TurfAdjacent(T))
				var/list/turfs_to_hit
				if(T.x == src.x)
					turfs_to_hit = block(locate(max(1, src.x - 2), max(1, src.y - 1), src.z), locate(min(world.maxx, src.x + 2), min(world.maxy, src.y + 1), src.z))
				else
					turfs_to_hit = block(locate(max(1, src.x - 1), max(1, src.y - 2), src.z), locate(min(world.maxx, src.x + 1), min(world.maxy, src.y + 2), src.z))
				for(var/turf/open/TT in turfs_to_hit)
					been_hit = HurtInTurf(TT, been_hit, gold_rush_damage, RED_DAMAGE, null, TRUE, FALSE, TRUE, hurt_hidden = TRUE)
					RVP.NewSmashEffect(TT, 2.5)
			for(var/obj/machinery/door/D in T)
				if(D.CanAStarPass(null))
					INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door, open), 2)
			forceMove(T)
			SLEEP_CHECK_DEATH(0.8)
		been_hit.Cut()
		RVP.ReturnToPool(popleft(portals))
	sleep(5 SECONDS)
	can_act = TRUE
	can_special = TRUE
