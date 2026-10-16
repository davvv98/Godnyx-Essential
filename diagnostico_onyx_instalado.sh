#!/system/bin/sh
# Solo lectura. Primero intentar GPU, CPU y color en la aplicación.
echo '=== ROOT Y SELINUX ==='
id
getenforce
echo '=== MODULO Y PROCESOS ==='
cat /data/adb/modules/nees_rodin_essential_backend/module.prop 2>/dev/null
pidof onyx_daemon
ps -AZ 2>/dev/null | grep -E 'onyx_daemon|onyxessential'
echo '=== SNAPSHOT DAEMON ==='
CTL=/data/adb/modules/nees_rodin_essential_backend/bin/onyx_ctl
if [ -x "$CTL" ]; then
    if command -v timeout >/dev/null 2>&1; then timeout 12 "$CTL" GET snapshot; else echo 'Sin timeout: se omite IPC para evitar bloqueo'; fi
fi
echo
echo '=== LOG DAEMON ==='
tail -n 90 /data/adb/onyx-essential/backend.log 2>/dev/null
echo '=== LOG APP ==='
logcat -d -v brief -s OnyxEssential '*:S' 2>/dev/null | tail -n 100
echo '=== DENEGACIONES RECIENTES ==='
logcat -d -b all -v brief 2>/dev/null | grep -i 'avc: denied' | grep -iE 'onyx|kgsl|cpufreq|displayfeature|touchfeature' | tail -n 35
echo '=== GPU ==='
for n in cur_freq min_freq max_freq governor available_frequencies available_governors; do
    f="/sys/class/kgsl/kgsl-3d0/devfreq/$n"
    echo "--- $f"
    ls -lZ "$f" 2>/dev/null
    cat "$f" 2>/dev/null
done
echo '=== CPU ==='
for p in 0 2 5 7; do
    d="/sys/devices/system/cpu/cpufreq/policy$p"
    for n in scaling_min_freq scaling_max_freq scaling_governor; do
        echo "--- $d/$n"
        ls -lZ "$d/$n" 2>/dev/null
        cat "$d/$n" 2>/dev/null
    done
done
echo '=== XIAOMI HAL ==='
service list | grep -iE 'xiaomi.*(touch|display)'
echo '=== TOUCH ==='
ls -lZ /sys/class/touch/ /sys/class/touch/touch_dev/ /dev/xiaomi-touch* 2>/dev/null
cat /proc/tp_fw_version 2>/dev/null
echo '=== CARGA ==='
for n in constant_charge_current constant_charge_current_max charge_control_limit charge_control_limit_max; do
    f="/sys/class/power_supply/battery/$n"
    echo "--- $f"
    ls -lZ "$f" 2>/dev/null
    cat "$f" 2>/dev/null
done
