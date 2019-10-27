String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("prepare rootfs") {
        sh """ \
            #!/usr/bin/bash
            docker-compose exec arch-build builtfs
            archlinux.tar
        """
        sh "mv ./build/archlinux.tar ."
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
}
