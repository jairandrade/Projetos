#INCLUDE "TOTVS.CH"
user function MT103FIN()
	local lVenc    := .T.
	/*Local aLocHead := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
	Local aLocCols := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
	Local lLocRet  := PARAMIXB[3]      // Flag de validações anteriores padrões do sistema  
	Local nE2Vnc   := aScan(aLocHead,{|X| ALLTRIM(X[2]) == "E2_VENCTO"})
	Local nE2Val   := aScan(aLocHead,{|X| ALLTRIM(X[2]) == "E2_VALOR"})
    LOCAL nRecord  := 1
    local nDiasVenc	:= superGetMV("TCP_DIAVEN",,13) 
    lOCAL dDataVal := DaySum( Date(),nDiasVenc ) 
    
	For nRecord:= 1 to Len(aLocCols)   
		If aLocCols[nRecord,nE2Val] > 0 .AND. aLocCols[nRecord,nE2Vnc] < dDataVal  
			lVenc := .F.
		Endif
	Next
		
   	_cMsg := "Não é permitido lançar NF com data de vencimento inferior a "+DTOC(dDataVal)+" (prazo "+ALLTRIM(STR(nDiasVenc))+" dias).                       "
 	
	 IF!(lVenc)
 		Help(,,"VENCIMENTO_INVÁLIDO.", NIL, _cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Altere o vencimento para uma data igual ou superior a "+DTOC(dDataVal)+". Se necessário o vencimento deverá ser corrigido pelo setor financeiro."})
 	ENDIF*/
 	
Return lVenc  