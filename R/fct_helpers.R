#' Abbreviate units
#'
#' @description Create abbreviations of units.
#' @param unit Character. A character vector for a unit.
#'
#' @return Returns a character vector with one element.
#'
#' @examples
#' \dontrun{
#' movedesign::abbrv_unit("square kilometers")
#' }
#'
#' @noRd
abbrv_unit <- function(unit, ui_only = TRUE) {

  if (missing(unit))
    stop("`unit` argument not provided.")

  if (!is.character(unit))
    stop("`unit` argument must be a character string.")
  
  all_units <- c("year", "month", "week",
                 "day", "hour", "minute", "second",
                 "kilometer", "meter", "km", "m",
                 "km^2", "m^2", "ha",
                 "square kilometer", "square meter", "hectare",
                 "kilometers/hour", "meters/second",
                 "kilometers/day" , "meters/day",
                 "km/h", "m/s",
                 "km/day", "m/day")

  x <- gsub("(.)s$", "\\1", unit)
  var <- all_units[pmatch(x, all_units, duplicates.ok = TRUE)]

  if (any(is.na(var)))
    stop("Invalid unit: ", paste(x[is.na(var)], collapse = ", "),
         call. = FALSE)
  
  out <- x
  if (x == "year") out <- "yr"
  if (x == "month") out <- "mth"
  if (x == "week") out <- "wk"
  if (x == "day") out <- "d"
  if (x == "hour") out <- "hr"
  if (x == "minute") out <- "min"
  if (x == "second") out <- "sec"

  if (x == "kilometer") out <- "km"
  if (x == "meter") out <- "m"

  if (x == "square kilometer" || x == "km^2") 
    out <- ifelse(ui_only, "km\u00B2", "km^2")
  if (x == "square meter" || x == "m^2") 
    out <- ifelse(ui_only, "m\u00B2", "m^2")
  if (x == "hectare") out <- "ha"

  if (x == "kilometers/hour") out <- "km/h"
  if (x == "meters/second") out <- "m/s"
  if (x == "kilometers/day") out <- "km/day"
  if (x == "meters/day") out <- "m/day"

  return(out)

}

#' Fix values and units of space and time
#'
#' @description Correctly convert values and units for reporting.
#'
#' @param value numeric, integer. For example, 1.
#' @param unit character vector of time units. For example, "hours" or "meters".
#' @return A list with the corrected value and the corrected unit.
#'
#' @examples
#' \dontrun{
#' movedesign:::fix_unit(1, "hours")
#' }
#' @keywords internal
#'
#' @importFrom dplyr case_when
#' @importFrom dplyr add_row
#' @importFrom ctmm `%#%`
#' @noRd
fix_unit <- function(value, unit,
                     digits = 2,
                     ui = FALSE,
                     convert = FALSE)  {

  if (!is.character(unit)) {
    stop("`unit` argument must be a character string.")
  }

  all_units <- c("year", "month", "week",
                 "day", "hour", "minute", "second",
                 "kilometer", "meter", "km", "m",
                 "square kilometer", "square meter", "hectare",
                 "km^2", "m^2", "ha",
                 "kilometers/day", "kilometer/day", "km/day",
                 "kilometers/hour", "kilometer/hour", "km/hour",
                 "meters/second", "meter/second", "m/s")

  units_tm <- all_units[1:7]
  units_sp <- all_units[8:11]
  units_ar <- all_units[12:17]
  units_vl <- all_units[18:26]

  if (!unit %in% units_vl) {
    x <- gsub("(.)s$", "\\1", unit)
  } else { x <- unit }
  
  var <- all_units[pmatch(x, all_units, duplicates.ok = TRUE)]
  if (any(is.na(var))) {
    stop("Invalid unit: ", paste(x[is.na(var)], collapse = ", "),
         call. = FALSE)
  }

  # Convert value:

  y <- ifelse(convert, value %#% x, value)
  
  if ((x %in% units_tm) & convert) {
    x_new <- dplyr::case_when(
      y < 60 ~ "second",
      y < 3600 ~ "minute",
      y < 86400 ~ "hour",
      y < (1 %#% "month") ~ "day",
      y < (1 %#% "year") ~ "month",
      TRUE ~ "year")
    
    y <- x_new %#% y
    x <- x_new
  }
  
  if ((x %in% units_sp) & convert) {
    x_new <- ifelse(y >= 1000, "km", "m")
    y <- x_new %#% y
    x <- x_new
  }

  if ((x %in% units_ar) & convert) {
    x_new <- dplyr::case_when(
      y < 1e4 ~ "m^2",
      y < 1e6 ~ "ha",
      TRUE ~ "km^2")
    
    y <- x_new %#% y
    x <- x_new
  }

  if (x %in% units_ar) {
    x_html <- dplyr::case_when(
      (x == "square kilometer" | x == "km^2") ~ "km\u00B2",
      (x == "square meter" | x == "m^2") ~ "m\u00B2",
      (x == "hectare" | x == "ha") ~ "ha")
  }

  if ((x %in% units_vl) & convert) {
    x_new <- dplyr::case_when(
      y < 0.01 ~ "m/s",
      y < 0.25 ~ "km/day",
      TRUE ~ "km/hour")
    
    y <- x_new %#% y
    x <- x_new
  }
  
  if (x %in% units_vl) {
    if (x == "kilometers/hour" || x == "km/h") {
      x <- "km/h"
      x_html <- "kilometers/day"
    } else if (x == "kilometers/day" || x == "km/day") {
      x <- "km/day"
      x_html <- "kilometers/day"
    } else if (x == "meters/second" || x == "m/s") {
      x <- "m/s"
      x_html <- "meters/second"
    }
  }

  # Round value:
  y <- sigdigits(y, digits)
  
  # Check if value is equal to 1 (e.g. 1 hour), adjust unit:
  if (x %in% units_tm) {
    x <- dplyr::case_when(y < 1 || y > 1 ~ paste0(x, "s"),
                          y == 1 ~ x)
  }

  # Show units as HTML:
  x <- ifelse(ui, x_html, x)
  
  out <- data.frame(value = numeric(0), unit = character(0))
  out <- out %>% dplyr::add_row(value = as.numeric(y), unit = x)
  return(out)
}

#' Prepare movement model
#'
#' @description Prepare parameters for movement data simulation
#' @keywords internal
#'
#' @param tau_p0 numeric, integer. position autocorrelation timescale.
#' @param tau_p0_units character vector of tau p units.
#' @param tau_v0 numeric, integer. velocity autocorrelation timescale.
#' @param tau_v0_units character vector of tau v units.
#' @param sigma0 numeric, integer. semi-variance or sigma.
#' @param tau_p0_units character vector of sigma units.
#'
#' @importFrom ctmm `%#%`
#' @noRd
prepare_mod <- function(tau_p,
                        tau_p_units,
                        tau_v,
                        tau_v_units,
                        sigma,
                        sigma_units) {

  # characteristic timescales
  taup <- tau_p %#% tau_p_units # position autocorrelation
  tauv <- tau_v %#% tau_v_units # velocity autocorrelation

  sig <- sigma %#% sigma_units # spatial variance

  # generate the mod0
  mod <- ctmm::ctmm(tau = c(taup, tauv),
                    isotropic = TRUE,
                    sigma = sig,
                    mu = c(0,0))
  return(mod)
}

#' Simulate movement data
#'
#' @description Simulate movement data through ctmm
#' @keywords internal
#'
#' @param mod0 movement model
#' @param dur0 numeric, integer. sampling duration.
#' @param dur0_units character vector of sampling duration units.
#' @param tau_v0 numeric, integer. sampling interval.
#' @param tau_v0_units character vector of sampling interval units.
#' @param seed0 random seed value for simulation.
#'
#' @noRd
simulate_data <- function(mod,
                          dur,
                          dur_units,
                          dti,
                          dti_units,
                          seed) {

  dur <- dur %#% dur_units # duration
  dti <- round(dti %#% dti_units, 0) # sampling interval

  t0 <- seq(0, dur, by = dti)
  dat <- ctmm::simulate(mod, t = t0, seed = seed)
  dat <- pseudonymize(dat)
  dat$index <- 1:nrow(dat)

  return(dat)
}


CI.upper <- Vectorize(function(k, level) {
  stats::qchisq((1 - level)/2, k, lower.tail = FALSE) / k} )

CI.lower <- Vectorize(function(k, level) {
  stats::qchisq((1 - level)/2, k, lower.tail = TRUE) / k} )

calculate_ci <- function(variable, level) {
  
  out <- data.frame(
    CI = level,
    CI_low = CI.lower(variable, level),
    CI_high = CI.upper(variable, level))
  
  return(out)
}


#' Extract parameters.
#'
#' @description Extracting parameter values and units from ctmm summaries.
#' @return The return value, if any, from executing the utility.
#' @keywords internal
#'
#' @noRd
extract_pars <- function(obj, par, 
                         fraction = .65, 
                         data = NULL) {
  
  if (par == "sigma") { 
    if (missing(data)) {
      stop("`data` argument not provided.")
    }

    svf <- extract_svf(data, fraction = fraction)
    out <- c("low" = mean(svf$var_low95) %#% "km^2",
             "est" = var.covm(obj$sigma, ave = T),
             "high" = mean(svf$var_upp95) %#% "km^2")
    
    out <- data.frame(value = out, "unit" = "m^2")
    
  } else if (inherits(obj, "telemetry")) {
    nms.dat <- suppressWarnings(names(summary(obj)))
    
    unit <- extract_units(nms.dat[grep(par, nms.dat)])
    value <- suppressWarnings(as.numeric(
      summary(obj)[grep(par, nms.dat)]))
    
    out <- data.frame(value = value, "unit" = unit)
    
  } else if (inherits(obj, "ctmm")) {
    sum.fit <- summary(obj)
    nms.fit <- rownames(sum.fit$CI)
    
    out <- sum.fit$CI[grep(par, nms.fit), ]
    
    if (all(is.na(out))) {
      out <- NULL
    } else {
      unit <- extract_units(nms.fit[grep(par, nms.fit)])
      out <- data.frame(value = out, "unit" = unit)
    }
  }
  return(out)
}

#' Extract DOF
#'
#' @description Extracting DOF values and units from ctmm summaries.
#' @return The return value, if any, from executing the utility.
#' @keywords internal
#'
#' @noRd
extract_dof <- function(obj, par) {
  
  par_list <- c("mean", "speed", "area", "diffusion")
  
  if (!(par %in% par_list)) {
    stop("`par` argument is not valid.")
  }
  
  if (inherits(obj, "ctmm")) {
    sum.fit <- summary(obj)
    nms.fit <- names(sum.fit$DOF)
    
    out <- sum.fit$DOF[grep(par, nms.fit)][[1]]
    if (is.na(out)) out <- NULL
    
  } else {
    stop("`object` argument is not a `ctmm` movement model.")
  }
  
  return(out)
}

#' Extract semi-variance data
#'
#' @description Extract semi-variance data
#' @keywords internal
#'
#' @noRd
extract_svf <- function(data, fraction = .65) {

  level <- 0.95
  SVF <- ctmm::variogram(data = data) # CI = "Gauss"
  vardat <- data.frame(SVF = SVF$SVF,
                       DOF = SVF$DOF,
                       lag = SVF$lag) %>%
    dplyr::slice_min(lag, prop = fraction) %>%
    dplyr::mutate(lag_days = lag/60/60/24)

  vardat$lag_days <- (vardat$lag)/60/60/24
  vardat$var_low95 <- "square kilometers" %#%
    ( vardat$SVF * CI.lower(vardat$DOF, level) )
  vardat$var_upp95 <- "square kilometers" %#%
    ( vardat$SVF * CI.upper(vardat$DOF, level) )
  vardat$var_low50 <- "square kilometers" %#%
    ( vardat$SVF * CI.lower(vardat$DOF, .5) )
  vardat$var_upp50 <- "square kilometers" %#%
    ( vardat$SVF * CI.upper(vardat$DOF, .5) )
  vardat$SVF <-"square kilometers" %#% vardat$SVF

  return(vardat)
}

#' Simulate GPS battery life decay
#'
#' @description Simulate GPS battery life decay
#'
#' @param data data.frame. A dataset with frequencies.
#' @param yrange Numeric. Value for the range of duration (y).
#' @param yunits Character. Unit for the range of duration (y).
#' @param cutoff Character. Cut-off for for minimum duration required.
#' @param max_dti Maximum sampling interval (or minimum) frequency for the maximum duration.
#' @param trace Logical. Display messages as function runs.
#' @keywords internal
#'
#' @importFrom ctmm `%#%`
#' @importFrom dplyr `%>%`
#' 
#' @noRd
simulate_gps <- function(data,
                         yrange,
                         yunits,
                         cutoff,
                         max_dti,
                         trace = FALSE) {

  stopifnot("Error: data required." = !is.null(data))

  stopifnot(is.numeric(yrange) || is.null(yrange))
  stopifnot(is.numeric(cutoff) || is.null(cutoff))

  stopifnot(is.character(yunits) || is.null(yunits))
  stopifnot(is.character(max_dti) || is.null(max_dti))
  
  dti <- dti_notes <- dti_scale <- dti_yn <- frq_hrs <- NULL
  trace <- FALSE

  if(trace == TRUE) message(paste(yrange, yunits))
  if(yrange == 0) stop("Duration cannot be 0.", call. = FALSE)

  unit <- "days"
  params <- data.frame(
    id = ifelse(max_dti == "1 fix every day", "main", "other"),
    y0 = round(unit %#% (yrange %#% yunits), 1),
    x0 = data$frq_hrs[match(max_dti, data$dti_notes)],
    yrange = yrange,
    shift = NA)

  params[["shift"]] <- dplyr::case_when(
    params[["y0"]] < 31 ~ "very low", # 1 month
    params[["y0"]] < unit %#% 1/2 %#% "years" ~ "low",
    params[["y0"]] < unit %#% 1 %#% "year" ~ "medium",
    params[["y0"]] < unit %#% 3 %#% "years" ~ "high",
    params[["y0"]] < unit %#% 5 %#% "years" ~ "very high",
    TRUE ~ "extremely high"
  )

  newdata <- data %>%
    dplyr::select(dti_notes, dti, frq_hrs) %>%
    dplyr::filter(frq_hrs >= params[["x0"]])

  threshold <- dplyr::case_when(
    params[["shift"]] == "very low" ~ 0.05,
    params[["shift"]] == "low" ~ 0.1,
    params[["shift"]] == "medium" ~ 0.25,
    params[["shift"]] == "high" ~ 0.3,
    TRUE ~ 1
  )

  init <- init0 <- c(-16.913, params[["y0"]])
  y <- calculate_pars(newdata$frq_hrs, init)

  x <- c(NA, NA, 1, 1)
  x[1] <- dplyr::case_when(
    params[["shift"]] == "very low" ~ 1,
    params[["shift"]] == "low" ~ 3,
    params[["shift"]] == "medium" ~ 10,
    params[["shift"]] == "high" ~ 20,
    TRUE ~ 30
  )

  x[3] <- dplyr::case_when(
    params[["shift"]] == "very low" ~ yunits %#% 1 %#% "day",
    params[["shift"]] == "low" ~ yunits %#% 5 %#% "days",
    params[["shift"]] == "medium" ~ yunits %#% 1 %#% "months",
    params[["shift"]] == "high" ~ yunits %#% 1 %#% "months",
    params[["shift"]] == "very high" ~ yunits %#% 1.4 %#% "months",
    TRUE ~ yunits %#% 6 %#% "months"
  )

  i <- 0
  n_attempts <- m_attempts <- 40
  for (n in 1:n_attempts) {

    if (all(y == 0)) {
      init <- init0
      break
    }

    if (n > 1 && all(init == init0)) break

    # Match maximum duration with yrange:
    for(m in 1:m_attempts) {

      out <- c("expected" = params[["y0"]],
               "current" = max(y),
               "diff" = diff(c(params[["y0"]], max(y))))

      if(trace) print(paste0("[m] dur: ", out[["current"]],
                             ", goal dur: ", out[["expected"]]))
      if(trace) print(paste("[m] diff dur:", round(out[["diff"]], 3),
                            "compared to", threshold))

      x[2] <- dplyr::case_when(
        abs(out[["diff"]]) <= 0.5 ~ 2,
        abs(out[["diff"]]) <= 5 ~ 5,
        abs(out[["diff"]]) <= 10 ~ 10,
        abs(out[["diff"]]) <= 20 ~ 20,
        TRUE ~ 30)

      if (abs(out[["diff"]]) > threshold) {

        if (sign(out[["diff"]]) == 1) {
          init[1] <- init[1] + x[1] * x[2]
        } else {
          init[1] <- init[1] - x[1] * x[2]
        }

        y <- calculate_pars(newdata$frq_hrs, init)
        i <- i + 1
        if(all(y == 0)) { init <- init0; break }

      } else break
    }

    y <- calculate_pars(newdata$frq_hrs, init)

    # Adjust initial parameters:

    out[["current"]] <- max(y)
    out[["diff"]] <- diff(c(out[["expected"]], out[["current"]]))

    if(trace) print(paste0("dur: ", out[["current"]],
                           ", goal dur: ", out[["expected"]]))
    if(trace) print(paste("diff dur:", round(out[["diff"]], 3),
                          "compared to", threshold))

    if (abs(out[["diff"]]) <= threshold) break

    x[4] <- dplyr::case_when(
      abs(out[["diff"]]) <= 1 ~ 1,
      abs(out[["diff"]]) <= 5 ~ 2,
      TRUE ~ 3)

    if (out[["diff"]] > threshold) {
      yrange <- yrange - x[3] * x[4]
    } else {
      yrange <- yrange + x[3] * x[4]
    }

    init[2] <- unit %#% yrange %#% yunits
    y <- calculate_pars(newdata$frq_hrs, init)
    i <- i + 1
  }

  newdata$dur_sec <- y %#% unit
  newdata$dur_mth <- "months" %#% newdata$dur_sec

  if (max(newdata$dur_sec) > cutoff) {
    newdata$color <- as.factor(dplyr::case_when(
      newdata$dur_sec < cutoff ~ "red",
      newdata$dur_sec >= cutoff ~ "blue"))
  } else { newdata$color <- "red" }

  if (trace) print(paste("-- number of attempts:", i))

  newdata$id <- 1:nrow(newdata)
  newdata <- dplyr::left_join(
    newdata,
    data %>% dplyr::select(dti, dti_scale, dti_yn),
    by = "dti")
  return(newdata)
}


#' Calculate initial parameters
#'
#' @description Calculate initial parameters for log-logistic function
#' @keywords internal
#'
#' @noRd
#'
calculate_pars <- function(x, init) {
  
  d <- init[1] + 6.756 * init[2]
  if (!sign(d/init[2]) == 1) return(rep(0, length(x)))
  
  e <- 1.005511 / 
    ( 1 + exp(1.490650 *
                (log(d/init[2]) - log(0.202345))) )
  b <- 0.847 + (0.985 - 0.847) * exp(-(init[2]) / 14.297)
  y <- d / ( 1 + exp(b * (log(x)-log(e))) )
  return(y)
}


#' Estimate computation time
#'
#' @description Calculate computation time of ctmm functions.
#' @keywords internal
#'
#' @noRd
#'
guesstimate_time <- function(data, 
                          fit = NULL,
                          type = "fit",
                          trace = FALSE,
                          parallel = TRUE) {
  
  if (!type %in% c("fit", "speed")) {
    stop("type =", type, " is not supported.", call. = FALSE)
  }
  
  if (missing(data)) {
    stop("`data` argument not provided.")
  }
  
  units <- "minute"
  
  n <- 500
  if (nrow(data) < n) {
    
    # Does not need to run for smaller datasets:
    
    expt <- expt_max <- 1
    expt_min <- 0
    expt_units <- units
    
  } else {
    
    if (type == "fit") {
      
      start_test <- Sys.time()
      tmpdat <- data[1:n, ]
      
      guess <- ctmm::ctmm.guess(tmpdat, interactive = FALSE)
      inputList <- list(list(tmpdat, guess))
      fit <- par.ctmm.select(inputList, trace = FALSE, parallel = TRUE)
      
      total_time <- difftime(Sys.time(), start_test,
                             units = "secs") %>%
        as.numeric()
      
    } # end of if (type == "fit")
    
    if (type == "speed") {
      
      if (missing(fit)) {
        stop("ctmm `fit` object argument not provided.")
      }
      
      n <- 10
      start_test <- Sys.time()
      units <- "minute"
      
      dti <- data[[2,"t"]] - data[[1,"t"]]
      tauv <- extract_pars(fit, par = "velocity")
      m <- ifelse(dti >= 4 * (tauv$value[2] %#% tauv$unit[2]),
                  1, 90)
      
      tmpdat <- data[1:n, ]
      inputList <- align_lists(list(fit), list(tmpdat))
      speed <- par.speed(inputList, trace = trace, parallel = parallel)
      
      total_time <- difftime(Sys.time(), start_test,
                             units = "secs") %>%
        as.numeric() / m
      
    } # end of if (type == "speed")
    
    expt <- ((total_time/n) * nrow(data))
    expt <- ceiling(units %#% expt)
    
    if (expt >= 15) {
      expt_max <- round_any(expt, 5, f = ceiling)
      expt_min <- expt - 5
    } else if (expt < 15 & expt > 5) {
      expt_max <- round_any(expt, 1, f = ceiling)
      expt_min <- expt - 3
    } else {
      expt_max <- round_any(expt, 1, f = ceiling)
      expt_min <- expt_max
    }
  }
  
  expt_units <- ifelse(expt_max == 1, units, "minutes")
  
  outputs <- data.frame(expt, expt_min, expt_max, expt_units)
  names(outputs) <- c("mean", "min", "max", "units")
  return(outputs)
  
}


#' Calculate distance
#'
#' @description Calculate distance traveled
#' @keywords internal
#'
#' @noRd
#'
calc_dist <- function(data) {

  tmpdat <- data.frame(
    x = data$x,
    y = data$y)

  tmpdist <- list()
  for(i in 2:nrow(data)) {
    tmpdist[[i]] <-
      sqrt((tmpdat$x[i] - tmpdat$x[i-1])^2 +
             (tmpdat$y[i] - tmpdat$y[i-1])^2)
  }
  dist <- c(0, do.call("rbind", tmpdist))
  return(dist)

  # dist <- c(0, sqrt((data$x - lag(data$x))^2 +
  #                     (data$y - lag(data$y))^2)[-1])
  # return(dist)

}

