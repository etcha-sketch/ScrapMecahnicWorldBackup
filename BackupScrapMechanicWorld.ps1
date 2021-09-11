# Scrap Mechanic Backup and Restore Tool
# Author: Etcha-Sketch
# https://github.com/etcha-sketch

function BackupScrapMechanicSurvivalWorlds
{
    Push-Location "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\"
    Push-location "$((Get-ChildItem "User_*").Name)\Save\Survival"
    
    if (!(Test-Path 'Backups'))
    {
        New-Item -ItemType directory 'Backups' | Out-Null
        Write-host "Backup directory created.`n"
    }
    else
    {
        Write-host "Backup directory already exists.`n"
    }
    
    $backuppath = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save\Survival\Backups\"
    
    foreach ($save in (Get-ChildItem *.db))
    {
        $newname = "$($save.Name.Split('.')[0])_$((($save.LastWriteTime).ToString("yyyy-MM-dd_hh-mm-tt"))).db"
        if (!(Test-Path ($newpath = Join-Path -Path $backuppath -ChildPath $newname)))
        {
            Write-host "Copied $($save.Name.Split('.')[0]) to the backup directory."
            Copy-Item $save $newpath
        }
        else
        {
            Write-host "Backup of $($save.Name.Split('.')[0]) already exists in the backup directory."
        }
    
    }

    Write-host "`n`nAll survival games successfully backed up." -ForegroundColor Green
    Pop-Location
    Pop-Location
}

function BackupScrapMechanicCreativeWorlds
{
    Push-Location "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\"
    Push-location "$((Get-ChildItem "User_*").Name)\Save"
    
    if (!(Test-Path 'Backups'))
    {
        New-Item -ItemType directory 'Backups' | Out-Null
        Write-host "Backup directory created.`n"
    }
    else
    {
        Write-host "Backup directory already exists.`n"
    }
    
    $backuppath = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save\Backups\"
    
    foreach ($save in (Get-ChildItem *.db))
    {
        $newname = "$($save.Name.Split('.')[0])_$((($save.LastWriteTime).ToString("yyyy-MM-dd_hh-mm-tt"))).db"
        if (!(Test-Path ($newpath = Join-Path -Path $backuppath -ChildPath $newname)))
        {
            Write-host "Copied $($save.Name.Split('.')[0]) to the backup directory."
            Copy-Item $save $newpath
        }
        else
        {
            Write-host "Backup of $($save.Name.Split('.')[0]) already exists in the backup directory."
        }
    
    }

    Write-host "`n`nAll creative games successfully backed up." -ForegroundColor Green
    Pop-Location
    Pop-Location
}

function RestoreScrapMechanicCreativeWolrds
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)`n`n"
    $wbackup = Read-host "Would you like to make backups of all of your worlds first? [y]/n"
    if (!($wbackup -ieq "n"))
    {
        BackupScrapMechanicCreativeWorlds; start-sleep -seconds 3
    }
    
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)`n`n"

    $folderdir = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save\Backups"
    Push-Location $folderdir
    $allworlds = (Get-ChildItem *.db | Sort-Object)
    $uniqueworlds = @()
    foreach ($world in $allworlds)
    {
        if ((($world.Name).split('_'))[0] -inotin $uniqueworlds)
        {
            $uniqueworlds += ($world.Name.split('_'))[0]
        }
    }

    #List Creative Worlds
    Write-host "Worlds available for restore`n`n"
    $op = 1
    foreach ($world in $uniqueworlds)
    {
        write-host "$($op)>   $($world)"
        $op ++
    }
    Write-host "`n0>   Main Menu"

    $userchoice = Read-host "Restore which world?"

    if (($userchoice -gt ($op-1)) -or ($userchoice -lt 0))
    {
       Write-host "Invalid Choice, exiting now." -ForegroundColor Red
    
    }
    elseif ($userchoice -eq 0)
    {
        Showmenu
    }
    else 
    {
        $worldindex = $userchoice - 1
        Write-host "`n`nRestoring the $($uniqueworlds[$worldindex]) world.`n"

        $restorepoints = Get-ChildItem *.db | Where-Object Name -like "$($uniqueworlds[$worldindex])*"
        if ($restorepoints.Count -eq 1)
        {
            Write-host "Only 1 restore point available from $(($restorepoints.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))`n"
            $restorepoint = $restorepoints[0]
        }
        else 
        {
            Write-Host "More than one restore point available`n`n"
            $nn = 1
            foreach ($point in $restorepoints)
            {
                write-host "$($nn)>   $(($point.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))"
                $nn ++
            }
            Write-Host "`n"
            $restorepointchoice = Read-Host "Which restore point?"
            if (($restorepointchoice -gt $nn) -or ($restorepointchoice -le 0))
            {
                write-host "Invalid selection."
                start-sleep -Seconds 3
                ShowMenu
            }
            else
            {
                $restorepoint = $restorepoints[$restorepointchoice-1]    
            }
        }
        $restoreworldconfirm = Read-Host "Are you sure you want to restore $($uniqueworlds[$worldindex]) to $(($restorepoint.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))? y/[n]"

        if ($restoreworldconfirm -ieq "y")
        {
            Write-host "Please wait. Restoring world now."
            Push-Location $folderdir.Replace('\Save\Backups','\Save')
            Get-ChildItem *.db | Where-Object Name -eq "$($uniqueworlds[$worldindex]).db" | Remove-Item
            start-sleep -seconds 1
            copy-item $restorepoint.FullName "$($uniqueworlds[$worldindex]).db"
            Pop-Location
            Write-Host "Restore of $($uniqueworlds[$worldindex]) to $(($restorepoint.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db','')) complete."
        }
        else
        {
            Write-host "Returning to main menu."
            Start-Sleep -Seconds 5
            ShowMenu    
        }

    }
    
    
    Pop-Location
}
function RestoreScrapMechanicSurvivalWolrds
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)`n`n"
    $wbackup = Read-host "Would you like to make backups of all of your worlds first? [y]/n"
    if (!($wbackup -ieq "n"))
    {
        BackupScrapMechanicSurvivalWorlds; start-sleep -seconds 3
    }
    
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)`n`n"

    $folderdir = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save\Survival\Backups"
    Push-Location $folderdir
    $allworlds = (Get-ChildItem *.db | Sort-Object)
    $uniqueworlds = @()
    foreach ($world in $allworlds)
    {
        if ((($world.Name).split('_'))[0] -inotin $uniqueworlds)
        {
            $uniqueworlds += ($world.Name.split('_'))[0]
        }
    }

    #List Survival Worlds
    Write-host "Worlds available for restore`n`n"
    $op = 1
    foreach ($world in $uniqueworlds)
    {
        write-host "$($op)>   $($world)"
        $op ++
    }
    Write-host "`n0>   Main Menu"

    $userchoice = Read-host "Restore which world?"

    if (($userchoice -gt ($op-1)) -or ($userchoice -lt 0))
    {
       Write-host "Invalid Choice, exiting now." -ForegroundColor Red
    
    }
    elseif ($userchoice -eq 0)
    {
        Showmenu
    }
    else 
    {
        $worldindex = $userchoice - 1
        Write-host "`n`nRestoring the $($uniqueworlds[$worldindex]) world.`n"

        $restorepoints = Get-ChildItem *.db | Where-Object Name -like "$($uniqueworlds[$worldindex])*"
        if ($restorepoints.Count -eq 1)
        {
            Write-host "Only 1 restore point available from $(($restorepoints.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))`n"
            $restorepoint = $restorepoints[0]
        }
        else 
        {
            Write-Host "More than one restore point available`n`n"
            $nn = 1
            foreach ($point in $restorepoints)
            {
                write-host "$($nn)>   $(($point.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))"
                $nn ++
            }
            Write-Host "`n"
            $restorepointchoice = Read-Host "Which restore point?"
            if (($restorepointchoice -gt $nn) -or ($restorepointchoice -le 0))
            {
                write-host "Invalid selection."
                start-sleep -Seconds 3
                ShowMenu
            }
            else
            {
                $restorepoint = $restorepoints[$restorepointchoice-1]    
            }
        }
        $restoreworldconfirm = Read-Host "Are you sure you want to restore $($uniqueworlds[$worldindex]) to $(($restorepoint.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db',''))? y/[n]"

        if ($restoreworldconfirm -ieq "y")
        {
            Write-host "Please wait. Restoring world now."
            Push-Location $folderdir.Replace('\Save\Survival\Backups','\Save\Survival')
            Get-ChildItem *.db | Where-Object Name -eq "$($uniqueworlds[$worldindex]).db" | Remove-Item
            start-sleep -seconds 1
            copy-item $restorepoint.FullName "$($uniqueworlds[$worldindex]).db"
            Pop-Location
            Write-Host "Restore of $($uniqueworlds[$worldindex]) to $(($restorepoint.name.replace("$($uniqueworlds[$worldindex])_",'')).Replace('.db','')) complete."
        }
        else
        {
            Write-host "Returning to main menu."
            Start-Sleep -Seconds 5
            ShowMenu    
        }

    }
    
    
    Pop-Location
}

function ShowMenu
{

    Clear-Host
    Write-Host '---------------------------------------------------------'
    Write-Host '       etcha-sketch`s Scrap Mechanic Backup Tool'
    Write-Host 'No warranties expressed or implied. Use at your own risk.' -ForegroundColor Red
    Write-Host "---------------------------------------------------------"
    
    
    Write-host "`n`n1) Backup All Creative and Survival Worlds"
    Write-host "2) Backup All Survival Worlds"
    Write-host "3) Backup All Creative Worlds"
    Write-host "4) Restore a Survival World"
    Write-host "5) Restore a Creative World"
    Write-host "6) Open Scrap Mechanic survival save folder in Windows Explorer"
    Write-host "7) Open Scrap Mechanic creative save folder in Windows Explorer"
    Write-host "`n0) Exit Tool`n"
    $option = read-host "What would you like to do?"
    
    if ($option -eq 0)
    {
        Pop-Location; Pop-Location; Pop-Location; Pop-Location; Pop-Location
    }
    elseif ($option -eq 1) { BackupScrapMechanicSurvivalWorlds; start-sleep -seconds 2; BackupScrapMechanicCreativeWorlds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 2) { BackupScrapMechanicSurvivalWorlds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 3) { BackupScrapMechanicCreativeWorlds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 4) { RestoreScrapMechanicSurvivalWolrds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 5) { RestoreScrapMechanicCreativeWolrds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 6) { $folderdir = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save\Survival" ; Start-process 'C:\Windows\explorer.exe' -ArgumentList @($folderdir) ; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 7) { $folderdir = $((Get-ChildItem "$($env:APPDATA)\Axolot Games\Scrap Mechanic\User\*").FullName)+ "\Save" ; Start-process 'C:\Windows\explorer.exe' -ArgumentList @($folderdir) ; start-sleep -seconds 2; ShowMenu }
    else { Write-host "`n`nPlease make a valid selection" -foregroundcolor red;  start-sleep -seconds 2; ShowMenu }
}
ShowMenu
Write-Host "`n`nThanks for using etcha-sketch`'s Scrap Mechanic Backup Tool!"
Write-host "Visit https://github.com/etcha-sketch for more useful tools."
start-sleep -seconds 5
