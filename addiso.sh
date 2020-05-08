#!/bin/bash

# Grub image adder by Don B. Cilly (donbcilly@gmail.com) #
########### This script will add an entry to your grub boot menu for the ISO selected by the Dolphin Service Menu ##########
########### It will not work if not called from it ##########
###########
########### This is the experimental version ###########
########### To actually make it work, comment out the "echo "$grubentry" >>customentry.txt" line ##########
########### and uncomment the following one  ###########
########### Do the same for the"ls -la" one  ###########
isoentry="$1";isoshort="${isoentry##*/}"
echo A couple of checks:

FILE=$(which isoinfo)
if [ -f "$FILE" ]; then
    echo "$FILE exist." $'\e[0;36m' "OK."$'\e[0;37m'
else 
    echo "isoinfo is" $'\e[0;31m' "not installed." $'\e[0;37m' "Please [sudo apt] install genisoimage and run this again.";exit
fi
echo
part=$(df -P . | sed -n '$s/[[:blank:]].*//p');p1=${part:7:1};p2=${part:8:1};p3=$(tr abcdefghij 0123456789 <<< "$p1");p4="hd"$p3,$p2
ptype=${part:5:1}
case $ptype in 
n) p1=${part:9:1};p2=${part:13:1};p4="hd"$p1,$p2                   ;;
s) p1=${part:7:1};p2=${part:8:1};p3=$(tr abcdefghij 0123456789 <<< "$p1");p4="hd"$p3,$p2                         ;;
esac
echo The partition your ISO is on is $'\e[0;32m' $part $'\e[0;37m'
echo "grub notation": $p4
echo
echo
grbv=$(grub-install --version  | awk '/(GRUB)/ {print substr($3,4,1)}')
case $grbv in 
2) echo Your grub version is $'\e[0;32m' "2.0"$grbv".  OK." $'\e[0;37m'
lz=$(isoinfo -l -i $isoentry |grep -i initrd | awk '{ print substr($NF, 1, length($NF)-2)}' | tr '[A-Z]' '[a-z]')
grubentry="$(cat <<-EOF
#
#
#!/bin/sh
exec tail -n +3 \$0
menuentry "$isoshort" {
        set isofile="$isoentry"
        loopback loop ($p4)\$isofile
        linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=\$isofile noprompt noeject toram
        initrd (loop)/casper/$lz
}
EOF
)"              ;;
4) echo Your grub version is $'\e[0;33m' "2.0"$grbv". Grub 2.04 is known to have problems with loopack devices." $'\e[0;37m'
isoentry="$1"
lz=$(isoinfo -l -i $isoentry |grep -i initrd | awk '{ print substr($NF, 1, length($NF)-2)}' | tr '[A-Z]' '[a-z]')
grubentry="$(cat <<-EOF
#
#
#!/bin/sh
exec tail -n +3 \$0
menuentry "$isoshort" {
        set isofile="$isoentry"
        rmmod tpm
        loopback loop ($p4)\$isofile
        linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=\$isofile noprompt noeject toram
        initrd (loop)/casper/$lz
}
EOF
)"             ;;
###read -rsn1 -p"Press any key to continue";echo ;;
esac

echo $'\e[0;36m'Adding entry to /etc/grub.d/40_custom...
#echo "$grubentry" | sudo tee -a /etc/grub.d/40_custom ## This is the actual line
echo "$grubentry" >>~/.local/share/kservices5/ServiceMenus/customentry.txt ## This is the line for testing purposes :·)
echo $'\e[0;36m'Done
echo Entry added to /etc/grub.d/40_custom
echo
#echo The added entry was:
#echo $'\e[0;37m'
#tail -10 ~/.local/share/kservices5/ServiceMenus/customentry.txt
#echo $'\e[0;36m'
echo
while true; do
    read -p "Does that look correct? y/n: " yn
    case $yn in
        [Nn]* ) echo Close the window to exit.;exit;;
        [Yy]* ) echo "OK. Let's update grub then."; break;;
    esac
done
echo
echo
while true; do
    read -p "Would you like to update grub? y/n: " yn
    case $yn in
        [Nn]* ) echo Close the window to exit.;exit;;
        [Yy]* ) echo OK.; break ;;
    esac
done
echo
echo "Updating grub..."
echo $'\e[0;37m'
#pkexec update-grub ## This is the actual line
ls -la ## This is the line for testing purposes :·)
echo $'\e[0;36m'
echo "Let's check. "
echo "These are the last 24 lines of /boot/grub/grub.cfg:"
echo $'\e[0;37m'
tail -24 /boot/grub/grub.cfg
echo $'\e[0;36m'
echo "You should find an entry for 'New bootable ISO' in your grub menu that should boot the OS"
echo
echo Close the window to exit.
