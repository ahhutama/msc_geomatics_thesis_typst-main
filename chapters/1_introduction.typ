#import "../template.typ": *
#import "../other_tools/styled-blocks.typ": block-discussion, block-todo

= Introduction <chap:intro>
This chapter begins with an introduction to the problem statement and motivation behind this research, followed by the research objectives and questions. The scope of the research is defined. Ultimately, an outline of the thesis structure is provided to guide the reader through the subsequent chapters.

== Introduction <sec:intro>

Historical maps are widely recognized as valuable resources for understanding the transformation of geographical space over time, particularly in the fields of historical and urban studies. The rapid development of geodesy and cartography from the 18th century resulted in extensive production of topographic maps at various scales across the Western world. Among these, urban maps are especially informative due to their high level of detail and often reliable geometric representation of spatial features #cite(<ICDAR2021Vectorization>). By integrating these maps within modern geospatial systems, researchers can gain valuable insights into the processes that shaped present-day urban configurations #cite(<nobajasHistoricalMapOnline2015>). 

According to urban studies conducted in the Netherlands #cite(<rutte2023netherlands>, supplement: [p. 14]) the underlying spatial structures of towns and cities such as street patterns, parcel layouts, and drainage networks, tend to persist over centuries, a phenomenon described as "inertia", implying that present-day urban configurations cannot be properly understood without tracing their origins through historical map series. Such studies were made possible by the extensiveavailability of historical map collections in the Netherlands, such as the _Topografische en Militaire Kaart van het Koningrijk der Nederlanden_ (TMK) series (1850-1865), the _Chromotopograische kaart des Rijks_ series (1884-1930), and numerous municipality-specific historical map series.

// insert image Topotijdreis: TMK, Bonne, (study area) - rotterdam

However, despite the rich availability of historical map collections and recent digitization efforts that have made large map collections browsable on screen, their contents remain largely inaccessible for computational analysis, because they are not yet machine-readable #cite(<hosseiniMapReaderComputerVision2022>). Extracting geospatial information from these maps presents several challenges, including the heterogeneity and inconsistency in cartographic styles across different map series, the visual complexity introduced by overlapping text, symbols, and digitization artifacts, as well as the degradation of map quality over time #cite(<ICDAR2021Vectorization>). Furthermore, before any computational analysis can be performed, these maps must first be accurately georeferenced, a prerequisite step that is particularly demanding for maps with low planimetric accuracy, often requiring substantial manual effort #cite(<vaientiGeoreferencingHistoricalMaps2025>). Moreover, the time-consuming nature of converting maps into machine-readable formats remained unfeasible over large geographical areas #cite(<goodchildReimaginingHistoryGIS2018>). The scalability limitation has historically constrained historical map analysis to case studies with smaller size of datasets, preventing computational analysis of larger areas needed to address complex spatiotemporal questions #cite(<liuEmergingTrendsGIS2024>).

In recent years, computer-vision-based deep learning has emerged as a promising approach for automating feature extraction from satellite imagery and has been increasingly applied to historical map analysis, demonstrating good performance in dectecting urban features, road networks, and land-cover classes #cite(<oharaUnleashingPowerOld2024>), #cite(<xiaMapSAMAdaptingSegment2025>). This shift has opened new possibilities for processing historical maps at a scale previously unfeasible through manual or semi-automated workflows #cite(<hosseiniMapReaderComputerVision2022>).

However, deep learning methods are notoriously data-hungry, requiring large volume and high-quality annotated training data to achieve reliable performance. Producing such annotations is a costly and labor-intensive process, as each map sheet must be manually interpreted and labelled, a task that contradicts the very objective of automation #cite(<arzoumanidisAutomaticUncertaintyAwareSynthetic2025>). This challenge is further amplified by the stylistic variability across different map series where different cartographic conventions, color palettes, and map quality across time periods and map series limit the ability of models trained on one collection to generalize to another #cite(<arzoumanidisAutomaticUncertaintyAwareSynthetic2025>).

Automated extraction of urban features from historical maps can be approached at different levels of granularity. At the broader level, patch-based methods classify map regions to delineate urban extent, enabling statistical-level analysis or urban growth across large geographic areas. At a finer-level, object-based methods aim to detect and delineate individual objects, particularly building objects, offering more detailed spatial information but at greater computational cost and data demand. Each approach carries distinct trade-offs in terms of spatial detail, scalability, and processing requirement.




== Research Objectives <sec:research_objectives>

Addressing the challenges and trade-offs in the previous @sec:intro is essential for enabling reproducible urban change analysis from historical map series. Therefore, this thesis investigates and compares patch-level and object-level deep learning approaches for automated urban extent extraction from Dutch historical topographic maps, with the aim of assessing their respective effectiveness for enabling urban change analysis across multiple temporal periods.


The main research question of this thesis is:
_"To what extent do patch-level and object-level deep learning approaches differ in their effectiveness for extracting urban extent from multi-temporal historical topographic maps for enabling urban change analysis?"_


To address the main question, the following sub-research questions are as follows:
1. How can patch-level deep learning classification be applied to extract urban extent from multi-temporal historical maps?
2. How can CycleGAN-based synthetic data generation be applied to enable object-level building footprint extraction from historical maps?
// What are the required processing steps? 
3. What urban change patterns can be identified by comparing automatically extracted urban extents from historical maps against reference data?
4. What are the relative strengths, limitations, and trade-offs between patch-level and object-level deep learning approaches for urban extent from historical maps?

== Scope
The following clarifies the scope of this thesis:
- This study only uses historical maps that are already scanned, and digitally available to access online from authoritative sources. Besides this study only uses historical maps that are already georeferenced.
- The use of additional historical data sources (cadastral records, building registries, old photographs, paintings, or textual archives) is not included in this study.
- Urban extent in this study refers to the horizontal built-up footprint as depicted on the map surface, such as building blocks and individual building footprints. Vertical urban change such as building height or densification, and administration-based boundary definitions are not considered.
// - The term "historical maps" used in this thesis refers to topographic maps produced through ground-based field survey methods, originating from the era of systematic cartographic programmes in the 18th to early 20th century (pre-modern aerial photogrammetry or digital remote sensing).


== Thesis Outline

This thesis is structured into six main chapters, the outline of which is as follows:

  @chap:intro[Chapter] gives the overview of the research, including the background and motivation, followed by research objectives, research questions, scope of research, and lastly, the outline to the thesis.
  
  @chap:relatedwork[Chapter] provides an overview of scientific related work and theoretical background related to the thesis topic. It begins with a review of previous studies on historical maps for urban studies. Followed by the use of IIIF in supporting access of historical map collections, existing methods of feature extraction from historical maps, and deep learning approaches.

  @chap:methodology[Chapter] provides the detailed description of the research methodology, including the approaches for data processing, model training, evaluation, and post-processing steps.


  @chap:implementation[Chapter] describes the datasets and study area used in this thesis. Followed by the description of programming tools, software, and hardware implemented to test the methodology.


  @chap:result[Chapter] presents the result and findings of the experiments and analyses conducted in this thesis.


  @chap:conclusion[Chapter] discusses the main findings of the research, addresses the research questions, and provides recommendations for future work.
