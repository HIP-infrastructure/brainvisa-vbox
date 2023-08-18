# brainvisa-vbox

Create a directory for your brainvisa image:
`mkdir brainvisa-5.1.0`

Download the brainvisa ova file:
`wget -O brainvisa-5.1.0/brainvisa-5.1.0.ova https://brainvisa.info/download/brainvisa-5.1.0.ova`

Run the script to export it as a docker image:
`sudo ./Ova2Docker.sh brainvisa-5.1.0/brainvisa-5.1.0.ova`
