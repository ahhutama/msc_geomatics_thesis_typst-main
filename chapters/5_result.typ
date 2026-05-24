#import "../template.typ": *
#import "../other_tools/styled-blocks.typ": block-discussion, block-todo

= Result and Analysis <chap:result>

This chapter presents the results of both classification methods and the subsequent change analysis. @sec:5_1_method1 covers Method 1, the patch-level classification applied to the Bonnebladen map series, including dataset assessment, pipeline execution, and evaluation. @sec:5_2_method2 covers Method 2, the object-level building footprint extraction applied to historical municipality maps. Urban change analysis derived from both methods is presented in @sec:5_3_change.


== Method 1 - Patch level classification <sec:5_1_method1>
The following sections document the implementation and results of the patch-level pipeline using the MapReader framework. The assessment of the Bonnebladen dataset is reported first, as several dataset characteristics directly influenced design decisions in subsequent pipeline stages.

=== Assessment of bonnebladen map series <sec:assess_bonne>

// Why don't I see airfields and barracks on older maps?
// During a certain period, this fell under classified area and was not allowed to be displayed. It was left blank or depicted with a fantasy area (grass fields, ditches).
// Why is a building not visible on a map in the year of release?
// The maps are created based on aerial photographs, and there is a gap of a few years between the two, which can extend up to 5 years. Additionally, maps were not revised as frequently in the past as they are today.

// Redundant with Chapter 4
//The Bonnebladen (_Chromo-Topografische kaart des Rijks_) is a colored topographic map series of the Netherlands at a scale of 1:25,000, produced by the former _Topografisch Bureau_ over the period 1868 to 1940. Sheets were drawn in the Bonneprojection. 

According to the sheet index (_bladwijzer_), the series comprises 776 sheet indices covering the entire Dutch territory as illustrated in @fig:bonne_bladwijzer. Of these, 709 indices correspond to actual map sheets; the remaining 67 cover areas that were still open water or sea at the time of survey, most notably the present-day province of Flevoland, for which no sheets were produced. Multiple editions were published for most sheets as content was resurveyed and revised over time. The combined catalog used in this research, derived from the TU Delft Library and Allmaps IIIF metadata, contains 2940 sheet editions in total across those 709 sheet indices. 

Each sheet is identified by a numeric sheet number, a sheet name corresponding to the primary toponym in that area, and a publication year. In the catalog, year refers to the _Uitgave_ date, that is, the date on which the edition was officially published. This is distinct from the _Verkend_ date, which records when the field survey was conducted and can predate publication by years. The practical implication is that the year attribute used in this thesis reflects when each edition was made available, not necessarily when the depicted landscape was observed on the ground. This distinction is relevant when comparing results against external datasets: for instance, the HGN1900 land use dataset uses the _Verkend_ date as the reference year for temporal attribution #cite(<HGN1900dataset>), which is discussed in detail in @sec:5_1_hgn1900.

The filename convention for sheets downloaded via the custom pipeline follows the pattern `sheet_{NNNN}_{NAME}_{YEAR}.tif`, where `NNNN` is the zero-padded four-digit sheet number, `NAME` is the sheet toponym, and `YEAR` is the _Uitgave_ year.

// #footnote[Other sources report slightly different counts; for instance, #citet(<synthesis project>) lists 2991 scans in the DANS repository. The figure of 2940 reflects the editions accessible via the IIIF infrastructure and is used consistently throughout this thesis.]


==== Temporal structure and editions <sec:bonne_temporal>

The term _edition_ in the Bonnebladen context does not refer to a single revision of the entire map series, but to an individual resurvey of a specific sheet. According to the catalog, one sheet could be revised up to approximately 11 times across the production period, with each revision published as a new dated edition. The temporal coverage therefore varies per sheet: sheets in urbanising or strategically significant areas were revised more frequently than those in stable rural regions.

Four map sheet index figures are included below, showing for each sheet location across the Netherlands: the _Uitgave_ year of the first available edition (@fig:bonne_indices_first), the _Uitgave_ year of the last available edition (@fig:bonne_indices_last), the timespan between the two in years (@fig:bonne_indices_timespan), and the total edition count per sheet (@fig:bonne_indices_total). Three bar charts are additionally included summarising the number of sheets published per edition rank (@fig:barchart_bonne_by_edition), cumulative sheet output per year (@fig:barchart_bonne_by_year_cumulative), and publication counts grouped by edition (@fig:barchart_bonne_by_year_edition).

#figure(
  image("../figs/ch5-figs/Bonne_NL_sheet_indices.png", width: 100%),
  caption: [_Bonnebladen bladwijzer_, or sheet indices of bonnebladen map series],
  placement: none,
) <fig:bonne_bladwijzer>


#figure(
  image("../figs/ch5-figs/Bonne_NL_first_editions.png", width: 100%),
  caption: [Published date (_Uitgave_) of the first available edition per sheet.],
  placement: none,
) <fig:bonne_indices_first>


// BLADWIJZER
#figure(
  image("../figs/ch5-figs/Bonne_NL_last_editions.png", width: 100%),
  caption: [Published date (_Uitgave_) of the latest available edition per sheet.],
  placement: none,
) <fig:bonne_indices_last>

#figure(
  image("../figs/ch5-figs/Bonne_NL_edition_timespan.png", width: 100%),
  caption: [Timespan in years between the first available edition and the last edition per sheet.],
  placement: none,
) <fig:bonne_indices_timespan>

#figure(
  image("../figs/ch5-figs/Bonne_NL_total_editions.png", width: 100%),
  caption: [Total available editions per sheet.],
  placement: none,
) <fig:bonne_indices_total>


// Barcharts
#figure(
  image("../figs/ch5-figs/bonne_by_edition.png", width: 100%),
  caption: [Number of sheets published per edition rank.],
  placement: none,
) <fig:barchart_bonne_by_edition>

#figure(
  image("../figs/ch5-figs/bonne_by_year_cumulative.png", width: 100%),
  caption: [Number of sheets published per year (cumulative).],
  placement: none,
) <fig:barchart_bonne_by_year_cumulative>

#figure(
  image("../figs/ch5-figs/bonne_by_year_edition.png", width: 100%),
  caption: [Number of sheets published per year and edition grouped.],
  placement: none,
) <fig:barchart_bonne_by_year_edition>




=== Data preparation <sec:data_preparation>

The study area for Method 1 is the province of South Holland. As shown in @fig:bonne_indices_first, @fig:bonne_indices_last, @fig:bonne_indices_timespan, and @fig:bonne_indices_total, South Holland is among the best-represented provinces in the Bonnebladen catalog in terms of edition count, temporal range, and coverage continuity, making it the most suitable candidate for a multi-temporal analysis. The province also offers a range of settlement types relevant to the classification task, from the dense historic urban regions of Rotterdam and The Hague to smaller towns and dispersed rural settlement.

A total of 74 sheet numbers covering the province were identified and downloaded via the custom pipeline. The pipeline was executed twice: once selecting the first available edition per sheet (T1) and once selecting the last available edition per sheet (T2). The resulting two sets of georeferenced GeoTIFFs form the primary input for all subsequent pipeline stages, and are used for the urban change analysis described in @sec:5_3_change.


=== Patch creation <sec:5_1_patch>
For this research, these two requirements are particularly in tension: dense building blocks require a patch area large enough to present a representative portion of urban fabric, so that the classifier receives sufficient visual context to distinguish continuous urban clusters from isolated features, while scattered individual buildings require a patch small enough to be captured at adequate spatial resolution.
- Weak classifier

=== Manual annotation <sec:5_1_annotate>

=== Model training and evaluation <sec:5_1_train>
- INitial training
- Fine-tune -TBC?

=== Inference results <sec:5_1_inference>
Inference is performed at 2 time period: the first edition and the last edition. 

=== Comparison with HGN-1900 <sec:5_1_hgn1900>





== Method 2 - Object-level classification <sec:5_2_method2>

=== Downloading Rotterdam municipality maps

Assessment of Rotterdam municipality maps


=== Image-to-image translation

==== Cartographic Style Transfer
#block-todo[Key Ideas][
  - Table manually selected image patches 
  - Table hexcode of class taxonomy
  
]

Table shows the
#let data = csv("../data/style_parameters.csv")

#{
  set text(size: 8pt)
  
  table(
    columns: 15,
    inset : 2pt,
    align: (
      left,  // class
      left,  // hex_mean
      right, right, right,
      right, right, right,
      right, right, right,
      right, right, right,
      right, right,
    ),
    ..data.flatten(),
    )
} <tab:style_transfer_table>



=== Instance segmentation

==== Model training


==== Inference result



==== Model evaluation



=== Post-processing
Building regularisation


== Change analysis <sec:5_3_change>
For both method

=== Method 1 


==== Edition types: general and secret military <sec:bonne_geheim>

Two edition types exist in the catalog. General-purpose editions constitute the majority of the dataset. A subset of sheets also has a secret military edition, flagged in the DANS catalog as _OOK GEHEIME UITGAVE_ (also secret edition). These secret editions include depictions of military fortifications that were omitted from, or intentionally obscured in, the corresponding general-purpose edition. Unlike what the flag description implies, both edition types are accessible through the publicly available IIIF resources maintained by TU Delft Library, and both are included in this research.

Sheet 443 (_Bodegraven_) illustrates the difference explicitly: in its first edition, the Wierickerschans Fort is clearly depicted in @fig:bonne_edition_geheim, while in a later edition the same area is rendered without military structures and turned into an open land @fig:bonne_edition_general. This raises a consideration for the change analysis: if T1 and T2 for a given sheet correspond to editions of different types (one general-purpose, one secret military), observed differences in urban content may partly reflect cartographic omission rather than genuine land cover change. //This possibility is noted and carried forward in the change analysis discussion(@sec:5_3_change). 

#subpar-grid(
  figure(
    image("../figs/ch5-figs/bonne_edition_geheim.png", width: 90%),
    caption: [],
  ), <fig:bonne_edition_geheim>,
  figure(
    image("../figs/ch5-figs/bonne_edition_general.png", width: 90%),
    caption: [],
  ), <fig:bonne_edition_general>,
  columns: (1fr),
  caption: flex-caption(
    [Cartographic style difference between general purpose edition and secret military purposes.],
    [*(a)* Secret military (_Geheim_) edition.
     *(b)* General edition.]
  ),
  placement: none,
  label: <fig:bonne_geheim_comparison>
)


==== Cartographic style changes after the 1930s <sec:bonne_style>

A shift in cartographic style occurs in editions published after approximately 1930, consistent with observations reported in the HGN methodology #cite(<HGN1900dataset>).
Visual comparison of sheets before and after this period, conducted in QGIS using the pipeline-produced GeoTIFFs, reveals several changes, as illustrated in @fig:bonne_style_comparison.

- *Map grid introduction.* Editions after the 1930s include a kilometre grid overlay. Measurements in QGIS confirm a grid spacing of 1 x 1 km.

- *Building outline color.* The building outline stroke shifts from a near-black color (approximately RGB 26, 20, 19) to a clear red (approximately RGB 194, 29, 43). This change is unambiguous and directly affects the red-channel response used for annotation pre-filtering in this pipeline (@sec:3_1_annotate).

- *Railway symbology.* The graphical representation of railways changes between
  early and late editions. 

#subpar-grid(
  figure(
    image("../figs/ch5-figs/bonne_style_before1930s.png", width: 100%),
    caption: [],
  ), <fig:bonne_style_before>,
  figure(
    image("../figs/ch5-figs/bonne_style_after1930s.png", width: 100%),
    caption: [],
  ), <fig:bonne_style_after>,
  columns: (1fr, 1fr),
  caption: flex-caption(
    [Cartographic style difference between Bonnebladen editions before and after the 1930s.],
    [*(a)* Pre-1930s edition showing dark building outlines and no map grid.
     *(b)* Post-1930s edition showing red building outlines and 1 x 1 km grid overlay.]
  ),
  placement: none,
  label: <fig:bonne_style_comparison>
)

These stylistic differences introduce potential inconsistencies when applying a
single trained model across sheets from different periods. // and are discussed further in the evaluation (@sec:3_1_evaluation).


=== Method 2


