<####################
Written By: Tony Harris
Task: Count the number of enabled accounts with an email in auto and in csaid.
Comleted: 8/7/19
####################>

Clear-Host

# folder for text files of the enabled accounts - SamAccountNames listed
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "enabled_with_an_email" -ItemType "directory" -ErrorAction SilentlyContinue

# txt files for account lists
$auto_file = "C:\Users\$env:UserName\Desktop\enabled_with_an_email\auto.txt"
$csaid_file = "C:\Users\$env:UserName\Desktop\enabled_with_an_email\csaid.txt"

# objects to write the accounts to the files
$auto_file_sw = New-Object System.IO.StreamWriter $auto_file
$csaid_file_sw = New-Object System.IO.StreamWriter $csaid_file



# queries auto to get accounts that are enabled and have an email
$auto_accounts = Get-ADUser -SearchBase "DC=auto,DC=cooperintra,DC=ctb" -Filter *  -Properties mail  -Server "auto.cooperintra.ctb" | Where-Object{($null -ne $_.mail) -AND ($_.Enabled -eq "true")}
# loops through adding up the total and writes the accounts to a file line by line
foreach($account in $auto_accounts){
    $total_auto += 1
    $auto_file_sw.WriteLine($account.SamAccountName)
}
Write-Host "In auto:",$total_auto



# queries csaid to get accounts that are enabled and have an email
$csaid_accounts = Get-ADUser -SearchBase "DC=csaid,DC=cooperintra,DC=ctb" -Filter *  -Properties mail  -Server "csaid.cooperintra.ctb" | Where-Object{($null -ne $_.mail) -AND ($_.Enabled -eq "true")}
# loops through adding up the total and writes the accounts to a file line by line
foreach($account in $csaid_accounts){
    $total_csaid += 1
    $csaid_file_sw.WriteLine($account.SamAccountName)
}
Write-Host "In csaid:",$total_csaid

# closes stream writer objects
$auto_file_sw.close()
$csaid_file_sw.close()