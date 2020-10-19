User function MT150OK  
    Local lAtiva     := GetNewPar("MV_TRVFRE",.F.) 
    Private frete := c150Frete 
    Private retorno := .F.
    
    If AllTrim(lAtiva) == 'S' 
    	If ((PARAMIXB[1] == 3).OR.(PARAMIXB[1] == 4)) 
			    if !empty(frete) 
				    If(frete == "T-Por Conta Terceiros")
				    	Aviso("Atenção","O tipo de frete por conta de terceiros foi inativado, favor escolher outra opção.", {"Ok"})
				    EndIf    
				    If(frete == "S-Sem Frete")
				    	Aviso("Atenção","O tipo de frete por conta de terceiros foi inativado, favor escolher outra opção.", {"Ok"})
				    EndIf    
				    If(frete == "S-Sem Frete")
				    	Aviso("Atenção","O tipo de frete por conta de terceiros foi inativado, favor escolher outra opção.", {"Ok"})
				    EndIf
				    If(frete == "C-CIF")
				    	retorno := .T.
				    EndIf    
				    If(frete == "F-FOB")
				    	retorno := .T.
				    EndIf
				Else 
					MsgStop("Atenção, deve-se informar o tipo de frete.")   
		    EndIf 
		Else  
          retorno := .T.
        EndIf  
	  Else
	  	retorno := .T.  
	  EndIf  
Return retorno