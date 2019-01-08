#MT-Doctor
This script recovers a faulty Apple® TimeMachine® backup when the volume is compromised due to power glitches or disconnection issue during backup execution.

The name is pronounced like the English name Emmet, after the "Back to the Future" Doc's name and corresponds to the inversion of TM (aka. TimeMachine®).

To execute the script it is enough to run:

```
$ <sudo> bash MT-Doctor.sh
```

Note that `sudo` is not required, but highly recommended since automatic stop and restart of the TimeMachine® demon can only be performed with high privileges.

This script has to be executed within Mac OS X and has been tested only with Mojave 10.14.1.