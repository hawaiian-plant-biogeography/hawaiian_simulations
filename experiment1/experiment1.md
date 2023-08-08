# Experiment 1

## Data

(1) In this first exploratory experiment, we will assume 6 regions:

  * Hawaii (H);
  * Maui Nui complex (M);
  * Oahu (O);
  * Kauai (K);
  * Northwest islands (R);
  * Continent (Z);
  
(2) We will use 6 epochs, going backwards in time:

  * Epoch 1 (age1): Present to appearance of Hawaii (0.4 Ma);
  * Epoch 2 (age2): Appearance of Hawaii to appearance of Maui-Nui complex (2.0 Ma);
  * Epoch 3 (age3): Appearance of Maui-Nui complex to appearance of Oahu (3.0 Ma);
  * Epoch 4 (age4): Appearance of Oahu to appearance of Kauai (4.7 Ma);
  * Epoch 5 (age5): Appearance of Kauai to appearance of Necker ("R"; 11.0 Ma);
  * Epoch 6 (age6): Appearance of Necker to deeper times;
  
The boundaries between epochs, which is what we need to set the model up, are summarized in `experiment/feats_epochs/age_summary.csv`:

```
index,age_end
5,11.0
4,4.7
3,3.0
2,2.0
1,0.6
```

(3) One categorical between (cb) feature, representing the progression rule ("1" indicates migration from old to young), no interpolation needed:

In `age1/cb1.csv` (present, all islands exist):

```
R,K,O,M,H,Z
0,1,1,1,1,0
0,0,1,1,1,0
0,0,0,1,1,0
0,0,0,0,1,0
0,1,1,1,1,0
```

In `age6/cb1.csv` (only continent exists):

```
X,K,O,M,H,Z
0,nan,nan,nan,nan,nan
nan,0,nan,nan,nan,nan
nan,nan,0,nan,nan,nan
nan,nan,nan,0,nan,nan
nan,nan,nan,nan,0,nan
nan,nan,nan,nan,nan,0
```

(4) One quantitative within (qw) feature, representing island height, interpolation required:

In `age1/qw1.csv` (present, all islands exist):

```
R,K,O,M,H,Z
0.0,0.0,0.0,0.0,0.0,0.0
```

In `age6/qw1.csv` (only continent exists):

```
R,K,O,M,H,Z
nan,nan,nan,nan,nan,0.0
```

