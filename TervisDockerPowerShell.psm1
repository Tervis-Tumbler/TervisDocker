function Remove-DockerContainerAllOff {
    docker rm $(docker ps -a -q)
}

function Get-DockerContainer {
    docker ps -a
}