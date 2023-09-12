# RoboPlan5G

This is the public repository for the RoboPlan5G system, a joint robot/5G-radio planner and optimization system.

This repository contains the files necessary to run the simulation example from the ETFA 2023 paper _RoboPlan5G: Coordinating Cloud-Controlled Mobile Robots with 5G Network Configuration_, as well as other PDDL-style plans.

## Requirements
Currently, the following software is required to be installed:
- [webots](https://www.cyberbotics.com/) R2023b (required for controller support)
- MATLAB (only tested with 2021a, older versions may work)
- Optional: A [LPG-_td_](https://lpg.unibs.it/lpg/) installation, for example [planutils](https://github.com/AI-Planning/planutils) for testing your own plans

## Usage
```
webots Webots/warehouse-demo/worlds/warehouse-demo.wbt
```

![Picture1](https://github.com/nilsjor/RoboPlan5G/assets/41992014/9177fa26-0c26-41e7-88fe-35627599c0ac)

## Running your own plans
For this, [LPG-_td_](https://lpg.unibs.it/lpg/) (or any other temporal planner) is needed---see above.
Make sure to save your output to `PDDL/domains/network-aware/tempo-numeric/solutions` and change the appropriate file name in the controller code.
