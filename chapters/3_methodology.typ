#import "../template.typ": *

= Methodology <chap:methodology>

This chapter describes the methodology developed to automatically extract urban extent from historical topographic maps. In general, this thesis is divided into 2 main methodologies: (1) patch-based classification method and (2) object-based classification method. The first method is based on a patch-based classification approach, where the map is divided into small patches and each patch is classified as urban or non-urban using a deep learning model, from this point afterwards in this report will be referred as METHOD 1. The second method is based on an object-based classification approach, where individual building footprints are extracted as objects alongside it's geometry, in which will be referred as METHOD 2. Both methods are implemented using deep learning techniques, specifically convolutional neural networks (CNNs). The methodology also includes a change analysis step to analyze the urban transformation across multiple temporal periods. The main difference of the 2 methodologies lies in their granularity of target object, where one focuses on patches and the other on individual buildings. 


The following sections provide a detailed description of each methodology. Section xx to section yy d


== Patch-based CNN method DL

== Object-based method DL


=== Image-to-Image translation using CycleGAN DL

==== Evaluation (FID)

=== Instance segmentation using Mask R-CNN DL



== Change Analysis