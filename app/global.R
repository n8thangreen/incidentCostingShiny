
#library(reshape2)
require(dplyr)
require(rsample)
require(purrr)
require(tidyr)
require(broom)


# source("R/functions.R")
# source("R/VBA_converted.R")
# source("scripts/model_data.R")



# VBA_converted -----------------------------------------------------------


#' ADJUSTED_SALARY
#'
#' @param c_jobtitle_hr
#' @param c_jobtitle_yr
#'
#' @return
#' @export
#'
ADJUSTED_SALARY <- function(c_jobtitle_hr,
                            c_jobtitle_yr){

  excess_salary <- (c_jobtitle_yr - NI_min)/(days_2018 * 7.5) * p_NI
  return(c_jobtitle_hr*(1 + p_oncost) + excess_salary)
}


#' PATH_INVITE_BIRM
#'
#' @param n_id
#' @param n_screen
#' @param n_latent
#'
#' @return
#' @export
#'
PATH_INVITE_BIRM <- function(n_id,
                             n_screen,
                             n_latent) {

  RA <- c_inc_meet_BIRM + c_phoneRA_BIRM + c_siteRA_BIRM
  screen <-
    CINVITE_SCREEN(n_id, n_screen) + CFUP(n_latent) + c_meeting_review_BIRM

  return(RA + screen)
}

#' CINVITE_SCREEN
#'
#' @param n_id
#' @param n_screen
#'
#' @return
#' @export
#'
CINVITE_SCREEN <- function(n_id,
                           n_screen) {

  T_ADMIN <- t_admin_appt * n_id + t_admin_post * n_screen
  c_nurse_3_hr_adj <- ADJUSTED_SALARY(c_nurse_3_hr_outside, c_nurse_3_yr_outside)

  return(n_screen * (c_apptnurse + c_blood) + (T_ADMIN * c_nurse_3_hr_adj))
}


#' CALLTX
#'
#' @param n_latent
#'
#' @return
#' @export
#'
CALLTX <- function(n_latent) {

  return(c_Tx * n_latent)
}


#' PATH_SITE_BIRM
#'
#' @param n_id
#' @param n_screen
#' @param n_latent
#'
#' @return
#' @export
#'
PATH_SITE_BIRM <- function(n_id,
                           n_screen,
                           n_latent) {

  RA <- c_inc_meet_BIRM + c_phoneRA_BIRM + c_siteRA_BIRM

  if (n_screen > 25) {
    screen <- CSITE_SCREEN_PHLEB(n_id, n_screen)
  }
  else if (n_screen <= 25) {
    screen <- CSITE_SCREEN_NURSE(n_id, n_screen)
  } else{
    screen <- -999999 #error code
  }

  return(RA + screen + CFUP(n_latent) + c_meeting_review_BIRM)
}


#' CSITE_SCREEN_PHLEB
#'
#' @param n_id
#' @param n_screen
#'
#' @return
#' @export
#'
CSITE_SCREEN_PHLEB <- function(n_id,
                               n_screen){

  C_TESTS <- c_blood * n_screen
  T_ADMIN <- t_admin_id * n_id + t_admin_post * n_screen
  DUR = n_screen/max_screen
  n_days <- ceiling(DUR)
  TSITE <- t_site_screen * n_days

  c_nurse_7_hr_adj <- ADJUSTED_SALARY(c_nurse_7_hr_outside, c_nurse_7_yr_outside)
  c_nurse_3_hr_adj <- ADJUSTED_SALARY(c_nurse_3_hr_outside, c_nurse_3_yr_outside)
  c_hpp_hr_adj <- ADJUSTED_SALARY(c_hpp_hr_outside, c_hpp_yr_outside)

  C_PEOPLE <- (c_nurse_7_hr_adj + c_hpp_hr_adj) * TSITE + c_nurse_3_hr_adj * T_ADMIN
  C_OTHER <- C_TESTS + c_inc_meet_BIRM + (3 * c_phleb + 2 * c_drive * d_site) * n_days

  return(C_PEOPLE + C_OTHER)
}


#' CFUP
#'
#' @param n_latent
#'
#' @return
#' @export
#'
CFUP <- function(n_latent) {

  return(c_fup_appt * n_latent)
}


#' PATH_INFORM
#'
#' this is now independent of the number of identified.
#' From H Kaur this is a fixed period
#'
#' @return
#' @export
#'
PATH_INFORM <- function() {

  c_nurse_3_hr_adj <- ADJUSTED_SALARY(c_nurse_3_hr_outside,
                                      c_nurse_3_yr_outside)

  return(c_nurse_3_hr_adj * t_inform)
}


#' CSITE_SCREEN_NURSE
#'
#' @param n_id
#' @param n_screen
#'
#' @return
#' @export
#'
CSITE_SCREEN_NURSE <- function(n_id,
                               n_screen) {

  C_TESTS <- c_blood * n_screen
  T_ADMIN <- t_admin_id * n_id + t_admin_post * n_screen
  TSITE <- t_site_screen

  c_nurse_7_hr_adj <- ADJUSTED_SALARY(c_nurse_7_hr_outside, c_nurse_7_yr_outside)
  c_nurse_3_hr_adj <- ADJUSTED_SALARY(c_nurse_3_hr_outside, c_nurse_3_yr_outside)
  c_hpp_hr_adj <- ADJUSTED_SALARY(c_hpp_hr_outside, c_hpp_yr_outside)

  C_PEOPLE <- ((4 * c_nurse_7_hr_adj + c_hpp_hr_adj) * TSITE + c_nurse_3_hr_adj * T_ADMIN)
  C_OTHER <- C_TESTS + c_inc_meet_BIRM + (5 * c_drive * d_site)

  return(C_PEOPLE + C_OTHER)
}


#' total_year_cost
#'
#' @param inc_sample
#' @param id_per_inc
#' @param screen_per_inc
#' @param ltbi_per_inc
#'
#' @return
#' @export
#'
total_year_cost <- function(inc_sample,
                            id_per_inc,
                            screen_per_inc,
                            ltbi_per_inc){

  invite_cost <- PATH_INVITE_BIRM(id_per_inc, screen_per_inc, ltbi_per_inc)
  site_cost <- PATH_SITE_BIRM(id_per_inc, screen_per_inc, ltbi_per_inc)
  screen_cost <- invite_cost*pinvite + site_cost*p_site_screen

  inc_sample*(screen_cost + odds_advise*PATH_INFORM())
}


# in order to use in mutate()
vtotal_year_cost <- Vectorize(total_year_cost)


# functions ---------------------------------------------------------------


# method of moments beta distn parameter estimation
MoM_beta <- function(xbar,
                     vbar) {
  if (vbar == 0) {
    stop("zero variance not allowed")
  } else if (xbar * (1 - xbar) < vbar) {
    stop("mean or var inappropriate")
  } else{
    a <- xbar * (((xbar * (1 - xbar)) / vbar) - 1)
    b <- (1 - xbar) * (((xbar * (1 - xbar)) / vbar) - 1)
  }
  list(a = a, b = b)
}

# method of moments gamma distn parameter estimation
MoM_gamma <- function(mean,
                      var) {
  stopifnot(var >= 0)
  stopifnot(mean >= 0)
  names(mean) <- NULL
  names(var)  <- NULL

  list(shape = mean ^ 2 / var,
       scale = var / mean)
}

# use for second/outer statistic of bootstrap totals
mean_by_setting <- function(dat){

  dat %>%
    group_by(setting) %>%
    summarise(
      identified = median(identified, na.rm = TRUE),
      screen = median(screen, na.rm = TRUE),
      latent = median(latent, na.rm = TRUE),
      incidents = median(incidents, na.rm = TRUE),
      p_screen = median(p_screen, na.rm = TRUE),
      p_ltbi = median(p_screen, na.rm = TRUE),
      id_per_inc = median(id_per_inc, na.rm = TRUE),
      screen_per_inc = median(screen_per_inc, na.rm = TRUE),
      latent_per_inc = median(latent_per_inc, na.rm = TRUE),
      cost = median(cost, na.rm = TRUE)
    )
}

# summary statistic of individuals
# within each group (e.g. year and setting )
fn_by_group <- function(dat, fn, ...){

  dat %>%
    group_by(...) %>%
    summarise(
      identified = fn(`Total No identified`, na.rm = TRUE),
      screen = fn(`Total No Screened`, na.rm = TRUE),
      latent = fn(`Latent`, na.rm = TRUE),
      cost = fn(cost, na.rm = TRUE),
      incidents = n()) %>%
    mutate(p_screen = screen/identified,
           p_ltbi = latent/screen,
           id_per_inc = identified/incidents,  #num identified per incident
           screen_per_inc = screen/incidents,  #num screened per incident
           latent_per_inc = latent/incidents)  #num ltbi per incident
}

sum_by_group <- purrr::partial(fn_by_group, fn = sum)
mean_by_group <- purrr::partial(fn_by_group, fn = mean)

# generate sample from bootstrap statistic distribution
rnorm_boot <- function(mu, lCI,
                       n_sample = 100){
  sample_res <- NULL

  for (i in seq_along(mu)){

    sample_res <-
      rnorm(n = n_sample,
            mean = mu[i],
            # mean =    , # from raw data
            sd = (mu[i] - lCI[i])/1.96) %>%
      round(digits = 2) %>%
      pmax(0) %>%     #left censoring at origin
      rbind.data.frame(sample_res, .)
  }

  sample_res
}

#
include_year_totals <- function(sample_dat){

  sample_dat %>%
    group_by(year) %>%
    summarise_all(sum) %>%               #column totals
    rbind.data.frame(sample_dat, .) %>%  #append to bottom
    arrange(year)
}


# model_data --------------------------------------------------------------


## on-costs

p_pension18 <<- 0.2060
p_pension19 <<- 0.1430
p_admin <<- 0.0008
p_apprent <<- 0.005
p_NI <<- 0.138
p_oncost <<- 0.2118

d_avail  <<- 253
d_pubhol <<- 8
d_leave0 <<- 27
d_leave5 <<- 29
d_leave10 <<- 33

d_actual  <<- 224
days_2018 <<- 261
NI_min <<- 8632.52          #P White correspondence
NI_min_week <<- 166.01

c_phleb <<- 220             #H Kaur correspondence
c_apptnurse  <<- 76         #NHS reference cost (17/18) HRG code: N28AF
t_admin_post <<- 0.25
t_admin_appt <<- 0.33
t_admin_id <<- 0.25
c_drive <<- 0.50            #H Kaur correspondence

t_QandA  <<- 2
t_inform <<- 0.5
t_inform_pp <<- 0.33
t_siteRA  <<- 2
t_phoneRA <<- 1
t_phone_preRA <<- 0.25
t_site_screen <<- 7.5

d_site <<- 20           #average total distance to/from site
t_meet_review <<- 1     #review meeting duration
t_incid_meet  <<- 1     #incident meeting duration
max_screen <<- 100      #maximum number screened per day
p_site_screen <<- 0.9   #proportion of screening event that are site visits
c_fup_appt <<- 61.60    #follow-up appointment cost; reference cost: HRG code WF02B
t_enquire  <<- 2        #time phone line manning
p_screen_incid <<- 0.85 #probability that screening follows an Incident Management Meeting
c_blood <<- 36          #unit cost of IGRA blood test   #H Kaur correspondence


## salaries

c_TBphys_yr_outside <<- 86449
c_TBphys_hr_outside <<- 44.33

c_hpp_yr_outside <<- 38765
c_hpp_hr_outside <<- 19.88

c_nurse_3_yr_outside <<- 18157
c_nurse_3_hr_outside <<- 9.28

c_nurse_6_yr_outside <<- 28746
c_nurse_6_hr_outside <<- 14.70

c_nurse_7_yr_outside <<- 33895
c_nurse_7_hr_outside <<- 17.34

c_nurse_lead_yr_outside <<- 43469
c_nurse_lead_hr_outside <<- 22.23

c_inc_meet_BIRM <<- 148.62
c_meeting_review_BIRM <<- 148.62
c_meeting_weekly <<- 43.58


pinvite <<- 1 - p_site_screen
odds_advise <<- (1 - p_screen_incid)/p_screen_incid

c_phoneRA_BIRM <<- t_phone_preRA*(c_nurse_7_hr_outside*(1 + p_oncost) + (c_nurse_7_yr_outside - NI_min)*p_NI/(days_2018*7.5))

c_siteRA_BIRM <<- 2*t_siteRA*(c_nurse_7_hr_outside*(1 + p_oncost) + (c_nurse_7_yr_outside - NI_min)*p_NI/(days_2018*7.5)) + 2*c_drive*d_site

