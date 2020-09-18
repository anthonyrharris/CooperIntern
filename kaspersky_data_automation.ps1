Clear-Host
  
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "kasp_auto" -ItemType "directory" -ErrorAction SilentlyContinue

function get_computers(){

    
}

function check($comps_to_check){
    $has_kaspersky = "C:\Users\$env:UserName\Desktop\cooper_group\t_or_f.txt"

    foreach($comp in $comps_to_check){

    }

    $has_kaspersky_sw.close()
}
$has_kaspersky_sw = New-Object System.IO.StreamWriter $has_kaspersky


