# Computer-Architecture-Mips-Final-Project
Final Project Report
Problem:
For the Final Project it is required of us to basically combine all other previous programs
to form a super program that is able to take in a year inputted by the user. With this year our
program must output every full moon that occurs in that year but also output weather a full moon
is a blue moon monthly and or if a seasonal blue moon occurs as well. The most complicated
part of this program is the need to calculate seasonal moons. This uses the leap year function to
determine if a year is leap in accounting for the extra julian date. Also the julian date conversion
program to output the Day,Month and Year of that julian date and finally the full moon program
that outputs every full moon of a requested year. I choose my reference year of 1970 so my
program only performs calculations on years equal or greater than 1970.
Approach:
Since my fullmoon program built the framework in order to calculate full moons and
implementing my julian date program with the leap year. I was able to keep that framework
basically intact. The main change that I did make was with my season calculator program.
Instead of outputting the individual date and time for each season, I kept that information hidden
to the user and just stored the julian date of each season into an array. These julian date are
obtained in the beginning of the program since seasoncal is the first function that is called.
SeasonCal function first finds the amount of years in between the reference year and the
requested year. This is used to run a loop from the reference year to the requested year. The
loop sends each year into the leapyear function and increments a counter if the year is a loop
year. Once this number is found then it's multiplied by 366(numberofleapyears * 366) this is
added with the number of non leap years multiplied by 365 (Non-leap years *365). So this gives
us actual days = (#ofleapyears * 366) + (#ofNon-leap years *365). Then the number of years in
between is multiplied by 365 (delta * 365). Finally (delta*365) is subtracted from Actual days (
(#ofleapyears * 366) + (#ofNon-leap years *365). This value is added to the reference julian
date that is loaded from memory. This julian date is then sent to the functions I defined in
program 4. This process is done for each reference julian date. The hour is calculated with the
reference number of the season added by delta multiplied by 5 (delta*5). The min is calculated
the same way by loading the reference number for min and adding by delta multiplied by 50
(delta*50). Once these numbers are added and corrected for overflow and converted to 12 hour
clock time then all values are outputted for each individual season.
With seasoncal calculating the julian dates for each season completed it then goes into
the FullMooncal function. In order to calculate the monthly and seasonal bluemoons, I decided
that it was best to split the functionality into two different functions. One calculated the monthly
blue moons and the other calculated seasonal blue moons.
The easiest one to calculate is the monthly bluemoons. For this function I load the
previouses moon index value and then with the julian date of the current fullmoon I calculate themonth of which the julian date is in. If both those months are the same then it returns a 1 if not
then it returns a 0. The pseudocode looks like this:
boolean BlueMonthCal(int prevMonthIndex, int curJulianDate){
if(leapyear(){
for(int i = 0; i < leapYearArray.length; i++){
if(curJulianDate< leapYeaArray[i]){
if((leapYearArray[i]-1) == prevMonthIndex){
return true;
}
else
return false;}
}
else
for(int i = 0; i < YearArray.length; i++){
if(curJulianDate< lYeaArray[i]){
if((YearArray[i] -1_== prevMonthIndex){
return true;
}
else
return false;
}
}
For the BlueSeasonalMoon function it required a bit more calculations and registers to
keep track of. First before the function is called inside my fullmoon function I set 4 counters set
to zero. One counter for each season. Then during the calculation of fullmoon I send the julian
date into my BlueSeasonalMoon function after going into the bluemoonth function. Once inside
the blue seasonal function. It is here where i compare the julian date of the full moon to find the
correct season that it belongs to. If it's greater than or equal to the start of spring and less than
the start of summer then it must be in spring. This same logic is continued for the rest of the
season. So if the julian date is found to be in a season the counter for that specific season is
increased. Once the counter reaches 3 then that julian date of the full moon is stored into an
array because we will need it in order to identify the full moon that is considered the blue
seasonal moon. Once the counter reaches 4 it is then that we jump into another if statement
that goes ahead and calls the output function to print to the user that that full moon is the
seasonal blue moon of that corresponding season. The pseudo code looks as follows:
void BlueSeasonCal(){
if(JD >=79 && JD < 172){
springMoon++;
if(springMoon ==3){
JD = BMSP;}
if(springMoon ==4){
Output: Seasonal Blue Moon:
}}
if(JD >= 172 && JD < 266){
summerMoon++;
if(summerMoon == 3){
JD = BMSU;}
if(summerMoon ==4){
Output: Seasonal Blue Moon:
}
}
if(JD >= 226 && JD < 356){
fallMoon++;
if(fallMoon == 3){
JD = BMFL;}
if(fallMoon ==4){
Output: Seasonal Blue Moon:
}
}
if(JD >= 356 || JD < 79){
winterMoon++;
if(winterMoon == 3){
JD = BMWI;}
if(winterMoon ==4){
Output: Seasonal Blue Moon:
}
}
Finally the process is complete. These functions are called within the FullMoonCalculator
function. The function is based on loops. To find the next full moon we increment 29 days, 12
hours and 43 minutes and adjust for overflow. This is done until the reference year is equal to
the requested year. The leap year function is also used in determining the correct amount of
days to subtract depending if that year is a leap year or not. Once The RefYear is equal to
requested Year the algorithm for output is essentially the same in incrementing to output all full
moons until the year is passed. However the dates and times calculated to accumulate an error
offset the further the requested year is from the reference year. The finale pseudo code is as
follows including the function calls for monthly and seasonal full moons and output.
pseudo code:
springMoon=0;
summerMoon=0;
fallMoon=0;
winterMoon=0;
while(RefYear < ReqYear){
RefDay += 29;
RefHour += 12;
RefMin +=43;if(RefMin >= 60){
RefMin -= 60;
RefHour++;}
if(RefHour >= 24){
RefHour -=24;
RefDay++;}
if(RefYear is leapyear && RefDay > 366){
RefYear++;
RefDay -= 366;}
else if (RefDay > 365){
RefYear++;
RefDay-=365;}
MonthBlueMoon(RefDay);
SeasonalBlueMoon(RefDay);
Output();
}
