# brainvisa-vbox

Create a directory for your brainvisa image:
`mkdir brainvisa-5.1.0`

Download the brainvisa ova file:
`wget -O brainvisa-5.1.0/brainvisa-5.1.0.ova https://brainvisa.info/download/brainvisa-5.1.0.ova`

Run the script to export it as a docker image:
`sudo ./Ova2Docker.sh brainvisa-5.1.0/brainvisa-5.1.0.ova`

## Acknowledgement

This research was supported by the EBRAINS research infrastructure, funded from the European Union’s Horizon 2020 Framework Programme for Research and Innovation under the Specific Grant Agreement No. 945539 (Human Brain Project SGA3).
