function Get-Uri($Hostname, $Secure, $Path){
    return "http://$hostname/$path"
}

function Get-Thermostat ($Hostname) {
    $response = Invoke-WebRequest -UseBasicParsing -Uri (Get-Uri -Hostname $Hostname -Path "tstat") -Method GET

    return $response | ConvertFrom-Json
}

function Get-ThermostatDatalog ($hostname){
    $response = Invoke-WebRequest -UseBasicParsing -Uri (Get-Uri -Hostname $Hostname -Path "tstat/datalog") -Method GET

    return $response | ConvertFrom-Json
}

function Set-ThermostatHold ([string]$Hostname, $Hold){
    $request = @{
        hold = 0    
    }

    if ($Hold -eq $true) {
        $request.hold = 1
    } else {
        $request.hold = 0
    }

    $uri = (Get-Uri -Hostname $Hostname -Path "tstat")
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $request)
}

function Set-ThermostatHeatSetpoint ([string]$Hostname, [float]$Temperature, [switch]$Hold, [switch]$SetMode) {
    $request = @{
        it_heat = $Temperature        
    }

    if ($Hold.IsPresent) {
        $request.hold = 1
    }

    if ($SetMode.IsPresent){
       $request.tmode = 1
    }

    $uri = (Get-Uri -Hostname $Hostname -Path "tstat")
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $request)
}

function Set-ThermostatTime([string]$Hostname){
    $now = Get-Date

    $dayOfWeek = [int]$now.DayOfWeek - 1
    # thermostat day of week is 0=monday
    if ($dayOfWeek -lt 0){
        $dayOfWeek = 6
    }

    $request = @{
        time = @{
            day = $dayOfWeek;
            hour = $now.Hour;
            minute = $now.Minute;
        }
    }

    $uri = (Get-Uri -Hostname $Hostname -Path "tstat")
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $request)
}

function Set-ThermostatOperatingMode([string]$Hostname, [string]$SystemMode){
    $tmode = 0

    if ($Mode -eq "Heat"){
        $tmode = 1
    } elseif ($Mode -eq "Cool"){
        $tmode = 2
    } elseif ($Mode -eq "Auto"){
        $tmode = 3
    } elseif ($Mode -eq "Off"){
        $tmode = 0
    }
   
    $request = @{
        tmode = $tmode
    }

    $uri = (Get-Uri -Hostname $Hostname -Path "tstat")
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $request)
}

function Set-ThermostatFanMode([string]$Hostname, [string]$SystemMode){
    $fmode = 0

    if ($Mode -eq "Auto"){
        $fmode = 0
    } elseif ($Mode -eq "Circulate"){
        $fmode = 1
    } elseif ($Mode -eq "On"){
        $fmode = 2
    }
   
    $request = @{
        fmode = $fmode
    }

    $uri = (Get-Uri -Hostname $Hostname -Path "tstat")
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $request)
}

function Get-ThermostatHeatProgram([string]$Hostname) {
    $uri = (Get-Uri -Hostname $Hostname -Path "tstat/program/heat")

    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method GET

    return ConvertFrom-Json $response
}

function Set-ThermostatHeatProgram([string]$Hostname, $DayOfWeek, $Program) {
    $uri = (Get-Uri -Hostname $Hostname -Path "tstat/program/heat/$DayOfWeek")

    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -Method POST -Body (ConvertTo-Json $Program)
}

#Set-ThermostatHeatSetpoint "172.17.71.123" 70.00
#Set-ThermostatHold "172.17.71.123" -Hold $False
#Get-Thermostat "172.17.71.123"
#Get-ThermostatHeatProgram "172.17.71.123"
#Set-ThermostatTime "172.17.71.123"
#Get-Thermostat "172.17.71.123"
#Set-ThermostatHold "172.17.71.123" -Hold $True
#Get-ThermostatDatalog "172.17.71.123"

$heat = @{
    "2" = @( 345, 70, 405, 70, 1080, 70, 1320, 69 );
}

Set-ThermostatHeatProgram -Hostname "172.17.71.123" -DayOfWeek wed -Program $heat

