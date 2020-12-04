# pinstaller
**pinstaller** is an extendable, semi-automated virtual pinball installation script providing semi-automated installation of numerous components related to virtual pinball cabinet installations.

**WARNING, This application is still very much in early alpha stages and not yet suitable for usage, be patient**

**pinstaller** is:
* A Windows, script-based installer framework
* Faster than manual installs (once configured)
* Able to produce repeatable install results
* Driven by configuration scripts which control which components to install and how

**pinstaller** is NOT:
* A source of installation media
* A replacement for individual applications being installed, rather it facilitates their installation 

## Why
There are numerous great videos out there describing the process of performing a full installation of virtual pinball software on a cabinet - however this process is at the mercy of human error. This application attempts to reduce some of that risk, and at the same time speed up the process of installing software on a cabinet, as well as providing the ability to configure the install for repeatability.

## Supported Components
Initial supported components align to the needs of my cabinet, however the architecture of the **pinstaller** platform should allow for realtively easy addition of new components as needed.

**The following components are currently being supported - or on the sort term addition list:** 
* Pinball Simulators:
  * Visual Pinball (VPX): https://www.vpwiki.net/Visual_Pinball
  * Future Pinball - including BAM: https://www.vpwiki.net/Future_Pinball, https://www.vpwiki.net/BAM
* Simulation Enrichments:
  * FlexDMD: https://www.vpwiki.net/FlexDMD
  * Direct Output Framework (DOF): https://www.vpwiki.net/Direct_Output_Framework_(DOF)  
  * DOFLinx: https://www.vpwiki.net/DOFLinx
  * PinEvent: https://www.vpwiki.net/PinEvent
* Frontends:
  * PinUP System (Player/Popper): https://www.vpwiki.net/PinUP_Player, https://www.vpwiki.net/PinUP_Popper

## Implementation Status
| Component     | Status        |
| ------------- |:-------------:|
| Installer Framework and Utils | :black_square_button: in progress |
| VPX Installer | :white_check_mark: implemented |
| Future Pinball/BAM Installer | :red_circle: not started |
| DirectOutputFramework Installer | :white_check_mark: implemented |
| Pinup Player Installer | :white_check_mark: implemented |
| Pinup Popper Installer | :red_circle: not started |
| FlexDMD Installer | :red_circle: not started |
| PinEvent Installer | :red_circle: not started |
| VPX Table Installer | :white_check_mark: implemented |
| Pinup Video Installer | :white_check_mark: implemented |

## Future Components / Potential Additions
These components are on the wishlist for future addition:
* PinVol: https://www.vpwiki.net/PinVol
* PinballX: https://www.vpwiki.net/PinballX
* PinballY: https://www.vpwiki.net/PinballY
