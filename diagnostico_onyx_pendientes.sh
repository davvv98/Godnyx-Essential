#!/system/bin/sh
# Ejecutar: su -c 'sh /sdcard/Download/diagnostico_onyx_pendientes.sh'
echo '=== SERVICIOS XIAOMI ==='
service list | grep -iE 'xiaomi.*(touch|display)'
echo '=== TOUCH ==='
ls -l /sys/class/touch/ /sys/class/touch/touch_dev/ /dev/xiaomi-touch* 2>/dev/null
cat /proc/tp_fw_version 2>/dev/null
for n in /sys/class/touch/touch_dev/*; do
    [ -e "$n" ] && ls -ld "$n"
done
echo '=== GPU ==='
for n in gpu_model gpuclk gpu_busy_percentage gpubusy; do
    echo "--- $n"
    cat "/sys/class/kgsl/kgsl-3d0/$n" 2>/dev/null
done
echo '=== CARGA ==='
for d in battery usb; do
    for n in constant_charge_current constant_charge_current_max charge_control_limit charge_control_limit_max input_current_limit current_now voltage_now status usb_type; do
        f="/sys/class/power_supply/$d/$n"
        if [ -r "$f" ]; then echo "--- $f"; cat "$f"; fi
    done
done
