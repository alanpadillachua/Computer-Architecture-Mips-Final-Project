##################################################################################
# FINAL PROJECT 
# University of Texas at Dallas
# CS 3340 -Fall 2015
# Alan Padilla - axp141330
#
#Write and submit a MIPS Assembly Language program 
# by collecting the functions implemented in the "Other Programs"
# projects, which:
# 1) Reads the year of interest from user input,
# 2) displays the dates and time of all full moons for the year, and
# 3) identiefies the monthly and seasonal blue moons which occur during that year.
##################################################################################
	.data
year:	.asciiz "Please enter a Year (above or equal to 1970 XXXX): "
size: 	.word 12 # size of "array" 
NormM:	.word 1,32,60,91,121,152,182,213,244,274,305,335
LeapM:	.word 1,32,61,92,122,153,183,214,245,275,306,336
Jan:	.asciiz "Jan"
Feb:	.asciiz "Feb"
Mar:	.asciiz "Mar"
Apr:	.asciiz "Apr"
May:	.asciiz "May"
Jun:	.asciiz "Jun"
Jul:	.asciiz "Jul"
Aug:	.asciiz "Aug"
Sep:	.asciiz "Sep"
Oct:	.asciiz "Oct"
Nov:	.asciiz "Nov"
Dec:	.asciiz "Dec"
	.text
main:	la $a0, year #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	li $v0, 5 # sets up to take integer
	syscall 
	add $s1, $v0,$zero # moves integer into memory 
	blt $s1,1970,main # if the  year is less than zero then do it again
	add $t8, $s1, $zero # $t8 holds  copy of year
	addi $sp, $sp, -4 # clears space in stack pointer 
	addi $gp,$gp, -28 #opens global variable to store julian season dates 
	jal SeasonCal #jump to seasonCal 
	jal FullMoonCal
end:	addi $gp,$gp, 28 # pushes back the stack for gp 
	li $v0, 10 #terminates propperly 
	syscall # syscall 10 terminates executes
###########################################################################	
# Function: BlueSeasonCal
#	Determines if the FUllMoon is a Seasonal Blue Moon
#Input: Julian Date of Full Moon
#Output: Prints if it is SeasonalBlueMoon
#	$s7 if leap 
#	$s0 holds julian date 
#	$s5 hold index of month
#	s6 holds SpringMoon counter
#	s2 holds SummerMoon counter
#	s3 holds FallMoon counter 
#	s4 holds WinterMoon counter
###########################################################################
BlueSeasonCal:
	######loads from seasonsCal
	lw $t1,0($gp) #loads spring julian date 
	lw $t2,4($gp) #loads summer julian date
	lw $t3,8($gp) #loads fall julian date 
	lw $t4,12($gp) #loads winter julian date
	add $t5,$s0,$zero #t5 holds copy of current julian date
SeasonCheck:
	bge $s0,$t1,spcheck #if (JD >= spring julian date) then go to spcheck
	j wcheck2 #if not go to wintercheck
spcheck:	blt $s0,$t2,Ispring #if (JD< Summer JD ) then the moon is in spring
	j sucheck #if not go to summercheck
Ispring:	addi $s6,$s6, 1 #SpringMoon++
	beq $s6,3,spDate #if springMoon == 3 then jump to
	beq $s6,4,BMSP #if springMoon == 4 then branch to Blue Moon Spring
	j spExt #if neither exit
BMSP:	la $a0, BlueSeasonSp #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall
	lw $s0,16($gp) #loads JD of springin t9
	j BlueOutPut #jump to blue output
spDate:	sw $s0,16($gp) #store JD in t9	
spExt:	jr $ra #exit function	
##########################################################################
sucheck:	bge $s0,$t2,sucheck2 #if(JD >= Summer JD) then go to summercheck 2
	j facheck #if not jump to facheck
sucheck2:   blt $s0,$t3,Isummer #if(JD < FALL JD) then the moon is in summer
	j facheck #if not go to facheck
Isummer:   	addi $s2,$s2,1 #summerMoon++
	beq $s2,3,suDate # if summerMoon == 3 then jump to 
	beq $s2,4,BMSU #if summerMoon == 4 then branch to Blue Moon Summer
	j suExt #if neither exit
BMSU:	la $a0, BlueSeasonSu #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall
	lw $s0,20($gp) #loads JD of summer in t9
	j BlueOutPut #jump to blue output
suDate:	sw $s0,20($gp) #store jd in t9	
suExt:	jr $ra #exit
##########################################################################
facheck:	bge $s0,$t3, facheck2 # if(JD >= FallJD) then go to fallcheck 2
	j wcheck #if not check winter 
facheck2:	blt $s0,$t4, Ifall #if(JD < Winter JD) then moon is in winter 
	j wcheck #if not check winter 
Ifall:	addi $s3, $s3, 1 #fallmoon++
	beq $s3,3,faDate #if fallmoon == 3 then jump
	beq $s3,4,BMFA #if fallmoon == 4 then branch to Blue Moon Fall
	j faExt #if not exit 
BMFA:	la $a0, BlueSeasonFa #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall
	lw $s0,24($gp) #loads JD of summer in t9
	j BlueOutPut #jump to blue output
faDate:	sw $s0,24($gp) #store jd in t9 
faExt:	jr $ra #exit
wcheck:	bge $s0,$t4,Iwinter #If(JD >= WinterJD) then its in winter
wcheck2:	blt $s0,$t1,Iwinter#if(JD < SpringJD) then its in winter
Iwinter:	addi $s4,$s4,1 #wintermoon++
	beq $s4,3, wiDate # if wintermoon == 3 then jump
	beq $s4,4,BMWI # if wintermoon ==4 then branch to Blue Moon winter
	j Ext #if not jump to exit 
BMWI:	la $a0, BlueSeasonWi #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall
	lw $s0,28($gp) #loads JD of summer in t9
	j BlueOutPut #jump to blue output
wiDate:	sw $s0,28($gp) #store jd in t9
Ext:	jr $ra #exit
BlueOutPut:
	addi $sp,$sp,-32 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store spring day in stack 
	sw $t2,8($sp) #store summer day in stack 
	sw $t3,12($sp)#store fall day in stack 
	sw $t4,16($sp)#store spring day in stack 
	sw $t5,20($sp) #store copy of current JD in stack
	sw $s2,24($sp) #store count
	sw $s3,28($sp) #store count
	sw $s4,32($sp) #store $summer moon count
	jal GregNorm #go to GregorianLeap Function
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop day in stack 
	lw $t3,12($sp) #pop day in stack
	lw $t4,16($sp) #pop day
	lw $t5,20($sp) #pop copy
	lw $s2,24($sp) #store count
	lw $s3,28($sp) #store count 
	lw $s4,32($sp) #store $summer moon count
	addi $sp,$sp,32 #allocates space on stack
	add $s0,$t5,$zero #t5 holds copy of current julian date
	jr $ra #exit
	################################
###########################################################################	
# Function: BlueMonthCal
#	Determines if the FUllMoon is a monthly Blue Moon
#Input: Julian Date of Full Moon
#Output: Return 1 if it is in the same Month or 0 if it is Not
#	$s7 if leap 
#	#s0 holds julian date 
#	$a3 holds previous month of fool moon
#	$s5 hold index of month
###########################################################################
BlueMonthCal:
	lw $s5,20($sp) #loads previouse month index into $s5
	add $a3, $s5,$zero #copies previous value of $s5 being month index
	addi $s5, $zero, 1 #$s5 (loopcount) = 1
	add $t3, $s0, $zero # $t3 = $s0 creates a copy of julian date
	beq $s7, 1, LoadLeap #if the year is leap then load leap 
	j LoadNorm #if not load the norm
LoadLeap:	
	la $s2, LeapM  #s2 = NormM array address
	lw $t4, ($s2)  #t4 = NormM[i]
	bge $t3,$t4,MonthMoonLoop #if t3(julian date) >= t4 then branch to normLoop
LoadNorm:	la $s2, NormM  #s2 = NormM array address
	lw $t4, ($s2)  #t4 = NormM[i]
	bge $t3,$t4,MonthMoonLoop #if t3(julian date) >= t4 then branch to normLoop
MonthMoonLoop:	
	addi $s5, $s5, 1 #$s5 loopCount = ++1
	addi $s2, $s2, 4   #$s2 = Norm[i+1]
	lw $t4, ($s2)  #t4 = NormM[0]
	bge $t3,$t4, MonthMoonLoop #if t3(julian date) >= t4 then branch to normLoop	
	addi $s5, $s5, -1 #$s5 = loopCount - 1 for proper index
	beq $s5,$a3,Yes #if Month index equal to previous month index then yes
	add $a1,$zero,$zero #since different month then  a1 holds zero
	jr $ra # return to function call
Yes:	addi $a1, $zero, 1 # $a1 holds 1 showing that FullMoon is monthly Blue Moon
	jr $ra #return to function call
##########################################################################	
# Function: Calculates the FullMoons of the requested year
#	increments refrence year until requestes year is reached.
# Input: Requeste Year
# Output: HH:MM dd month year for each full moon of year 	
#	
##########################################################################
	.data
RefMoonYear:.word 1970 
RefDay:	.word 22
RefHour:	.word 6
RefMin:	.word 55
Moon:	.asciiz "Full Moon"
BlueMonth:	.asciiz "Monthly Blue Moon|"
BlueSeasonSp: .asciiz "Seasonal Spring Blue Moon on "
BlueSeasonSu: .asciiz "Seasonal Summer Blue Moon on "
BlueSeasonFa: .asciiz "Seasonal Fall Blue Moon on "
BlueSeasonWi: .asciiz "Seasonal Winter Blue Moon on "
newLine:  	.asciiz "\n"
	.text
FullMoonCal:
	add $s6,$zero,$zero #s6 holds SpringMoon counter
	add $s2,$zero,$zero #s2 holds SummerMoon counter
	add $s3,$zero,$zero #s1 holds FallMoon counter 
	add $s4,$zero,$zero #s4 holds WinterMoon counter
	la $a0,RefMoonYear # $a0 holds the Refrence year adress to the word
	lw $t0,($a0) #$t0 holds the refrence year (1990)
	la $a0,RefDay # $a0 holds the Refrence day adress to the word
	lw $t1,($a0) #$t1 holds the refrence Day 
	la $a0,RefHour # $a0 holds the Refrence hour adress to the word
	lw $t2,($a0) #$t2 holds the refrence hour
	la $a0,RefMin # $a0 holds the Refrence min adress to the word
	lw $t3,($a0) #$t3 holds the refrence min
Start:
	blt $t0,$t8,UpdateLoop #if (refrence year < requested year) then go to UpdateLoop
	j CorOutput #if not jump to CorOutput
UpdateLoop:
	addi $t1,$t1,29 #Refrence day += 29 days
	addi $t2,$t2,12 #Refrence Hour += 12 hours
	addi $t3,$t3,43 #Refrence min += 43 mins
MinCheck:
	bge $t3, 60, Minflow #if(min >= 60) then go to overflow 
	j HourCheck #if not jump to hourconvert 
Minflow:
	addi $t3, $t3, -60 # min = min - 60
	addi $t2, $t2, 1 # hour = hour+1
	j MinCheck #jump to MinCheck
HourCheck:
	bge $t2,24,Hourflow #if(hour >= 24) then go to overflow 
	j YearUpdate #if not jump to yearupdate 
Hourflow:
	addi $t2, $t2, -24 # hour = hour - 24
	addi $t1, $t1, 1 # day++
	j HourCheck # jump to checkHour	
YearUpdate:
	add $s7 ,$zero,$zero #$s7 holds 1 if leap or 0 if not
	add $s1,$t0,$zero #copies refrence year to s1 to check if leap 
	addi $sp,$sp,-16 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store day in stack 
	sw $t2,8($sp) #stores hour in stack 
	sw $t3,12($sp) #stores min in stack 
	sw $t0,16($sp) #stores refYear in stack 
	jal leapYear # sends year to leapyear function
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop hour in stack 
	lw $t3,12($sp) #pop min in stack
	lw $t0,16($sp) #pop refyear
	addi $sp,$sp,16 #allocates space on stack 
	beq $s7,1,LeapDec #if the year is leap then send to LeapDec
	bgt $t1,365,NormOver #if (refrenceDay > 365) then go to NormOver
	j Start #if not jump to start
NormOver:
	addi $t0, $t0, 1 # refrenceYear++
	addi $t1, $t1, -365 # RefrenceDay = RefrenceDay - 365
	j Start # jumpback to start of loop
LeapDec: 
	bgt $t1,366,LeapOver #if (refrenceDay > 366) then go to LeapOver
	j Start #jumpback to start of loop 
LeapOver:
	addi $t0, $t0, 1 # refrenceYear++
	addi $t1, $t1, -366 # RefrenceDay = RefrenceDay - 366
	j Start # jumpback to start of loop
###########################################################
CorOutput:
	add $s1,$t0,$zero #copies refrence year(equal to requested year)to s1 to check if leap 
	add $s7 ,$zero,$zero #$s7 holds 1 if leap or 0 if not
	addi $sp,$sp,-16 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store day in stack 
	sw $t2,8($sp) #stores hour in stack 
	sw $t3,12($sp) #stores min in stack
	sw $t0,16($sp) #store year 
	jal leapYear # sends year to leapyear function
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop hour in stack 
	lw $t3,12($sp) #pop min in stack
	lw $t0,16($sp) #pop year
	addi $sp,$sp,16 #allocates space on stack 
	addi $t6, $zero, 1 #$t6 (loopcount) = 1
	beq $t6,1,MoonYearOut #if first time them jump to output
OutPutStart:
	beq $t0,$t8,MoonYearLoop #if (refrence year = requested year) then go to UpdateLoop
	bgt $t0,$t8 MoonYearQuit
MoonYearQuit:
	li $v0, 10 #terminates propperly 
	syscall # syscall 10 terminates executes
MoonYearLoop:addi $t1,$t1,29 #Refrence day += 29 days
	addi $t2,$t2,12 #Refrence Hour += 12 hours
	addi $t3,$t3,43 #Refrence min += 43 mins
MinFix:	bge $t3,60,MinConv#if(min >= 60) then go to overflow 
	j HourFix #if not jump to hourconvert 
MinConv:	addi $t3, $t3, -60 # min = min - 60
	addi $t2, $t2, 1 # hour = hour+1
	j MinFix #jump to MinCheck
HourFix:	bge $t2,24,HourConv #if(hour >= 24) then go to overflow 
	j YearFix #if not jump to yearupdate 
HourConv:	addi $t2, $t2, -24 # hour = hour - 24
	addi $t1, $t1, 1 # day++
	j HourFix # jump to checkHour	
YearFix:	beq $s7,1,LeapFix #if the year leap then send to LeapFix
	bgt $t1,365,NormSub #if (Day > 365) then go to NormSub
	j MoonYearOut #if not jump to MoonYearOut
NormSub:	addi $t0, $t0, 1 #increment year so loop will stop 
	j OutPutStart #return to OutPutStart
LeapFix: 	bgt $t1,366,LeapSub #if (refrenceDay > 366) then go to LeapOver
	j MoonYearOut #if not jump to MoonYearOut
LeapSub:	addi $t0, $t0, 1 #increment refrence year so loop will stop 
	j OutPutStart #return to OutPutStart
MoonYearOut:add $s0,$t1,$zero# copies calculated julian date to $s0 
	beq $t6,1,FMCONT #if first time them jump to MoonContinued
	add $a1,$zero, $zero #a1 set to zero
	addi $sp,$sp,-24 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store day in stack 
	sw $t2,8($sp) #stores hour in stack 
	sw $t3,12($sp) #stores min in stack
	sw $t0,16($sp) #store year 
	sw $s5,20($sp) #stores previouse month index into stack
	sw $s2,24($sp) #store summermoon count 
	jal BlueMonthCal #jumps and links to blue month cal 
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop hour in stack 
	lw $t3,12($sp) #pop min in stack
	lw $t0,16($sp) #pop year
	lw $s5,20($sp) #pop back month index
	lw $s2,24($sp) #store summermoon count 
	addi $sp,$sp,20 #allocates space on stack 
	beq $a1,0,FMCONT #if $a1 == 0 then its not monthly blue Moon
	la $a0, BlueMonth #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall
FMCONT:	add $a1,$zero, $zero #a1 set to zero
	addi $sp,$sp,-24 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store day in stack 
	sw $t2,8($sp) #stores hour in stack 
	sw $t3,12($sp) #stores min in stack
	sw $t0,16($sp) #store year 
	sw $s5,20($sp) #stores previouse month index into stack
	jal BlueSeasonCal #jumps and links to blue month cal 
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop hour in stack 
	lw $t3,12($sp) #pop min in stack
	lw $t0,16($sp) #pop year
	lw $s5,20($sp) #pop back month index
	addi $sp,$sp,24 #allocates space on stack 
MoonCont:	
	addi $t6,$t6,1 #t6 +=1 so loop will continue 
	la $a0, Moon #loads word
	li $v0, 4 #loads 4 in syscall 
	syscall 
	li $a0, ' '
	li $v0, 11    # print SPACE character
	syscall
	la $a0, ($t2) #loads hour
	li $v0, 1 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	li $a0, ':'
	li $v0, 11    # print SPACE character
	syscall
	la $a0, ($t3) #loads min
	li $v0, 1 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	li $a0, ' '
	li $v0, 11    # print SPACE character
	syscall
	addi $sp,$sp,-28 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	sw $t1,4($sp) #store day in stack 
	sw $t2,8($sp) #stores hour in stack 
	sw $t3,12($sp) #stores min in stack 
	sw $t0,16($sp) #store year
	sw $s2,20($sp) #store $summer moon count
	sw $s3,24($sp) #store $summer moon count
	sw $s4,28($sp) #store $summer moon count
	jal GregNorm #go to GregorianLeap Function
	lw $ra,0($sp) #pop first return adress
	lw $t1,4($sp) #pop day in stack 
	lw $t2,8($sp) #pop hour in stack 
	lw $t3,12($sp) #pop min in stack
	lw $t0,16($sp) #pop year
	lw $s2,20($sp) #pop summer moon count 
	lw $s3,24($sp) #pop summer moon count 
	lw $s4,28($sp) #store $summer moon count
	addi $sp,$sp,28 #allocates space on stack 
	j OutPutStart #return to OutPutStart
##########################################################################
#	Function LeapYear checks if the year is a leap year
# Input: 	year that the user entered
#
# Output: if the year is a leapyear then it return 1 in s7 
#	that states that it is one
#	if not then it will return to main to  and s7 will hold 0
#	$s1 holds year 
#	$s0 holds julian date 
#	$s7 holds LeapYearCheck 
##########################################################################	
leapYear: 	addi $t1, $zero, 4 #$t1 = holds 4 
	add $t0, $s1, $zero#$t0 = $s0 + 0 Copy of the year 
	div $t0, $t1 #year/4 
	mfhi $t2  #year%4 = $t2
	beq  $t2, $zero, step2  #if its equal to zero then continue to step 2
	jr $ra # if not return to function call with $s7 = 0 
step2:	addi $t1, $zero, 100 #$t1 = holds 100
	div $t0, $t1 # year/100
	mfhi $t2 # year%100 = $t2
	beq $t2,$zero,step3  # if its equal to zero then go to step 3
	j Final #if not then go to leapyear output
step3:	addi $t1, $zero, 400 # $t1 = holds 400
	div $t0, $t1 # year/400
	mfhi $t2# year%400 = $t2
	beq $t2,$zero,Final #if equal to zero then its a leap year
	jr $ra # if not then go to main
Final:	addi $s7, $zero, 1 #if its a leap year the $s7 holds 1
	jr $ra # jumps to end program properly
##########################################################################
#	Function GregNorm finds the month and day of the julian date 
#	of a NON-LEAP YEAR
# Input: 	Julian date given by user
#
# Output:  dd MMM yyyy 
#	dd is the numeric value of the day of the month, 
# 	MMM is the 3 letter abbreviation of the month's name 	
#	yyyy is the numeric value of the year
#	FINAL $s0 holds julian date 
#	FINAL $s1 holds year 
#	$s2 holds &NormM
#	FINAL $s3 = day (dd)
#	$s4 = Month ("  ")
#	$s5 = loop count 
#
##########################################################################
GregNorm:	addi $s5, $zero, 1 #$s5 (loopcount) = 1
	add $t3, $s0, $zero # $t3 = $s0 creates a copy of julian date
	beq $s7, 1, LeapArray #if the year is leap then load leap 
	j NormArray #if not load the norm
LeapArray:	la $s2, LeapM  #s2 = NormM array address
	lw $t4, ($s2)  #t4 = NormM[i]
	bge $t3,$t4,normLoop #if t3(julian date) >= t4 then branch to normLoop
NormArray:	la $s2, NormM  #s2 = NormM array address
	lw $t4, ($s2)  #t4 = NormM[i]
	bge $t3,$t4,normLoop #if t3(julian date) >= t4 then branch to normLoop
normLoop:	
	addi $s5, $s5, 1 #$s5 loopCount = ++1
	addi $s2, $s2, 4   #$s2 = Norm[i+1]
	lw $t4, ($s2)  #t4 = NormM[0]
	bge $t3,$t4, normLoop #if t3(julian date) >= t4 then branch to normLoop	
	addi $s5, $s5, -1 #$s5 = loopCount - 1 for proper index
	addi $s2,$s2,-4 #if not then NormM[i-1}= index of month
	lw $t4,($s2) #t2 = Norm[i(index of begging of julian month)]
	sub $s3,$t3,$t4 # $s3(day) = $t3(julian date) - $t4(index of month)
	addi $s3, $s3, 1 #$s3(day)= $s3 + 1	
	bge $s5, 12, decCase#if equal to 12 then DecCase
	j outputs1
decCase:	
	beq $s7,1,outputs1
	addi $s3, $s3, 1 #$s3(day)= $s3 + 1
	#outputs 
outputs1:
	la $a0, ($s3) #loads day
	li $v0, 1 # v0 holds 1 for sycall 
	syscall # syscall 1(output) executes
	li $a0, ' '
	li $v0, 11    # print SPACE character
	syscall
	beq $s5, 1, outJan #if equal to 0 then its jan
	beq $s5, 2, outFeb #if equal to 1 then feb 	
	beq $s5, 3, outMar #if equal to 2 then Mar
	beq $s5, 4, outApr#if equal to 3 then April
	beq $s5, 5, outMay#if equal to 4 then May
	beq $s5, 6, outJun#if equal to 5 then Jun
	beq $s5, 7, outJul#if equal to 6 then Jul
	beq $s5, 8, outAug#if equal to 7 then Aug
	beq $s5, 9, outSep#if equal to 8 then Sep
	beq $s5, 10, outOct#if equal to 9 then Oct
	beq $s5, 11, outNov#if equal to 10 then Nov
	bge $s5, 12, outDec#if equal to 11 then Dec
outJan:	la $a0, Jan #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outFeb:	la $a0, Feb #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outMar:	la $a0, Mar #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outApr:	la $a0, Apr #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outMay:	la $a0, May #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outJun:	la $a0, Jun #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outJul:	la $a0, Jul #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outAug:	la $a0, Aug #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outSep:	la $a0, Sep #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outOct:	la $a0, Oct #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outNov:	la $a0, Nov #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outDec:	la $a0, Dec #loads prompt to user 
	li $v0, 4 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	j outputs2
outputs2:	li $a0, ' '
	li $v0, 11    # print SPACE character
	syscall
	la $a0, ($t8) #loads year
	li $v0, 1 # v0 holds 4 for sycall 
	syscall # syscall 4(output) executes
	la $a0, newLine #loads to print new line
     	li $v0, 4 # v0 holds 4 for sycall 
     	syscall# syscall 4(output) executes
	jr $ra # if not then go to main	
###########################################################################################
#	Function: SeasonCal 
#This function calulates the date and time of each season that occur in the year 
#that the use specified. 
# 	Input: User inputed year
# 	Output: Day of when each season starts in the year
#	$s1 holds year
#	$s0 calculated day
#	$s7 holds leapyear check
############################################################################################
	.data
LeapDays:	.word 366
NormDays:	.word 365
RefYear:	.word 1970 
RefSpDay:	.word 79
RefSpHour:	.word 18
RefSpMin:	.word 57
RefSuDay:	.word 172
RefSuHour:	.word 14
RefSuMin:	.word 43
RefFaDay:	.word 266
RefFaHour:	.word 6
RefFaMin:	.word 0
RefWiDay:	.word 356
RefWiHour:	.word 0
RefWiMin:	.word 36
JulianArray:.word 0,0,0,0,0,0,0,0
	.text
SeasonCal:	addi $sp,$sp,-8 #allocates space on stack 
	sw $ra,0($sp) #store first return adress
	la $a0,RefYear # $a0 holds the Refrence year adress to the word
	lw $t0,($a0) #$t0 holds the refrence year (1970)
	sub $t1,$s1,$t0 #$t1(delta) = Requested Year - Refrence year gives years in between
	abs $t1, $t1 # get aboslute value of $s7
	add $s6, $t1, $zero #$s6 holds copy of delta
	addi $t2, $s1, 0 # $t2 holds a copy of requested year
	add $t3, $zero, $zero #$t3 holds NumberofLeapYears
	add $s5, $zero, $zero #$s5 (loopcount) = 0
	move $t0,$s1 #moves refrence year to s1 to check if leap 
LeapYearStart:blt $s5, $t1, LeapYearLoop # if loopcount < $t1(delta) then do the loop
	j ActualDayCal #if not jump to ActualDay
LeapYearLoop:add $s7 ,$zero,$zero #$s7 holds 1 if leap or 0 if not
	addi $s5, $s5, 1 #$s5 loopCount = ++1
	jal leapYear # sends year to leapyear function	
LoopCheck:	beq $s7,1,IncreaseLeap	#if year is leap then $s7 holds 1
	addi $s1, $t0, 1 #if not then: Refrence year + 1
	j LeapYearStart #jump back to start of loop 
IncreaseLeap:addi $t3,$zero,1 # NumberofLeapYears++
	addi $s1, $t0, 1 # Refrence year + 1
	j LeapYearStart #go back to start of loop
ActualDayCal:la $a0,LeapDays #a0 holds the address to leapdays word 
	lw $t4, ($a0) #$t4 holds 366
	mul $t5,$t3,$t4 # $t5 = NumberofLeapYears * 366 
	la $a0, NormDays #a0 holds the address to Normdays word
	lw $t4, ($a0) #t4 holds now 365
	sub $t7 , $t1, $t3 #t7 = Delta - NumberofLeapYears
	mul $t6, $t4,$t7 #t6 holds $t7(Delta - NumberofLeapYears)*365
 	add $t4, $t6, $t5 #t4 = NumberofLeapYear(366) + (Delta - NumberofLeapYears)(365)
OverFlowDays:la $a0, NormDays #a0 holds the address to Normdays word
	lw $t5, ($a0) #t5 holds now 365
	abs $t1, $t1 #absolute value of $t1
	mul $t5, $t5,$t1 #$t5 = Delta * 365
	sw $t4 4($sp)
FinalDaySpring:la $a0, RefSpDay #a0 holds the address of Refrence Spring Day
	lw $t6, ($a0) #$t6 = 79
	lw $t4, 4($sp)
	sub $s0,$t5,$t4 #s0(finalday) = $t5(NumberofLeapYears * 366) - $t4(NumberofLeapYear(366) + (Delta - NumberofLeapYears)(365))
	add $s0, $s0, $t6 #$s0 = $s0 + t6(79) refrence day 
	move $s1,$t2 #s1 now holds the requested year again 
	jal TimeCalSpring #Jumps to TimeCalSpring
FinalDaySummer:la $a0, RefSuDay #a0 holds the address of Refrence Summer Day
	lw $t6, ($a0) #$t6 = 172
	lw $t4, 4($sp)
	sub $s0,$t5,$t4 #s0(finalday) = $t5(delta -NumberofLeapYears * 365) - $t4(NumberofLeapYear(366) + (Delta - NumberofLeapYears)(365))
	add $s0, $s0, $t6 #$s0 = $s0 + t6(79) refrence day 
	move $s1,$t2 #s1 now holds the requested year again 
	jal TimeCalSummer #Jumps to TimeCalSpring
FinalDayFall:la $a0, RefFaDay #a0 holds the address of Refrence Summer Day
	lw $t6, ($a0) #$t6 = 172
	lw $t4, 4($sp)
	sub $s0,$t5,$t4 #s0(finalday) = $t5(NumberofLeapYears * 366) - $t4(NumberofLeapYear(366) + (Delta - NumberofLeapYears)(365))
	add $s0, $s0, $t6 #$s0 = $s0 + t6(79) refrence day 
	move $s1,$t2 #s1 now holds the requested year again 
	jal TimeCalFall #Jumps to TimeCalSpring
FinalDayWinter:la $a0, RefWiDay #a0 holds the address of Refrence Summer Day
	lw $t6, ($a0) #$t6 = 172
	lw $t4, 4($sp)
	sub $s0,$t5,$t4 #s0(finalday) = $t5(NumberofLeapYears * 366) - $t4(NumberofLeapYear(366) + (Delta - NumberofLeapYears)(365))
	add $s0, $s0, $t6 #$s0 = $s0 + t6(79) refrence day 
	move $s1,$t2 #s1 now holds the requested year again 
	jal TimeCalWinter #Jumps to TimeCalSpring
	lw $ra,0($sp) #load adress back 
	addi $sp, $sp, 8 # pop the stack 
	jr $ra
TimeCalSpring:addi $sp,$sp,-4 #allocates space on stack 
	sw $ra,($sp) #store first return adress
	la $a0,RefSpHour # $a0 holds the Refrence hour adress to the word
	lw $s5,($a0) # $s5 holds the Refrence time for spring
	addi $t4, $zero, 5 #t4 = 5 
	mul $t3, $s6, $t4 # $t3 = Delta * 5
	abs $t3, $t3 # sets the absolute value of hour 
	add $s5, $s5, $t3 # $s5 = refrence hour + (Delta*5)
Hcheck:	bge $s5,24,HOverflow #if(hour >= 24) then go to overflow 
	j Min #if not jump to min
HOverflow:	addi $s5, $s5, -24 # hour = hour - 24
	addi $s0,$s0, 1 # day = day+1
	j Hcheck	# jump to hour check
Min:	la $a0,RefSpMin # $a0 holds the Refrence hour adress to the word
	lw $s4, ($a0) # s4 holds the refrence min 
	addi $t4, $zero, 50 #t4 = 50 
	mul $t3, $s6, $t4 # $t3 = Delta * 50
	abs $t3, $t3 # sets the absolute value of min
	add $s4, $s4, $t3 # $s4 = refrence min + (Delta*50)
Mcheck:	bge $s4, 60, MOverflow #if(min >= 60) then go to overflow 
	j out #if not jump to hourconvert 
MOverflow:	addi $s4, $s4, -60 # min = min -60
	addi $s5, $s5, 1 # hour = hour+1
	j Mcheck #jump to Min Check
out:	sw $s0,0($gp)#stores season julian in t9
	lw $ra,($sp) #load adress back 
	addi $sp, $sp, 4 # pop the stack 
	jr $ra # if not then go to main
#####################################################################################################
TimeCalSummer:addi $sp,$sp,-4 #allocates space on stack 
	sw $ra,($sp) #store first return adress
	la $a0,RefSuHour # $a0 holds the Refrence hour adress to the word
	lw $s5,($a0) # $s5 holds the Refrence time for spring
	addi $t4, $zero, 5 #t4 = 5 
	mul $t3, $s6, $t4 # $t3 = Delta * 5
	abs $t3, $t3 # sets the absolute value of min
	add $s5, $s5, $t3 # $s5 = refrence hour + (Delta*5)
sHcheck:	bge $s5,24,sHOverflow #if(hour >= 24) then go to overflow 
	j sMin #if not jump to min
sHOverflow:	addi $s5, $s5, -24 # hour = hour - 24
	addi $s0,$s0, 1 # day = day+1
	j sHcheck	# jump to hour check
sMin:	la $a0,RefSuMin # $a0 holds the Refrence hour adress to the word
	lw $s4, ($a0) # s4 holds the refrence min 
	addi $t4, $zero, 50 #t4 = 50 
	mul $t3, $s6, $t4 # $t3 = Delta * 50
	abs $t3, $t3 # sets the absolute value of min
	add $s4, $s4, $t3 # $s4 = refrence min + (Delta*50)
sMcheck:	bge $s4, 60, sMOverflow #if(hour >= 60) then go to overflow 
	j sout #if not jump to output 
sMOverflow:	addi $s4, $s4, -60 # min = min -60
	addi $s5, $s5, 1 # hour = hour+1
	j sMcheck #jump to Min Check
sout:	sw $s0,4($gp)#stores season julian in t9
	lw $ra,($sp) #load adress back 
	addi $sp, $sp, 4 # pop the stack 
	jr $ra # if not then go to main
TimeCalFall:addi $sp,$sp,-4 #allocates space on stack 
	sw $ra,($sp) #store first return adress
	la $a0,RefFaHour # $a0 holds the Refrence hour adress to the word
	lw $s5,($a0) # $s5 holds the Refrence time for spring
	addi $t4, $zero, 5 #t4 = 5 
	mul $t3, $s6, $t4 # $t3 = Delta * 5
	abs $t3, $t3 # sets the absolute value of min
	add $s5, $s5, $t3 # $s5 = refrence hour + (Delta*5)
fHcheck:	bge $s5,24,fHOverflow #if(hour >= 24) then go to overflow 
	j fMin #if not jump to min
fHOverflow:addi $s5, $s5, -24 # hour = hour - 24
	addi $s0,$s0, 1 # day = day+1
	j fHcheck	# jump to hour check
fMin:	la $a0,RefFaMin # $a0 holds the Refrence hour adress to the word
	lw $s4, ($a0) # s4 holds the refrence min 
	addi $t4, $zero, 50 #t4 = 50 
	mul $t3, $s6, $t4 # $t3 = Delta * 50
	abs $t3, $t3 # sets the absolute value of min
	add $s4, $s4, $t3 # $s4 = refrence min + (Delta*50)
fMcheck:	bge $s4, 60, fMOverflow #if(hour >= 60) then go to overflow 
	j fout #if not jump to output 
fMOverflow:addi $s4, $s4, -60 # min = min -60
	addi $s5, $s5, 1 # hour = hour+1
	j fMcheck #jump to Min Check
fout:	sw $s0,8($gp)#stores season julian in t9
	lw $ra,($sp) #load adress back 
	addi $sp, $sp, 4 # pop the stack 
	jr $ra # if not then go to main
TimeCalWinter:addi $sp,$sp,-4 #allocates space on stack 
	sw $ra,($sp) #store first return adress
	la $a0,RefWiHour # $a0 holds the Refrence hour adress to the word
	lw $s5,($a0) # $s5 holds the Refrence time for spring
	addi $t4, $zero, 5 #t4 = 5 
	mul $t3, $s6, $t4 # $t3 = Delta * 5
	abs $t3, $t3 # sets the absolute value of min
	add $s5, $s5, $t3 # $s5 = refrence hour + (Delta*5)
wHcheck:	bge $s5,24,wHOverflow #if(hour >= 24) then go to overflow 
	j wMin #if not jump to min
wHOverflow:	addi $s5, $s5, -24 # hour = hour - 24
	addi $s0,$s0, 1 # day = day+1
	j wHcheck	# jump to hour check
wMin:	la $a0,RefWiMin # $a0 holds the Refrence hour adress to the word
	lw $s4, ($a0) # s4 holds the refrence min 
	addi $t4, $zero, 50 #t4 = 50 
	mul $t3, $s6, $t4 # $t3 = Delta * 50
	abs $t3, $t3 # sets the absolute value of min
	add $s4, $s4, $t3 # $s4 = refrence min + (Delta*50)
wMcheck:	bge $s4, 60, wMOverflow #if(hour >= 60) then go to overflow 
	j wout #if not jump to output 
wMOverflow:addi $s4, $s4, -60 # min = min -60
	addi $s5, $s5, 1 # hour = hour+1
	j wMcheck #jump to Min Check
wout:	sw $s0,12($gp)#stores season julian in t9
	lw $ra,($sp) #load adress back 
	addi $sp, $sp, 4 # pop the stack 
	jr $ra # if not then go to main
