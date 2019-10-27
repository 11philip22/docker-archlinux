String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("prepare rootfs") {
        // def build_container = docker.image("arch-build").withRun("--privileged")
        //     build_container.inside {
        //     sh "builtfs"
        // }
        sh "docker-compose up -d"
        sh "docker-compose exec -T arch-build 'builtfs >> /build/log'"
        sh "docker-compose down"
        sh "mv ./build/archlinux.tar ."
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
}
