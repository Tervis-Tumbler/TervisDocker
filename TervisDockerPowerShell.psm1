function Remove-DockerContainerAllOff {
    docker rm $(docker ps -a -q)
}

function Get-DockerContainer {
    docker ps -a
}

function Get-DockerImage {
    docker image ls
}

function Invoke-DockerContainer {
    param (
        $EnvironmentVariables,
        $Name,
        $ImageName,
        $Volumes,
        [Switch]$Force,
        [Switch]$Interactive
    )
    if ($Force) {
        & docker rm $Name
    }

    $Arguements = "run","--tty", "--interactive"

    if ($Interactive) {
        $Arguements += "--interactive"
    }

    foreach ($Key in $EnvironmentVariables.Keys) {
        $Arguements += "--env", "$Key=`"$($EnvironmentVariables.$Key)`""
    }
    foreach ($Key in $Volumes.Keys) {
        $Arguements += "--volume", "$Key`:$($Volumes.$Key)"
    }
    
    $Arguements += "--name", $Name, $ImageName

    & docker $Arguements
}

function Start-DockerContainer {
    param (
        $Name,
        [Switch]$Interactive
    )
    $Arguements = "start", $Name
    if ($Interactive) {
        $Arguements += "--interactive"
    }

    & docker $Arguements
}

function Invoke-DockerContainterPowerShell {
    param (
        [Switch]$Nightly
    )
    $PasswordStateAPIKey = Get-PasswordstatePassword -ID 3985 | Select-Object -ExpandProperty Password
    $ImageName = if($Nightly) {
        "microsoft/powershell-nightly"
    } else {
        "microsoft/powershell"
    }
    
    Invoke-DockerContainer -Name pwshtest -ImageName $ImageName -Volumes @{$(Get-UserPSModulePath)="/root/.local/share/powershell/Modules"} -Force -EnvironmentVariables @{PasswordStateAPIKey=$PasswordStateAPIKey}
}

function Invoke-DockerContainerPowerShellManually {
    docker run -dit --name powershell --restart unless-stopped microsoft/powershell
    gci "C:\Users\c.magnuson\OneDrive - tervis\Documents\WindowsPowerShell\Modules\TervisPasswordstatePasswordCache" |
    % {
        docker cp "$($_.FullName)" "powershell:/root/$($_.Name)"
    }
    #https://rominirani.com/docker-on-windows-mounting-host-directories-d96f3f056a2c
    $ModulePath = Get-UserPSModulePath
    $ModulePathInDockerVolumeFormat = $ModulePath -replace "\\", "/"
    docker run -dit --name powershell -v "$($ModulePathInDockerVolumeFormat):/usr/local/share/powershell/Modules" mcr.microsoft.com/powershell:6.2.0-alpine-3.8
    docker exec -it powershell pwsh


    #https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal
    az account set --subscription "Production and Infrastructure - Microsoft Azure Enterprise"
    az acr login --name tervisinfrastructure

    docker tag envoyproxy/envoy-alpine:v1.9.0 tervisinfrastructure.azurecr.io/envoy2:v1
    docker push tervisinfrastructure.azurecr.io/envoy2:v1
}