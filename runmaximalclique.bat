@echo off

set DATASET_FOLDER=%1%
set MAX_CLIQUE=%2$
 
bin\mace.exe MqVe -l %MAX_CLIQUE% %DATASET_FOLDER%\features\match.grh %DATASET_FOLDER%\features\match_maximal_clique.grh



