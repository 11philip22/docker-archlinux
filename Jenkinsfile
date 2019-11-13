String dockerHubUser = "philipwold" 
String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("run dos2unix") {
        sh "find . -type f -print0 | xargs -0 dos2unix"
    }
    
    stage ("prepare rootfs") {
        rel_date = sh (
            script: "date +%Y.%m.01",
            returnStdout: true
        ).trim()
        sh """\
            wget -O archlinux.tar.gz \
                http://archlinux.de-labrusse.fr/iso/latest/archlinux-bootstrap-${rel_date}-x86_64.tar.gz
            
            tar --exclude=root.x86_64/etc/resolv.conf --exclude=root.x86_64/etc/hosts -xvf archlinux.tar.gz || true
        """
    }
    
    stage ("download tini") {
        sh """\
            curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/tini_release_tag -L https://github.com/krallin/tini/releases
            tini_release_tag=$(cat /tmp/tini_release_tag | grep -P -o -m 1 '(?<=/krallin/tini/releases/tag/)[^"]+')
            curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o tini -L "https://github.com/krallin/tini/releases/download/${tini_release_tag}/tini-amd64"
            chmod +x tini
        """
    }

    stage ("docker build") {
        def mpd_image = docker.build("${dockerHubUser}/${repo}")
        mpd_image.push()
    }qqqqq
    
    stage ("cleanup") {
        sh "rm archlinux.tar.gz"
        sh "rm -rf archlinux.tar.gz"
    }
}
