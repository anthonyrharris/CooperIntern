<#
    -Created by: Tony Harris
    -Name of program: user_search
    -Description: This program serves as a way to search for members to be added to a distribution group based on country and department.
                    The users are found by: 
                        1. Getting all AD-Users that are either hourly or salary and are in the IT department
                        2. These users are split into two groups that are either in the EU or in India
                    The resulting users can then be added to a distribution group either by evaluating the csv files generated on the desktop located in the 'desired_members' folder or by using the arrays that they are stored in below.
    -Date Completed: 6/14/19
#>
# folder that will hold the files of the rest of the data
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "desired_members" -ItemType "Directory" -ErrorAction SilentlyContinue

Clear-Host

Write-Host "The users that are in the csaid domain and are hourly or salary in the IT department are being gathered."

# this queries the csaid domain for all hourly or salary employees that are in the IT department
$csaid_query = Get-ADUser -SearchBase "DC=csaid,DC=cooperintra,DC=ctb" -Filter * -Properties employeeType,Country,Department -Server "csaid.cooperintra.ctb" | Where-Object {(($_.employeeType -eq "Hourly") -OR ($_.employeeType -eq "Salary") -AND ($_.Department -eq "IT"))}

Write-Host "All of the users have been gathered."

# arrays used for the seprate groups
$india_users_temp = @()
$EU_users_temp = @()

Write-Host ""
Write-Host "The users are now being sorted based on country and will then be written to the files (alphabetically based on country) located in the 'desired_members' folder on your desktop."
foreach($user in $csaid_query){
    # sort them based on if they are India IT or not
    if($user.Country -eq "IN"){
        # user is added to the array
        $india_users_temp += $user
    }
    else {
        # user is added to the array
        $EU_users_temp += $user
    }
}
# the user objects are then sorted before they are written to the file
$india_users = $india_users_temp | Sort-Object -Property { [System.String] $_.Country }
$EU_users = $EU_users_temp | Sort-Object -Property { [System.String] $_.Country }

try{
    # the arrays are then used to generate two files for the two groups
    $EU_users | Export-Csv "C:\Users\$env:UserName\Desktop\desired_members\EU_Group.csv"
}
catch{
    # this is when the user has the India_Group excel file open while the program is trying to write to it
    Clear-Host
    Write-Host -ForegroundColor DarkYellow "The program failed to export beacause the excel file 'EU_Group' is currently open."
    Write-Host -ForegroundColor DarkYellow "The program will now exit. Please exit the file and rerun the program."
    exit
}
try{
    # the arrays are then used to generate two files for the two groups
    $india_users | Export-Csv "C:\Users\$env:UserName\Desktop\desired_members\India_Group.csv"
}
catch{
    # this is when the user has the EU_Group excel file open while the program is trying to write to it
    Clear-Host
    Write-Host -ForegroundColor DarkYellow "The program failed to export beacause the excel file 'India_Group' is currently open."
    Write-Host -ForegroundColor DarkYellow "The program will now exit. Please exit the file and rerun the program."
    exit
}

Write-Host "The program has now completed."