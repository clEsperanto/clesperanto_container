
## Notes from Meeting with Fabian

- [Fabians singularity recipe on github](https://github.com/dcgc-bfx/singularity-single-cell)
- store containers on cloud.sylabs.io (or a self-hosted singularity cloud registry) the [TU Chemnitz gitlab](https://gitlab.hrz.tu-chemnitz.de) has a registry for docker containers
- use date flags to identify containers
- start container on the cluster (use contain flag to ensure that only local libraries inside the container)
- bind mount the folder in your user directory where the socket files for the communication between jupyter kernel and jupyter hub happens 
- use the config file Fabian sent to tell jupyter hub how to start jupyter kernels within the singularity

## first steps

1. Get an account on Taurus (in my case I asked robert to add me to the bioimage project).
2. clone this repository
3. `mkdir -p ~/.local/share/jupyter/kernels/singularity-kernel`
4. `cp singularity-jupyter-hpc/kernel.json ~/.local/share/jupyter/kernels/singularity-kernel/`
5. replace `/home/h4/tkorten` with your username in `~/.local/share/jupyter/kernels/singularity-kernel/kernel.json`:
   Note: on Taurus, your user directory is actually a symlink to some other directory. Sou need to figure out to which actual directory your user directory is linked by doing a `ls -la ~` on the taurus command line. The result should look like this: `lrwxrwxrwx 1 root root 10 Jul 11 16:55 /home/tkorten -> h4/tkorten` this means in my case the home directory is actually `/home/h4/tkorten`

   ```json
    {
    "argv": [
    "singularity",
    "exec",
    "--writable-tmpfs",
    "-C",
    "--pwd",
    "{cwd}",
    "-B",
    "/home/h4/tkorten/.local/share/jupyter/runtime",
    "-B",
    "/home/h4/tkorten/",
    "-B",
    "/etc/OpenCL",
    "-B",
    "/projects",
    "library://fabianrost84/dcgc-bfx/singularity-single-cell.sif:e67259e",
    "python",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
    ],
    "display_name": "Python ssc.e67259e",
    "language": "python"
    }
   ```
6. Start a [jupyter lab session on taurus](https://taurus.hrsk.tu-dresden.de/jupyter/hub/home).
7. You should now see an additional button named `Python ssc.e67259e` on the jupyter lab home screen.
8. Klick on that button to start a jupyter notebook inside the singularity container. Note that the first command execution will take a while because of the additional time it takes to start the singularity container.

Note: if you want to start a different container, you can replace `library://fabianrost84/dcgc-bfx/singularity-single-cell.sif:e67259e` with the path (or library url) to that container.

## Creating your own containers

### Easy: From an existing docker container:

1. ssh into taurus and start an interactive job: `srun --pty --ntasks=1 --cpus-per-task=2 --mem-per-cpu=2541 --time=08:00:00 bash -l`
2. build the container: `singularity build tensorflow_2.9.1-gpu-jupyter.sif docker://tensorflow/tensorflow:2.9.1-gpu-jupyter`
3. follow **first steps** and replace the default image (the line starting with `library:`) with the full path to your new image in `kernel.json`.

### Intermediate: Create your own singularity container

1. create your own singularity recipe (see the [Singularity file](/Singularity) in this reposityory for an example). Recommendation: fork this repository and start from there.
2. apply for a Linux (e.g. Ubuntu 20.04 LTS) virtual machine from the [TUD self-service portal](https://selfservice.zih.tu-dresden.de/l/index.php/cloud_dienste/vm)
3. ssh into taurus and check their current singularity version: `singularity --version` (currently v3.5 from 2020)
3. In your vm, compile and install the same singularity version following the [official documentation](https://docs.sylabs.io/guides/3.5/user-guide/quick_start.html#quick-installation-steps)
4. get your singularity recipe onto the vm (e.g. by git cloning your forked repo) and cd into it.
5. build the singularity container: `singularity build py-clesperanto.sif Singularity`

Note: currently this fails, because there is not enoug disk space in the standard vms (20GB total) I asked to increase the space to 50 GB, but have not heard back yet.

### Advanced: Via gitlab ci

1. create a .gitlab-cy.yml in the root of your repository with the following content (adapted from https://gitlab.com/singularityhub/gitlab-ci): 
   ```yml
   image:
      name: quay.io/singularity/singularity:v3.5.3 #docker container configured for building singularity images
      entrypoint: ["/bin/sh", "-c"]

   build:
      script:
         - singularity build py-clesperanto.sif Singularity

            # step 1. build the container!
            # You can add any other sregistry push commands here, and specify a client
            # (and make sure your define the encrypted environment credentials in gitlab
            # to push to your storage locations of choice

         - mkdir -p build && cp *.sif build
         - mkdir -p build && cp Singularity* build

            # Step 2. Take a look at "artifacts" below and add the paths you want added
            # You can also add the entire build folder. You can also upload to storage
            # clients defined by sregistry, here are some examples
            # https://singularityhub.github.io/sregistry-cli/clients
            # Environment variables must be defined in CI encrypted secrets/settings
            # https://code.stanford.edu/help/ci/variables/README#variables).
            #- /bin/bash build.sh --uri collection/container --cli google-storage Singularity
            #- /bin/bash build.sh --uri collection/container --cli google-drive Singularity
            #- /bin/bash build.sh --uri collection/container --cli globus Singularity
            #- /bin/bash build.sh --uri collection/container --cli registry Singularity

      # This is where you can save job artifacts
      # https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html
      # You can specify the path to containers or the build folder to save.
      # Don't forget to save your recipes too!
      artifacts:
            paths:
            - build/py-clesperanto.sif
            - build/Singularity
   ```
   this builds a new image everytime you push to your repo. It is probably advisable to configure it such that it only runs when a new tag is pushed (and then builds an image with said tag)

Note: The CI job currently fails because the singularity docker container needs to run in a privileged runner, which we don't get. I wrote an email to the admins of our gitlab instance - let's see if they have suggestions. If they don't, we probably need to [host our own gitlab runner](https://docs.gitlab.com/runner/install/) on a machine for which we have root access.

## Debugging

Check that you can start the singularity container manually:
1. get an interactive command line on taurus: `srun --pty -n 1 -c 1 --time=1:00:00 --mem-per-cpu=1700 bash`
2. run `ipykernel_launcher` in Fabians singularity container: `singularity exec --writable-tmpfs -C --pwd $(pwd) -B /home/h4/tkorten/.local/share/jupyter/runtime -B /home/h4/tkorten/ -B /projects library://fabianrost84/dcgc-bfx/singularity-single-cell.sif:e67259e python -m ipykernel_launcher`
   
   you should see something like this:
   ```
   NOTE: When using the `ipython kernel` entry point, Ctrl-C will not work.

   To exit, you will have to explicitly quit this process, by either sending
   "quit" from a client, or using Ctrl-\ in UNIX-like environments.

   To read more about this, see https://github.com/ipython/ipython/issues/2049


   To connect another client to this kernel, use:
       --existing kernel-12.json
   ```