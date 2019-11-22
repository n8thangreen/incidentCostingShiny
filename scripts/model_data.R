
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
