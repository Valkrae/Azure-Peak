//Chain link fences
//Sprites ported from /VG/


#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = ""
	density = TRUE
	anchored = TRUE

	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE

/obj/structure/fence/Initialize()
	. = ..()

	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()

	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/end
	icon_state = "end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!cuttable)
			to_chat(user, span_warning("This section of the fence can't be cut!"))
			return
		if(invulnerable)
			to_chat(user, span_warning("This fence is too strong to cut through!"))
			return
		var/current_stage = hole_size
		if(current_stage >= MAX_HOLE_SIZE)
			to_chat(user, span_warning("This fence has too much cut out of it already!"))
			return

		user.visible_message(span_danger("\The [user] starts cutting through \the [src] with \the [W]."),\
		span_danger("I start cutting through \the [src] with \the [W]."))

		if(do_after(user, CUT_TIME*W.toolspeed, target = src))
			if(current_stage == hole_size)
				switch(++hole_size)
					if(MEDIUM_HOLE)
						visible_message(span_notice("\The [user] cuts into \the [src] some more."))
						to_chat(user, span_info("I could probably fit myself through that hole now. Although climbing through would be much faster if it was even bigger."))
						climbable = TRUE
					if(LARGE_HOLE)
						visible_message(span_notice("\The [user] completely cuts through \the [src]."))
						to_chat(user, span_info("The hole in \the [src] is now big enough to walk through."))
						climbable = FALSE

				update_cut_status()

	return TRUE

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			density = FALSE

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = ""
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize()
	. = ..()

	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE
	density = TRUE

/obj/structure/fence/door/attack_hand(mob/user)
	if(can_open(user))
		toggle(user)

	return TRUE

/obj/structure/fence/door/proc/toggle(mob/user)
	switch(open)
		if(FALSE)
			visible_message(span_notice("\The [user] opens \the [src]."))
			open = TRUE
		if(TRUE)
			visible_message(span_notice("\The [user] closes \the [src]."))
			open = FALSE

	update_door_status()
	playsound(src, 'sound/blank.ogg', 100, TRUE)

/obj/structure/fence/door/proc/update_door_status()
	switch(open)
		if(FALSE)
			density = TRUE
			icon_state = "door_closed"
		if(TRUE)
			density = FALSE
			icon_state = "door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE
