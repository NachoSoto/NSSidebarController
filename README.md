## SidebarController, created by Nacho Soto
### SidebarController is a similar menu controller to the one found in Facebook and Path 2.0 on iOS.

## License

Copyright 2012 by Nacho Soto
SidebarController is released under the [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0)

## Introduction

SidebarController is designed to be used in a similar way as how you use UINavigationController. 

## Installation

 1. Copy everything from "SidebarController" into your project.
 
## Usage

### You can instantiate it just like a UINavigationController

``` objective-c
  SidebarController *controller = [[SidebarController alloc] initWithMainController:mainController];
```

### Then, you can set the left and/or right controllers

``` objective-c
  controller.leftController = leftController;
  controller.rightController = rightController;
```

### Whenever you want to show either menu, from your main controller you call:

``` objective-c
  [self.sidebarController showLeftController];
  [self.sidebarController showRightController];
```

### And from the menus you can easily replace the main controller, and this will animate nicely to show the new one:

``` objective-c
  [self.sidebarController replaceMainController:newController];
```

## Contact
- http://github.com/NachoSoto
- http://twitter.com/NachoSoto
- hello@nachosoto.com
- http://www.nachosoto.com