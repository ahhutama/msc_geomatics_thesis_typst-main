#import "../template.typ": *
#import "../other_tools/styled-blocks.typ": block-discussion, block-todo

= Implementation <chap:implementation>

This chapter begins by outlining all the datasets required for conducting this research, including the historical maps and supporting datasets as described in @sec:datasets. @sec:studyarea describes the study area for each method. In addition, the tools and hardware used to implement and test the methodologies are also described in @sec:tools and @sec:hardware respectively.

== Datasets <sec:datasets>
 As mentioned in the previous chapter, this research involves 2 main methodologies, each method requires different datasets. For Method 1, multi-temporal Dutch historical topographic maps or the _Bonnebladen_ map series is used as the main dataset. Subsequently, historical land use data (_Historisch Grondgebruik Nederland_ - HGN1900) are used as reference data for evaluation.
 
 For Method 2, historical municipality maps (i.e. _Gemeente Rotterdam Plattegrond 1897_ and _Brandgrens kaart_) and current building footprint data from _Basisregistratie Grootschalige Topografie_ (BGT) are used as the main datasets. 


Additionally, several supporting datasets are also used for the implementation of both methods, such as current administrative boundaries and topographic base maps. All datasets used in this research originate from their respective sources and are available through open-access means. The following sections provide a detailed description of each dataset.


=== Bonnebladen map series <sec:bonnebladen>

Bonnebladen maps is the chromo-topographical map of the Kingdom of the Netherlands on the scale of 1:25,000, which was originally produced by the former _Topograhisch Bureau_ between 1865 to 1949 #cite(<DANS-XQF-R4XF_1940>). The map series can be accessed from the Data Station Physical and Technical Sciences (DANS) repository in JPEG scans and GeoTIFF formats via their website (Link: #link("https://phys-techsciences.datastations.nl/dataset.xhtml?persistentId=doi:10.17026/dans-xqf-r4xf")). Relevant materials such as data catalogue, map legends, and metadata are also available on the website. To access the dataset, users are required to create a DANS account and request access to the dataset. Example of a single map sheet of Delft area is shown in the @fig:sample_bonnebladen below.

#figure(
  image("../figs/bonnegrids-figs/NL-HaNA_4.ZHPB4_14A_20-groot.jpg", width: 100%),
  placement: auto,
  caption: [Single sheet of Bonnebladen - sheet no 449 - Delft]
)<fig:sample_bonnebladen>

Alternatively, the same datasets are also available in the form of IIIF resources, which are organized and maintained by the TU Delft Library. An interactive web viewer is established to facilitate the access and visualization of the dataset, which can be accessed via the following link: #link("https://observablehq.com/d/ded63244d9f6625d").


Bonnebladen map series is selected as the main dataset for method 1 because of its rich historical map collection, which covers the entire Netherlands and spans a long temporal period, offers flexibility for defining the thesis scope. The consistent cartographic style with the addition of information of color is also beneficial for the implementation of computer-vision based deep learning techniques. More details about the dataset is discussed further in @chap:result.



=== HGN1900 (Historisch Grondgebruik Nederland) <sec:hgn1900>
The _Historisch Grondgebruik Nederland_ (HGN1900) dataset is a historical land use dataset that provides information about the land use in the Netherlands around the year 1900 #cite(<HGN1900dataset>). The dataset is available in raster format with resolution 50 meters per pixel and georeferenced with the RD coordinate system. The final product of the dataset is a land use map with 10 classes, which are derived from a semi-automatic classification from the original scanned Bonnebladen maps. The dataset is available for download from the website of the Land Use Database of The Netherlands (LGN) with the following link: #link("https://lgn.nl/bestanden"). The dataset is selected as reference data for method 1 because it provides a comprehensive land use map of the Netherlands around the same period as the Bonnebladen maps, which allows for evaluation of the results.




=== Historical municipality maps of Rotterdam <sec:rtm1897>
Map of Rotterdam (1897) sheets are the topographical maps series (1:5000 map scale) obtained from the Rotterdam City Archives. The series contains 10 sheets for the city of Rotterdam with published date around the year 1897.

The link to access the dataset is as follows: #link("https://stadsarchief.rotterdam.nl/zoek-alles?mivast=184&mizig=299&miadt=184&miview=ldt&milang=nl&micode=4201&minr=39521873&miaet=14"). Additionally, these map series has been processed and georeferenced by the TU Delft Library and AllMaps team, and made available as IIIF resources. A public interactive web viewer is established to facilitate the access and visualization of the dataset, which can be accessed via the following link: #link("https://observablehq.com/@allmaps/rtm-historical-atlas").

Following this, another historical maps from the city archives, the _Brandgrens kaart (1940)_ or fire boundary map with 1:5000 map scale, is also used as a supporting dataset for method 2. The map provides information about the extent of the fire that occurred in Rotterdam during World War II, particularly the bombing of May 14th 1940, which can be used to analyze the urban transformation before and after the war. @fig:sample_rtm1897 and @fig:sample_brandgrens show the sample sheets of the Rotterdam municipality map and the fire boundary map respectively.


#figure(
  image("../figs/rotterdam-figs/rtm1897-3.jpg", width: 100%),
  placement: auto,
  caption: [Sample sheet of Rotterdam municipality map - sheet no 3]
)<fig:sample_rtm1897>

#figure(
  image("../figs/rotterdam-figs/brandgrens_kaart.png", width: 100%),
  placement: auto,
  caption: [Fire boundary map of Rotterdam]
)<fig:sample_brandgrens>


The dataset is selected as the main dataset for method 2 because of its detailed representation of the city of Rotterdam in the late 19th century, which allows for the extraction of individual building footprints as objects, instead of building blocks as in other historical maps with lower map scale.


=== Basisregistratie Grootschalige Topografie (BGT) <sec:bgt>
The _Basisregistratie Grootschalige Topografie_ (BGT) is a large-scale topographic dataset that provides detailed information about the built environment in the Netherlands. The dataset includes information about buildings, roads, water bodies, and other topographic features. The building footprints in the BGT dataset are represented as polygons with relevant attributes to the research such as function and construction year. The dataset is available for download from the website of the Dutch Kadaster with the following link: #link("https://api.pdok.nl/lv/bgt/ogc/v1/").

== Study Area <sec:studyarea>
#todo[Study area in: Chapter 4 or Chapter 3?]
For method 1, the research focuses on the Province of South Holland, which is one of the most urbanized regions in the Netherlands. #todo[Cite Why Zuid-Holland and Rotterdam as study area] While for method 2, the research limits the study area to the city of Rotterdam. Due to World War II, the city of Rotterdam has undergone significant urban transformation, which makes it an interesting case study for analyzing urban change over time. The choice of the study area is based on the availability of data as well as the relevance to the research topic, where both areas have rich historical map collections and have undergone significant urban transformation in the past.






== Tools <sec:tools>
The implementation in this research is mainly written in Python programming language, includes data preparation, model training, evaluation, and post-processing. The following sections provide a detailed description of the tools used in this research, including software, essential libraries and frameworks, and hardware.


=== Essential libraries and frameworks
- GDAL is an open-source geospatial library for reading, writing, and transforming raster and vector geospatial data formats.

- Rasterio is a Python library for reading and writing geospatial raster data, built on top of GDAL, used for GeoTIFF handling and spatial metadata access.

- Geopandas is a Python library extending Pandas for working with geospatial vector data, used for spatial operations, reprojections, and saving GeoPackage outputs.

- MapReader is a Python library for patch-based classification pipeline for large map collections, used for data loading, patch extraction, model training, inference, and evaluation, available at https://github.com/maps-as-data/MapReader.

- PyTorch is an open-source deep learning framework used to implement and train the CycleGAN image-to-image translation model and the Mask R-CNN instance segmentation model.

- Torchvision is a PyTorch companion library providing pre-trained models and utilities used here to load the Mask R-CNN architecture and apply non-maximum suppresssion.

- pycocotools is a Python library for COCO dataset evaluation, used here to compute MAP50 metrics during Mask R-CNN training.

- Building-Regulariser is a post-processing tool used to regularize the building footprints extracted from the instance segmentation model, available at https://github.com/DPIRD-DMA/Building-Regulariser.

- Weights and Biases (WandB) is a machine learning experiment tracking tool used to log and visualize the training process of the deep learning models, used here to monitor the training of both CycleGAN and Mask R-CNN models, available at https://wandb.ai/.

- AllMaps CLI is a command-line interface tool for programmatically accessing and manipulating the IIIF resources such as georeference annotations of the historical mapsheets, available at https://github.com/allmaps/allmaps/tree/develop/apps/cli. AllMaps XYZ Tiles API is also used to access the historical maps in the form of XYZ tiles for visualization and exploration purposes, available at https://observablehq.com/@allmaps/allmaps-tile-server.

=== Software
- QGIS used for spatial data inspection, visualization, and manual verification of results. Additional plugins are also used for specific tasks including PDOK plugins for accessing BGT data.

- GIMP is an open-source raster image editor used for visual inspection of the map images. 

== Hardware <sec:hardware>

All implementation is performed on a laptop computer with the following hardware specifications: 
- CPU Intel Core with 14 physical cores (20 logical cores)
- GPU NVidia Geforce RTX 4050 with 6GB VRAM, CUDA 12.7
- RAM 16GB
- OS Windows 11