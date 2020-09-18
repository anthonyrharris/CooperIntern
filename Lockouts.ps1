$locked_out = Search-ADAccount -LockedOut |  Where-Object {$_.PasswordNeverExpires -ne "false"} <#|  Where-Object {$_.PasswordNeverExpires -ne "false"}#> <#Search-ADAccount -LockedOut#>
$usernames = @()
foreach($account in $locked_out){

    $username = $account.SamAccountName
    Write-Host $username
    $usernames += $username
}
write-host ($usernames.length - 1)
<#$x = 0
foreach($user in $usernames){
$x+=1

Write-host $x

    $asia_user = Get-ADUser -Filter "SamAccountName -eq '$user'" -Properties BadPWDCount, LockedOut -Server 'asia.cooperintra.ctb' | Where-Object {$_.badpwdcount -gt 0}
    $auto_user = Get-ADUser -Filter "SamAccountName -eq '$user'" -Properties BadPWDCount, LockedOut -Server 'auto.cooperintra.ctb' | Where-Object {$_.badpwdcount -gt 0}
    $csaid_user = Get-ADUser -Filter "SamAccountName -eq '$user'" -Properties BadPWDCount, LockedOut -Server 'csaid.cooperintra.ctb' | Where-Object {$_.badpwdcount -gt 0}

    if($null -ne $asia_user){
        $bad_pasword_entered = $asia_user | Select-Object -ExpandProperty "badpwdcount"
        if($bad_pasword_entered -gt 0){
            Write-Host $asia_user.SamAccountName,$bad_pasword_entered
        }
        
    }
    if($null -ne $auto_user){
        $bad_pasword_entered = $auto_user | Select-Object -ExpandProperty "badpwdcount"
        if($bad_pasword_entered -gt 0){
            Write-Host $asia_user.SamAccountName,$bad_pasword_entered
        }
    }
    if($null -ne $csaid_user){
        $bad_pasword_entered = $csaid_user | Select-Object -ExpandProperty "badpwdcount"
        if($bad_pasword_entered -gt 0){
            Write-Host $asia_user.SamAccountName,$bad_pasword_entered
        }
    }
}
#>
