
options(shiny.maxRequestSize = 500 * 1024^2) # 500 MB

.onLoad <- function(libname, pkgname) {
  rlang::run_on_load()
}

rlang::on_load(rlang::local_use_cli(inline = TRUE))

.onAttach <- function(libname, pkgname) {
  version <- utils::packageDescription(pkgname, fields = "Version")
  website <- "{.url https://github.com/ecoisilva/movedesign/issues}"
  
  rlang::inform(
    class = "packageStartupMessage",
    message = c(
      "i" = 'To cite, run: {.code citation("movedesign")}',
      "!" = paste("Bugs?", website),
      "x" = "Silence? {.code suppressPackageStartupMessages(library(movedesign))}"
    )
  )
}

# Global variables:

utils::globalVariables(
  c(".data", "datList", "outList", "truthList",
    
    "i", "id",
    "group", "seed",
    "x", "y", "x0", "y0", "x1", "y1",
    "long", "lat", "longitude", "latitude",
    "time", "timestamp", "lag",
    
    "taup", "tau_p", "tauv", "tau_v", 
    
    "device",
    "duration", "dur", "dur_unit",
    "interval", "dti", "dti_unit", "dti_notes",
    
    "CI", "LCI", "UCI",
    "CI_low", "CI_high",
    "value", "low", "high",
    "est", "lci", "uci",
    "error", "error_lci", "error_uci",
    "ratio_est", "ratio_lci", "ratio_uci",
    "subpop_detected",
    "area", "area_err_max",
    "ctsd", "dist_err",
    
    "svf",
    "svf_lower",
    "svf_upper",
    "svf_low50",
    "svf_upp50",
    
    "par_modal",
    
    "type",
    "variable",
    "target", "set_target",
    
    "to_filter",
    "get_truth",
    
    "n",
    "m",
    "N1", "N2",
    "subpop",
    "overlaps",
    
    "var_color",
    "color",
    
    "out_meta",
    "out_meta_groups",
    
    "buffalo",
    "coati",
    "pelican",
    "jaguar",
    "wolf",
    "gazelle",
    "turtle",
    
    "ctmm",
    "get_coi",
    "get_cri",
    
    "set_style_title",
    "txtProgressBar",
    "txt_link_meta",
    "txt_ratio_order",
    "txt_target",
    "txt_title",
    
    "rv")
)
