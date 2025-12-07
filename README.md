DISCLAIMER: I have used chatgpt to help me diagnose this issue and write this text. This was tested on a Rog Ally X running bazzite, A windows version could be made. 
(Will proof read later just wanted to have this publicly available.)

# ROG Ally X – SD Card Stutter Fix  
### Realtek RTS525A Voltage-Switch Bug: Technical Summary & Workaround

This repository documents the diagnosis and workaround for SD card stuttering on the **ASUS ROG Ally X** when using the internal **Realtek RTS525A** SD card reader. The issue causes periodic in-game stutter when running titles from the SD card and produces voltage-switch errors in kernel logs.

The fix below fully eliminates the problem.

---

### 1. Symptoms

- Games/emulators stutter for 1–2 seconds when run from the SD card.
- No stutter occurs when running the same game from NVMe.
Kernel logs show errors such as:
- mmc1: cannot verify signal voltage switch
- mmc1: error -110
- mmc1: voltage switch failed


- Stutter disappears the moment continuous SD I/O occurs.

---

### 2. Root Cause (Verified Through Testing)**

### Realtek RTS525A enters a broken low-power state**

After ~4 seconds of no SD activity, the controller:

1. Enters a deep runtime idle state  
2. Attempts a **1.8 V UHS-I voltage switch** when waking  
3. Frequently fails the voltage switch
4. Resets/retries, causing **1–2 second I/O stalls**

These stalls surface as **regular gameplay stutters**.

### Why OS settings don't help

Tests showed:

- `mmc0/power/control=on` does not prevent the bug  
- Card-level power control causes a forced rebind (crashes applications)  
- Read-only keepalive fails due to caching  
- No `uhs_*` sysfs controls are exposed  
- The behaviour originates inside the **Realtek firmware**, not Linux  

---

### 3. The Fix: A Lightweight Write-Based Keep-Alive

A tiny physical write every 3 seconds prevents the controller from entering its unstable idle state.

This was validated experimentally:

- 5 seconds → stutter still occurs  
- 4 seconds → borderline  
- **3 seconds → fully stable**  

### Why it works

- Only **real block writes** reset the controller’s internal idle timer  
- Cached reads do not  
- Keeping the card “alive” bypasses the faulty voltage-switch path entirely

---

### 4. Script + Systemd User Service

after creating scripts use the following to enable service:

systemctl --user daemon-reload
systemctl --user enable sd-keepalive.service
systemctl --user start sd-keepalive.service

---

### 5. Wear and Power Usage
NAND wear

At 1 byte every 3 seconds during 3 hours/day of gaming:

~3.6 KB/day
~1.25 MB/year
~6 MB over 5 years

---

### 6. Final Diagnosis

Problem:
Realtek RTS525A voltage-switch failures when recovering from deep idle.

Cause:
Internal firmware behaviour, not controllable by kernel runtime power settings.

Effect:
Stalls SD I/O for 1–2 seconds → gameplay stutter.

Solution:
Prevent the controller from entering the problematic idle state via a lightweight periodic 1-byte write.

---

### 7. Notes on PCIe ASPM (Active State Power Management)

ASPM was investigated because the Realtek RTS525A SD reader is a PCIe device.  
On some systems, aggressive ASPM can cause latency spikes during link power-state transitions.

### Findings from testing on the ROG Ally X

- The usual Linux interfaces for adjusting ASPM (`/sys/module/pcie_aspm/parameters/policy`, `/sys/bus/pci/.../link/*`) were either **read-only** or **not writable**.
- This indicates that ASPM policy is **locked by firmware/BIOS** on the Ally X, and cannot be modified from the operating system.
- The device consistently stayed in the same link state regardless of attempted configuration.
- Stuttering and voltage-switch failures continued unchanged.

### Why ASPM is not involved

The problematic behavior occurs at the **MMC/SD voltage-switch layer**, not at the PCIe link layer.  
The Realtek controller transitions into an internal low-power state independent of ASPM and fails during recovery, triggering MMC errors such as:


