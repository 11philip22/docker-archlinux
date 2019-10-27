String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("prepare rootfs") {
        sh """
            rm -rf build_dir
            chmod +x ./build_rootfs.sh
            ./build_rootfs.sh
        """
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
}
