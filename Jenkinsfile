String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    // stage ("run dos2unix") {
    //     sh "dos2unix *"
    // }
    
    stage ("prepare rootfs") {
        rel_date = sh (
            script: "date +%Y.%m.01",
            returnStdout: true
        ).trim()
        sh """
            wget -O archlinux.tar.gz \
                http://archlinux.de-labrusse.fr/iso/latest/archlinux-bootstrap-${rel_date}-x86_64.tar.gz
            
            tar --exclude=root.x86_64/etc/resolv.conf --exclude=root.x86_64/etc/hosts -xzf archlinux.tar.gz 
        """
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
    
    stage ("cleanup") {
        sh "rm archlinux.tar.gz"
        sh "rm -rf archlinux.tar.gz"
    }
}
