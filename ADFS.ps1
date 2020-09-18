# used to see if program has been ran before
$path = "C:\Users\$env:UserName\Desktop\ADFS_Logs"

# Tests the path
$used_before = $path | Test-Path
# If the path does not exist then there is an error message that pops up telling the user what to do so they can run the script
if(!$used_before){
    [System.Windows.MessageBox]::Show("This appears to be the first time you are using this script. So, you need to follow the tutorial on onenote to be added to the group found in the tab 'ADFS' titled: 'ADFS Event Logging'! Good Bye.",'Required Action','Ok','Error') 
    # Launches One Note for convenience
    Start-Process -FilePath 'C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE'
    # Creates the file so that they don't get the error message again#################################### I should figure out a better way to see if they are in the policy
    New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "ADFS_Logs" -ItemType "Directory" -ErrorAction SilentlyContinue
    exit
}
#create the necessary file needed that the script will use (located on the desktop) to store the data
New-Item -Path "C:\Users\$env:UserName\Desktop\" -Name "ADFS_Logs" -ItemType "Directory" -ErrorAction SilentlyContinue

#these are the location(s) used by the "function(s)". It is where the info will be stored
$non_zero_file = "C:\Users\$env:UserName\Desktop\ADFS_Logs\nonzero_events.txt"
$zeros_file = "C:\Users\$env:UserName\Desktop\ADFS_Logs\allzero_events.txt"

Function check_log{
    
    # This is so that they can search the events for a specific user if they want, if they want they can enter 1 to skip it. This could be a precheck on the GUI
    $userTemp = Read-Host "If you would like to search for username enter it now or enter '1' to skip this."
    
    # Control that will be used later to see if IDs need to be matched up in order to combine there data together
    $control = 'no user specified'

    # this means that the user of the program entered a name that they want to search for a lockout for
    if($userTemp -ne 1){

        $control = 'user specified'

        $user = $userTemp
        Write-Host "Searching for:", $user
        
        # Designates the timefram to search in
        $time = (Get-Date) - (New-TimeSpan -Day -1)
        Write-Host "The 411 Get-WinEvent will now exceute."
        
        <# Retrieves the security 411 events. It retrieves up to 2500 events to search (reduce time), where the event is generated from $time until now. The event must also match the lock out message that can be found within events.
        Finally the event must be for the username that was entered in. The message in the event is then selected.
        #>
        $411_events = Invoke-Command -ScriptBlock{ Get-WinEvent -FilterHashtable @{logname='Security';ID='411'} -MaxEvents 2500 | Where-Object { $_.TimeCreated -ge $time -AND (
        $_.message -Match ' referenced account is currently locked out and may not be logged on to') -AND ($_.message -Match $user)} | Select-Object message
        }-ComputerName AUBVADFS31.csaid.cooperintra.ctb -ErrorAction Stop
    }
    else{
        # This section occurs if there was not a user entered to search for
        Write-Host 'No user specified!'

        Write-Host "The 411 Get-WinEvent will now exceute."
        <# Retrieves the security 411 events. It retrieves up to 2500 events to search (reduce time), where the event is generated from $time until now. The event must also match the lock out message that can be found within events.
        The message in the event is then selected.
        #>
        $411_events = Invoke-Command -ScriptBlock{ Get-WinEvent -FilterHashtable @{logname='Security';ID='411'} -MaxEvents 50 | Where-Object { $_.TimeCreated -ge $time -AND (
        $_.message -Match ' referenced account is currently locked out and may not be logged on to')} | Select-Object message
        }-ComputerName AUBVADFS31.csaid.cooperintra.ctb -ErrorAction Stop
    }
    # testing purposes
    Write-Host "411 Get-WinEvent completed."

    # When a user is entered, no events may pop up if the client they provided to the user of the program was incorrect. This lets you know if that has occurred.
    if($null -eq $411_events){
        Write-Host "There doesn't appear to be any to be any events within this search. It is recommended to increase the size of 'Max Events' in the Get-WinEvent for the 411 events."
        more
    }

    # The 411_events are passed to the function get_event_data. The function returns muliple arrays each of which are stored respectively in the variables 411_non_zero, 411_all_zeros, 411_client_ips
    $411_non_zero,$411_all_zeros, $411_client_ips = get_event_data($411_events)

    # this whole section displays the returned data from get_event_data
    #_______________________________________________________________________________________________________________________________________________________________#

    Write-Host '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($control -ne 'no user specified'){
        Write-Host "This is the data for",$userTemp
    }
    if("" -eq $411_non_zero){
        Write-Host 'There is no data to be displayed for the 411 non-zero activity ids.'
    }
    if("" -eq $411_all_zeros){
        Write-Host 'There is no data to be displayed for the 411 all-zero activity ids.'
    }
    if("" -eq $411_client_ips){
        Write-Host 'There is no data to be displayed for the 411 client IPs.'
    }
    if($x -eq $something){
        
    }
    elseif(("" -ne $411_all_zeros) -AND ("" -ne $411_client_ips)){
        #table
    }
    elseif(("" -ne $411_non_zero) -AND ("" -ne $411_client_ips)){
        #table
    } 

    Write-Host $411_all_zeros
    Write-Host $411_non_zero
    Write-Host $411_client_ips

    #_____________________________________________________#_____________________________________________________#_____________________________________________________
<#
    Write-Host "The 403 Get-WinEvent will now exceute."
    <# Retrieves the security 403 events. It retrieves up to 2500 events to search (reduce time), where the event is generated from $time until now. The message in the event is then selected.
    
    $403_events = Invoke-Command -ScriptBlock{ Get-WinEvent -FilterHashtable @{logname='Security';ID='403'} -MaxEvents 2500 | Where-Object {($_.TimeCreated -ge $time)}| Select-Object message
    }-ComputerName AUBVADFS31.csaid.cooperintra.ctb -ErrorAction Stop
    Write-Host "403 Get-WinEvent completed."

    # The 403_events are passed to the function get_event_data. The function returns muliple arrays each of which are stored respectively in the variables 403_non_zero, 403_allzero, 403_client_ips, 403_query_strings, 403_user_agents
    $403_non_zero, $403_allzero, $403_client_ips, $403_query_strings, $403_user_agents = get_event_data($403_events)

    # this whole section is mainly for testing purposes that displays the returned data from get_event_data
    #_____________________________________________________#_____________________________________________________#_____________________________________________________
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($null -ne $403_non_zero){
        Write-Host '403 non-zero activity ID at index 0: >>>>>>>>>>>>',$403_non_zero[0]
    }
    else{
        Write-Host 'There seems to have been an issue.'
    }
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($null -ne $403_allzero){
        Write-Host '403 non-zero activity ID at index 0: >>>>>>>>>>>>',$403_non_zero[0]
    }
    else{
        Write-Host 'There seems to have been an issue.'
    }
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($null -ne $403_client_ips){
        Write-Host '403 client IPv4 at index 0: >>>>>>>>>>>>>>>>>>>>>',$403_client_ips[0]
    }
    else{
        Write-Host 'There seems to have been an issue.'
    }
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($null -ne $403_query_strings){
        Write-Host '403 query string at index 0: >>>>>>>>>>>>>>>>>>>>',$403_query_strings[0]
    }
    else{
        Write-Host 'There seems to have been an issue.'
    }
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if($null -ne $403_user_agents){
        Write-Host '403 user agent at index 0: >>>>>>>>>>>>>>>>>>>>>>',$403_user_agents[0]
    }
    else{
        Write-Host 'There seems to have been an issue.'
    }
    Write-Host '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    #_____________________________________________________#_____________________________________________________#_____________________________________________________

    # Variables intialized to null to act as 'controls' for the logicc below. The it will make it easy later to check each index to see if there is a value rather than storing a placeholder.
    $null = $this_id
    $null = $this_ip
    $null = $this_query
    $null = $this_agent

    # Uses the control specified at the beginning of the script to evaluate that a username has been entered to search for
    if($control -eq 'user specified'){
        # testing purposes
        Write-Host 'first if'
        # Checks to see that there are non zero 411 activity IDs (must be non zero because all zero activity IDs can not be matched to the corresponding 403 event).
        if($null -ne $411_non_zero){
            # testing purposes
            Write-Host 'second if'
            # Loops through the 411 activity IDs
            for($411id = 0; $411id -lt ($411_non_zero.length - 1); $411id++){
                # Loops through the 403 IDs
                for($403id = 0; $403id -lt ($403_non_zero.length - 1); $403id++){
                    # If the current 403 ID matches any of the 411 IDs then that is the data that is stored to see what the clients issues may be.
                    if($403_non_zero[$403id] -eq $411_non_zero[$411id]){
                        # testing purposes
                        Write-Host 'third if'

                        $this_id = $403_non_zero[$403id]
                        $this_ip = $403_client_ips[$403id]
                        $this_query = $403_query_strings[$403id]
                        $this_agent = $403_user_agents[$403id]
                    }
                }
            }
        }
    }
    # Writes out the data that matched if they are not null
    if($null -ne $this_id){
        Write-Host 'ID:',$this_id
    }
    if($null -ne $this_ip){
        Write-Host 'IP:',$this_ip
    }
    if($null -ne $this_query){
        Write-Host 'Query:',$this_query
    }
    if($null -ne $this_agent){
        Write-Host 'Agent:',$this_agent
    }
    # More determines the if the program user would like to do another search or not
#>
    more
}
<#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

<# The function below is passed events in a parameter and searches them for the desired data.

#>
function get_event_data{
    param ($event_messages)

    # StreamWriter objects are very fast at writing to files
    $sw1 = New-Object System.IO.StreamWriter $non_zero_file
    $sw2 = New-Object System.IO.StreamWriter $zeros_file

    # Determines if the events contain and activty ID of all zeros or not and writes the data to the appropriate file
    foreach($i in $event_messages){
        $does_it = $i | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
        if(!$does_it){
            # These are the events that do not contain all zeros
            $sw1.WriteLine($i)
        }
        else{
            # Theses are the events that do contain all zeros.
            $sw2.WriteLine($i)
        }
    }
    # The StreamWriter obejects must be closed each time so that the next function call where events are passed may write to the files too, if not closed an error occurs.
    $sw1.close()
    
    $sw2.Close()

    # array for the ids that don't consist of only zeros.
    #$403_activity_ids_nonzero = @()

    # array for the ids that do consist of only zeros.
    #$403_activity_ids_allzero = @()

    # array for the client ips in the 403 events.
    #$403_client_ips = @()

    # array for the events that contain a query string - the quesry string is what they are trying to log into?
    #$403_query_string = @()

    #the user agent provides information on the device they were using when they tried to logon with.
    #$403_user_agent = @()

    # array for the ids that don't consist of only zeros.
    $411_activity_ids_nonzero = @()

    # array for the ids that do consist of only zeros.
    $411_activity_ids_allzero = @()

    # array for the client ips in the 411 events.
    $411_client_ips = @()
<#
    #determines if it is a 403 or 411 event.
    $event_id_check1 = Get-Content $non_zero_file | Select-String 'User Agent:'
    $event_id_check2 = Get-Content $zeros_file | Select-String 'User Agent:'
#>
    $non_zero_file_data = Get-Content $non_zero_file
    $zeros_file_data = Get-Content $zeros_file

    # 403 events, this 'if' is for the 403 events <<< basically two files are passed at each function call. The function determines here if they are a 403 or a 411. Then for each event id there are going to be two files either
    #         all-zeros or all-non-zeros. So, sr1 is all-non-zeros and sr2 is all-zeros. Therefore, each stream reader needs to read to the end of each file to get the data. There for and if for determining the event and two while loops each
    #         since there is an all-zero file and an all-non-zero file.
<#
    if($event_id_check1 -OR $event_id_check2){

        #each line is read so that it can be checked for certain properties
        # reads until the end of the file
        foreach($line in $non_zero_file_data){

            # if a line contains 'Activity ID:' then that is stored in the array: $activity_ids_nonzero >> it is important to note this file being used will only have all-zero activity ids, this just finds them
            $conatins_id = $line | Select-String -Pattern 'Activity ID:'
            $conatins_id_zeros = $line | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
            if($conatins_id -AND !$conatins_id_zeros){
                $403_activity_ids_nonzero += $conatins_id
            }
            elseif($conatins_id_zeros){
                $403_activity_ids_allzero += $conatins_id_zeros
            }
            
            $contains_client_ip0 = $line | Select-String -Pattern 'Client IP: 0'
            $contains_client_ip1 = $line | Select-String -Pattern 'Client IP: 1'
            $contains_client_ip2 = $line | Select-String -Pattern 'Client IP: 2'

            # searches each line to see if it is an ip, if it is then it is stored in the array: $403_client_ips
            if($contains_client_ip0){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 0'
            }
            elseif($contains_client_ip1){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 1'
            }
            elseif($contains_client_ip2){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 2'
            }

            $contains_query_string = $line | Select-String -Pattern 'Query string: ?'
            $contains_query_string_empty = $line | Select-String -Pattern 'Query string: -'
            # if a line does not contain 'Query string: -' then that it is populated in the event and the data is stored in the array: $query_string
            # if it does contain 'Query string: -' then '$$$' is added to the array: $query_string ,so the indexes all match up. I just picked something I thought would never show up
            if($contains_query_string_empty){
                $403_query_string += '$$$'
            }
            elseif($contains_query_string){
                $403_query_string += $line.trim() | Select-String -Pattern 'Query string: ?'
            }

            $contains_user_agent = $line | Select-String -Pattern 'User Agent: M'
            $contains_user_agent_empty = $line | Select-String -Pattern 'User Agent: -'
            # if a line does not contain 'User Agent: -' then that it is populated in the event and the data is stored in the array: $user_agent
            if($contains_user_agent){
                $403_user_agent += $line.trim() | Select-String -Pattern 'User Agent: M'
            }
            # if it does contain 'User Agent: -' then '$$$' is added to the array: $user_agent ,so the indexes all match up. I just picked something I thought would never show up
            elseif($contains_user_agent_empty){
                $403_user_agent += '$$$'
            }
        }
        # reads until the end of the file
        foreach($line in $zeros_file_data){

            # if a line contains 'Activity ID:' then that is stored in the array: $activity_ids_nonzero >> it is important to note this file being used will only have all-zero activity ids, this just finds them
            $contains_id = $line | Select-String -Pattern 'Activity ID:'
            $contains_id_zeros = $line | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
            if($contains_id -AND !$contains_id_zeros){
                $403_activity_ids_nonzero += $line | Select-String -Pattern 'Activity ID:'
            }
            elseif($contains_id_zeros){
                $403_activity_ids_allzero += $line | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
            }

            $contains_client_ip0 = $line | Select-String -Pattern 'Client IP: 0'
            $contains_client_ip1 = $line | Select-String -Pattern 'Client IP: 1'
            $contains_client_ip2 = $line | Select-String -Pattern 'Client IP: 2'

            # searches each line to see if it is an ip, if it is then it is stored in the array: $403_client_ips
            if($contains_client_ip0){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 0'
            }
            elseif($contains_client_ip1){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 1'
            }
            elseif($contains_client_ip2){
                $403_client_ips += $line.trim() | Select-String -Pattern 'Client IP: 2'
            }

            $contains_query_string = $line | Select-String -Pattern 'Query string: ?'
            $contains_query_string_empty = $line | Select-String -Pattern 'Query string: -'
            # if a line does not contain 'Query string: -' then that it is populated in the event and the data is stored in the array: $query_string
            if($contains_query_string){
                $403_query_string += $line.trim() | Select-String -Pattern 'Query string: ?'
            }
            # if it does contain 'Query string: -' then '$$$' is added to the array: $query_string ,so the indexes all match up. I just picked something I thought would never show up
            elseif($contains_query_string_empty){
                $403_query_string += '$$$'
            }

            $contains_user_agent = $line | Select-String -Pattern 'User Agent: M'
            $contains_user_agent_empty = $line | Select-String -Pattern 'User Agent: -'
            # if a line does not contain 'User Agent: -' then that it is populated in the event and the data is stored in the array: $user_agent
            if($contains_user_agent){
                $403_user_agent += $line.trim() | Select-String -Pattern 'User Agent: M'
            }
            # if it does contain 'User Agent: -' then '$$$' is added to the array: $user_agent ,so the indexes all match up. I just picked something I thought would never show up
            elseif($contains_user_agent_empty){
                $403_user_agent += '$$$'
            }
        }
    
        return $403_activity_ids_nonzero, $403_activity_ids_allzero, $403_client_ips, $403_query_string,$403_user_agent
    }
#>
    # 411 events - There is not much data that can be gathered from the 411 events so all I get is the lines that contain the activity IDs
    #else{
    
    # reads until the end of the file
        foreach($line in $non_zero_file_data){
            
            # if a line contains 'Activity ID:' then that is stored in the array: $activity_ids_nonzero >> it is important to note this file being used will only have all-zero activity ids, this just finds them
            $contains_id = $line | Select-String -Pattern 'Activity ID:'
            $contains_id_zeros = $line | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
            if($contains_id -AND !$contains_id_zeros){
                $411_activity_ids_nonzero += $line | Select-String -Pattern 'Activity ID:'
            }
            # if a line contains '00000000-0000-0000-0000-000000000000' then that line is stored int the array
            elseif($contains_id_zeros){
                $411_activity_ids_allzero += $line | Select-String -Pattern 'Activity ID:'
            }
            
            # searches each line to see if it is an ip, if it is then it is stored in the array: $411_client_ips
            if($line.StartsWith('0') -OR $line.StartsWith('1') -OR $line.StartsWith('2')){
                $411_client_ips += $line
            }
        }
        
        # reads until the end of the file
        foreach($line in $zeros_file_data){
            # if a line contains 'Activity ID:' then that is stored in the array: $activity_ids_nonzero >> it is important to note this file being used will only have all-zero activity ids, this just finds them
            $contains_id = $line | Select-String -Pattern 'Activity ID:'
            $contains_id_zeros = $line | Select-String -Pattern '00000000-0000-0000-0000-000000000000'
            if($contains_id -AND !$contains_id_zeros){
                $411_activity_ids_nonzero += $line | Select-String -Pattern 'Activity ID:'
            }
            # if a line contains '00000000-0000-0000-0000-000000000000' then that line is stored int the array 
            elseif($contains_id_zeros){
                $411_activity_ids_allzero += $line | Select-String -Pattern 'Activity ID:'
            }

            # searches each line to see if it is an ip, if it is then it is stored in the array: $411_client_ips
            if($line.StartsWith('0') -OR $line.StartsWith('1') -OR $line.StartsWith('2')){
                $411_client_ips += $line
            }
        }
        
        
        return $411_activity_ids_nonzero, $411_activity_ids_allzero, $411_client_ips
    #}
}  
<#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
<# Simple little function literally just adds spaces to the console when wanted. Looks better in the code. #>

<#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>

<# After each event search is done this will ask the user to either enter 1 or 2 to continue or exit. If chosen to contine then the program will take them to the correct location in the code. #>
function more{

    

    #Gets the program user's input to see if they would like to make another search or if they would like to exit
    $input = Read-Host "Would you like to check another event? Enter '1' to check another or '2' to exit."
    
    do{
        if($input -eq '1'){
            check_log
        }
        elseif($input -eq '2'){
            
            Write-Host "Ending the program ... Good Bye."
            exit
        }
        else{
            
            Write-Host "Unknown input entered, please try entering it again!"
            more
        }
    }while($input -ne '1' -OR $input -ne '2')
}
<#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>
<# This is a single entry for the code to start with an event. #>
check_log
<#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#>