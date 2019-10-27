String repo = "archlinux"

node ("master") {
    stage ("checkout scm") {
        checkout scm
    }
    
    stage ("prepare rootfs") {
        sh """
            tmp_dir=\$(mktemp -d)
            env -i pacstrap -c -G -M \${tmp_dir} \
                pacman systemd

            cp --recursive --preserve=timestamps --backup --suffix=.pacnew rootfs/* \${tmp_dir}/
            arch-chroot \${tmp_dir} locale-gen
            arch-chroot \${tmp_dir} pacman-key --init
            arch-chroot \${tmp_dir} pacman-key --populate archlinux

            tar --numeric-owner --xattrs --acls --exclude-from=exclude -C \${tmp_dir} -c . -f archlinux.tar
            rm -rf \${tmp_dir}
        """
    }
    
    stage ("docker build") {
        def mpd_image = docker.build("philipwold/${repo}")
        mpd_image.push()
    }
}
