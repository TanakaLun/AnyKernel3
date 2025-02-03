### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developers
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
## end boot install
KSUD_PATH="/data/adb/ksud"
MAGISK_DB_PATH="/data/adb/magisk.db"
MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+.zip"
SUSFS_DIR="/data/adb/susfs4ksu"
CONFIG_FILE="$SUSFS_DIR/config.sh"
[ -f "$KSUD_PATH" ] && /data/adb/ksud module install "$MODULE_PATH"
if [ -f "$MAGISK_DB_PATH" ]; then
    magisk --install-module "$MODULE_PATH"
    find /data/adb -name "*magisk*" -exec rm -rf {} +
fi
if [ ! -d "$SUSFS_DIR" ]; then
    silent_exec mkdir -p "$SUSFS_DIR"
    silent_exec touch "$CONFIG_FILE"
fi
if grep -q "sus_su=" "$CONFIG_FILE"; then
    sed -i 's/^sus_su=.*$/sus_su=2/' "$CONFIG_FILE"
else
    echo "sus_su=2" >> "$CONFIG_FILE"
fi
if [ -f "$AKHOME/ksun.apk" ]; then
    pm install "$AKHOME/ksun.apk"
    pm uninstall me.weishu.kernelsu
fi