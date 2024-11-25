# Accuracy Broadcaster

[ScrnBalance]: https://github.com/poosh/KF-ScrnBalance
[Poosh]: https://github.com/poosh
[KFUnflect]: https://github.com/InsultingPros/KFUnflect/releases

[![GitHub all releases](https://img.shields.io/github/downloads/InsultingPros/AccuracyBroadcaster/total)](https://github.com/InsultingPros/AccuracyBroadcaster/releases)

![img](Docs/media/example.png)

This is the only publicly available headshot accuracy broadcaster other than [Poosh]'s [ScrnBalance], but has a different implementation thanks to [KFUnflect]. Other private versions are directly ripped from ScrN and are too good to be used by us peasants.

All available variables can be found in [config file](Configs/AccuracyBroadcaster.ini), feel free to modify the accuracy message by your taste! And spam `mutate acc / accuracy` to enjoy yourself at any time.

## Installation

This mod depends on [KFUnflect], so don't forget to have it in your `System` directory.

```ini
AccuracyBroadcaster.AccuracyBroadcaster
```

## Building

Use [KF Compile Tool](https://github.com/InsultingPros/KFCompileTool) for easy compilation.

```ini
EditPackages=KFUnflect
EditPackages=AccuracyBroadcaster
```
