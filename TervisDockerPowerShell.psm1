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
        $ImageName
    )
    $Arguements = "run","--tty", "--interactive"

    foreach ($Key in $EnvironmentVariables.Keys) {
        $Arguements += "--env", "$Key=`"$EnvironmentVariables.$Key`""
    }
    
    $Arguements += "--name", $Name, $ImageName

    & docker $Arguements
}
