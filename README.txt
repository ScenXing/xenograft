#!/bin/bash
#####################################################################
##### Author: Sen Peng #####
##### Date: March 2015#####
#######################################
#@@@@@@@@@@@@@@@@#
## INTRODUCTION ##
#@@@@@@@@@@@@@@@@#

This software is used to classify massively parallel sequencing reads between human and mouse genome. Our tool will apply an alignment-based approach to improve the aligned percentage and the capability of further fusion calling. Moreover, it will assign "both" group reads (read sequence are essentially the same between human and mouse, and thus could not be differentiated) RANDOMLY to each class based on the established human mouse ratio. Proper handling of "both" group will avoid underestimation nor overestimation of gene expression.

#@@@@@@@@@@@@@@@@#
## REQUIREMENTS ##
#@@@@@@@@@@@@@@@@#
This software requires the following tools/software to be installed:

perl  v5.10.1 or up
linux commands: cat, case, cd , cut, sed, grep, awk, sort, uniq, bc, wc, mv, cp, head , pwd, echo, for while, if, bash, read, mkdir, wait, do, rm, local.


#@@@@@@@@@@@@@@@@#
##### INPUTS #####
#@@@@@@@@@@@@@@@@#
3 files(MANDATORY but extensible):
PreprocessedFileContainingInfoAboutRatio(H/M)
BothRead1File
BothRead2File









