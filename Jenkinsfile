String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("prepare rootfs") {
        sh "docker-compose up -d"
        // sh "docker-compose exec -T arch-build builtfs"
        docker.image("arch-build").inside {
            sh "builtfs"
        }
        sh "docker-compose down"
        sh "mv ./build/archlinux.tar ."
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
}
