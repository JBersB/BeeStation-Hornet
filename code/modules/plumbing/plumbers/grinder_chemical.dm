/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "chemical grinder."
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	rcd_cost = 30
	rcd_delay = 30
	buffer = 400
	active_power_usage = 80
	var/eat_dir = SOUTH

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/grinder_chemical/setDir(newdir)
	. = ..()
	eat_dir = newdir

/obj/machinery/plumbing/grinder_chemical/CanAllowThrough(atom/movable/AM)
	. = ..()
	if(!anchored)
		return
	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		return TRUE

/obj/machinery/plumbing/grinder_chemical/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(grind), AM)

/obj/machinery/plumbing/grinder_chemical/proc/grind(atom/AM)
	if(machine_stat & NOPOWER)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return
	var/obj/item/I = AM
	if(I.juice_results || I.grind_results)
		if(I.juice_results)
			I.on_juice()
			reagents.add_reagent_list(I.juice_results)
			if(I.reagents)
				I.reagents.trans_to(src, I.reagents.total_volume, transfered_by = src)
			qdel(I)
			return
		I.on_grind()
		reagents.add_reagent_list(I.grind_results)
		if(I.reagents)
			I.reagents.trans_to(src, I.reagents.total_volume, transfered_by = src)
		qdel(I)

