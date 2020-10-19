USER FUNCTION FIRSTNFSE()


aadd(aRotina,{'Ajusta Flag','U_FLGMI()' , 0 , 2,0,NIL})   
//ONDE:Parametros do array a Rotina:
//1. Nome a aparecer no cabecalho
//2. Nome da Rotina associada    
//3. Reservado                        
//4. Tipo de Transação a ser efetuada:     
//1 - Pesquisa e Posiciona em um Banco de Dados      
//2 - Simplesmente Mostra os Campos                  
//3 - Inclui registros no Bancos de Dados            
//4 - Altera o registro corrente                     
//5 - Remove o registro corrente do Banco de Dados 
//5. Nivel de acesso                                   
//6. Habilita Menu Funcional              
return

User Function FLGMI()                                              
cDoc 	:= SF2->F2_DOC
cSerie  := SF2->F2_SERIE
cF3Doc	:= ""
   
SF3->(DBSETORDER(6))
IF SF3->(DBSEEK(xFilial("SF3")+cDoc+cSerie))
	cF3Doc := SF3->F3_NFISCAL
	RECLOCK("SF3",.F.)   
	SF3->F3_CODRET = ' ' 
	MSUNLOCK()
	Alert("Flag Ajustado, aguarde transmissão da NF")
EndIf


return