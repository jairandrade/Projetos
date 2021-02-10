#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"  
#include "Protheus.ch"                                                                                                                                   

#DEFINE __TAMLINHA 120
User Function OMS100()  

//CHAMA importacao de ocorrencias
fImpOco()  

Return 

Static Function fImpOco( pEmpresa, pFilial )

Private cArq
Private nHandle
Private cBuffer
Private nBytesLidos
Private lError := .F.
Private oDlg,oList1,oConfirma,oImprime,oCancela
Private aConfere := {}
Private aOcorre	:= {}
Private aPerguntas := {}
Private cPerg    := "EDIRET" 

If Select("SX2") > 0

	cArq := cGetFile( '*.TXT |*.TXT | *.OCO |*.OCO',;
							"Selecione o arquivo a ser importado.", 1, "", .T.,;
							GETF_LOCALFLOPPY+;
							GETF_LOCALHARD+;
							GETF_NETWORKDRIVE )
	
	Processa({|| ImpArq(.F.)},"Lendo Arquivo")
	
	If ! lError 
		If len(aConfere) = 0
			aAdd(aConfere, {"","","","","Nใo Existem ocorrencias informadas","",""})
		Endif
		oDlg := MSDIALOG():Create()
		oDlg:cName := "oDlg"
		oDlg:cCaption := "Verifica็ใo das Ocorrencias EDI Retorno - Proceda - Ocoren"
		oDlg:nLeft := 0
		oDlg:nTop := 0
		oDlg:nWidth := 910 // 501
		oDlg:nHeight := 391 // 391
		oDlg:lShowHint := .F.
		oDlg:lCentered := .T.
	
	   oList1 := RDListBox(0.66,0.65,883,53,aConfere,{"N.Fiscal","Serie","Nome do Cliente","Ocorrencia","Descri็ใo"})
		oList1:lColDrag := .F.
		oList1:lJustific := .T.
		oList1:lAdjustColSize := .T.
		oList1:lVisibleControl := .T.
		oList1:aArray := aConfere
		oList1:nAt := 1
		oList1:nLeft := 2
		oList1:nTop  := 3
		oList1:nWidth  := 899 //489
		oList1:nHeight := 331
		
		oImprime := SBUTTON():Create(oDlg)
		oImprime:cName := "oImprime"
		oImprime:cCaption := "oSBtn3"
		oImprime:nLeft := 7 //220
		oImprime:nTop := 338  //337
		oImprime:nWidth := 52
		oImprime:nHeight := 22
		oImprime:lShowHint := .F.
		oImprime:lReadOnly := .F.
		oImprime:Align := 0
		oImprime:lVisibleControl := .T.
		oImprime:nType := 6
		oImprime:bAction := {|| Imprime() }
		
		oCancela := SBUTTON():Create(oDlg)
		oCancela:cName := "oCancela"
		oCancela:cCaption := "oSBtn4"
		oCancela:nLeft := 438
		oCancela:nTop := 339
		oCancela:nWidth := 52
		oCancela:nHeight := 22
		oCancela:lShowHint := .F.
		oCancela:lReadOnly := .F.
		oCancela:Align := 0
		oCancela:lVisibleControl := .T.
		oCancela:nType := 2
		oCancela:bAction := {|| Cancela() }
		
		oDlg:Activate()
		
	EndIf
Else 

	PREPARE ENVIRONMENT EMPRESA pEmpresa FILIAL pFilial //Tables  "SD2", "SB1", "SF2", "SA3", "SA1", "SF4", "SC6", "SC5" 
	
	cPasta := "C:\EDI\Recepcao\MBA\PATRUS\"
	aFiles := Directory(cPasta+"*.TXT")
	
	If Len(aFiles) > 0
	
		ProcRegua(Len(aFiles))
		
		For nI := 1 to Len(aFiles)
		
			cArq    := cPasta+alltrim(aFiles[nI][1])
			ImpArq(.T.)
			
			IncProc()
		
		Next nI
	Else 
		Return
	Endif
Endif

Return



Static Function ImpArq(pSrv) 

Local nLinha := 0


Private cCod		:= space(06)
Private cLoja		:= space(02)
Private cNomeCli	:= Space(40)
Private cDesOcor	:= Space(60)

ProcRegua(1000)

For nX:=len(cArq) to 1 step -1
	
	If substr(cArq,nX,1) == "\"
		cPath:= substr(cArq,1,nX)
		cNomeArq:= substr(cArq,Nx+1,Len(cArq))
		If len(cNomeArq) > 20
			cNomeAlt:= substr(cNomeArq,1,20)
		Else
			cNomeAlt:= cNomeArq
		Endif
		exit
	Endif
	
Next

If File(cArq)
	nHandle := FOpen(cArq)
	If nHandle > 0

		cBuffer := Space(__TAMLINHA+2)
		nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
		lOK:= .T.

		While (__TAMLINHA+2) == nBytesLidos

			IncProc("Leitura...")           
			nLinha++
			                                             
			If Substr(cBuffer,1,3) == "341"			
				
				cCGCTrans      := SubStr( cBuffer, 4, 14)
				DbSelectArea("SA4")
				SA4->(DbsetOrder(3))
				If !SA4->( DbSeek( xFilial("SA4") + cCGCTrans ) )  
					cMsg:="Cadastro da Transportadora nใo encontrado: " + CRLF + ;
							"CNPJ: " + Transform( cCGCTrans, "@R 99.999.999/9999-99" ) + CRLF +;
							"Transportadora: " + SA4->A4_NOME + CRLF + ;
							"Favor cadastrar."
					
					If pSrv
						Conout(cMsg)
					Else
						MsgBox( cMsg )
					Endif
					
					Return
				Else
					cTransp	:= SA4->A4_COD
				Endif
			
         ElseIf Substr(cBuffer,1,3) == "342"
            
				cCGCArq:= Substr(cBuffer,4,14)
            	
            If cCGCArq == SM0->M0_CGC
					
					cNrImp	:= GetSXENum("GXL","GXL_NRIMP")
					cNRDC		:= substr(cBuffer,21,8)
	           	cSERDC	:= strzero(val(substr(cBuffer,18,3)),03)
	           	cOcorre	:= substr(cBuffer,29,2) 
					dDatOco	:= ctod( substr(cBuffer,31,02)+"/"+substr(cBuffer,33,02)+"/"+substr(cBuffer,35,04) )
					cHorOco	:= substr(cBuffer,39,02) + ":" + substr(cBuffer,41,2)							           	
					
					cNrNf		:= substr(cBuffer,23,6)
   	        	cSerie	:= strzero(val(substr(cBuffer,18,3)),3)	           	
		   	        	
	           	If cSerie == "000"
	           		cSerie:= space(3)
	           	Endif					
	           	
	           	DbSelectArea("GXH")
	           	GXH->(DbSetOrder(2)) // GXH_FILIAL+GXH_NRDC+GXH_SERDC
	           	If ! GXH->(DbSeek(xFilial("GXH")+cNRDC+cSERDC, .T.))                                                                     
	           		If pSrv
	           			Conout(cNrNf+"/"+cSerie+"- Nota Fiscal nao exite na base de Conhecimentos Importados")
	           		Else
		           		aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Nota Fiscal nao exite na base de Conhecimentos Importados"} )   
		           	Endif
						lOK:= .F.
	           	Endif
	           	
					DbSelectArea("GXL")
					GXL->(DbSetOrder(5)) //GXL_FILIAL+DTOS(GXL_DTOCOR)+GXL_HROCOR+GXL_NRDC+GXL_SERDC+GXL_CODOCO
					If GXL->(DbSeek(xFilial("GXL")+dtos(dDatOco)+cHorOco+cNRDC+cSERDC+cOcorre, .T.))             
						If pSrv 
							Conout(cNrNf+"/"+cSerie+"- Ocorrencia ja existe no Arquivo")
						Else
							aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Ocorrencia ja existe no Arquivo"} )   
						Endif
					Else
					  
						If lOK
						
							cCod		:= GetAdvFVal("SF2","F2_CLIENTE",xFilial("SF2")+cNrNf+cSerie,1)
							cLoja		:= GetAdvFVal("SF2","F2_LOJA",xFilial("SF2")+cNrNf+cSerie,1)
							cNomeCli	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+cCod+cLoja,1)
							cDesOcor := GetAdvFVal("DT2","DT2_DESCRI",xFilial("DT2")+cOcorre,1)  
							If empty(cDesOcor)
								cDesOcor:= "Ocorrencia nao existe na Tabela DT2"
							Endif
						
							RecLock("GXL",.T.)
							GXL->GXL_FILIAL	:= xFilial("GXL")
							GXL->GXL_NRIMP		:= cNrImp
							GXL->GXL_CDTRP		:= cTransp
							GXL->GXL_DTOCOR	:= dDatOco
							GXL->GXL_HROCOR	:= cHorOco
							GXL->GXL_EMISDC	:= cCGCTrans
							GXL->GXL_SERDC		:= cSERDC
							GXL->GXL_NRDC		:= cNRDC
							GXL->GXL_CODOCO	:= cOcorre
							GXL->GXL_OBS		:= substr(cBuffer,45,70)
							GXL->GXL_EDISIT	:= "1" //1=Importado 2=Processado 3=Rejeitado 4= Alterado
							GXL->GXL_EDIMSG	:= ""
							GXL->GXL_EDINRL	:= nLinha
							GXL->GXL_EDILIN	:= cBuffer
							GXL->GXL_EDIARQ	:= cArq
							GXL->GXL_DTIMP		:= dDataBase
							GXL->GXL_CODOBS	:= substr(cBuffer,43,02)
							MsUnlock()					    
							
					  	   AAdd(aConfere,{cNrNF,cSerie,cNomeCli,cOcorre,cDesOcor,cCod,cLoja})
			  	      Endif
			  	      
					Endif
									  	   
			  	Endif   
				
			Endif	
			
		  	cBuffer := Space(__TAMLINHA+2)
		   nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
		   If Len(cBuffer) == (__TAMLINHA-2)
		   	cBuffer += Space(2)
			EndIf			
			
		End
		
		FClose(nHandle)
		
		cFileDest := "PROC_"+cNomeArq      
		MakeDir(cPath+"PROCESSADO")
		__CopyFIle(cArq,cPath+'PROCESSADO\' + cFileDest)
		FERASE(cArq)				
			
		aConfere:= aSort( aConfere,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )		
			
		If Len(aConfere) =  0 
			If len(aOcorre)= 0                     
				cMsg:= "O arquivo nใo cont้m dados para essa empresa CGC: "+ transform( SM0->M0_CGC, "@R 99.999.999/9999-99")
				If pSrv
					Conout(cMsg)
				Else
					MsgBox(cMsg)
				Endif
				lError := .T.
			Endif
		EndIf
			
	Else              
		cMsg:= 'Erro ao tentar abrir o arquivo!  ' + cArq
		If pSrv
			Conout(cMsg)
		Else
			MsgBox(cMsg)
		Endif
		lError := .T.
	EndIf 
		
Else
	cMsg:= 'Arquivo '+AllTrim(cArq)+' nใo encontrado!'
	If pSrv
		Cnout(cMsg)
	Else
		MsgBox()
	Endif
	lError := .T.
EndIf  

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcancela   บAutor  ณRodrigo dos Santos  บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cancela()
oDlg:End()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimprime   บAutor  ณRodrigo dos Santos  บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Imprime()
Local cDesc1         	:= "Este programa tem como objetivo imprimir as ocorrencias "
Local cDesc2         	:= "no arquivo de retorno EDI - Proceda. "
Local cDesc3         	:= ""
Local cPict          	:= ""
Local Imprime      		:= .T.
Local cPerg		      := ""

Private Titulo       		:= "Composicao do Arquivo de Retorno"
Private Cabec1       		:= " "
Private Cabec2       		:= " "

Private nLin 			:= 80
Private nPos 			:= 0
Private aOrd            := {}
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private Limite          := 132
Private Tamanho         := "G"
Private NomeProg        := "COMMC005" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo           := 18
Private aReturn         := { "A4", 1, "Logistica", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cPerg         	:= ""
Private cbTxt      		:= Space(10)
Private cbCont     		:= 00
Private ContFl     		:= 01
Private M_Pag      		:= 01
Private wNRel      		:= "RETORNO" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString		    := ""

wNRel := SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrunreport บAutor  ณMicrosiga           บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function RunReport(Cabec1,Cabec2,Titulo)

If Len(aOcorre) > 0

	Cabec1       		:= "Ocorrencias Nao Importadas "
	Cabec2       		:= "Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia"
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9                           
	
	For nAux := 1 To Len(aOcorre)
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		EndIf
		
		/*                                                                                                                                          
		         1         2         3         4         5         6         7         8         9         0         1         2         3
		1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia 
		9999999999999999   99/99/99  99:99     99999999  999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*/	
		
		@ nLin,01 PSay aOcorre[nAux,01]
		@ nLin,20 PSay aOcorre[nAux,02]
		@ nLin,30 PSay aOcorre[nAux,03]
	   @ nLin,40 PSay aOcorre[nAux,04]
	   @ nLin,50 PSay aOcorre[nAux,05]
		@ nLin,55 PSay aOcorre[nAux,06]   
		nLin++
		
	Next
	
Endif 

Cabec1       		:= "Ocorrencias Importadas "
Cabec2       		:= "Serie         Numero           Cod.        Loja       Cliente                                                   Data Proc.             Cod.         Ocorrencia                                                              "
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9                           

For nAux := 1 To Len(aConfere)
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	EndIf
	
	@ nLin,000 PSay aConfere[nAux][2]
	@ nLin,014 PSay aConfere[nAux][1]
	@ nLin,054 PSay substr(alltrim(aConfere[nAux][3]),1,40) 
   @ nLin,031 Psay aConfere[nAux][6] 
   @ nLin,044 Psay aConfere[nAux][7] 
   @ nLin,113 PSay Dtoc(DDatabase)
   @ nLin,135 PSay aConfere[nAux][4]
   @ nLin,148 Psay aConfere[nAux][5] 
	nLin++
	
Next

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณNUMNF     ณ Autor ณ  Carlos Cleuber       ณ Data ณ 14/05/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณ Retorno o Tamanho correto da NF Formatado                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Diversos programas especificos                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function NumNF( cNF )
Local nTamNf:= TamSX3("D1_DOC")[1]

Local cRet := StrZero( Val( cNF ), nTamNf )

Return cRet

User Function OMS100C()

Return
