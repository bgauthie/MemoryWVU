conf = struct();
%conf.root = 'D:/Episodic_Memory_Sonication/';
conf.root = 'E:\Blanke\MemoryWVU_baptiste';

conf.dir_stim = [conf.root '/'];
conf.subdir1 = 'DATA_RTs/';
conf.subdir2 = 'DATA_Perf/';
conf.indoor = [conf.root '/Pictures/Indoor/*.jpg'];
conf.outdoor = [conf.root '/Pictures/Outdoor/*.tif'];

conf.indoorscrambled = [conf.root '/Pictures/IndoorScrambled/*.jpg'];
conf.outdoorscrambled = [conf.root '/Pictures/OutdoorScrambled/*.jpg'];

conf.dir_outdoor = [conf.root '/Pictures/Outdoor/'];
conf.dir_indoor = [conf.root '/Pictures/Indoor/'];

conf.dir_outdoorscrambled = [conf.root '/Pictures/OutdoorScrambled/'];
conf.dir_indoorscrambled = [conf.root '/Pictures/IndoorScrambled/'];

conf.dir_rt = [conf.root '/DATA_RTs/'];
conf.dir_retrieval = [conf.root '/Pictures/Retrieval/'];

conf.debug = 0;