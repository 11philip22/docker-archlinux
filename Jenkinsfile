String repo = "archlinux"
String rel_date = sh "date +%Y.%m.01"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("run dos2unix") {
        sh "dos2unix *"
    }
    
    stage ("prepare rootfs") {
        sh """
        wget -O /bootstrap/archlinux.tar.gz \
             http://archlinux.de-labrusse.fr/iso/latest/archlinux-bootstrap-${rel_date}-x86_64.tar.gz

        mkdir -p build
        tar --exclude=root.x86_64/etc/resolv.conf --exclude=root.x86_64/etc/hosts -xvf archlinux.tar.gz 
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
