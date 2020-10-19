User function AMAT001(cGrupo, nTipo)
Local lRet := .F.

if SB1->B1_GRUPO $ GetMV("TCP_GRPINF")  
	lRet := .T.
endif          

IF(nTipo == 2 .AND. IsInCallStack("MATA140"))
	lRet := .F.
endif                                            

return lRet