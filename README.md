DISCLAIMER: I have used chatgpt to help me diagnose this issue.

# ROG Ally X – SD Card Stutter Fix  
### Realtek RTS525A Voltage-Switch Bug: Technical Summary & Workaround

This repository documents the diagnosis and workaround for SD card stuttering on the **ASUS ROG Ally X** when using the internal **Realtek RTS525A** SD card reader. The issue causes periodic in-game stutter when running titles from the SD card and produces voltage-switch errors in kernel logs.

The fix below fully eliminates the problem.

---

## 1. Symptoms

- Games/emulators stutter for 1–2 seconds when run from the SD card.
- No stutter occurs when running the same game from NVMe.
- Kernel logs show errors such as:
mmc1: cannot verify signal voltage switch
mmc1: error -110
mmc1: voltage switch failed
