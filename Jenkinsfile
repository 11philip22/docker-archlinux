String dockerHubUser = "philipwold" 
String repo = "archlinux"

node ("master") {
    try {
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
            sh """
                wget -O archlinux.tar.gz \
                    http://archlinux.de-labrusse.fr/iso/latest/archlinux-bootstrap-${rel_date}-x86_64.tar.gz
                
                tar --exclude=root.x86_64/etc/resolv.conf --exclude=root.x86_64/etc/hosts -xvf archlinux.tar.gz || true
            """
        }
        
        stage ("download tini") {
            sh "chmod +x download_tini.sh; ./download_tini.sh"
        }

        stage ("docker build") {
            def mpd_image = docker.build("${dockerHubUser}/${repo}")
            mpd_image.push()
        }
        
        stage ("cleanup") {
            sh "rm archlinux.tar.gz"
            sh "rm -rf archlinux.tar.gz"
        }
    }

    catch(err){
        println(err.toString())
        error(err.getMessage())
        currentBuild.result = 'FAILED'
        exception_msg = err.getMessage();
    }

    finally {
        stage('Clean Workspace') {
            cleanWs()
        }
    }
}