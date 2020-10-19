//#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "protheus.ch"
#include "rwmake.ch"
#include "ap5mail.ch"
#include "Directry.ch"
#include "fileio.ch"	

#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ AJPRDSTD ¦ Autor ¦ Silvio Lima                ¦ Data ¦ 10/09/15 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Programa para ajustar o custo stand do produto com arquivo CSV  ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/          
  
User Function ATUITEMC ()
      
Processa({|| ATUITEMC1() },"Processando..."," ")  // u_AJPRDSTD()

Return

Static Function ATUITEMC1() 

Local cPerg		:= "AJCLIGRP"
Local cArquivo	:= ""
Local xBuffer	:= Space(85)
Local nTamArq	:= 0
Local nLidos	:= 0
Local aDados	:= {} 
Local lContin   := .T.     
Local cCodNatu  := ''

AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif	

cArquivo:= mv_par01

If !File(cArquivo)
	Aviso("Atenção","Não foi possível localizar o arquivo informado. Verifique!",{"OK"})
	Return
Endif	

	  
//Abre o arquivo
FT_FUse(cArquivo) 
                               
msg:= ("Linhas no arquivo g ["+str(ft_flastrec(),6)+"]")
 
FT_FGOTOP()
         
nCount := 0
Count To nCount
Cont := 0
Procregua(nCount)

//if FT_FEof()
//	DbSelectArea('CTD')
//	CTD->(dbSetOrder(1))  
//	WHILE CTD->(!Eof()) 
//		Reclock("CTD",.F.)	
//		CTD->CTD_BLOQ := '1'
//		CTD->(MsUnlock())
//		
//		CTD->(DbSkip())
//	enddo
//endif
nLin := 0
While !FT_FEof() .AND. lContin
	nLin++
	cLinha:= FT_FReadln()
	nTamLinha := Len(cLinha)
	cLinhaD := cLinha+';'
	nPosSep:= At(";",cLinhaD)
	
	aLin:= Separa(cLinhaD,";")
    
    Incproc("Atualizando Itens contas " + Substr(cValToChar(aLin[1]),1,15) + " ")
    
	If Empty(cLinha)
		IncProc()  
		FT_FSkip()
		Loop
	Endif
	lAcho := .F.
	_cFil   := ALLTRIM(aLin[1])
	cCodItd := ALLTRIM(aLin[2])
	cNomItd := ALLTRIM(aLin[3])
	cCodNatu := ALLTRIM(aLin[3])
	
	IF(val(_cFil) > 0)
		_cFil := PadL(_cFil, 2, '0')
	endif
	
	DbSelectArea('CTD')
	CTD->(dbSetOrder(1))  
	if !empty(alltrim(cCodNatu)) .and. !empty(ALLTRIM(aLin[2])) .and.  CTD->(dbSeek(_cFil+cCodItd)) 
		//WHILE SA1->(!Eof()) .AND. SA1->A1_CGC = ALLTRIM(aLin[1])
			Reclock("CTD",.F.)	
			CTD->CTD_BLOQ := '2'
			CTD->CTD_XNATUR := ALLTRIM(aLin[4])
			CTD->(MsUnlock())
			
//			CTD->(DbSkip())
			lAcho := .T.
			
		//enddo
	else
		DbSelectArea('CTD')
		CTD->(dbSetOrder(4))  
		if !empty(alltrim(cNomItd)) .and. !empty(ALLTRIM(aLin[3])) .and.  CTD->(dbSeek(_cFil+cNomItd)) 
		//WHILE SA1->(!Eof()) .AND. SA1->A1_CGC = ALLTRIM(aLin[1])
			Reclock("CTD",.F.)	
			CTD->CTD_BLOQ := '2'
			CTD->CTD_XNATUR := ALLTRIM(aLin[4])
			CTD->(MsUnlock())
			
//			CTD->(DbSkip())
			lAcho := .T.
		ENDIF	
		//enddo
		
	endif
	IF !lAcho
		//Conout(ALLTRIM(aLin[1]) +' - '+ALLTRIM(aLin[2])+' - '+ALLTRIM(aLin[3]))
	ENDIF
	FT_FSkip()
	 
End Do	


FT_FUse() //Fecha o arquivo.

Return


Static Function AjustaSX1(cPerg)

Local aRegs:= {}
aAdd(aRegs,{cPerg,"01","Arquivo Importado"	 ,"Arquivo Importadoe"  ,"Arquivo Importado"	,"mv_ch1","C",60,0,0,"G","naovazio()","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","DIR","","",""})

U_BuscaPerg(aRegs)
Return

