# singularity-jupyter-HPC

Run jupyter kernels inside custom singularity containers on an HPC cluster that runs jupyter lab

## quick start

1. Start a [jupyter lab session on taurus](https://taurus.hrsk.tu-dresden.de/jupyter/hub/home). Make sure to select at least one GPU.
2. In Jupyter lab, open a terminal and type the following commands. IMPORTANT: make sure to wait until the script reports that it is done. otherwise you may end up with a broken partial singularity image in your `~/.singularity/cache` directory.
   ```bash
   git clone https://gitlab.mn.tu-dresden.de/bia-pol/singularity-jupyter-hpc.git
   cd singularity-jupyter-hpc
   ./install.sh
   ```
3. You should now see an additional button named `Py clEsperanto` on the jupyter lab home screen.
4. Klick on that button to start a jupyter notebook inside the singularity container. Note that the first command execution will take a while because of the additional time it takes to start the singularity container.


## ToDo
I would try the following approach:
- [x] get Fabians singularity container to work for my user
- [x] create my own singularity container with vanilla jupyter and get that to work
- [x] get custom python modules to work within the vanilla jupyter container
- [x] get tensorflow to work with GPU support
- [x] get py-clesperanto to work with GPU support
- [x] write scripts to automate adapting to different users
- [ ] set up continuous integration so that new singularity containers are created automatically when a new version tag is set
- [ ] set up a storage for singularity images
