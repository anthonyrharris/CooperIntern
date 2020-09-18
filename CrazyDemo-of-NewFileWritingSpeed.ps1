#-------------------------------------------------------------------------------------------------------------------------#

#######This is a crazy demo of the speed difference bewteen using out-file and System.IO.StreamWriter


$startTime = (Get-Date)
$file1 = "C:\Users\aharris\Desktop\slow.txt"
del $file1
for($i = 0; $i -lt 1000; $i++){
"$i This is alot longer" | Out-File $file1 -Append
}
$endTime = (Get-Date)
write-host "Elapsed Time: $([math]::Round(($endTime-$startTime).totalseconds, 2)) seconds"

del $file2
$startTime = (Get-Date)
$file2 = "C:\Users\aharris\Desktop\fast.txt"
$sw = New-Object System.IO.StreamWriter $file2
for($i = 0; $i -lt 1000; $i++){
$sw.WriteLine("$i This is alot faster")
}
$sw.close()
$endTime = (Get-Date)
write-host "Elapsed Time: $([math]::Round(($endTime-$startTime).totalseconds, 2)) seconds"

$startTime = (Get-Date)
$file3 = "C:\Users\aharris\Desktop\fast_maybe.txt"
$list = for($i = 0; $i -lt 1000; $i++){
"$i This is may be the fastest yet"
}
$list | Out-File $file3
$endTime = (Get-Date)
write-host "Elapsed Time: $([math]::Round(($endTime-$startTime).totalseconds, 2)) seconds"

#-------------------------------------------------------------------------------------------------------------------------#