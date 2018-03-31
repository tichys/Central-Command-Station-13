//coded by RepresentativeTreat / Noober84555

/*

Clock-in and clock-out system for IDs (certain ids only)


spawn "/obj/item/weapon/card/id/clocked"

spawn "/obj/machinery/computer/security_clock_in_clock_out"


sorta commentate for noobs LOL
*/

var/clocksystemlist = list() //variable


/*

the id

it's what you wear.


*/
/obj/item/weapon/card/id/clocked
	name = "ID"
	desc = "ERROR" //error, no process() yet
	icon_state = "guest" //idk what icons exist

	var/temp_access = list() //Access. Edit this!

	var/timeleft = 0 //Time left, in seconds.
	var/rand_id = 0 //this is incase someone is named grey man, and tehres 2 grey mans, so it can be grey man (948) and grey man (578) for example
	var/reasonfortime = "Unknown, Not set" //Reason

	New()
		clocksystemlist += src //adds to clock system
		..()
		rand_id = rand(1,99999) //Creates a ID
		START_PROCESSING(SSprocessing, src) //starts processing
	Del()
		clocksystemlist -= src //removes from clock system
		STOP_PROCESSING(SSprocessing, src) //stops processing
		..()
	Destroy()
		clocksystemlist -= src
		STOP_PROCESSING(SSprocessing, src)
		..()


/obj/item/weapon/card/id/clocked/process() //process
	name = "ID ([rand_id]-[registered_name])" //sets the name to ID (myID-myName)
	timeleft-- //Decreases time
	if(timeleft > 0)
		desc = "It's a ID. <font color='blue'>Temporary access : [timeleft] seconds left. ([reasonfortime])</font>" //When time is above 0 seconds, use this description.
	else
		desc = "It's a ID." //Normal description
	if(timeleft < 0)
		timeleft = 0 //we can't have -1,-2,-3,-4 etc

/*

gets access

*/

/obj/item/weapon/card/id/clocked/GetAccess() //Get access
	if (timeleft < 1) //If time is over
		return access //put normal access
	else
		return access + temp_access //else, put access and temporary access.

/*

the console.

it does the ID changing stuff.

*/

/obj/machinery/computer/security_clock_in_clock_out
	name = "ID clock-in and clock-out console"
	desc = "It's used to edit access times, etc."

	icon_screen = "security"
	light_color = LIGHT_COLOR_ORANGE

	req_one_access = list(access_security) //access required to operate.

	circuit = /obj/item/weapon/circuitboard/secure_data
	var/obj/item/weapon/card/id/scan = null

	var/authenticated = "Unknown"
	var/rank = "Unknown"

	var/loggedIn = 0
	var/logsc = "Started up."

/*
console procs below

to-do : commentate (too much shit to commentate)
*/

/obj/machinery/computer/security_clock_in_clock_out/proc/LogActionConsole(var/ass)
	logsc += "<br>[ass]"

/obj/machinery/computer/security_clock_in_clock_out/proc/eject_id_proc()
	if(scan)
		authenticated = "Unknown"
		rank = "Unknown"
		loggedIn = 0
		scan.loc = get_turf(src)
		scan = null

/obj/machinery/computer/security_clock_in_clock_out/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.loc = src
		scan = O
		user << "You insert [O]."
		authenticated = scan.registered_name
		rank = scan.assignment
		loggedIn = 1
	..()

/obj/machinery/computer/security_clock_in_clock_out/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact(user)

/*
console UI procs below

to-do : commentate (too much shit to commentate)
*/

/obj/machinery/computer/security_clock_in_clock_out/ui_interact(user)
	if (src.z > 6)
		user << "<span class='warning'>Unable to establish a connection:</span> You're too far away from the station!"
		return //idk how this works, but sure
	var/dat
	dat += "<body style='background-color:black;'><font color='white'>"
	dat += "<h2>Login area</h2><br>"
	dat += "<A href='?src=\ref[src];choice=eject'>{Eject Id and Log Out}</A><br>" //this may break
	dat += "<br>"
	dat += "Logged in as : [authenticated] ([rank])" //idk
	dat += "<br><br><br>"

	dat += "<h2>ID list</h2><br>"
	dat += "<A href='?src=\ref[src];choice=changetime'>Change ID from list</A><br>"
	dat += "<hr>"
	for(var/obj/item/weapon/card/id/clocked/ied in clocksystemlist)
		if(ied.timeleft > 0)
			dat += "[ied.name] - [ied.timeleft] seconds left ([ied.reasonfortime])<br>"
		else
			dat += "[ied.name] - OVER<br>"
	dat += "<hr><br><br>"
	dat += "<h2>Logs</h2><br>"
	dat += "[logsc]"
	user << browse(text("<HEAD><TITLE>ID list</TITLE></HEAD><TT>[]</TT>", dat), "window=secure_id_clock_system;size=800x600") //idk
	onclose(user, "secure_id_clock_system")
	return

/obj/machinery/computer/security_clock_in_clock_out/Topic(href, href_list)
	if(..())
		return 1
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) )
		usr.set_machine(src)
		if(href_list["choice"] == "eject")
			eject_id_proc() //ejects id

		//better or what

		if(href_list["choice"] == "changetime")
			if (istype(scan, /obj/item/weapon/card/id))
				if(check_access(scan))

					var/obj/item/weapon/card/id/clocked/ied = input(usr,"What card?","Select ID") in clocksystemlist
					if(ied)
						var/g = input(usr,"Please enter minutes to have access.","Time",1) as num
						var/e = input(usr,"Please enter reason","Time","No reason") as text
						if(e)
							ied.reasonfortime = e
						if(g)
							if(g < 60 && g > 0)
								ied.timeleft = round(g)*60
						LogActionConsole("[authenticated] ([rank]) modified [ied] : [ied.timeleft/60] minutes - [ied.reasonfortime]")
	updateUsrDialog()
