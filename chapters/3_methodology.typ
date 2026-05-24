#import "../template.typ": *
#import "../other_tools/styled-blocks.typ": block-discussion, block-todo

= Methodology <chap:methodology>

// == Overview <sec:3_overview>

This chapter describes the methodology developed to automatically extract urban extent from historical topographic maps. In general, this thesis is divided into 2 main methodologies: (1) patch-based classification method and (2) object-based classification method. The first method is based on a patch-based classification approach, where the map is divided into small patches and each patch is classified as urban or non-urban using a deep learning model, from this point afterwards in this report will be referred as METHOD 1. The second method is based on an object-based classification approach, where individual building footprints are extracted as objects alongside it's geometry, which will be referred as METHOD 2. Both methods are implemented using deep learning techniques, specifically convolutional neural networks (CNN) based architectures. The methodology also includes a change analysis step to analyze the urban transformation across multiple temporal periods. The main difference of the 2 methodologies lies in their granularity of target object, where one focuses on patches and the other on individual buildings. @fig:diagram_method1 and @fig:diagram_method2 displays the general methodology workflow for each method. A complete version of implemented steps is given in Appendix. #todo[insert complete workflow]

// #subpar-grid(
//   figure(
//     image("../figs/ch3-figs/diagram_method1_patch_level.png", page: 1, width: 75%),
//     caption: [],
//   ), <fig:diagram_method1>,
//   figure(
//     image("../figs/ch3-figs/diagram_method2_object_level.png", page: 2, width: 100%),
//     caption: [],
//   ), <fig:diagram_method2>,
//   columns: (1fr),
//   caption:
//   flex-caption(
//     [Diagram workflow side-by-side],
//     [*(a)* Method 1: Patch-level. *(b)* Method 2: Object-level]
//   ),
//   placement: none,
//   label: <fig:diagram_method>
// )

#figure(
  image(
    "../figs/ch3-figs/diagram_method1_patch_level.png",
    page: 1,
    width: 75%,
  ),
  caption: [
    *(a)* Method 1: Patch-level
  ],
  placement: none,
) <fig:diagram_method1>

#figure(
  image(
    "../figs/ch3-figs/diagram_method2_object_level.png",
    page: 2,
    width: 100%,
  ),
  caption: [
    *(b)* Method 2: Object-level
  ],
  placement: none,
) <fig:diagram_method2>


The following sections provide a detailed description of each methodology.


== Method 1: Patch-level classification <sec:3_method1>
Method 1 extracts patches of classified urban extents as raster images from the Dutch Bonnebladen map series using a six-stage pipeline: (1) data acquisition and preparation, (2) patch creation, (3) manual annotation, (4) model training, (5) inference, and (6) post-processing. This study uses deep learning pipeline implementation from the MapReader#footnote[https://github.com/maps-as-data/MapReader] framework established by #citet(<hosseiniMapReaderComputerVision2022>). In the following sections, the complete pipeline from Method 2 is described.

=== Data acquisition and preparation <sec:3_1_dataprep>
#block-todo[Key pointers][
  - Data acquisition approach TBC: 
    - Allmaps CLI GeoTIFF, 
    - IIIF Presentation API integration into MapReader, or
    - custom script
  - Map projection / CRS handling (EPSG:28992 workaround)
]
#todo[Complete this section after finalizing data acquisition approach]

This step handles: reprojection to the correct EPSG:28992, removing the borders outside the neatline, and writing to the correct output format: GeoTIFF

=== Patch creation <sec:3_1_patches>
The georeferenced map sheets are loaded into a `MapImages` object provided by the MapReader library, which manages the collection of image paths and their associated geographic metadata. Prior to patchification, geographic information is extracted from each GeoTIFF and registered to the `MapImages` object. This step is a prerequisite for defining patch size in metric units: MapReader supports patch size specification either in pixels or in meters, and the latter requires the geographic coordinates of the bounding box corners to be available in the image metadata #cite(<hosseiniMapReaderComputerVision2022>).

The map sheets are then split into square patches (as illustrated in @fig:mr_patchify) with a size specified in meters. Patch size is a critical design parameter in the MapReader pipeline: it must be large enough that the target feature occupies a sufficient portion of the patch to be identifiable by both the human annotator and the classifier, yet small enough to retain meaningful spatial resolution in the output #cite(<hosseiniMapReaderComputerVision2022>). 

#figure(
  image("../figs/ch3-figs/mapreader_patchify.png"),
  caption: [
    Patch extraction workflow in MapReader.
    Source: #citet(<hosseiniMapReaderComputerVision2022>), adapted from the MapReader documentation.
  ],
) <fig:mr_patchify>

The patch size is determined through a comparative visual inspection of candidate sizes on a representative subset of map sheets; the selected value and the rationale behind it are reported in @chap:result. Specifying patch size in metric units ensures that each patch represents a consistent physical footprint on the ground, independent of the pixel resolution or scan characteristics of individual sheets, which is particularly relevant for the Bonnebladen collection where sheets from different survey years may vary in scan resolution. Each patch is assigned geographic coordinates derived from the affine geotransform of its parent sheet, making the patch dataset spatially referenced and directly compatible with GIS workflows.

Per-patch pixel statistics, specifically the mean and standard deviation of pixel intensities per RGB channel, are computed and stored as patch attributes. These statistics serve as a proxy for visual content and are used in the subsequent annotation stage to pre-filter candidate patches by color response, as described in @sec:3_1_annotate. The resulting patch metadata is exported as a CSV file alongside the patch image files, which together form the input to subsequent stages of the pipeline.



=== Manual annotation <sec:3_1_annotate>
Annotation is performed using MapReader's interactive Annotator tool, which presents each patch alongside a context window showing the surrounding area of the parent sheet to aid interpretation of ambiguous cases, illustrated in @fig:mr_annotation.

#figure(
  image("../figs/ch3-figs/mapreader_annotation.png"),
  caption: [
    Annotation workflow in MapReader. Source: #citet(<hosseiniMapReaderComputerVision2022>).
  ],
) <fig:mr_annotation>

Three label classes are defined: *"no"* (no significant urban content), *"building_blocks"* (dense building clusters characteristic of urban fabric), and *"individual_buildings"* (isolated or dispersed buildings in urban or rural areas). This taxonomy distinguishes continuous urban fabric from scattered settlement, a distinction that is clearly visible on the Bonnebladen series due to the consistent red fill used to render buildings across the collection.

To focus annotation effort on informative patches, a pixel-based pre-filtering step is applied before presenting patches to the annotator. Patches are filtered by thresholds on the mean and standard deviation of the red channel intensity, retaining only those whose color statistics fall within the range characteristic of building content. This step reduces the proportion of uninformative background patches in the annotation queue, following the accelerated annotation strategy of #citet(<hosseiniMapReaderComputerVision2022>). 
A label review pass is conducted after the initial annotation to verify consistency, with particular attention to *"individual_buildings"*, which shares visual characteristics with both *"no"* and *"building_blocks"* in edge cases.

=== Model training <sec:3_1_train>
#block-todo[Key Ideas][
- Data splitting: use stratified method, use citation [31]
- Data augmentation during training. Clarify: Did we perform this? The paper mentioned it, but Im not sure if we did this, check the python script.
- Explain briefly Option for training: a custom-defined CV or pretrained model from torchvision or PyTorch. Decision: use pretrained model. Describe the selected model and justification.  Check citation [21,26,30]. Question: can we check if we use torchvision or PyTorch?
- Define optimizers, schedulers, and optimization criteria. Use backed-up citation, if there is none in the paper. Write as note to carry in the chat to google search the relevant materials.
- "Freeze" the layer? Don't include it in the draft, but explain in the chat 
- Learning rate: one or multiple LR?
- Class imbalance: Cross-Entropy criterion and AdamW optimization (citation[29]) with linear, layer-wise learning rate
- Batch-size (define)
- Evaluation: performance metrics (use citation)
-------------------------------------------
- Prefer to use direct explanation, with simple english language
- try to always provide definition first concisely to a key concept/technical thing, then provide justification of the decision made. E.g. stratified method, optimizers, scheulders, optimization criteria, learning rate, batch size.
- Question1: For the implemented parameters, should they be written in Ch 3 methodology, or Ch 5 result, or a new specific subchapter in Ch 4 Implementation? 
- Q2: I only train the model one-time, without experimenting different parameters. What do you think about this, can I still answer the sub-RQ? Or should this be identified as Future Work/Suggestion?
- Q3: Explain what is hyperparameter
]
// PARA 1
The annotated patches are loaded using MapReader's AnnotationsLoader. To split the dataset into training, validation, and test subsets, stratified sampling is used. Stratified sampling is a method that ensures each subset contains the same proportion of each label class as the full dataset #cite(<pedregosa2018scikitlearnmachinelearningpython>). This is important here because the *no* class is expected to dominate across most map sheets, and without stratification the minority classes could be underrepresented in training. The dataset is partitioned into 70% training, 15% validation, and 15% test. 

Before training, each patch undergoes resizing, which rescales the patch to the fixed pixel dimensions required by the model architecture, and normalization, which rescales raw pixel intensity values to a small centered range to ensure stable and efficient training. These default image transforms (i.e. normalization and resizing) are applied at training time. Dataloaders are constructed with a batch size of 16. Batch size defines how many training samples are processed in a single forward-backward pass; a smaller batch size introduces more gradient noise but reduces memory requirements.

MapReader supports multiple options for the classifier model: a pretrained model from torchvision #cite(<paszke2019pytorchimperativestylehighperformance>), a custom-defined architecture, or a locally saved model. In this research, a pretrained ResNet-101 model is selected and fine-tuned on the annotated training set. Fine-tuning a pretrained model -- rather than training from scratch -- is preferred because pretraining on large natural image datasets provides a strong initialization of low-level visual features such as edges and textures, which transfer effectively to the historical map domain and substantially improve classification performance @hosseiniMapReaderComputerVision2022 @JMLR:v10:larochelle09a.

The cross-entropy loss is used as the optimization criterion. It 
measures the difference between the predicted class probabilities 
and the true labels across all classes:

$ cal(L)_"CE" = - sum_(c=1)^(C) y_c log(hat(y)_c) $ <eq:crossentropy>

where $C$ is the number of classes, $y_c in {0, 1}$ is the 
ground-truth indicator for class $c$, and $hat(y)_c$ is the 
predicted probability for class $c$.

The model is optimized using AdamW #cite(<loshchilov2019decoupledweightdecayregularization>), an optimizer that combines adaptive learning rates with decoupled weight decay regularization, and has been shown to generalize well across a range of image classification tasks. A layer-wise learning rate strategy is applied, where each layer in the network is assigned a different learning rate. Rates are distributed using geometric spacing between a minimum of $1 times 10^(-4)$ and a maximum of $1 times 10^(-3)$, with lower rates assigned to earlier layers and higher rates to later layers. This preserves the general visual features learned during pretraining in the earlier layers, while allowing the later layers to adapt more strongly to the historical map domain #cite(<hosseiniMapReaderComputerVision2022>). A learning rate scheduler progressively reduces the learning rate during training, preventing large weight updates in later epochs when the model is close to convergence. The model checkpoint with the lowest validation loss is selected for inference. 
Full hyperparameter settings are listed in @chap:implementation #todo[TBC - Full hyperparameter settings].





=== Inference <sec:3_1_inference>
The fine-tuned model is applied to the complete patch set covering all loaded map sheets. A patch dataset is constructed from the patch metadata CSV, and test-time transforms are applied consistently with those used during training. The ClassifierContainer produces a predicted label and a confidence score for each patch. Predictions are saved to a CSV file and joined to the spatial patch metadata, producing a georeferenced patch dataset in which each patch polygon carries its predicted class label as an attribute. The output is exported as a GeoJSON file to enable spatial analysis and visualization in GIS software.







=== Post-processing <sec:3_1_postprocessing>
#figure(
  image("../figs/ch3-figs/mapreader_postprocessing_patch2raster.png"),
  caption: [
    Post-processing.
  ],
) <fig:mr_postprocessing_patch2raster>

The inference output GeoJSON is processed through a custom post-processing script to produce classified raster outputs per temporal period. First, patches predicted as background (*no*) are discarded, retaining only patches classified as *building_blocks* or *individual_buildings*. An optional confidence threshold can be 
applied at this stage to discard low-confidence predictions before any spatial processing is performed. Second, a survey year and edition number are extracted from each patch's parent sheet filename, enabling temporal attribution without a separate metadata lookup. Third, the filtered patches are dissolved by predicted label and survey year, merging spatially adjacent patches that share the same class and temporal period into unified polygons. Where patches of different urban classes spatially overlap, *building_blocks* takes priority over *individual_buildings*, reflecting the higher urban density it represents. The dissolved output is saved as a GeoPackage for vector-based inspection.

Finally, the dissolved polygons are rasterized to a GeoTIFF at a resolution of 10 meters in EPSG:28992, with pixel values encoding the predicted class directly. This process is applied twice, once for the first edition of each sheet (T1) and once for the latest available edition (T2), following the Bonnebladen's multi-edition structure in which individual sheets were resurveyed and revised independently over time. Rather than selecting a fixed calendar year, this edition-based approach ensures that T1 and T2 each represent the earliest and most recent available survey state per location, respectively. The two resulting rasters serve as the primary input to the change analysis described in //@sec:change_analysis.




=== Evaluation <sec:3_1_evaluation>



#block-todo[Hints][
  1. Selesaiin Method 2 dulu (karena dikerjain terakhir)
  2. Baru Method 1 (sambil inget2 lagi nanti)
]
== Method 2: Object-level classification <sec:3_method2>
Method 2 extracts individual building footprints as vector polygons from the Rotterdam 1897 municipality map series using a four-stage pipeline: (1) data acquisition and preparation, (2) synthetic training data generation
via CycleGAN, (3) instance segmentation via Mask R-CNN, and (4) post-processing. In the following sections, the complete pipeline from Method 2 is described.

=== Data acquisition and preparation <sec:3_2_dataprep>
#block-todo[Key pointers][
- Explored multiple sources of historical maps which comply to the requirement criteria, selected: Rotterdam 1897 map sheets.
- Download the map sheet using Allmaps CLI, export to GeoTIFF
- Download BGT using QGIS Plugin BGT Downloader
- List relevant BGT layers for cartographic style adjustment
- Allmaps XYZ Tile server to help visualization
- Inspect all layers in QGIS
]
Method 2 uses two primary datasets: the Rotterdam 1897 municipality maps and the current BGT vector data, both described in @sec:datasets.

The historical map sheets are retrieved using the Allmaps CLI#footnote[https://github.com/allmaps/allmaps/tree/main/apps/cli], which exports each sheet as a georeferenced GeoTIFF by applying the georeference annotations stored on the Allmaps platform @meijersMappingEdgeNovel2024. Of the 10 sheets in the series, only sheets 2, 3, and 4 are used. These three sheets cover areas with dense building content, making them more suitable for training a building segmentation model. The remaining sheets are dominated by water bodies and open land.

BGT data are downloaded via the BGT Downloader plugin in QGIS. The relevant layers selected for this research are:
1. _Pand_ (buildings)
2. _Wegdeel_ (road surfaces)
3. _Waterdeel_ (water bodies)
4. _BegroeidTerreindeel_ (vegetated areas)
5. _OnbegroeidTerreindeel_ (bare surfaces)


While the primary segmentation target is buildings, the background layers are included because they form the visual context that looks similar to the historical map sheets. Then, all downloaded data are inspected in QGIS to verify spatial coverage, alignment with the historical map extent, and layer completeness. The Allmaps XYZ Tile server is additionally used as an alternative to directly fetch IIIF resources as reference background in QGIS, without any preprocessing steps.


=== Georeference <sec:3_2_georef>
#block-todo[Key pointers][
  - Manual georeference
]
The georeference annotations for the Rotterdam 1897 sheets, maintained by the TU Delft Library and Allmaps team, are applied using the Allmaps CLI to produce georeferenced GeoTIFFs in EPSG:3857 #todo[recheck]. The warping procedure derives an affine
geotransform from the stored ground control points (GCPs), assigning
real-world coordinates to each pixel of the map scan. A qualitative
assessment of the georeferencing quality is reported in @chap:result. 

#todo[complete this section] To make sure the georeferenced maps are properly aligned with the BGT data, a visual inspection is conducted in QGIS by overlaying the georeferenced map sheets with the BGT layers. The alignment is verified by checking the spatial correspondence of prominent features such as building clusters, particularly those are already constructed before 1897 and still present in the current BGT data.

// While there are recent advancement to automate georeference on historical maps (for example using local delaunay cite Vaienti), in this case I need to perform georeference manually. Reason: Georeference is conducted by the AllMaps Team, 
// - Create table number of GCP for each sheet Rotterdam. From inspected Geoference Annotation. Sheet 2,3,4. #cite(<meijersMappingEdgeNovel2024>)


=== Synthetic data generation (CycleGAN) <sec:3_3_cyclegan>
#block-todo[Key pointers][
- Vector style transfer: configure cartographic style of current building vector data (BGT)
  - Visual inspection -> compute mean RGB from selected patches using 3x3 kernal
- Preprocessing -> `tile_patches.py`, verify (remove invalid patches), and data splitting into trainA/B and testA/B for CycleGAN input
- CycleGAN for image translation
  - Conceptual of CycleGAN (brief theory, figures from the paper, formula, loss, )
  - Training the model (`train.py`)
  - Testing (`test.py`)
  - Evaluation (Compute FID, loss metrics from training, visual observation)
  - Output: `model.pth` cycleGAN patches (PNGs)
  - Post processing - reconstruct (`stitch_fake_b.py`) -> GeoTIFF for input for mask r-cnn
]

Instance segmentation models require annotated training data in the form of pixel-level masks paired with source images. Manual annotation of individual building footprints is time-consuming and impractical at scale. To address this, Method 2 adopts a synthetic data bootstrapping approach following #citet(<arzoumanidisAutomaticUncertaintyAwareSynthetic2025>), where modern vector data is style-transferred to visually resemble the historical maps, generating a synthetic training dataset with automatically aligned annotation masks. The pipeline consists of two steps: (1) cartographic style transfer, which renders the BGT vector data to approximate the visual appearance of the
historical maps, and (2) unpaired image-to-image translation using CycleGAN #cite(<zhuUnpairedImagetoImageTranslation2020>), which adds realistic cartographic degradation effects to the style-transferred images. The BGT vector geometry simultaneously serves as the annotation mask, eliminating the need for manual labelling.

==== Cartographic style transfer <sec:carto_styletransfer>
// The BGT layers are rendered in a cartographic style approximating the Rotterdam 1897 maps. To determine the target colors, class-representative patch are manually selected from visually clean areas of the historical sheets using GIMP software, one set per feature class, avoiding regions with scan artifacts, text labels, or class boundaries. The mean RGB value per class is computed from these selected patches. These steps are implemented within a custom python script, then outputs the mean RGB value and the hexcode for each class. 

The BGT layers are rendered in a cartographic style approximating the Rotterdam 1897 maps. To determine the target fill and stroke colors per class, a set of class-representative image patches is manually selected from visually clean areas of the historical sheets for each feature class, avoiding regions with scan artifacts, text labels, or class boundaries. The mean RGB value per class is computed from these patches using a custom Python script, following the visual inspection approach described by #citet(<arzoumanidisAutomaticUncertaintyAwareSynthetic2025>). The resulting color values (in hexcodes) are applied as fill and stroke colors to the corresponding BGT layers in QGIS.


The Rotterdam 1897 map series distinguishes two building types: (1) *regular buildings*, rendered with a solid red fill, and (2) *hatched buildings*, rendered with a diagonal hatching pattern over the same red fill. Visual inspection of the historical sheets indicates that hatched buildings consistently correspond to public and civic functions, including churches, schools, markets, prisons, and government offices. Example of the text overlays in Dutch are as follows: _Cellulaire Gevangenis, O.S (Public School), O.B.S (Nursery School), Societeit Harmonie (Doele), Zuider kerk, Post en Telegraaf kantoor, Zeevischmarkt, Kapel, Barakbesrn: zieken, Exercitie-loods, Openbaar Slaachthuis, Goedernloods_. To represent this distinction in the synthetic training data, the BGT _Pand_ layer is split into two subsets using a SQL filter on the `gebruiksdoel` attribute(@fig:sql_hatching), which classifies each building by its intended use. Buildings with a meeting, industrial, or office function are assigned the hatching style; all remaining buildings receive the solid fill style.
#figure(
  ```sql
  "gebruiksdoel" IN ('bijeenkomstfunctie', 'industriefunctie', 'kantoorfunctie')
  ```,
  placement: none,
  caption: [SQL filter applied to the BGT _Pand_ layer to identify 
  hatched building candidates.],
) <fig:sql_hatching>


The styled BGT map is exported from QGIS using PyQGIS export script as a PNG image covering the spatial extent of each selected sheet. 
// A corresponding flat-color annotation mask is exported simultaneously, where each feature class is rendered in a distinct solid color, producing pixel-aligned ground truth labels for the synthetic maps.

==== Data preprocessing and patch tiling <sec:3_3_preprocessing>
The styled synthetic PNGs and the historical GeoTIFFs are sliced into fixed-size patches using a custom tiling script. Patches are extracted at 512 x 512 pixels with a stride of 256 pixels, producing a 50% spatial overlap between adjacent patches. This overlap strategy increases dataset diversity and ensures that features near patch boundaries appear in multiple contexts during training #todo[Citation-check-zhu2020]. Patches falling below a minimum content threshold are discarded to remove uninformative background-only tiles.

The dataset is split by sheet: sheets 2 and 3 form the training set (`trainA`: synthetic, `trainB`: historical), and sheet 4 forms the test set (`testA`: synthetic, `testB`: historical). This spatial split ensures evaluation on a geographically unseen area.


==== CycleGAN image translation <sec:3_3_cyclegan_training>
CycleGAN #cite(<zhuUnpairedImagetoImageTranslation2020>) is an unpaired image-to-image translation framework that learns mappings between two visual domains $X$ and $Y$ without requiring paired training examples. The framework consists of two generators, $G: X -> Y$ and $F: Y -> X$, and two discriminators, $D_X$ and $D_Y$. In this research, domain $X$ corresponds to the style-transferred BGT patches and domain $Y$ corresponds to the historical Rotterdam 1897 map patches. The translation $G(x)$ produces a synthetic historical map patch from a styled BGT input, adding cartographic aging and degradation effects while preserving building geometry.

#figure(
  grid(
    columns: 3,
    gutter: 1em,
    [
      #figure(
        image("../figs/ch3-figs/cyclegan_1.png", width: 100%),
        caption: [(a) Model architecture],
        numbering: none,
      )
    ],
    [
      #figure(
        image("../figs/ch3-figs/cyclegan_2.png", width: 100%),
        caption: [(b) Forward cycle],
        numbering: none,
      )
    ],
    [
      #figure(
        image("../figs/ch3-figs/cyclegan_3.png", width: 100%),
        caption: [(c) Backward cycle],
        numbering: none,
      )
    ],
  ),
  caption: [
    CycleGAN architecture #cite(<zhuUnpairedImagetoImageTranslation2020>). (a) Two mapping functions $G: X -> Y$ and $F: Y -> X$ with discriminators $D_Y$ and $D_X$, where $X$ denotes the style-transferred BGT domain and $Y$ denotes the historical Rotterdam 1897 map domain. (b) Forward cycle-consistency: $x -> G(x) -> F(G(x)) approx x$. (c) Backward cycle-consistency: $y -> F(y) -> G(F(y)) approx y$.
  ],
) <fig:cyclegan_architecture>

The training objective combines two loss terms. The adversarial loss encourages each generator to produce outputs indistinguishable from the target domain:

$ cal(L)_"GAN" (G, D_Y, X, Y) = bb(E)_y [log D_Y (y)]
  + bb(E)_x [log(1 - D_Y (G(x)))] $ <eq:lgan>

The cycle consistency loss enforces that translating an image to the target domain and back recovers the original #cite(<zhuUnpairedImagetoImageTranslation2020>):

$ cal(L)_"cyc" (G, F) = bb(E)_x [||F(G(x)) - x||_1]  + bb(E)_y [||G(F(y)) - y||_1] $ <eq:lcyc>

The full training objective is:

$ cal(L) (G, F, D_X, D_Y) = cal(L)_"GAN" (G, D_Y, X, Y)  + cal(L)_"GAN" (F, D_X, Y, X)  + lambda cal(L)_"cyc" (G, F) $ <eq:lfull>

where $lambda = 10$ #todo[CycleGAN - lambda = 10? TBC] controls the relative weight of the cycle consistency term #cite(<zhuUnpairedImagetoImageTranslation2020>). The model is trained using the official PyTorch implementation of Zhu et al. #cite(<zhuUnpairedImagetoImageTranslation2020>) with a ResNet-based generator (9 residual blocks) #cite(<zhuUnpairedImagetoImageTranslation2020>), instance normalization, and a PatchGAN discriminator. Input patches are cropped to 256 x 256 pixels from the 512 x 512 source patches at training time. Training uses the Adam optimizer with a batch size of 1, a constant learning rate of 0.0002 for the first phase, followed by linear decay to zero #cite(<zhuUnpairedImagetoImageTranslation2020>). Full hyperparameter settings are listed in @chap:implementation #todo[TBC - Full hyperparameters - CycleGAN].


==== Evaluation of synthetic data quality <sec:3_3_cyclegan_evaluation>
The quality of the translated synthetic images is evaluated using the Frechet Inception Distance (FID) #cite(<heusel2018ganstrainedtimescaleupdate>), a widely adopted metric for assessing the realism of generative model outputs. FID measures the distance between the feature distributions of two image sets by fitting multivariate Gaussian distributions to the activations of the final pooling layer of a pre-trained Inception-v3 network #cite(<heusel2018ganstrainedtimescaleupdate>). A lower FID indicates greater similarity between the synthetic and reference distributions. The score is computed as:

$ "FID" = ||mu_X - mu_Y||^2 + "Tr"(Sigma_X + Sigma_Y- 2(Sigma_X Sigma_Y)^(1/2)) $ <eq:fid>
where $mu_X, Sigma_X$ and $mu_Y, Sigma_Y$ are the mean and covariance of the feature embeddings of the synthetic and real image sets respectively #cite(<heusel2018ganstrainedtimescaleupdate>).

A key consideration specific to this research is the choice of training checkpoint for inference. As noted by #citet(<arzoumanidisAutomaticUncertaintyAwareSynthetic2025>), early training epochs introduce cartographic degradation effects at the texture and color level without inducing geometric distortions of building boundaries, which would corrupt the alignment between synthetic image and annotation mask. To identify the optimal checkpoint, inference is run at multiple saved epochs and each output is evaluated using FID against the historical test patches (`testB`), supplemented by visual inspection of building geometry preservation. The checkpoint yielding the best balance between FID score and geometric fidelity is selected for generating the final synthetic training dataset. Results of this evaluation are reported in @chap:result.


==== Post-processing and output <sec:3_3_postproc>
CycleGAN inference produces individual translated patches (`fake_B`) as PNG files. These are stitched into a full-sheet composite image using a custom Python script, which places each patch at its pixel-origin position encoded in the filename and averages overlapping regions to reduce seam artifacts. The stitched composite is georeferenced using the CRS and affine geotransform of the corresponding historical GeoTIFF for the same sheet, producing a spatially referenced GeoTIFF per sheet. These files serve as input to the Mask R-CNN pipeline described in @sec:3_4_maskrcnn.


=== Instance segmentation (Mask R-CNN) <sec:3_4_maskrcnn>



==== Data preparation and training <sec:3_4_train>
==== Inference and output <sec:3_4_inference>
=== Post-processing
Building regularisation

=== Evaluation


== Urban Change Analysis
(shared for both methods)