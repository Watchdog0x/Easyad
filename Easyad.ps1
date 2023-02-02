##########################################################################################################################
#                                                                                                                        #
#                                       EesyAD 0.3 by Watchdog								 #
#                                   _________________________________________________                                    #
#                                                                                          				 #
#                                                                                                                        #
##########################################################################################################################


$local:version = 0.3

function add($argv) {

    $help = @"

EasyAD $version By Daniel Abildgaard

Usage:
    Easyad add [flags]


Flags:
  -n, --name               Set name
  -h, --help               help for add
  -c, --csv                Read data from CSV and add to AD
  
      
"@


    [array] $flags = @()

    
    [hashtable] $data = @{}
    [hashtable] $falgs_set = @{
        flag1 = [bool] 0        # --name
        flag2 = [bool] 0        # --cvs
        flag3 = [bool] 0
    }

    foreach ($arg in $argv) {

        $count ++
        if ($arg -like '-*') { 
            $flags += $arg 
            $data[$arg] += ($argv[$count])
             
        }
       
    }
    if ($flags) { 
        foreach ($flag in $flags) { 
            switch ($flag) {
                { ($_ -eq "-n") -or ($_ -eq "--name") } { $falgs_set.flag1 = [bool] 1 }
                { ($_ -eq "-c") -or ($_ -eq "--csv") } { $falgs_set.flag2 = [bool] 1 }
                { ($_ -eq "-h") -or ($_ -eq "--help") } { $help }
                default { 
                    Write-Host "Bad option: $flag is not a valid flag. Try use --help" -ForegroundColor Red
                }
            }
        }
    }
    else {
        $help 
    }

}


function  remove {
    
    
}




function list($argv) {

    $help = @"

EasyAD $version By Daniel Abildgaard

Usage:
    Easyad list [flags]


Flags:
  -ou                      Get all of the OUs in a domain
  -u, --users              Get all users in a domain
  -g, --Groups             Get all groups in a domain 

   Groups Flags:
     -t, --type            Show a specific group type Security/Distribution
     -s, --scope           Show a specific group scope Domain local, global or universal


  -h, --help               help for list
  
      
"@

    [array] $flags = @()

    
    [hashtable] $data = @{}
    [hashtable] $falgs_set = @{
        flag1 = [bool] 0        # -ou
        flag2 = [bool] 0        # --users
        flag3 = [bool] 0        # --groups
        flag4 = [bool] 0        # --type
        flag5 = [bool] 0        # --scope
    }

    foreach ($arg in $argv) {

        $count ++
        if ($arg -like '-*') { 
            $flags += $arg 
            $data[$arg] += ($argv[$count])
             
        }
       
    }
    if ($flags) { 
        foreach ($flag in $flags) { 
            switch ($flag) {
                "-ou" { $falgs_set.flag1 = [bool] 1 }
                { ($_ -eq "-u") -or ($_ -eq "--users") } { $falgs_set.flag2 = [bool] 1 }
                { ($_ -eq "-g") -or ($_ -eq "--groups") } { $falgs_set.flag3 = [bool] 1 }
                { ($_ -eq "-t") -or ($_ -eq "--type") } { $falgs_set.flag4 = [bool] 1 }
                { ($_ -eq "-s") -or ($_ -eq "--scope") } { $falgs_set.flag5 = [bool] 1 }
                { ($_ -eq "-h") -or ($_ -eq "--help") } { $help }
                default { 
                    Write-Host "ERROR: $flag is not a valid flag. Try use --help" -ForegroundColor Red
                }
            }
        }
    }
    else {
        $help 
    }

    if ($falgs_set.flag1){
        Write-Host ""
        Write-Host "_____________OrganizationalUnits_____________"

        Get-ADOrganizationalUnit -Filter * | Format-Table Name, DistinguishedName
    }
    if ($falgs_set.flag2) {
        Write-Host ""
        Write-Host "____________________Users____________________"
        Get-ADUser -Filter * | Format-Table Name, SamAccountName, Enabled, DistinguishedName
    }

    if ($falgs_set.flag3) {
        Write-Host ""
        Write-Host "____________________Groups____________________"
        
        if($falgs_set.flag4 -and $falgs_set.flag5 -eq $false){
            Get-ADGroup -Filter * `
                | Where-Object  { ($_.GroupCategory -match $data["-t"]) -and ($_.GroupCategory -match $data["--type"]) } `
                | Format-Table Name, GroupCategory, GroupScope,  DistinguishedName
        }
        elseif ($falgs_set.flag5 -and $falgs_set.flag4 -eq $false) {
            Get-ADGroup -Filter * `
                | Where-Object  { ($_.GroupScope -match $data["-s"]) -and ($_.GroupScope -match $data["--scope"]) } `
                | Format-Table Name, GroupCategory, GroupScope,  DistinguishedName
        }
        elseif ($falgs_set.flag5 -and $falgs_set.flag4 ) {
            Get-ADGroup -Filter * `
            | Where-Object  { `
                (($_.GroupScope -match $data["-s"]) -and ($_.GroupScope -match $data["--scope"])) `
                -and `
                 (($_.GroupCategory -match $data["-t"]) -and ($_.GroupCategory -match $data["--type"]))} `
            | Format-Table Name, GroupCategory, GroupScope,  DistinguishedName
        }
        else {
            Get-ADGroup -Filter * | Format-Table Name, GroupCategory, GroupScope,  DistinguishedName
        }
    }


}

function help {
    $help = @"

EasyAD $version By Danylo Abildgaard

Usage:
    Easyad [command]


Available Commands:
    add           Add something to your AD
    remove        Remove something from your AD 
    list          List items from AD
    help          help for usage


"@

    return $help
}

function menu($argv) {
 
    [array] $command = @()

    foreach ($arg in $argv[0] ) {

        if ($arg) { $command += $arg }
    
    }
    if ($command) { 
        foreach ($cmd in $command) { 
            switch ($cmd) {
                "add" { add $argv }
                "remove" { remove }
                "list" { list $argv }               
                "help" { help }

                default { 
                    Write-Host "ERROR: $cmd is not a valid command. Try use help" -ForegroundColor Red
                }
            }
        }
    }
    else {
        help
    }

}


menu $args
