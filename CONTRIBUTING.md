## How to contribute to:
Thank you for Contributing to the StationFinder project.\
Here's how to do it:
1. Gather data from Navy Lists
2. To add ship data, you need to create a csv-File named "newshipdata.csv" with the following columns:\
  Label	P_ID	S_ID	Station	Von	Bis	Displacement	Hull	Propulsion	Lat	Long	ColVal
  * In Label, the name of the ship is given.
  * P_ID defines the commanding officer of the ship
  * S_ID defines the ship ID (new ships start with S89)
  * Station defines the Region, in which the ship is stationed
  * Von defines the start of the deployment (year only)
  * Bis defines the end of the deployment (year only)
  * Displacement defines the displacement of the ship (in Builder's Measurement)
  * Hull defines the Hull of the ship
  * Propulsion defines the method of propulsion
  * Lat defines the latitude of the station
  * Long defines the longitude of the station
  * ColVal defines the color for the bubbles (the colors follow this schema:)

3. To add officer data, you need to create a csv-File named "newoffdata.csv" with the following columns:\
  P_ID	Vorname	Nachname	Label
  * P_ID is the ID for ship.csv (new officers start with 16)
  * Vorname defines the surname of the officer
  * Nachname defines the last name of the officer
  * Label defines the combined name of the officer

4. Finally, send the files to sfprojectws2018@googlemail.com. I will then add the data to the existing tables.
 Thanks :)
