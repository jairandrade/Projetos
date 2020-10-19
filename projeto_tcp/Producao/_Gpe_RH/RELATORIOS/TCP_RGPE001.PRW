#INCLUDE "RWMAKE.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Relatorio                                               |
+------------------+---------------------------------------------------------+
|Modulo            | GPE                                                     |
+------------------+---------------------------------------------------------+
|Nome              | RGPE001                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Geracao de relatorio gerencial em excel                 |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                   			 |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/10/13                                                |
+------------------+----------------------------------+-------------+--------+
| Alterações                                          | Responsavel | Data   |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+-------*/
User Function RGPE001()

Local aArea := GetArea()

Local bProcess := {|oSelf| RGPE0011(oSelf)}
Local oProcess := Nil

Private cCVHEFer := SuperGetMv("ES_CVHEFER",,"110")

RGPE0010("RGPE001")
Pergunte("RGPE001",.F.)

oProcess := tNewProcess():New("RGPE001","Relatório Gerencial" ,bProcess,"Geração de Relatório Gerencial em Excel","RGPE001",,.F.,,,.T.,.F.)

if oProcess != nil
	oProcess := FreeObj(oProcess)
endif

RestArea(aArea)

Return

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RGPE0010     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Cria grupo de perguntas para a rotina.                      !
+-----------+------------------------------------------------------------*/
Static Function RGPE0010(cPerg)

local aTam := {}

aAdd(aTam, TamSx3('RA_FILIAL' ))
aAdd(aTam, TamSx3('RA_MAT'    ))
aAdd(aTam, {10,0}              )
aAdd(aTam, TamSx3('RA_CC'     ))
aAdd(aTam, TamSx3('RA_CARGO'  ))
aAdd(aTam, TamSx3('RA_CODFUNC'))
aAdd(aTam, {5,0}               )

//PutSx1(cPerg,"01","Filial de?"           ,"Filial de?"           ,"Filial de?"           ,"mv_ch1","C",aTam[1,1],aTam[1,2],0,"G",""            ,""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Filial ate?"          ,"Filial ate?"          ,"Filial ate?"          ,"mv_ch2","C",aTam[1,1],aTam[1,2],0,"G",""            ,""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Matricula de?"        ,"Matricula de?"        ,"Matricula de?"        ,"mv_ch3","C",aTam[2,1],aTam[2,2],0,"G",""            ,"SRA","","","mv_par03","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Matricula ate?"       ,"Matricula ate?"       ,"Matricula ate?"       ,"mv_ch4","C",aTam[2,1],aTam[2,2],0,"G",""            ,"SRA","","","mv_par04","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Mes Mov De?"          ,"Mes Mov De?"          ,"Mes Mov De?"          ,"mv_ch5","N",2        ,0        ,0,"G","U_RGPE0019()",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Mes Mov Ate?"         ,"Mes Mov Ate?"         ,"Mes Mov Ate?"         ,"mv_ch7","N",2        ,0        ,0,"G","U_RGPE0019()",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"07","Ano Mov De?"          ,"Ano Mov De?"          ,"Ano Mov De?"          ,"mv_ch8","N",4        ,0        ,0,"G","U_RGPE001A()",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"08","Ano Mov Ate?"         ,"Ano Mov Ate?"         ,"Ano Mov Ate?"         ,"mv_ch9","N",4        ,0        ,0,"G","U_RGPE001A()",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"09","Centro de Custos de?" ,"Centro de Custos de?" ,"Centro de Custos de?" ,"mv_ch0","C",aTam[4,1],aTam[4,2],0,"G",""            ,"CTT","","","mv_par09","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"10","Centro de Custos ate?","Centro de Custos ate?","Centro de Custos ate?","mv_cha","C",aTam[4,1],aTam[4,2],0,"G",""            ,"CTT","","","mv_par10","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"11","Cargo de?"            ,"Cargo de?"            ,"Cargo de?"            ,"mv_chb","C",aTam[5,1],aTam[5,2],0,"G",""            ,"SQ3","","","mv_par11","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"12","Cargo ate?"           ,"Cargo ate?"           ,"Cargo ate?"           ,"mv_chc","C",aTam[5,1],aTam[5,2],0,"G",""            ,"SQ3","","","mv_par12","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"13","Função de?"           ,"Função de?"           ,"Função de?"           ,"mv_chd","C",aTam[6,1],aTam[6,2],0,"G",""            ,"SRJ","","","mv_par13","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"14","Função ate?"          ,"Função ate?"          ,"Função ate?"          ,"mv_che","C",aTam[6,1],aTam[6,2],0,"G",""            ,"SRJ","","","mv_par14","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"15","Situação?"            ,"Situação?"            ,"Situação?"            ,"mv_chf","C",aTam[7,1],aTam[7,2],0,"G","fSituacao()" ,""   ,"","","mv_par15","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")

return

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RGPE0011     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Processa dados da rotina                                    !
+-----------+------------------------------------------------------------*/
Static Function RGPE0011( oProcess )

Local aDados   := {}
Local aDadExl  := {}
Local aLinha   := {}
Local aCabec   := {}
Local aVerbas  := {}
Local cPeriodo := ''
Local cDtFun   := ''
Local cDtSal   := ''
Local cCsv     := ''
Local lExcel   := .F. 
Local lCampoOk := .F.
Local nK       := 0
Local nSalario := 0
Local nCount   := 0
Local nMax     := 0
Local nAtual   := 0
Local nMes     := 0
Local nAno     := 0 
Local nPosVrb  := 0
Private cAliasF  := ''

oProcess:SetRegua1(6) 
oProcess:IncRegua1("Pesquisando dados de acordo com parâmetros.")
oProcess:SaveLog("Pesquisando dados de acordo com parâmetros.")
ProcessMessage()

cAliasF := RGPE0012()

oProcess:IncRegua1("Verificando quantidade de registros aguarde...")
oProcess:SaveLog("Verificando quantidade de registros aguarde...")
ProcessMessage()
(cAliasF)->( dbEval( {|| nCount++ } ) )
(cAliasF)->(dbGoTop())

// Procura as verbas que serão exibidas na planilha. Campo RV_XFLAGRL define a exibição da verba.
DbSelectArea("SRV")  
lCampoOk := FieldPos("RV_XFLAGRL") > 0
/*If lCampoOk
	SRV->(DbSetOrder(1)) // RV_FILIAL+RV_COD  
	SRV->(DbGoTop())
	While SRV->(!Eof())  
		If SRV->RV_XFLAGRL == "S"
	    	aAdd(aVerbas,{ SRV->RV_COD, Alltrim(UPPER(SRV->RV_DESC)) })
	 	EndIf
		SRV->(DbSkip())	
	EndDo
EndIf*/

if nCount > 0 
	oProcess:IncRegua1(cValToChar(nCount) + " Encontrados, iniciando processamento...")
	oProcess:SaveLog(cValToChar(nCount) + " Encontrados, iniciando processamento...")
	ProcessMessage()
	
	lExcel := ApOleClient("MSExcel")
	lExcel := .T.	
	If !lExcel
		oProcess:IncRegua1("Microsoft Excel não instalado!")
		oProcess:SaveLog("Microsoft Excel não instalado!")
		ProcessMessage()
		MsgAlert("Microsoft Excel não instalado!")
	else
		oProcess:IncRegua1("Microsoft Excel instalado.. prosseguindo!")
		oProcess:SaveLog("Microsoft Excel instalado.. prosseguindo!")
		ProcessMessage()
		
		oProcess:IncRegua1("Processando os dados, aguarde...")
		oProcess:SaveLog("Processando os dados, aguarde...")
		ProcessMessage()
		
		cPeriodo := cValToChar(MV_PAR07) + StrZero(MV_PAR05, 2)
		nAtual := val(cValToChar(MV_PAR07) + StrZero(MV_PAR05, 2))
		nMax := val(cValToChar(MV_PAR08) + StrZero(MV_PAR06, 2))
				
		nMes := MV_PAR05
		nAno := MV_PAR07

		// Numero maximo de periodos apurado
		nPeriMax := 0
		// corre todos os funcionarios encontrados
		While !(cAliasF)->(EOF()) .AND. !oProcess:lEnd		
			cPeriodo := cValToChar(MV_PAR07) + StrZero(MV_PAR05, 2)
			nAtual := val(cValToChar(MV_PAR07) + StrZero(MV_PAR05, 2))
			nMax := val(cValToChar(MV_PAR08) + StrZero(MV_PAR06, 2))
					
			nMes := MV_PAR05
			nAno := MV_PAR07

			oProcess:IncRegua1("Processando matricula " + (cAliasF)->RA_MAT + ".")
			oProcess:SaveLog("Processando matricula " + (cAliasF)->RA_MAT + ".")
			ProcessMessage()
			
			// Inicializa variaveis de alteracao de Centro de Custo e dados funcionais
			aDadCC := {}
			aDadFunc := {}
			aLastInfo := {}
			aSitFun := {}
			aLastSRA := {}
			cSitFun := ''
			// Linha de espaçamento removido a pedido do usuario
			//aAdd(aDadExl, {'','','','','','','','','','','','','','','','','','',''})
			// corre o período definido pelos parâmetros para pesquisa de dados
			while nAtual <= nMax .AND. !oProcess:lEnd
				cPeriodo := cValToChar(nAno) + StrZero(nMes,2)
				cCabPer := cValToChar(nMes) + '/' + cValToChar(nAno)
				//aAdd(aDadExl, {'','','','','','','','','','','','','','','','','',''})
				oProcess:IncRegua2("Processando periodo " + cCabPer + "")
//				oProcess:SaveLog("Processando matricula " + (cAliasF)->RA_MAT + ".")
				ProcessMessage()				
					
				// Se a data de admissao do funcionario for maior que o periodo calculado,
				// ele nao existiu neste periodo, portanto exibe linha em branco
				// OU
				// Se a pessoa foi demitida e a data de demissao e menor que o periodo atual
				// nao necessita mais imprimir a linha 
				cSitDem1 := "" //Demitido
				cSitDem2 := "" //data demissao   
				If len(aSitFun) == 0
					aSitDem := RGPE001SIT( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
					cSitDem1 := aSitDem[1]
					cSitDem2 := aSitDem[2]   
				EndIf                                          
				If (MesAno(STOD((cAliasF)->RA_ADMISSA)) > cPeriodo) /*.OR.; 
					(cSitFun == 'D' .And. MesAno(aSitFun[1]) < cPeriodo) .OR.;
					(cSitDem2 == 'D' .And. MesAno(cSitDem1) < cPeriodo)*/
					// Incrementa as variaveis de controle e pula este periodo
					nMes := nMes + 1
					if nMes > 12
						nMes := 1
						nAno++
					endif
					nAtual := val(cValToChar(nAno) + if(len(cValToChar(nMes)) == 1, "0" + cValToChar(nMes), cValToChar(nMes)))
					// Pula o periodo
					Loop // comentado 21/03/19
				EndIf
				
				aLinha := {}
				//aAdd(aLinha, cCabPer)   
				aAdd(aLinha, substr(mesextenso(nMes),1,3) + '/' + cValToChar(nAno))
				aAdd(aLinha, (cAliasF)->RA_FILIAL)
				aAdd(aLinha, (cAliasF)->RA_MAT)
				aAdd(aLinha, (cAliasF)->RA_NOME)
				aAdd(aLinha, DTOC(STOD((cAliasF)->RA_ADMISSA))) 
				
				oProcess:IncRegua2("Buscando ultima data de alteração de dados funcionais...")
				ProcessMessage()
				// Se as informacoes de alteracao do centro de custo estao atualizadas para este periodo
				// Nao e necessaria busca em banco (Se a data de alter. de CC for maior que o periodo atual)
				If Len(aDadCC) <= 0 .Or. MesAno(aDadCC[1]) <= cPeriodo
					aDadCC := RGPEFCC( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
				EndIf
				// Se existem transferencias
				If Len(aDadCC) > 0
					cCodCC := aDadCC[2]	// CC da ultima transferencia
					cDescCC := aDadCC[3]	// Descricao do CC
				Else
					cCodCC := (cAliasF)->RA_CC	// CC atual (pois nao foram encontradas transferencias)
					cDescCC := (cAliasF)->CTT_DESC01	// Descricao do CC
				EndIf
				// Adiciona as informacoes de CC na linha				
				aAdd(aLinha, cCodCC)	// CC 
				aAdd(aLinha, cDescCC)	// Descricao do CC

				// Se as informacoes de alteracao de cargo/funcao estao atualizadas para este periodo
				// Nao e necessaria busca em banco (Se a data de alteracao for maior que o periodo atual)
				If Len(aDadFunc) <= 0 .Or. (!Empty(aDadFunc[1]) .And. MesAno(aDadFunc[1]) < cPeriodo)
					aDadFunc := RGPE0017( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
				EndIf

				// Se nao trouxe nenhum resultado (nao houveram alteracoes)
				If Len(aDadFunc) <= 0
					aDadFunc := {(cAliasF)->RA_ADMISSA, (cAliasF)->Q3_DESCSUM, (cAliasF)->RJ_DESC}
				EndIf
				
				cDtFun   := aDadFunc[1]		// Data da ultima movimentacao funcional				
				aAdd(aLinha, aDadFunc[2])	// Cargo
				aAdd(aLinha, aDadFunc[3])	// Funcao
				
				If Len(aSitFun) <= 0 .Or. MesAno(aSitFun[1]) < cPeriodo
					aSitFun := RGPE001SIT( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
				EndIf
				
				cSitFun := aSitFun[2]
				
				do case
					case Empty(cSitFun)
						aAdd(aLinha, "ATIVO")				// Alterado de "situacao normal" para "ativo" a pedido da usuaria
						
					case cSitFun == 'A'
						aAdd(aLinha, "AFASTADO TEMP.")

					case cSitFun == 'M'
						aAdd(aLinha, "ATESTADO MEDICO")
					
					case cSitFun == 'D'
						aAdd(aLinha, "DEMITIDO") 
						
					case cSitFun == 'F'
						aAdd(aLinha, "FERIAS")
						
					case cSitFun == 'T'
						aAdd(aLinha, "TRANSFERIDO") 

				endcase
				
				If ( cSitFun == 'D' )
					aAdd(aLinha, DTOC(aSitFun[1]))	// dt. demissao
					aAdd(aLinha, aSitFun[3]) //Motivo
				Else
					aAdd(aLinha,'')
					aAdd(aLinha,'')
				EndIf
				

				oProcess:IncRegua2("Buscando ultima data de alteração de dados salariais...")
				ProcessMessage()
				
				// Se as informacoes de alteracao salarial estao atualizadas para este periodo
				// Nao e necessaria busca em banco (Se a data de alteracao for maior que o periodo atual)
				If Len(aLastInfo) <= 0 .Or. MesAno(aLastInfo[1]) < cPeriodo
					aLastInfo := RGPE0018( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
				EndIf				
				
				cDtSal   := aLastInfo[1]
				nSalario := aLastInfo[2]
				
				// Se as informacoes de alteracao da  estao atualizadas para este periodo
				// Nao e necessaria busca em banco (Se a data de alteracao for maior que o periodo atual)
				nPosHrsMes := aScan(aLastSRA,{|aItem| aItem[2] == "RA_HRSMES"})
				nPosSindi := aScan(aLastSRA,{|aItem| aItem[2] == "RA_SINDICA"})
				
				If Len(aLastSRA) <= 0 .Or.;
				 ( (nPosHrsMes <= 0 ) .Or. MesAno(aLastSRA[nPosHrsMes,1]) < cPeriodo ) .Or.;
				 ( (nPosSindi <= 0 ) .Or. MesAno(aLastSRA[nPosSindi,1]) < cPeriodo )
				 
					aLastSRA := RGPESRA( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cCabPer )
				EndIf
				
				nPosHrsMes := aScan(aLastSRA,{|aItem| aItem[2] == "RA_HRSMES"})
				nPosSindi := aScan(aLastSRA,{|aItem| aItem[2] == "RA_SINDICA"})
				
				If Len(aLastSRA) > 0
					If nPosHrsMes > 0
						nHrsMes  := aLastSRA[nPosHrsMes, 3]
					Else
						nHrsMes  := cValToChar((cAliasF)->RA_HRSMES)
					EndIf
					
					If nPosSindi > 0 
						cDescSindi := Posicione("RCE", 1, xFilial("RCE") + aLastSRA[nPosSindi, 3], "RCE_DESCRI" )
					Else
						cDescSindi := (cAliasF)->RCE_DESCRI
					EndIf
				Else
					nHrsMes  := cValToChar((cAliasF)->RA_HRSMES)
					cDescSindi := (cAliasF)->RCE_DESCRI
				EndIf
				
				aAdd(aLinha, iif(empty(cDtFun), '', dToC(sToD(cDtFun))))
				//aAdd(aLinha, iif(empty(cDtSal), '', dToC(sToD(cDtSal))))	
				//aAdd(aLinha, (cAliasF)->RA_TABNIVE) // Nivel do cargo -- Valor SEMPRE atual do cadastro do funcionario (sem buscar historico)
				//aAdd(aLinha, (cAliasF)->RA_TABFAIX) // Tabela Faixa -- Valor SEMPRE atual do cadastro do funcionario (sem buscar historico)
				//aAdd(aLinha, (cAliasF)->RA_HIERARQ) // Hierarquia -- Valor SEMPRE atual do cadastro do funcionario (sem buscar historico)
				aAdd(aLinha, Transform((cAliasF)->RA_ZMULPPR ,PesqPict("SRA","RA_ZMULPPR"))) // Valor SEMPRE atual do cadastro do funcionario (sem buscar historico)
				aAdd(aLinha, nHrsMes)
				aAdd(aLinha, cDescSindi)
				//aAdd(aLinha, '')
				
				oProcess:SetRegua2(6)
				
				oProcess:IncRegua2("Buscando proventos e descontos...")
				ProcessMessage()
				aDados := RGPE0013( (cAliasF)->RA_FILIAL, (cAliasF)->RA_MAT, cPeriodo, nMes, nAno, aVerbas )
				
				oProcess:IncRegua2("Buscando salário liquido...")
				ProcessMessage()
			
				oProcess:IncRegua2("Adicionando dados para o relatório...")
				ProcessMessage()
				
				aAdd(aLinha, Transform(nSalario ,PesqPict("SRA","RA_SALARIO")))	// Salario nominal
				//aAdd(aLinha, Transform(aDados[1],PesqPict("SRA","RA_SALARIO")))					// Salario bruto
				//aAdd(aLinha, aDados[2])															// Horas extras em hora
				//aAdd(aLinha, Transform(aDados[2],PesqPict("SRA","RA_SALARIO")))						// Horas extras em hora
				//aAdd(aLinha, Transform(aDados[3],PesqPict("SRA","RA_SALARIO")))					// Horas extras em valor
				//aAdd(aLinha, aDados[5])															// Horas extras - feriados
				//aAdd(aLinha, Transform(aDados[5],PesqPict("SRA","RA_SALARIO")))						// Horas extras - feriados
				//aAdd(aLinha, AllTrim(Transform(aDados[4],PesqPict("SRA","RA_SALARIO"))))		// Salario liquido
			    //aAdd(aLinha, "--------")
			    
			    // Adiciona o conteúdo para as verbas, caso o campo RV_XFLAGRL como Sim
			    If !Empty(aVerbas)
				    For nK := 1 to Len(aVerbas)			    
				    	nPosVrb := aScan(aDados[6], {|x| AllTrim(x[1]) == aVerbas[nK][1] })			    	
				    	If nPosVrb > 0 
				    	  	aAdd(aLinha, Transform(aDados[6][nPosVrb][2],PesqPict("SRA","RA_SALARIO")))
				    	Else
				       		aAdd(aLinha, Transform(0,PesqPict("SRA","RA_SALARIO")) )
				    	EndIf
					Next nK   
					//aAdd(aLinha, "--------")
				EndIf

				aAdd(aLinha, (cAliasF)->RA_CIC )
				aAdd(aLinha, (cAliasF)->RA_RG )
				aAdd(aLinha, If((cAliasF)->RA_SEXO=="M","Masculino","Feminino") ) 
				aAdd(aLinha, DTOC(STOD((cAliasF)->RA_NASC)) )
				aAdd(aLinha, Posicione("SX5" , 1 , xFilial("SX5") + "26" + PadR((cAliasF)->RA_GRINRAI,TamSX3("X5_CHAVE")[1],""),"X5_DESCRI"))
				aAdd(aLinha, (cAliasF)->RA_CBO)
				aAdd(aLinha, If((cAliasF)->RA_DEFIFIS=="1","Sim","Não"))
				aAdd(aLinha, If((cAliasF)->RA_CTPCD=="1","Sim","Não"))
				aAdd(aLinha, '')
				
				nMes := nMes + 1

				if nMes > 12
					nMes := 1
					nAno++
				endif
				
				nAtual := val(cValToChar(nAno) + iif(len(cValToChar(nMes)) == 1, "0" + cValToChar(nMes), cValToChar(nMes)))
				
				// Adiciona a linha com os dados
				aAdd(aDadExl, aClone(aLinha)) 
			enddo

			// Adiciona a linha com os dados
			//aAdd(aDadExl, aClone(aLinha)) 
			// Constroi e adiciona uma linha em branco "separadora"
			/*
			aLinhaSep := {}
			aEval(aLinha, {|| aAdd(aLinhaSep, '') })			
			aAdd(aDadExl, aLinhaSep)
			
			// Se o numero de periodos adicionados a linha for maior que o maximo, atualizo maximo
			If (Len(aLinha) - 18) / 5 > nPeriMax
				nPeriMax := (Len(aLinha) - 18) / 5
			EndIf
			*/
			(cAliasF)->(dbSkip())
		enddo
	endif
	
	// fecha o alias em questão 
	if Select(cAliasF) > 0
		(cAliasF)->(dbCloseArea())
	endif	
	
	if (len(aDadExl) > 0)
		oProcess:IncRegua1("Gerando arquivo aguarde...")
		oProcess:SaveLog("Gerando arquivo aguarde...")
		ProcessMessage()
		aAdd(aCabec, {"Período"                      ,"C", 20					  , 0 					   })
		aAdd(aCabec, {"Filial"                       ,"C", TamSx3('RA_FILIAL')[1] , TamSx3('RA_FILIAL')[2] })
		aAdd(aCabec, {"Matricula"                    ,"C", TamSx3('RA_MAT')[1]    , TamSx3('RA_MAT')[2]    })
		aAdd(aCabec, {"Nome do Funcionario"          ,"C", TamSx3('RA_NOME')[1]   , TamSx3('RA_NOME')[2]   })
		aAdd(aCabec, {"Data de Admissão"             ,"C", 10                     , 0                      })
		aAdd(aCabec, {"Centro de Custo"              ,"C", TamSx3('RA_CC')[1]     , TamSx3('RA_CC')[2]     })
		aAdd(aCabec, {"Descrição do Centro de Custo" ,"C", TamSx3('CTT_DESC01')[1], TamSx3('CTT_DESC01')[2]})
		aAdd(aCabec, {"Cargo"                        ,"C", TamSx3('Q3_DESCSUM')[1], TamSx3('Q3_DESCSUM')[2]})
		aAdd(aCabec, {"Função"                       ,"C", TamSx3('RJ_DESC')[1]   , TamSx3('RJ_DESC')[2]   })
		aAdd(aCabec, {"Situação"                     ,"C", 20                     , 0                      })
		aAdd(aCabec, {"Demissão"					 ,"C", 10                     , 0                      })
		aAdd(aCabec, {"Motivo"						 ,"C", 10                     , 0                      })
		aAdd(aCabec, {"Ultima Movimentação Funcional","C", 10                     , 0                      })
		//aAdd(aCabec, {"Ultima Movimentação Salarial" ,"C", 10                     , 0                      })
		//aAdd(aCabec, {"Nivel do Cargo"               ,"C", 10                     , 0                      })
		//aAdd(aCabec, {"Faixa Salarial"               ,"C", TamSx3('RA_FAIXA')[1]  , TamSx3('RA_FAIXA')[2]  })
		//aAdd(aCabec, {"Hierarquia"                   ,"C", 10                     , 0                      })
		aAdd(aCabec, {"Múltiplo do PPR"              ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
		aAdd(aCabec, {"Jornada Mensal"               ,"C", TamSx3('RA_HRSMES')[1] , TamSx3('RA_HRSMES')[2] })
		aAdd(aCabec, {"Sindicato"                    ,"C", TamSx3('RCE_DESCRI')[1], TamSx3('RCE_DESCRI')[2]})
		//aAdd(aCabec, {""                             ,"C", TamSx3('RCE_DESCRI')[1], TamSx3('RCE_DESCRI')[2]})
		
		//For nI := 1 To nPeriMax
			aAdd(aCabec, {"Salário Nominal"              ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
			//aAdd(aCabec, {"Salário Bruto Nominal"        ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
			//aAdd(aCabec, {"Horas Extras em Horas"        ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
			//aAdd(aCabec, {"Horas Extras em Valor"        ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
			//aAdd(aCabec, {"Horas Extras em Feriados"     ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
			//aAdd(aCabec, {"Salário Líquido"              ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]}) 
			//aAdd(aCabec, {""							 ,"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
		//Next nI
		
		/*If !Empty(aVerbas)  		
			For nK := 1 to Len(aVerbas)
				aAdd(aCabec, {aVerbas[nK][1]+" "+aVerbas[nK][2],"C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]}) 
			Next nK
			aAdd(aCabec, {"","C", TamSx3('RA_SALARIO')[1], TamSx3('RA_SALARIO')[2]})
		EndIf*/
		
		aAdd(aCabec, {"CPF"                    	,"C", TamSx3('RA_CIC')[1], TamSx3('RA_CIC')[2]})
		aAdd(aCabec, {"RG"                    	,"C", TamSx3('RA_RG')[1], TamSx3('RA_RG')[2]})
		aAdd(aCabec, {"Sexo"                   	,"C", TamSx3('RA_SEXO')[1], TamSx3('RA_SEXO')[2]})
		aAdd(aCabec, {"Dt. Nasc."              	,"C", TamSx3('RA_NASC')[1], TamSx3('RA_NASC')[2]})
		aAdd(aCabec, {"Escolaridade"           	,"C", TamSx3('RA_DESCGIN')[1], TamSx3('RA_DESCGIN')[2]})
		aAdd(aCabec, {"CBO"           			,"C", TamSx3('RA_CBO')[1], TamSx3('RA_CBO')[2]})
		aAdd(aCabec, {"Deficiente ?"           	,"C", TamSx3('RA_DEFIFIS')[1], TamSx3('RA_DEFIFIS')[2]})
		aAdd(aCabec, {"Cota Def"           		,"C", TamSx3('RA_CTPCD')[1], TamSx3('RA_CTPCD')[2]})
		
		DlgToExcel({ {"GETDADOS", "Relatório Gerencial de Funcionários", aCabec, aDadExl} })
	endif
else
	oProcess:IncRegua1("Nenhum dado encontrado para exportação!")
	oProcess:SaveLog("Nenhum dado encontrado para exportação!")
	ProcessMessage()
	
	MsgAlert("Nenhum dado encontrado para exportação!")
endif

return

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RGPE0012     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Cria query para busca de Funcionarios.                      !
+-----------+------------------------------------------------------------*/
Static Function RGPE0012()

Local cAlias := getNextAlias()
Local cSitu  := ""
Local cTmp   := Replace(MV_PAR15, '*', '')
Local nS     := 0
Local cSitu22 := 0

For nS := 1 to Len(cTmp)
	cSitu += "'" + Subs(cTmp,nS,1) + "'"
  	If ( nS+1) <= Len(cTmp)
   		cSitu += "," 
  	Endif
Next nS

cSitu := "%SRA.RA_SITFOLH IN (" + cSitu + ")%"
//cSitu22:= "%('001438','002789','000020','000080','000140','000170','000195','000236','000256','000285','000316','000375','000429','000444','000487','000527','000578','000581','000622','000694','000759','000768','000784','000795','000819','000843','000849','000859','000862','000893','000902','001011','001048','001055','001058','001064','001067','001087','001092','001120','001153','001162','001203','001213','001261','001265','001274','001282','001285','001297','001311','001325','001326','001329','001335','001339','001340','001360','001372','001384','001385','001412','001443','001559','001593','001604','001605','001624','001634','001652','001656','001674','001680','001776','001789','001817','001829','001841','001846','001867','001895','001908','001912','001923','001929','001944','001948','001974','001976','001980','001993','001998','001999','002001','002004','002048','002099','002139','002177','002180','002186','002208','002226','002243','002256','002280','002282','002293','002314','002316','002360','002389','002442','002444','002455','002475','002488','002494','002497','002510','002526','002527','002543','002546','002551','002552','002554','002558','002563','002569','002576','002579','002596','002598','002631','002648','002649','002652')%"
//cSitu22:= "%('001299','002390','002092','001560','001299','001966','002259','002547','001786','001516','001408','002092','002751','002844','002259','002547','000891','001284','001516','001786','001502','001284','001519','002529','002578','002005','002392','001519','000891','001560','002390','002096','002315','000714','001502','000714','002315','001966','000522','001408','002390','000372','002005','002392','002259','000714','001786','002092','000891','001299','001516','001284','002096','001560','001502','001834','001408','000891','002005','001966','002312','000714','001220','001299','000824','001502','001786','000824','001408','001519','001220','001284','001519','001560','000372','001516','000938','001502','001147','000372','000938','000714','000891','001284','000522','001834','000824','001299','001084','001220','001516','000832','001560','001147','001502','000372','000522','001408','001519','000719','001147','000938','001084','000891','000372','000714','000719','000824','000832','001299','001220','001084','001284','001147','000938','000522','001084','001147','000891','000719','000832','000714','000824','000797','000938','000891','001147','000832','000372','000522','001147','000719','000714','000824','000501','000797','000522','000372','000714','000719','000522','000372','000522','000372','000414','000154','000522','000372','000501','000501','000414','000372','000154','000414','000154','000372','000154','000372','000154','000154','000154','000154')%"

// relacionamentos não são obrigatórios
BeginSql Alias cAlias
	SELECT
		SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, 
		SRA.RA_CC, CTT.CTT_DESC01, 
		SRA.RA_CARGO, coalesce(SQ3.Q3_DESCSUM, ' ') AS Q3_DESCSUM, 
		SRA.RA_CODFUNC, coalesce(SRJ.RJ_DESC, ' ') AS RJ_DESC,
		SRA.RA_SINDICA, coalesce(RCE.RCE_DESCRI, ' ') AS RCE_DESCRI,
		SRA.RA_HRSMES, SRA.RA_SITFOLH, SRA.RA_FAIXA, SRA.RA_ZMULPPR,
		SRA.RA_SALARIO,
		SRA.RA_DEMISSA,
	   	SRA.RA_TABNIVE,
		SRA.RA_TABFAIX,
		SRA.RA_HIERARQ,
		SRA.RA_SEXO,
		SRA.RA_NASC,
		SRA.RA_CIC,
		SRA.RA_RG,
		SRA.RA_GRINRAI,
		SRA.RA_CBO,
		SRA.RA_DEFIFIS,
		SRA.RA_CTPCD
	FROM
		%table:SRA% SRA
	INNER JOIN %table:CTT% CTT ON
		CTT.CTT_FILIAL = %xFilial:CTT%
		AND CTT.CTT_CUSTO = SRA.RA_CC
		AND CTT.%NotDel%
	LEFT OUTER JOIN %table:SQ3% SQ3 ON
		SQ3.Q3_FILIAL = %xFilial:SQ3%
		AND SQ3.Q3_CARGO = SRA.RA_CARGO
		AND SQ3.%NotDel%
	LEFT OUTER JOIN %table:SRJ% SRJ ON
		SRJ.RJ_FILIAL = %xFilial:SRJ%
		AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
		AND SRJ.%NotDel%
	LEFT OUTER JOIN %table:RCE% RCE ON
		RCE.RCE_FILIAL = %xFilial:RCE%
		AND RCE.RCE_CODIGO = SRA.RA_SINDICA
		AND RCE.%NotDel%
	WHERE
		(SRA.RA_FILIAL >= %Exp:MV_PAR01% AND SRA.RA_FILIAL <= %Exp:MV_PAR02%)
		AND (SRA.RA_MAT >= %Exp:MV_PAR03% AND SRA.RA_MAT <= %Exp:MV_PAR04%)
		//AND (SRA.RA_MAT IN %Exp:cSitu22%)
		AND (SRA.RA_CC >= %Exp:MV_PAR09% AND SRA.RA_CC <= %Exp:MV_PAR10%)
		AND (SRA.RA_CARGO >= %Exp:MV_PAR11% AND SRA.RA_CARGO <= %Exp:MV_PAR12%)
		AND (SRA.RA_CODFUNC >= %Exp:MV_PAR13% AND SRA.RA_CODFUNC <= %Exp:MV_PAR14%)
		AND %Exp:cSitu%
		AND SRA.%NotDel% 	
	ORDER BY 	
		SRA.RA_MAT
endsql            

return cAlias

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RGPE0013     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Retorna os proventos e descontos do periodo                 !
+-----------+------------------------------------------------------------*/
Static Function RGPE0013( cFilMat, cMatricula, cPeriodo, nMes, nAno, aVerbas )

Local aDescontos := {}
Local aProventos := {}
Local aValVerba	 := {}
Local cAlias     := ''
Local cHoras     := ''  
Local cQuery     := ''
Local nI         := 0 
Local nK		 := 0
Local nValor     := 0
Local nValorLiq  := 0
Local nValorH    := 0
Local nHoras     := 0
Local nHEFerHora := 0

/*-------------------------------------------------------------------------+
| Estrutura de retorno dos arrays                                          |
+--------------------------------------------------------------------------+
| Campos esperados                                                         |
| 1 - valor                                                                |
| 2 - horas                                                                |
| 3 - se eh hora extra ou não (.T. ou .F.)                                 |
+-------------------------------------------------------------------------*/

cAlias := "TMPGPE0013"
if cVAlToChar(nAno)+StrZero(nMes,2) == Alltrim(GetMV("MV_FOLMES")) 
//if month(dDatabase) == nMes .AND. year(dDatabase) == nAno
	BeginSql Alias cAlias
		SELECT
			SRC.RC_VALOR AS VALOR, SRC.RC_HORAS AS HORAS, SRV.RV_COD AS RV_COD, SRV.RV_HREXT AS HREXT, SRV.RV_TIPOCOD, SRV.RV_RREFLEX
		FROM
			%table:SRC% SRC			
		INNER JOIN %table:SRV% SRV ON
			SRV.RV_FILIAL = %xFilial:SRV%
			AND SRV.RV_COD = SRC.RC_PD
			AND SRV.RV_TIPOCOD IN ('1','2')
			AND SRV.RV_GEREN = 'S'
			AND SRV.%NotDel% 	 
		WHERE
			SRC.RC_FILIAL = %Exp:cFilMat%
			AND SRC.RC_MAT = %Exp:cMatricula%
			AND SRC.%NotDel%
	endsql 
		
	// Verifica as Verbas do período para o funcionário SRC
	If !Empty(aVerbas)
		
		cQuery += " SELECT * "	
		cQuery += " FROM "
		cQuery += " ( 	SELECT RC_PD VERBA, RC_VALOR VALOR "
		cQuery += " 	FROM	(	SELECT RC_PD, RC_VALOR "
		cQuery += " 				FROM "+RetSqlName("SRC")+" SRC "
		cQuery += " 				WHERE SRC.RC_FILIAL  = '"+xFilial("SRC")+"' " 
		cQuery += " 				   AND SRC.RC_MAT 	 = '"+cMatricula+"' " 
		cQuery += " 				   AND SRC.D_E_L_E_T_ <> '*' "
		cQuery += " 			) A " 
		cQuery += " ) B "
		
	EndIf
	
else
	BeginSql Alias cAlias
		SELECT
			SRD.RD_VALOR AS VALOR, SRD.RD_HORAS AS HORAS, SRV.RV_COD AS RV_COD, SRV.RV_HREXT AS HREXT, SRV.RV_TIPOCOD, SRV.RV_RREFLEX
		FROM
			%table:SRD% SRD			
		INNER JOIN %table:SRV% SRV ON
			SRV.RV_FILIAL = %xFilial:SRV%
			AND SRV.RV_COD = SRD.RD_PD
			AND SRV.RV_TIPOCOD IN ('1','2')
			AND SRV.RV_GEREN = 'S'
			AND SRV.%NotDel% 	 
		WHERE
			SRD.RD_FILIAL = %Exp:cFilMat%
			AND SRD.RD_MAT = %Exp:cMatricula%
			AND SRD.RD_DATARQ = %Exp:cPeriodo%
			AND SRD.%NotDel% 
	endsql
	
	// Verifica as Verbas do período para o funcionário SRD
	If !Empty(aVerbas)
		
		cQuery += " SELECT * "	
		cQuery += " FROM "
		cQuery += " ( 	SELECT RD_PD VERBA, RD_VALOR VALOR "
		cQuery += " 	FROM	(	SELECT RD_PD, RD_VALOR "
		cQuery += " 				FROM "+RetSqlName("SRD")+" SRD "
		cQuery += " 				WHERE SRD.RD_FILIAL  = '"+xFilial("SRD")+"' " 
		cQuery += " 				   AND SRD.RD_MAT 	 = '"+cMatricula+"' " 
		cQuery += " 				   AND SRD.RD_DATARQ = '"+cPeriodo+"' " 
		cQuery += " 				   AND SRD.D_E_L_E_T_ <> '*' "
		cQuery += " 			) A " 
		cQuery += " ) B "
		
	EndIf
	
endif

while !(cAlias)->(EOF())
	do case
		case (cAlias)->RV_TIPOCOD == '1'
			nValor += (cAlias)->VALOR
			nValorLiq += (cAlias)->VALOR
			if ((cAlias)->HREXT == 'S')
				nValorH += (cAlias)->VALOR	
				//nHoras += fConvHr((cAlias)->HORAS, "D")
				nHoras += (cAlias)->HORAS
				// Se a verba pertence as verbas de HE feriado
				If (cAlias)->RV_COD $ cCVHEFer
					nHEFerHora += (cAlias)->HORAS	// Horas ja estao em decimal
				EndIf
			endif
			// Se for verba de reflexo, soma somente no valor e nao nas horas
			if ((cAlias)->RV_RREFLEX == 'S')
				nValorH += (cAlias)->VALOR
			endif
		
		case (cAlias)->RV_TIPOCOD == '2'	
			nValorLiq -= (cAlias)->VALOR
			if ((cAlias)->HREXT == 'S')
				nValorH -= (cAlias)->VALOR
				//nHoras -= fConvHr((cAlias)->HORAS, "D")
				nHoras -= (cAlias)->HORAS
				// Se a verba pertence as verbas de HE feriado
				If (cAlias)->RV_COD $ cCVHEFer
					nHEFerHora -= (cAlias)->HORAS	// Horas ja estao em decimal
				EndIf
			endif
			// Se for verba de reflexo, subtrai somente no valor e nao nas horas
			if ((cAlias)->RV_RREFLEX == 'S')
				nValorH -= (cAlias)->VALOR
			endif
	endcase

	(cAlias)->(dbSkip())
enddo
(cAlias)->(dbCloseArea())

cHoras := Replace(Transform(fConvHr(nHoras,"H"), "@E 999.99"), ",", ":")
cHEFerHora := Replace(Transform(fConvHr(nHEFerHora,"H"), "@E 999.99"), ",", ":")

aHoras := StrTokArr(cHoras, ":")
cHoras := StrZero(Val(aHoras[1]), IIF(Val(aHoras[1]) >= 100, 3, 2)) + ":" + aHoras[2]

aHEFerHora := StrTokArr(cHEFerHora, ":")
cHEFerHora := StrZero(Val(aHEFerHora[1]), IIF(Val(aHEFerHora[1]) >= 100, 3, 2)) + ":" + aHEFerHora[2]

If !Empty(aVerbas)
	
	cQuery := ChangeQuery(cQuery)  
	 	   
	If Select("QRYR") > 0
		DbSelectArea("QRYR")
		QRYR->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRYR"   
	
	DbSelectArea("QRYR")
	QRYR->(DbGoTop())
	If !QRYR->(Eof()) 
	    While !QRYR->(Eof()) 
	      	aAdd( aValVerba, { QRYR->VERBA, QRYR->VALOR } )
	    	QRYR->(DbSkip())
	    EndDo 
	EndIf 
	
EndIf

Return {nValor, cHoras + ":00", nValorH, nValorLiq, cHEFerHora + ":00", aValVerba}
//return {nValor, nHoras, nValorH, nValorLiq, nHEFerHora}

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE0014                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Converte de Horas para Decimal.                         |
+------------------+--------------------------------------------------------*/
Static Function RGPE0014(cHora)

// Formato Hora = 01:45
Local nHoras := Val(SUBSTR(cHora, 1, 2))
Local nMinutos := Val(SUBSTR(cHora, 4, 2))
Local nNumHoras := 0

nNumHoras := nHoras + ROUND((nMinutos / 60), 2)

Return (nNumHoras)

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE0015                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Converte Decimal em Horas                               |
+------------------+--------------------------------------------------------*/
Static Function RGPE0015(nParam,nTam,ComPonto,ComZero)

local cRet := ""
local nMin := (abs(int(nParam) - nParam,0)) * 60

if nTam == NIL
   nTam := 6
endif     

if nMin == 60
   cRet := transform( int(nParam)+1, "@E 999,999,999")
   cRet += ":00"
else
   cRet := transform( int(nParam), "@E 999,999,999")
   cRet += ":"+ strzero(nMin,02) 
endif

if at(":60",cRet) > 0
   cRet := transform( int(nParam)+1, "@E 999,999,999")
   cRet += ":00"
else
   cRet := transform( int(nParam), "@E 999,999,999")
   cRet += ":"+ strzero(nMin,02)
endif

cRet := alltrim(cRet)
if len(cRet) < nTam
   if ComZero == .T.
      cRet := replicate("0",nTam - len(cRet)) + cRet
   else
      cRet := space(nTam - len(cRet)) + cRet
   endif
endif

if ComPonto == .F.
   cRet := strtran(cRet,":","")
endif

return cRet

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE0017                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a os dados da ultima alteracao funcional		 | 
+------------------+--------------------------------------------------------*/
Static Function RGPE0017( cFilMat, cMatricula, cPeriodo )

Local cAlias := "TMPGPE0017"
Local cCargo := ""
Local cDescCar:= ""
Local cFunc	 := ""
Local cDescFun:= ""
Local cData  := ''
Local dDataFinal := LastDay(CtoD('1/' + cPeriodo))	// Exemplo: '31/' + '12/2013'

BeginSql Alias cAlias
	SELECT
		SR7.R7_DATA	  ,
		SR7.R7_FUNCAO ,
		SR7.R7_DESCFUN,
		SR7.R7_CARGO  ,
		SR7.R7_DESCCAR
	FROM 
		%table:SR7% SR7
	WHERE 
			SR7.R7_FILIAL = %Exp:cFilMat% 
		AND SR7.R7_MAT = %Exp:cMatricula% 
		AND SR7.%NotDel% 
		AND SR7.R7_DATA <= %Exp:dDataFinal%
//		AND SR7.R7_TIPO <> %Exp:'010'%
//		AND SR7.R7_TIPO <> %Exp:'003'%  
	ORDER BY
		R7_DATA DESC
endsql

// Seta o ultimo cargo
If !(cAlias)->(EOF())
	cData := (cAlias)->R7_DATA 
	cFunc := (cAlias)->R7_FUNCAO
	cCargo:= (cAlias)->R7_CARGO
// Se nao houveram movimentacoes
Else
	(cAlias)->(dbCloseArea())
	Return {}
EndIf
// Busca a ultima mudanca de cargo -> anterior para o atual (percorre datas descendente)
while !(cAlias)->(EOF())
	// Se houve alteracao de cargo ou funcao, a ultima data encontrada e a que vale
	If ( cFunc != (cAlias)->R7_FUNCAO ) .OR. ( cCargo != (cAlias)->R7_CARGO )
		Exit
	Else
		cData := (cAlias)->R7_DATA
		cDescCar := (cAlias)->R7_DESCCAR
		cDescFun := (cAlias)->R7_DESCFUN
	EndIf
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())

return {cData, cDescCar, cDescFun}               

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE0018                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a ultima data de alteracao salarial             |
+------------------+--------------------------------------------------------*/
Static Function RGPE0018( cFilMat, cMatricula, cPeriodo )

Local cAlias := "TMPGPE0018"
Local cData  := ''
Local nValor := 0.0
Local dDataFinal := LastDay(CtoD('1/' + cPeriodo))	// Exemplo: '31/' + '12/2013'

BeginSql Alias cAlias
	SELECT
		TOP 1
		SR7.R7_DATA,
		SR3.R3_VALOR AS VALOR
	FROM 
			%table:SR7% SR7 INNER JOIN %table:SR3% SR3 ON (
			SR7.R7_FILIAL = SR3.R3_FILIAL
		AND SR7.R7_MAT	= SR3.R3_MAT
		AND SR7.R7_DATA	= SR3.R3_DATA
		AND SR7.R7_TIPO	= SR3.R3_TIPO  
	//	AND SR3.R3_TIPO != '001'     
	//	AND SR3.R3_TIPO != '013'    	
		AND SR3.%NotDel%
		)
	WHERE 
			SR7.R7_FILIAL = %Exp:cFilMat% 
		AND SR7.R7_MAT = %Exp:cMatricula% 
		AND SR7.%NotDel% 
		AND SR7.R7_DATA <= %Exp:dDataFinal%
	ORDER BY 
		R7_DATA DESC, R3_VALOR DESC
endsql
	                        
	
while !(cAlias)->(EOF())
	cData := (cAlias)->R7_DATA 
	nValor := (cAlias)->VALOR
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())

If nValor == 0
BeginSql Alias cAlias
	SELECT
		TOP 1
		SR7.R7_DATA,
		SR3.R3_VALOR AS VALOR
	FROM 
		%table:SR7% SR7 INNER JOIN %table:SR3% SR3 ON (
			SR7.R7_FILIAL = SR3.R3_FILIAL
		AND SR7.R7_MAT	= SR3.R3_MAT
		AND SR7.R7_DATA	= SR3.R3_DATA
		AND SR7.R7_TIPO	= SR3.R3_TIPO 
		AND (SR3.R3_TIPO = '001' OR SR3.R3_TIPO = '004')
		AND SR3.%NotDel%
		)
	WHERE 
			SR7.R7_FILIAL = %Exp:cFilMat% 
		AND SR7.R7_MAT = %Exp:cMatricula% 
		AND SR7.%NotDel% 
		AND SR7.R7_DATA <= %Exp:dDataFinal%
	ORDER BY 
		R7_DATA DESC, R3_TIPO DESC
endsql
	                        
	
while !(cAlias)->(EOF())
	cData := (cAlias)->R7_DATA 
	nValor := (cAlias)->VALOR
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())

EndIf
                      
If nValor == 0       
	cData := (cAliasF)->RA_ADMISSA
	nValor := Posicione("SRA",1,xFilial("SRA")+cMatricula,"RA_SALARIO")

EndIf
/*
BeginSql Alias cAlias
	SELECT
		TOP 1
		SR7.R7_DATA,
		SR3.R3_VALOR AS VALOR
	FROM 
			%table:SR7% SR7 INNER JOIN %table:SR3% SR3 ON (
			SR7.R7_FILIAL = SR3.R3_FILIAL
		AND SR7.R7_MAT	= SR3.R3_MAT
		AND SR7.R7_DATA	= SR3.R3_DATA
		AND SR7.R7_TIPO	= SR3.R3_TIPO  
		AND SR3.R3_TIPO != '001'     
		AND SR3.R3_TIPO != '013'    	
		AND SR3.%NotDel%
		)
	WHERE 
			SR7.R7_FILIAL = %Exp:cFilMat% 
		AND SR7.R7_MAT = %Exp:cMatricula% 
		AND SR7.%NotDel% 
		AND SR7.R7_DATA <= %Exp:dDataFinal%
	ORDER BY 
		R7_DATA DESC, R3_VALOR
endsql
	                        
	
while !(cAlias)->(EOF())
	cData := (cAlias)->R7_DATA 
	nValor := (cAlias)->VALOR
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())

If nValor == 0
BeginSql Alias cAlias
	SELECT
		TOP 1
		SR7.R7_DATA,
		SR3.R3_VALOR AS VALOR
	FROM 
		%table:SR7% SR7 INNER JOIN %table:SR3% SR3 ON (
			SR7.R7_FILIAL = SR3.R3_FILIAL
		AND SR7.R7_MAT	= SR3.R3_MAT
		AND SR7.R7_DATA	= SR3.R3_DATA
		AND SR7.R7_TIPO	= SR3.R3_TIPO 
		AND (SR3.R3_TIPO = '001' OR SR3.R3_TIPO = '004')
		AND SR3.%NotDel%
		)
	WHERE 
			SR7.R7_FILIAL = %Exp:cFilMat% 
		AND SR7.R7_MAT = %Exp:cMatricula% 
		AND SR7.%NotDel% 
		AND SR7.R7_DATA <= %Exp:dDataFinal%
	ORDER BY 
		R7_DATA DESC, R3_TIPO DESC
endsql
	                        
	
while !(cAlias)->(EOF())
	cData := (cAlias)->R7_DATA 
	nValor := (cAlias)->VALOR
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())

EndIf
                      
If nValor == 0       
	cData := (cAliasF)->RA_ADMISSA
	nValor := Posicione("SRA",1,xFilial("SRA")+cMatricula,"RA_SALARIO")

EndIf
*/
return {cData,nValor}

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE0019                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Função para validar o mes                               |
+------------------+--------------------------------------------------------*/
User Function RGPE0019()

Local MvPar    := Nil
Local MvParDef := ""
Local lRet     := .T.

MvPar := &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())	   // Iguala Nome da Variavel ao Nome variavel de Retorno

lRet := (!Empty(MvPar) .AND. (MvPar > 0) .AND. (MvPar < 13))

Return(lRet)

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE001A                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Função para validar o ano                               |
+------------------+--------------------------------------------------------*/
User Function RGPE001A()

Local MvPar    := Nil
Local MvParDef := ""
Local lRet     := .T.

MvPar := &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())	   // Iguala Nome da Variavel ao Nome variavel de Retorno

lRet := (!Empty(MvPar) .AND. (MvPar > 0))

Return(lRet)

/*-----------------+---------------------------------------------------------+
|Nome              | RGPE001SIT                                              |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a situacao do funcionario no periodo informado	 |
+------------------+--------------------------------------------------------*/
Static Function RGPE001SIT( cFilMat, cMatricula, cPeriodo )

Local cAlias 		:= "TMPGPE001"
Local dDataFinal 	:= LastDay(CtoD('1/' + cPeriodo))	// Exemplo: '31/' + '12/2013'
Local cDataFinal 	:= DTOS(dDataFinal)	// Exemplo: '31/' + '12/2013'
Local dDataInicial 	:= CtoD('01/' + cPeriodo)
Local cDataInicial 	:= DTOS(dDataInicial)
Local cSituacao 	:= ' '			// Ativo
Local dData 		:= dDataFinal
Local cMotivo		:= ""

BeginSql Alias cAlias
	SELECT
		SR8.R8_DATA,
		SR8.R8_TIPOAFA,
		SR8.R8_DATAFIM,
		SR8.R8_DURACAO
	FROM 
		%table:SR8% SR8
	WHERE 
		SR8.R8_FILIAL = %Exp:cFilMat% 
		AND SR8.R8_MAT = %Exp:cMatricula% 
		AND SR8.%NotDel% 
		//AND ((%Exp:cDataFinal% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM) OR (SR8.R8_DATAINI <= %Exp:cDataFinal% AND SR8.R8_DATAFIM = %Exp:''%))		
        AND  (SR8.R8_DATAINI >= %Exp:cDataInicial% AND  SR8.R8_DATAFIM <= %Exp:cDataFinal%  
        OR ((%Exp:cDataInicial% BETWEEN SR8.R8_DATAINI  AND  SR8.R8_DATAFIM) OR (%Exp:cDataFinal% BETWEEN SR8.R8_DATAINI  AND  SR8.R8_DATAFIM))
        OR SR8.R8_DATAINI <= %Exp:cDataFinal% AND SR8.R8_DATAFIM = %Exp:''% )

	ORDER BY
		R8_DATAINI DESC
endsql

If !(cAlias)->(EOF())
	If (cAlias)->R8_TIPOAFA == "001"	// Ferias
		cSituacao := 'F'  
	Else
		If (cAlias)->R8_DURACAO >= 15 
			cSituacao := 'A'		       // Afastamento Temp.
		elseif (cAlias)->R8_DURACAO > 0 .And. (cAlias)->R8_DURACAO < 15
			cSituacao := 'M' 				
		EndIf
	EndIf	
	dData := STOD((cAlias)->R8_DATAFIM)
EndIf

(cAlias)->(dbCloseArea())
	
// Se a data de demissao esta preenchida e foi no periodo
If !Empty((cAliasF)->RA_DEMISSA) .And. ( SubStr((cAliasF)->RA_DEMISSA,1, 6) <= SubStr(cDataFinal, 1, 6) )
	cSituacao 	:= 'D'			// Demitido
	dData 		:= STOD((cAliasF)->RA_DEMISSA)
	//+--------------------------------------------------------------+
	//¦ Pesquisando o Tipo de Rescisao 						         ¦
	//+--------------------------------------------------------------+
	dbSelectArea('SRG')
	SRG->(dbSetOrder(1))
	SRG->(dbGoTop())
	If SRG->( dbSeek((cAliasF)->RA_FILIAL+(cAliasF)->RA_MAT) )
		While ! EOF() .And. (cAliasF)->RA_FILIAL+(cAliasF)->RA_MAT == SRG->RG_FILIAL+SRG->RG_MAT
			If !Empty(SRG->RG_XTPDESL)
				cMotivo := GetSX3cBox("RG_XTPDESL",SRG->RG_XTPDESL)
				Exit
			EndIf
			SRG->(dbSkip())
		Enddo
	EndIf    
EndIf

return {dData, cSituacao,cMotivo}

/*-----------------+---------------------------------------------------------+
|Nome              | RGPEFCC                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a os dados da ultima alter. de centro de custo	 | 
+------------------+--------------------------------------------------------*/
Static Function RGPEFCC( cFilMat, cMatricula, cPeriodo )

	Local cAlias := "TMPGPEFCC"
	Local cCodCC := ""
	Local cDescCC:= ""
	Local dData	:= CtoD("//")
	Local dDataFinal := LastDay(CtoD('1/' + cPeriodo))	// Exemplo: '31/' + '12/2013'
	Local aRet := {}
	
	// SQL para buscar TODAS as transferencias do funcionario
	BeginSql Alias cAlias
		SELECT
			SRE.RE_DATA	  ,
			SRE.RE_MATD	  ,
			SRE.RE_MATP	  ,
			SRE.RE_CCD	  ,
			SRE.RE_CCP	  ,
			SRE.RE_EMPD	  ,
			SRE.RE_FILIALD,
			SRE.RE_EMPP	  ,
			SRE.RE_FILIALP
		FROM 
			%table:SRE% SRE
		WHERE 
				SRE.RE_FILIALD = %Exp:cFilMat% 
			AND SRE.RE_MATD = %Exp:cMatricula% 
			AND SRE.%NotDel% 
		ORDER BY
			RE_DATA ASC
	endsql
	
	dData := ""

	If !(cAlias)->(EOF())
		// Busca a ultima mudanca de centro de custo
		while !(cAlias)->(EOF())
			// Se o a data final do periodo for menor que a transf.
			// pega o C.C. antigo (ORIGEM)
			If dDataFinal < STOD((cAlias)->RE_DATA)
				If Empty(dData) .Or. STOD((cAlias)->RE_DATA) < dData
					dData := STOD((cAlias)->RE_DATA)
					cCodCC := (cAlias)->RE_CCD
					Exit
				EndIf
			// Senao pega o CC DESTINO da ultima transferencia com data maior que a data final do periodo
			Else
				dData := STOD((cAlias)->RE_DATA)
				cCodCC := (cAlias)->RE_CCP
			EndIf
			(cAlias)->(dbSkip())
		enddo
	EndIf
	
	(cAlias)->(dbCloseArea())
	
	If !Empty(cCodCC)
		aRet := {dData, cCodCC, Posicione("CTT", 1, xFilial("CTT") + cCodCC, "CTT_DESC01") }
	EndIf
	
Return aRet

/*-----------------+---------------------------------------------------------+
|Nome              | RGPESRA                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna as ultimas datas de alteracoes na SRA           |
+------------------+--------------------------------------------------------*/
Static Function RGPESRA( cFilMat, cMatricula, cPeriodo )

Local cAlias := "TMPGPESRA"
Local cData  := ''
Local cValor := ''
Local cCmp	 := ''
Local dDataFinal := LastDay(CtoD('1/' + cPeriodo))	// Exemplo: '31/' + '12/2013'
Local cCampos := "% 'RA_HRSMES','RA_SINDICA'  %"
Local aRet := {}

BeginSql Alias cAlias
	SELECT
		SR9.R9_MAT	,
		SR9.R9_DATA	,
		SR9.R9_CAMPO,
		SR9.R9_DESC
	FROM 
		%table:SR9% SR9
	WHERE 
			SR9.R9_FILIAL = %Exp:cFilMat% 
		AND SR9.R9_MAT = %Exp:cMatricula% 
		AND SR9.%NotDel% 
		AND SR9.R9_DATA <= %Exp:dDataFinal%
		AND SR9.R9_CAMPO IN (%Exp:cCampos%)
	ORDER BY 
		R9_DATA DESC,
		SR9.R_E_C_N_O_ DESC,
		R9_CAMPO
endsql
	                        
	
while !(cAlias)->(EOF())
	cData := (cAlias)->R9_DATA 
	cCmp := (cAlias)->R9_CAMPO
	cValor := (cAlias)->R9_DESC
	
	nPos := aScan(aRet, {|aItem| AllTrim(aItem[2]) == AllTrim(cCmp)})
	If nPos <= 0
		cValor := AllTrim(cValor)
		If AllTrim(cCmp) == "RA_HRSMES"
			cValor := Replace(Replace(cValor, ".00", ""), ",00", "")
			aAdd(aRet, { STOD(cData), AllTrim(cCmp), AllTrim(cValor)})
		EndIf
	EndIf
	(cAlias)->(dbSkip())	
enddo
(cAlias)->(dbCloseArea())


return aRet

/*-----------------+---------------------------------------------------------+
|Nome              | fSituacao                                               |
+------------------+---------------------------------------------------------+
|Descricao         | Função para validar as situacoes                        |
+------------------+--------------------------------------------------------*/
Static Function fSituacao()

Local MvPar    := Nil
Local MvParDef := ""
Local lRet     := .T.

MvPar := &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())	   // Iguala Nome da Variavel ao Nome variavel de Retorno

//lRet := (!Empty(AllTrim(Replace(MvPar,"*"," "))))

//If !lRet
//	Alert("E necessario informar ao menos uma situacao.")
//EndIf

Return(lRet)

/*/--------------------------------------------------------------------------------------------------
Função criada para ler a descrição de um campo a partir do código para um determinado campo.
Isso evita de fazer um select para cada DC impresso.
--------------------------------------------------------------------------------------------------/*/
Static Function GetSX3cBox(cCampo, cValor)

	cBox 	:= GetSx3Cache(cCampo,"X3_CBOX")
	aCombo 	:= StrToKArr(cBox, ";")

Return GetArVal(aCombo, cValor)

/*/--------------------------------------------------------------------------------------------------
Função criada para procurar um código em um array passado por parâmetro e retornar a descrição.
Permite a reutilização de código.
--------------------------------------------------------------------------------------------------/*/
Static Function GetArVal(aArray, cValor)
Local nInd

	For nInd := 1 To Len(aArray)
		If Substr(aArray[nInd], 1, At("=",aArray[nInd]) - 1) == cValor
			Return Substr(aArray[nInd], At("=",aArray[nInd]) + 1, Len(aArray[nInd]))
		EndIf
	Next nInd

Return( "" )