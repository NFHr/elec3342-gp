# ELEC3342 Group Project: The Music Code Decoder

## Usage

```bash
wget https://www.eee.hku.hk/~elec3342/fa23/handout/elec3342_prj_tmpl.tar.gz
tar -xzf elec3342_prj_tmpl.tar.gz
cd elec3342_prj_tmpl
git init
git remote add -t * -f origin https://github.com/NFHr/elec3342-gp.git
git checkout --force main
```

* Noted that ```git checkout --force main``` will overwrite all your local changes.

## Milestones

* [x] Milestone 1: Full Music Code decoder simulation
* [x] Milestone 2: Implementation on FPGA
  * [x] mcdecoder
  * [x] myuart
  * [x] symb_dect
* [x] Milestone 3
  * [x] Expand the code book

## Group Roles

You may add your group contributions as you wish.

### Milestone 1

#### Original Code

* mcdecoder.vhd – Guo Hao, Long Liangmao
* myuart.vhd – Guo Hao
* symb_dect.vhd – Long Liangmao, Guo Bao

-> Integrating: Guo Bao

### Milestone 2

#### Code improvements:

* mcdecoder -- Long Liangmao
* myuart -- Long Liangmao
* symb_dect -- Zhang Xiangyu (tried many versions), Guo Bao and Long Liangmao (final version)

* dpop -- Long Liangmao (unused in milestone 3)

### Milestone 3

#### Expand the code book

* mcdecoder -- Guo Hao

* symb_dect -- Long Liangmao