# Experiment 1

## Data

(1) In this first exploratory experiment, we will assume 6 regions:
  
  * Northwest islands (R);
  * Hawaii (H);
  * Maui Nui complex (M);
  * Oahu (O);
  * Kauai (K);
  * Continent (Z);
  
(2) We will use 6 epochs, going backwards in time:

  * Epoch 1 (age1): Present to appearance of Hawaii (at 1.2 Ma);
  * Epoch 2 (age2): Appearance of Hawaii to appearance of Maui-Nui complex (from 1.2 to 2.55 Ma);
  * Epoch 3 (age3): Appearance of Maui-Nui complex to appearance of Oahu (from 2.55 to 4.135 Ma);
  * Epoch 4 (age4): Appearance of Oahu to appearance of Kauai (from 4.135 to 6.15 Ma);
  * Epoch 5 (age5): Appearance of Kauai to deeper times, assuming islands Northwest of it always existed and so did the continent (from 6.15 to deeper times)
  
The boundaries between epochs, which is what we need to set the model up, are summarized in `experiment/feats_epochs/age_summary.csv`:

```
index,age_end
4,6.15
3,4.135
2,2.55
1,1.2
```

Source for these age ends: [Isaac will fill this out]

(3) One feature of each kind

TODO: update below this point

In `age1/cb1.csv` (present, all islands exist):

```
R,K,O,M,H,Z
0,1,1,1,1,0
0,0,1,1,1,0
0,0,0,1,1,0
0,0,0,0,1,0
0,1,1,1,1,0
```

In `age5/cb1.csv` (only R and continent exist):

```
X,K,O,M,H,Z
0,nan,nan,nan,nan,0
nan,0,nan,nan,nan,nan
nan,nan,0,nan,nan,nan
nan,nan,nan,0,nan,nan
nan,nan,nan,nan,0,nan
1,nan,nan,nan,nan,0
```

(4) One quantitative within (qw) feature, representing island area, from Lim & Marshall (2017):

In `age1/qw1.csv` (present, all islands exist):

```
R,K,O,M,H,Z
1000,1431,1548,3155,10434,3500
```

In `age5/qw1.csv` (only continent exists):

```
R,K,O,M,H,Z
1500,nan,nan,nan,nan,1000
```

