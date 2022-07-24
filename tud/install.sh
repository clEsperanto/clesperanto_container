#!/bin/bash
container_name=pyclesperanto
mkdir -p ~/.local/share/jupyter/kernels/$container_name
cp kernel_template.json ~/.local/share/jupyter/kernels/$container_name/kernel.json
userhome=$(ls -l $HOME | cut -d ">" -sf 2)
userhome=${userhome## }
sed -i "s|<userhome>|$userhome|g" ~/.local/share/jupyter/kernels/$container_name/kernel.json
cp files/icon-64x64.png ~/.local/share/jupyter/kernels/$container_name/
echo "downloading image from cloud.sylabs.io. this may take a while. Please do not interrupt this process..."
singularity exec -C --writable-tmpfs -B /etc/OpenCL --nv library://till.korten/pyclesperanto/pyclesperanto:latest echo "Done, you can open a jupyter notebook with a Py clEsperanto kernel now. Enjoy :)"