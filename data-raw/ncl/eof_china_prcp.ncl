begin
  neof   = 3
;*******************************************
;  Read data
;*******************************************
  fili = "/mnt/n/Research/ML/MLprcp/data-raw/CN05.1/CN05.1_1deg_Pre_1961_2018_month.nc"
  f    = addfile (fili, "r")
  x    = f->pre            ; (time,lat,lon) ==> (29,60,180)
;   printVarSummary(x) 
;*******************************************
;  EOF 
;*******************************************
  X = x(lat|:,lon|:,time|:)              ; Space x Time

  optEof = True
  eof    = eofunc_Wrap( X, neof, optEof)
  eof_ts = eofunc_ts_Wrap( X, eof, False)

  printVarSummary(eof)
  printVarSummary(eof_ts)
  
  ; fout=addfile("output_of_eof.nc","c")
  ; fout->eof=eof  
;*******************************************
;  plots
;*******************************************
  wks = gsn_open_wks("pdf","ex_01")         ; send graphics to PNG file

  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnAddCyclic         = False        ; data not cyclic
  res@cnFillPalette        = "posneg_1"   ; choose colormap
 
;   res@mpCenterLonF         = 180.         ; defailt is 0 [GM]
  res@mpMinLatF            = min(x&lat)
  res@mpMaxLatF            = max(x&lat)
  res@mpMinLonF            = min(x&lon)
  res@mpMaxLonF            = max(x&lon)
;  res@mpFillDrawOrder      = "PostDraw"

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = True         ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res); contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@gsnPanelMainString  = "EOF"

;   plot2 = gsn_csm_contour_map(wks,eof(1,:,:),res)
;   draw(plot2)
;   frame(wks)
  
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_contour_map(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/neof,1/), resP)     ; draw all 'neof' as one plot

;*******************************************
; time series (principal component) plot
;*******************************************
  eof_ts@long_name = "Amplitude"

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
 ;rts@gsnScale  = True        ; force text scaling               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                     = True             ; modify the panel plot
  rtsP@gsnMaximize         = True             ; large format
      
  resP@gsnPanelMainString  = "SCRIPPS: Pierce"
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,x&time,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)        ; draw all 'neof' as one plot

end
