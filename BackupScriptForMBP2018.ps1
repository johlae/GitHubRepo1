# Om det är mer än 24 timmar sedan senaste backupen
$latestbackup = [datetime]::parseexact($(sudo tmutil latestbackup), 'yyyy-MM-dd-HHmmss', $null)
if ($latestbackup -lt [datetime]::Now.AddDays(-1))
    {   
        # Mät antal hopp till landet och pluto respektive
        $distanceLandet = (traceroute landetnas.local.laerum.se | Measure-Object).Count
        $distancePluto = (traceroute plutoplay.local.laerum.se | Measure-Object).Count
        
        # Om vi är närmast pluto gör en backup till destinationen med "pluto" i sitt namn
        if ($distanceLandet -gt $distancePluto)
        {
            Write-Host "Vi är i Pluto"
            $plutobackupID = $(sudo tmutil destinationinfo | Select-String -Pattern pluto -Context -0,2 | out-string -Stream | Select-String  -Pattern ID).ToString().Trim().TrimStart("ID            : ")
            sudo tmutil startbackup -d $plutobackupID
        }
        # Om vi är närmast landet gör en backup till destinationen med "landet" i sitt namn
        if ($distancePluto -gt $distanceLandet)
        {
            Write-Host "Vi är på Landet"
            $landetbackupID = $(sudo tmutil destinationinfo | Select-String -Pattern landet -Context -0,2 | out-string -Stream | Select-String  -Pattern ID).ToString().Trim().TrimStart("ID            : ")
            sudo tmutil startbackup -d $landetbackupID
        }
    }
