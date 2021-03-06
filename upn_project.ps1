﻿#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@
#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@

<#
Created by Tony Harris
Completed on: 3/25/2019
To operate: Just run this script and follow the on-screen prompts located in the console.
#>

#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@
#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# these store the file paths in the program. Can be changed here to be easier than changing all individually.

# these create all of the necessary files needed that the script will use (located on the desktop)
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "UPN" -ItemType "directory" -ErrorAction SilentlyContinue
New-Item -Path "C:\Users\$env:UserName\Desktop\UPN\" -Name "comparing_the_emails_Avail_NoAvail" -ItemType "directory" -ErrorAction SilentlyContinue
#New-Item -Path "C:\Users\$env:UserName\Desktop\UPN\" -Name "emails-and-login_compare" -ItemType "directory" -ErrorAction SilentlyContinue
New-Item -Path "C:\Users\$env:UserName\Desktop\UPN\" -Name "all_usernames" -ItemType "directory" -ErrorAction SilentlyContinue
New-Item -Path "C:\Users\$env:UserName\Desktop\UPN\" -Name "all_emails" -ItemType "directory" -ErrorAction SilentlyContinue

# these six are the locations used
$current_emails_file = "C:\Users\$env:UserName\Desktop\UPN\all_emails\Current_emails-that-exist.txt"
$fl_generated_file = "C:\Users\$env:UserName\Desktop\UPN\all_emails\firstName_lastName-Emails-Generated.txt"
#$comparing_emails_and_logons_file = "C:\Users\$env:UserName\Desktop\UPN\emails-and-login_compare\emails-and-login_compare.txt"
$all_users_file = "C:\Users\$env:UserName\Desktop\UPN\all_usernames\all_usernames.txt"
$Conflicts_to_fix_file = "C:\Users\$env:UserName\Desktop\UPN\Conflicts_to_fix.txt"
$available_emails_file = "C:\Users\$env:UserName\Desktop\UPN\comparing_the_emails_Avail_NoAvail\firstLastEmailAvailable.txt"
$non_available_emails_file = "C:\Users\$env:UserName\Desktop\UPN\comparing_the_emails_Avail_NoAvail\firstLastEmailNotAvailable.txt"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function mainScript(){

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
<#
Section currentEmails_and_first.last_emails
The purpose of this Section is to generate a list of all of the current user account emails in each of the domains. 
As long as the email field for each user is not empty and it is @cooperstandard.com then their email will be displayed.

The other purpose of this function is to generate a list of emails using users first and last name. As long as the email field for each user is not empty, it is @cooperstandard.com, 
and they are a contractor/hourly/or salary then their email will be displayed.
#>
Write-Host "----------------------------------------"
            
# File handling
Remove-Item $current_emails_file -ErrorAction SilentlyContinue
Remove-Item $fl_generated_file -ErrorAction SilentlyContinue
#Remove-Item $comparing_emails_and_logons_file -ErrorAction SilentlyContinue
Remove-Item $all_users_file -ErrorAction SilentlyContinue

# instantiating objects for writing to files
$current_emails_sw = New-Object System.IO.StreamWriter $current_emails_file #current user emaoile

$fl_generated_sw = New-Object System.IO.StreamWriter $fl_generated_file # user emails that are generated by using the first.lastname constructor

#$comparing_emails_and_logons_sw = New-Object System.IO.StreamWriter $comparing_emails_and_logons_file, $true

$all_users_sw = New-Object System.IO.StreamWriter $all_users_file #all_usernames_from_emails = pre @ symbol

$count1 = 0 
$count2 = 0

# for loop encapsulates basically all of the function this is important so each of the domains are searced for all of their user accounts 
for($i = 0; $i -ne 3; $i++){
    if($i -eq 0)
    {
        #This gets all of the users based on the supplied parameters
        $allMailProperties = Get-ADUser -SearchBase "DC=auto,DC=cooperintra,DC=ctb" -Filter *  -Properties mail,employeeType  -Server "auto.cooperintra.ctb" | Where-Object{($null -ne $_.mail) -AND ($_.mail -like "*cooperstandard.com")}
        
        # each of the three calls to find_nonMatchings will find all of the accounts whose pre @ symbol in their email dont match their login info
        $non_matching += find_nonMatchings $allMailProperties
    }
    elseif($i -eq 1)
    {
        $allMailProperties = Get-ADUser -SearchBase "DC=asia,DC=cooperintra,DC=ctb" -Filter *  -Properties mail,employeeType  -Server "asia.cooperintra.ctb" | Where-Object{($null -ne $_.mail) -AND ($_.mail -like "*cooperstandard.com")}
        $non_matching += find_nonMatchings $allMailProperties
    }
    elseif($i -eq 2)
    {
        $allMailProperties = Get-ADUser -SearchBase "DC=csaid,DC=cooperintra,DC=ctb" -Filter *  -Properties mail,employeeType  -Server "csaid.cooperintra.ctb" | Where-Object{($null -ne $_.mail) -AND ($_.mail -like "*cooperstandard.com")}
        $non_matching += find_nonMatchings $allMailProperties
    }
    
    
    
    # Used to loop through each of the objects in $allMailProperties
    ForEach($userProperties in $allMailProperties){
        
        # must pass these checks to be stored
        if(($userProperties.employeeType -eq "contractor") -or ($userProperties.employeeType -eq "hourly") -or ($userProperties.employeeType -eq "salary")){

            # used to get each user's email
            $userEmail = $userProperties | Select-Object -ExpandProperty "mail"
            # writes the email to the file
            $current_emails_sw.WriteLine($userEmail)

            $count1++
        }
        # used to store the GivenName property
        $givenName = $userProperties | Select-Object -ExpandProperty "GivenName" 

        # used to store the surname property
        $surname = $userProperties | Select-Object -ExpandProperty "surname" 

        # Makes sure the givenname field is not null, the surname is not null, and they belong to either the contractor / hourly / or salary sub-OU
        if(($null -ne $givenName) -AND ($null -ne $surname) -AND (($userProperties.employeeType -eq "contractor") -or ($userProperties.employeeType -eq "hourly") -or ($userProperties.employeeType -eq "salary"))){
            
            #Generating and writing the email to a file        
            $fullnameSpaces = "$givenName.$surname@cooperstandard.com"
            $fullnameFinal = $fullnameSpaces.replace(" ","")
            $fl_generated_sw.WriteLine($fullnameFinal)
                    
            $count2++
        }
        # checks for cases where all important data isnt filled in and tells tou to fix them. $i is the number of the for loop at the beinning to specify which domain the user is located in
        elseif(($null -eq $givenName) -AND ($null -ne $surname) -AND (($userProperties.employeeType -eq "contractor") -or ($userProperties.employeeType -eq "hourly") -or ($userProperties.employeeType -eq "salary"))){

            Write-Host "The email $userEmail was entered into the system with a surname but no givenName. Please fix them...$i"
            
        }
        #checks for cases where all important data isnt filled in and tells tou to fix them. $i is the number of the for loop at the beinning to specify which domain the user is located in
        elseif(($null -ne $givenName) -AND ($null -eq $surname) -AND (($userProperties.employeeType -eq "contractor") -or ($userProperties.employeeType -eq "hourly") -or ($userProperties.employeeType -eq "salary"))){
            
            Write-Host "The email $userEmail was entered into the system with a givenName but no surname. Please fix them..$i"
            
        }   
    }
    }
    #$comparing_emails_and_logons_sw.close()
    # Handy data
    Write-Host "$count1 emails in Current_emails-that-exist.txt"
    Write-Host "$count2 emails in firstName_lastName-Emails-Generated"


    # calls conflicts passing the now compiled list of accounts that have issues that were returned from find_nonMatchings
    conflicts $non_matching

    # closes objects
    $current_emails_sw.close()
    $fl_generated_sw.close()
    $all_users_sw.close()
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    <#
    This section (part of the previous) is used to compare the the current emails being used and the firstName.lastName emails that have been generated up above. The firstName.lastName emails are based on their first and last names in AD.
    #>

    $count = 0
    # file handling
    Remove-Item $available_emails_file -ErrorAction SilentlyContinue
    Remove-Item $non_available_emails_file -ErrorAction SilentlyContinue

    # instantiating objects for writing to files
    $available_emails_sw = New-Object System.IO.StreamWriter $available_emails_file
    $non_available_emails_sw = New-Object System.IO.StreamWriter $non_available_emails_file

    # gets the file content
    $currentEmails = Get-Content $current_emails_file #the list of the currently used emails
    $firstLastEmails = Get-Content $fl_generated_file #the emails generated by firstName.lastName@cooperstandard.com

    #compares the two generated files to see what first.lat emails can and can't be used
    $objects = Compare-Object -ReferenceObject $currentEmails -DifferenceObject $firstLastEmails -IncludeEqual

    # each email that is being compared
    ForEach($object in $objects){
        
        #Gathers data used in the if statements
        $i = $object | Select-Object -ExpandProperty SideIndicator #shows you where the object is located
        $email = $object | Select-Object -ExpandProperty InputObject #email of each object

        #this means that the emails are in the current user list and the file I generated up above, thus there should not be an attempt to create these emails
        if($i -eq "=="){
            $count++
            $non_available_emails_sw.WriteLine("$email") # - is already is in use! Do not attempt to create this!
        }

        #these are the emails that are only in the file that I generated therefore they are good to be created
        elseif($i -eq "=>"){
            
            $available_emails_sw.WriteLine("$email")# - is not in use. You can create this if you'd like!
        }

        #these emails are only located in the current email list, thus it is not needed
        elseif($i -eq "<="){
            #can be used to print if needed
        }
    }
    #closes objects
    $available_emails_sw.close()
    $non_available_emails_sw.close()
    Write-Host "$count current emails use the first.Last convention."
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
}

function singleEmail{
#-------------------------------------------------------------------------------------------------------------------------#
Write-Host "----------------------------------------"

#enter your desired email to check
$desiredEmail_temp = Read-Host "Enter the email you would like to check to see if is already in use (just enter the first.lastname)! If you would like to return to the main slection enter 'go back'."
$desiredEmail = $desiredEmail_temp+"@cooperstandard.com"

Write-Host "----------------------------------------"

#searches files generated in main for desired email
$contains = Select-String -Path $non_available_emails_file -Pattern "^$desiredEmail`$"
$leave = $desiredEmail | Select-String -Pattern "go back"
    #this means that the email is located in the list of emails not available and should not be used.
    if($contains){
        Write-Host "$desiredEmail,This email is in use try something else!"
        # re-calls the function to try again
        singleEmail
    }
    elseif($leave){
        # used if 'go back' is entered so that the user may return to the main selection. 'dummy' is a function that does nothing
        dummy
    }
    else{
        #if this is displayed to the console then that means the email can be used if you want.
        Write-Host "$desiredEmail,This email is not in use! If you decide to use this make sure to rerun the 'main' function!"
        }
#-------------------------------------------------------------------------------------------------------------------------#
#>
}

function find_nonMatchings($ADUsers){

    $non_matches = @()

    #Used to loop through each of the objects in $allMailProperties
    foreach($userProperties in $ADUsers){
        # desired account types are checked
        if(($userProperties.employeeType -eq "contractor") -or ($userProperties.employeeType -eq "hourly") -or ($userProperties.employeeType -eq "salary")){

            #Gets the pre @ symbol of the user's emails
            $userEmail_pre_symbol_temp  = $userProperties | Select-Object -ExpandProperty "mail"
            $userEmail_pre_symbol, $location = $userEmail_pre_symbol_temp.split("@")
            $logonName = $userProperties | Select-Object -ExpandProperty "SamAccountName"

            # writes the data to the file
            $all_users_sw.WriteLine($logonName)

            # checks pre @s to see if they contain a perion
            $contains_period = $userEmail_pre_symbol.Contains(".")
            # if not then they are...
            if(!($contains_period)){
                $email_ = $userEmail_pre_symbol.toLower()
                $username_ = $logonName.toLower()
                # ... checked to see if they are not equal to the username of the account
                if($email_ -ne $username_){
                    #$comparing_emails_and_logons_sw.WriteLine("Email-----$email_----- Username------$username_")

                    # added to the array of non matching pre @s and usernames
                    $non_matches += $userProperties
                }
            }
        }
    }
    # array is returned
    return $non_matches
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

function conflicts($non_matchings){
    
    # file writer object
    $conflicts_to_fix_sw = New-Object System.IO.StreamWriter $Conflicts_to_fix_file

    # obtains the file containing the list of all pre @ names
    $all_users_file_data = Get-Content $all_users_file
    
    # loop through all of the aduser objects that are recieved by the parameter
    foreach($non_match_properties in $non_matchings){
    
        # obtains the parameters emails and makes it all lower case
        $non_match_email_ = $non_match_properties | Select-Object -ExpandProperty "mail"
        $non_match_email = $non_match_email_.toLower()

        # obtains the parameters login names and makes it all lower case
        $non_match_username_ = $non_match_properties | Select-Object -ExpandProperty "SamAccountName"
        $non_match_username = $non_match_username_.toLower()

        # now re-gets the pre @ symbol - I need to re-get this because I needed to pass the AD objects to this function so that I could get all of the user objects without having to reget them
        $non_match_pre_symbol_temp, $location = $non_match_email_.split("@")
        $non_match_pre_symbol = $non_match_pre_symbol_temp.toLower()
        
        # checks the data in the list of all usernames to see if the non-matching pre @ symbol name is currently being used y another account
        if($all_users_file_data -Contains $non_match_pre_symbol){
            
            # searches for the user counts that do use the pre @ symbol as a username
            $conflicting_account_auto = Get-Aduser -Filter "SamAccountName -eq '$non_match_pre_symbol'" -Properties mail -Server "auto.cooperintra.ctb"

            # means there is one
            if($null -ne $conflicting_account_auto){
                # the email of the username that matches
                $user_email_ = $conflicting_account_auto | Select-Object -ExpandProperty "mail"
                # found an account that did not have an email - so those arent needed
                if($null -ne $user_email_ ){

                    # makes email lowercase
                    $user_email = $user_email_.toLower()

                    # username of the account that has the same name as a pre @ symbol of an email
                    $logon_name = $conflicting_account_auto | Select-Object -ExpandProperty "SamAccountName"

                    # checks to see that they are in fact equal - at this point they chould be
                    if($non_match_pre_symbol -eq $logon_name){
                        $conflicts_to_fix_sw.WriteLine("User with the Email = $user_email and login name = $logon_name ---------- Conflicts with other email = $non_match_email and username = $non_match_username")
                    }
                    # this should not occur it was used for testing
                    else{
                        Write-Host "An Error has occured"
                    }
                }
            }
        <#
        This section is the exact same as the auto section but is for asia
        #>    

        $conflicting_account_asia = Get-Aduser -Filter "SamAccountName -eq '$non_match_pre_symbol'" -Properties mail -Server "asia.cooperintra.ctb"

        if($null -ne $conflicting_account_asia){

                $user_email_ = $conflicting_account_asia | Select-Object -ExpandProperty "mail"
                if($null -ne $user_email_ ){

                    $user_email = $user_email_.toLower()
                    $logon_name = $conflicting_account_asia | Select-Object -ExpandProperty "SamAccountName"

                    if($non_match_pre_symbol -eq $logon_name){
                        $conflicts_to_fix_sw.WriteLine("User with the Email = $user_email and login name = $logon_name ---------- Conflicts with other email = $non_match_email and username = $non_match_username")
                    }
                    else{
                        Write-Host "An Error has occured"
                    }
                }
            }
        <#
        This section is the exact same as the auto and asia sections but is for csaid
        #>     

        $conflicting_account_csaid = Get-Aduser -Filter "SamAccountName -eq '$non_match_pre_symbol'" -Properties mail -Server "csaid.cooperintra.ctb"

        if($null -ne $conflicting_account_csaid){

                $user_email_ = $conflicting_account_csaid | Select-Object -ExpandProperty "mail"
                if($null -ne $user_email_ ){

                    $user_email = $user_email_.toLower()
                    $logon_name = $conflicting_account_csaid | Select-Object -ExpandProperty "SamAccountName"

                    if($non_match_pre_symbol -eq $logon_name){
                        $conflicts_to_fix_sw.WriteLine("User with the Email = $user_email and login name = $logon_name ---------- Conflicts with other email = $non_match_email and username = $non_match_username")
                    }
                    else{
                        Write-Host "An Error has occured"
                    }
                }
            }
        }
    }
    # closes the file writer object
    $conflicts_to_fix_sw.close()
}

function dummy(){}

# decides what you want to do. This is what controls the entire script
$main = "main"
$singleEmail = "1"
$exit = "x"

# this do while is the control logic
do{
# displays to the user what their options are
Write-Host "----------------------------------------"
Write-Host "There are three choices based on your input:"
Write-Host "You can enter the main script to generate all of the necessary files by typing: 'main' followed by pressing the enter button." 
Write-Host "You can enter the function dedicated to checking one email to see if it exists (note must have previously ran main to have necessary files). Simply enter: '1' followed by pressing the enter button." 
Write-Host "Lastly you can type: 'x' followed by pressing the enter button to exit the program." 
Write-Host "----------------------------------------"

# user enters a keyword to choose what they want to do
$input = Read-Host 

# goes to mainScript function
if($input -eq $main){
    mainScript
}
# goes to singleEmail function
elseif($input -eq $singleEmail){
    singleEmail
}
elseif($input -eq $exit){
    exit
}
#if something unknown is entered
else{
    Write-Host "Unknown input entered, please try again." 
    Write-Host "----------------------------------------"
}

# this basically works by continuing to loop indefinitely until $input -eq $exit because $input is never actually reassigned
}while(($input -ne $main) -OR ($input -ne $singleEmail) -OR ($input -ne $exit));
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#