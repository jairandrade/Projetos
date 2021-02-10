#INCLUDE "TOTVS.CH"
  
User Function GetFile1()
    Local targetDir
  
    targetDir:= cGetFile( '*.txt|*.txt' , 'Textos (TXT)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
  
    Alert(targetDir)
  
Return
