# RhythmicAlly
Your R and Shiny based open source ally for the analysis of biological rhythms


Research on circadian rhythms often requires researchers to estimate period, robustness and phase of the rhythm.  These are important to estimate owing to the fact that they act as readouts of different features of the underlying clock.  The commonly used tools, to this end, suffer from either being very expensive or have very limited interactivity or are very cumbersome to use, or a combination of these.  To overcome these issues and to ease the analysis of biological time-series data, we have written RhythmicAlly, an open source program using R and Shiny that has the following advantages; a) it is free, b) it allows subjective marking of phases on actograms, c) provides high interactivity with graphs, d) allows visualisation and storing of data for a batch of individuals simultaneously, and e) does what other free programs do but with fewer mouse clicks, thereby being more efficient and user-friendly.  Moreover, in many cases, due to experimental constraints time series data for estimating periodicity can only be obtained over shorter intervals of time (relative to what is required in traditional time-series analyses methods).  Such data can be analysed using COSINOR, but given that most biological time-series, even if rhythmic are not sinusoidal, COSINOR is not appropriate in such situations.  Autocorrelation based method must be employed and RhythmicAlly allows you to do so (in addition to Enright and Lomb-Scargle periodograms).  The first version of RhythmicAlly is available on Github and we aim to maintain the program with subsequent versions having updated methods of analysing and visualising time-series data.  Although the goal of RhythmicAlly was to cater to biological rhythms in the circadian range, changing parameters can also allow one to use the program for analysing ultradian or infradian rhythms.  Lastly, RhythmicAlly will appeal to researchers who are uncomfortable with coding due to the availability of a user-friendly GUI and also to researchers who are familiar with coding who can very easily modify the codes to tailor the program specifically to their data.

Link to download RhythmicAlly:  https://github.com/abhilashlakshman/RhythmicAlly

RhythmicAlly was created and is maintained by Abhilash Lakshman.  Any queries regarding usage or bugs in the code must be addressed to abhilashl@jncasr.ac.in.

Last update on: 28th February 2019.

We are planning to submit RhythmicAlly as a manuscript, so that people who use it can cite the program.  But until then, it would be great if you acknowledged us in case you use this software to analyse your datasets.

PLEASE READ THE MANUAL BEFORE USING
