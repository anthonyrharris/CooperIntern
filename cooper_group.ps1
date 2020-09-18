<#
    -Created by: Tony Harris
    -Name of program: cooper_group
    -Description: This program serves as a way to create a group of Cooper accounts. The way this script works is by:
        1. Querying each of the three domains for the accounts that do not belong to any of the parameters that specify non cooper accounts
        2. Adding all of these accounts to a single array
        3. Obtaining the current group and gathering all of its members
        4. Comparing all of the distinguished names in the current group to the ones that are stored in the array. If:
                                                                        -they are already in the group, then there is nothing to be done.
                                                                        -they are not in the group, then they are added to the group
        Both of the two cases above are written to a file. Then the program is then completed.
    -Date Completed: 7/3/19
#>
Clear-Host
  
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "cooper_group" -ItemType "directory" -ErrorAction SilentlyContinue

# File paths to see accounts once the program has finished
$user_added_file = "C:\Users\$env:UserName\Desktop\cooper_group\users_added.txt"
$users_already_in_file = "C:\Users\$env:UserName\Desktop\cooper_group\users_already_in_group.txt"

# theses three statements can be used for testing. Each one uses three additional statements below. Each statement below will have either a 1, 2, or 3 specifying what to uncomment (directly below it) in order to test new code
# 1 #$asia = "C:\Users\$env:UserName\Desktop\cooper_group\asia.txt"
# 2 #$auto = "C:\Users\$env:UserName\Desktop\cooper_group\auto.txt"
# 3 #$csaid = "C:\Users\$env:UserName\Desktop\cooper_group\csaid.txt"

# The three domains needed to be traversed to find all users.
$asia_domain = "DC=asia,DC=cooperintra,DC=ctb"
$auto_domain = "DC=auto,DC=cooperintra,DC=ctb"
$csaid_domain = "DC=csaid,DC=cooperintra,DC=ctb"

function get_users{
    <#
    this function gets all of the non-continental accounts that do not match the criteria found in each of the three Get-ADUser calls (one for each domain) and this function passes the data to the edit_group function
    #>

    # Array to hold all of the non-continental users
    $cooper_users = @()
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

    Write-Host "Getting all AD accounts that match the search in asia and adding them to the array..."
    #This gets all of the accounts in the asia domain
    $asia_query = Get-ADUser -SearchBase $asia_domain -Filter * -Properties employeetype, extensionattribute11 -Server "asia.cooperintra.ctb" | Where-Object { $_.DistinguishedName -NotLike "*Continental*" }
    
    #1 - Explained above on line 24
    #$asia_sw = New-Object System.IO.StreamWriter $asia

    # Each of the accounts are seperated into arrays based on the search for the string pattern not like '*Continental*'
    foreach($aduser in $asia_query){
        # these are all non continental accounts that get added to the array
        $cooper_users += $aduser

        #1 - Explained above on line 24
        #$asia_sw.WriteLine($aduser.DistinguishedName)

        #Write-Host $aduser.DistinguishedName
    }
    Write-Host "...all AD accounts from asia have been gathered and added to the array."
    
    #1 - Explained above on line 24
    #$asia_sw.close()
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

    Write-Host "Getting all AD accounts that match the search in auto and adding them to the array..."
    #This gets all of the accounts in the auto domain
    $auto_query = Get-ADUser -SearchBase $auto_domain -Filter * -Properties employeetype, extensionattribute11 -Server "auto.cooperintra.ctb" | Where-Object { ($_.DistinguishedName -NotLike "*Continental*") -AND ($_.DistinguishedName -NotLike "*OU=Auburn Plant*") -AND ($_.DistinguishedName -NotLike "*OU=Mitchell*") } 
    
    #2 - Explained above on line 24
    #$auto_sw = New-Object System.IO.StreamWriter $auto

    # Each of the accounts are seperated into arrays based on the search for the string pattern not like '*Continental*', '*OU=Auburn Plant*', and '*OU=Mitchell*'.
    foreach($aduser in $auto_query){
        # these are all non continental accounts that get added to the array
        $cooper_users += $aduser

        #2 - Explained above on line 24
        #$auto_sw.WriteLine($aduser.DistinguishedName)

        #Write-Host $aduser.DistinguishedName
    }
    Write-Host "...all AD accounts from auto have been gathered and added to the array."

    #2 - Explained above on line 24
    #$auto_sw.close()
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

    Write-Host "Getting all AD accounts that match the search in csaid and adding them to the array..."
    #This gets all of the accounts in the csaid domain
    $csaid_query = Get-ADUser -SearchBase $csaid_domain -Filter * -Properties employeetype, extensionattribute11 -Server "csaid.cooperintra.ctb" | Where-Object { (($_.DistinguishedName -NotLike "*Continental*") -AND ($_.DistinguishedName -NotLike "*OU=Rennes*"))}
    
    #3 - Explained above on line 24
    #$csaid_sw = New-Object System.IO.StreamWriter $csaid

    # Each of the accounts are seperated into arrays based on the search for the string pattern not like '*Continental*' and '*OU=Rennes*'
    foreach($aduser in $csaid_query){
        # these are all non continental accounts that get added to the array
        $cooper_users += $aduser

        #3 - Explained above on line 24
        #$csaid_sw.WriteLine($aduser.DistinguishedName)
        #Write-Host $aduser.DistinguishedName
    }

    #3 - Explained above on line 24
    #$csaid_sw.close()
    Write-Host "...all AD accounts from csaid have been gathered and added to the array."
    edit_group $cooper_users
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    }

function edit_group($cooper_users){

    <#
    this function gets the current group and uses the data from get_users to see who needs to be added to the group
    #>

    # function call to get the operators credentials
    $credentials = user_credentials
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    # This section is dedicated to adding users to the group specified above. Only cooper users are to be added.

    # This is the group that the script is adding accounts to
    Write-Host "Getting the group and its members..."
    #The group is obtained to be able to add accounts to it
    $group = Get-AdGroup -Identity "CN=Everyone Cooper (Not Continental),OU=Continental,OU=External,DC=auto,DC=cooperintra,DC=ctb"

    # The accounts of the group are then collected - all of their DistinguishedNames
    $current_group_members = Get-AdGroup -Identity "CN=Everyone Cooper (Not Continental),OU=Continental,OU=External,DC=auto,DC=cooperintra,DC=ctb" -Properties Member | Select-Object -ExpandProperty Member 

    Write-Host "...the group and the members have been gathered."

    Write-Host "Checking the group to see who needs added..."
    
    # StreamWriter objects iin order to see what happened to each account
    $users_added_sw = New-Object System.IO.StreamWriter $user_added_file
    $already_in_group_sw = New-Object System.IO.StreamWriter $users_already_in_file

    $x = 0
    # Loops through all of the accounts in the array that was passed to the function
    foreach($user in $cooper_users){

        # $x is used to show the user the progress so far
        $x += 1
        Write-Host $x,"of",($cooper_users.length),"users checked"

        # If to see if the account is already a member of the group - don't need to re-add the same user mulitple times.
        if($current_group_members -eq $user.DistinguishedName){
            
            # Displays that the account is already in the group
            #Write-Host $user.DistinguishedName,"is already a member of the group."

            # Writes the DistinguishedName to a file to show what has occured during the process - these are the accounts that are already in the group and nothing is done.
            $already_in_group_sw.WriteLine($user.DistinguishedName)
        }
        else{
            # Displays that the account is not in the group to the console and will be added
            #Write-Host $user.DistinguishedName,"-------- was not found in the group: 'Everyone Cooper (Not Continental)' and will be added to the group."
            
            Add-ADGroupMember -Identity $group -Members $user -Credential $credentials -Server "auto.cooperintra.ctb"

            # Writes the DistinguishedName to a file to show what has occured during the process - these are the accounts that are not currently in the group, need to be, and therefore were added to the group.
            $users_added_sw.WriteLine($user.DistinguishedName)
        }
    }
    # Closes the StreamWriter objects
    $already_in_group_sw.Close()
    $users_added_sw.Close()
    Write-Host "...all users have been checked."
}
    
function user_credentials(){

    # This function asks the user to enter their password into the console in order to be used to edit the group
    return Get-Credential "$env:UserDomain\$env:UserName"
}

# Starts the script by going into the get_users function
get_users