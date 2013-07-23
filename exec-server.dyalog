:namespace execServer

    ∇ start port;rc;obj;event;data;wait

      load_conga_drc
      #.DRC.Init'' ⋄ CDONE←0
      :If 0≠1⊃r←#.DRC.Srv'XSrv' ''port'Raw'
          ⎕←'Unable to start Execute Server: ',⍕r
          :Return
      :EndIf
      ⎕←'Execute Server started on port ',⍕port
      :While ~CDONE
          rc obj event data←4↑wait←#.DRC.Wait'XSrv' 1000
          :Select rc
          :Case 0
              :Select event
              :Case 'Connect'
                  r←'*** ',(,ts),' Welcome to Dyalog execute server'
                  ⎕←'Client connected'
                  {}#.DRC.Send obj r 0 ⍝ 1=Close connection
              :Case 'Block'
                  rx rc obj event data
              :Else
                  ⎕←'closing'
                  {}#.DRC.Close obj ⍝ Anything unexpected
              :EndSelect
          :Case 100 ⍝ Time out - Housekeeping Here
          :Else
              ⎕←'Error in Wait: ',⍕wait ⋄ CDONE←1
          :EndSelect
      :EndWhile
      {}#.DRC.Close'XSrv' ⋄ ⎕←'Execute Server terminated.'
    ∇

    ∇ load_conga_drc;path;loadConga
      :If 0=⎕NC'#.DRC'
          path←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
          loadConga←{'DRC'#.⎕CY path,⍵,'ws',⍵,'conga'}
          :Trap 11
              loadConga'/' ⍝ try to load Unix style ws
          :Else
              loadConga'\'
          :EndTrap
      :EndIf
    ∇

    ∇ rx msg;rc;obj;event;rawData;cmd;res
      rc obj event rawData←4↑msg
      cmd←'UTF-8'⎕UCS rawData
      ⎕←ts,' ',cmd ⍝ why are the parenthesis needed?

      :Trap 0
          res←⍎cmd~⎕UCS 13 10
      :Else
          res←(⍕⎕EN),' ',(⍕⎕EM ⎕EN),' received: ',⍕cmd~⎕UCS 13 10
      :EndTrap

      ⎕←res
      {}#.DRC.Send obj(⎕UCS⍕res,⎕UCS 10)0
    ∇

    ∇ Z←ts;fmt
      fmt←'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'
      Z←,fmt ⎕FMT 1 6⍴⎕TS
    ∇

:endnamespace
