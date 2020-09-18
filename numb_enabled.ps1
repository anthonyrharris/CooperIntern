<##########################################
Written by: Tony Harris
Task: Gets the number of enabled users in a desired OU or set of OUs
Completed: 8/06/19
##########################################>
# clears any unwanted text
Clear-Host

#.spacer.#
# gets the users for the location where their objects enable property is equal to true
$rennes = Get-ADUser -SearchBase "OU=Rennes,OU=CSAFR,DC=csaid,DC=cooperintra,DC=ctb" -Filter * -Server "csaid.cooperintra.ctb"  | Where-Object { $_.Enabled -eq "true" }
$rennes_numb = 0
# little loop to count the number of enabled users and then prints the total
foreach($enabled in $rennes){
    $rennes_numb += 1
}
write-host "There are",$rennes_numb,"users enabled in rennes."

#.spacer.#
# gets the users for the location where their objects enable property is equal to true
$aub = Get-ADUser -SearchBase "OU=Auburn Plant,DC=auto,DC=cooperintra,DC=ctb" -Filter * -Server "auto.cooperintra.ctb"  | Where-Object { $_.Enabled -eq "true" }
$aub_numb = 0
# little loop to count the number of enabled users and then prints the total
foreach($enabled in $aub){
    $aub_numb += 1
}
write-host "There are",$aub_numb,"users enabled in auburn."

#.spacer.#
# gets the users for the location where their objects enable property is equal to true
$mitchell = Get-ADUser -SearchBase "OU=Mitchell,DC=auto,DC=cooperintra,DC=ctb" -Filter * -Server "auto.cooperintra.ctb"  | Where-Object { $_.Enabled -eq "true" }
$mitchell_numb = 0
# little loop to count the number of enabled users and then prints the total
foreach($enabled in $mitchell){
    $mitchell_numb += 1
}
write-host "There are",$mitchell_numb,"users enabled in mitchell."

# in order to get the -SearchBase parameters do something like: Get-ADOrganizationalUnit -Filter * -server "csaid.cooperintra.ctb" | Where-Object { $_.Name -Like "Renne" }
#                                               From this you just change the: -server parameter and the very last item in quotes... in this case Renne to get a different OU.