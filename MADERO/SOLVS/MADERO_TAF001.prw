#include 'totvs.ch'
#include "fileio.ch"
#include "topconn.ch"
/*---------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! TAF                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! TAF001                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina para atualização dos recibos nos eventos do      !
!		           ! e-Social relacionados as tabelas da Folha               ! 
+------------------+---------------------------------------------------------+
!Atualizado por    ! Márcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 01/02/2019                                              !
+------------------+--------------------------------------------------------*/
User Function TAF001
Local nX	    := 0
Local nY	    := 0
Local cDirBase  := "\import\TAF\"
Local aEventos  := {}
Local aSay      := {}
Local aButton   := {}
Local cTitulo   := "Processamento de eventos do e-Social"
Local cDesc01   := "Esta rotina tem como objetivo incluir o número dos recidos e status dos eventos  "
Local cDesc02   := "do e-Social nas tabelas do TAF, conforme layouts pré-definifos.                  "
Local lOk       := .F.
Local oRegua
Private oMainWnd:= NIL

    // -> Inclui eventos processados na rotina
    Aadd(aEventos,{"S1050","C90","Tabela de HoráriosTurnos de Trabalho"                                     })
    Aadd(aEventos,{"S1010","C8R","Rubricas"                                                                 })
    Aadd(aEventos,{"S1020","C99","Lotação Tributarias"                                                      })
    Aadd(aEventos,{"S1005","C92","Estabelecimentos, Obras ou Unidades de Órgãos Públicos"                   })
    Aadd(aEventos,{"S2300","C9V","Estagiario"                                                               })
    Aadd(aEventos,{"S2200","C9V","Funcionários"                                                             })
    Aadd(aEventos,{"S1030","C8V","Tabela de Cargos"                                                         })
    Aadd(aEventos,{"S1070","C1G","Processos Judiciais"                                                      })
    Aadd(aEventos,{"S2399","T92","Trabalhador sem vínculo de empregoestatutário"                            }) 
    Aadd(aEventos,{"S2260","T87","Convocação para Trabalho Intermitente"                                    })
    Aadd(aEventos,{"S2190","T3A","Admissão de Trabalhador - Registro Preliminar"                            })
    Aadd(aEventos,{"S2206","T1V","Alteração de Contrato de Trabalho"                                        })
    Aadd(aEventos,{"S2205","T1U","Alteração de Dados Cadastrais do Trabalhador"                             })
    Aadd(aEventos,{"S2306","T0F","Trabalhador sem vínculo de emprego estatutário - alteração contratual"    })
    Aadd(aEventos,{"S3000","CMJ","Exclusão de Eventos"                                                      })
    Aadd(aEventos,{"S2298","CMF","Reintegração"                                                             })
    Aadd(aEventos,{"S2299","CMD","Desligamento"                                                             })
    Aadd(aEventos,{"S2250","CM8","Aviso Prévio"                                                             })
    Aadd(aEventos,{"S2230","CM6","Afastamento Temporário"                                                   })
	
    // -> Mensagens de Tela Inicial
    aAdd( aSay, cDesc01 )
    aAdd( aSay, cDesc02 )
    
    // -> Botoes Tela Inicial
    aAdd(aButton,{1,.T.,{ || lOk:=.T.,oRegua := MsNewProcess():New({ || TAF001P(oRegua, cDirBase, aEventos) }, "Processando atualização dos dados..."),oRegua:Activate(),FechaBatch()}})
    aAdd(aButton,{2,.T.,{ || lOk:=.F.,FechaBatch()}})
    
    FormBatch(cTitulo,aSay,aButton)
	
return




/*
+------------------+---------------------------------------------------------+
!Nome              ! TAF001P                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Processa arquivos de eventos conforme layouts pré-defi- !
!		           ! nidos para atualização dos protcolos                    ! 
+------------------+---------------------------------------------------------+
!Atualizado por    ! Márcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 01/02/2019                                              !
+------------------+---------------------------------------------------------+
*/
Static Function TAF001P(oARegua, cDirBase, aEventos)
Local cAlias	:= ""
Local lOk       := .T.
Local cLine     := ""
Local aLinha    := {}
Local cArqTXT   := ""
Local cNomNovArq:= ""
Local cQuery    := ""
Local nCodigo   := 0
Local nRecibo   := 0
Local nStatus   := 0
Local cCodigo   := 0
Local cRecibo   := 0
Local cStatus   := 0
Local fCodigo   := 0
Local fRecibo   := 0
Local fStatus   := 0
Local aFiles    := {}
Local nRecs     := 0
Local nLineFile := 0
Local nY, nX    := 0
Local aFileEmp  := ""
Local cFileEmp  := ""

	oARegua:SetRegua1(2)
    oARegua:SetRegua1(Len(aEventos))

    // -> Processa eventos
    For nY:=1 to Len(aEventos)

        // -> Le arquivos no diretório
	    oARegua:IncRegua1(aEventos[nY,01]+" - "+aEventos[nY,03])
	    aFiles   := Directory(cDirBase + aEventos[nY,01] + "\*.CSV")

        lOk := .F.
	    For nX := 1 To Len(aFiles)

        	// -> Verifica se o aquivo é do grupo de empresa corrente
            aFileEmp:=StrTokArr(aFiles[nX,01],"-")
            cFileEmp:=IIF(Len(aFileEmp)<2,"",aFileEmp[02])
            If !(cEmpAnt $ cFileEmp)
                Loop
            EndIf
                        
            // -> Abre o arquivo
	        nHdl := FT_FUSE(cDirBase + aEventos[nY,01] + "\" + aFiles[nX,01] )  
	        If nHdl < 0
                Loop
            EndIf

            nRecs   := FT_FLastRec()
            lOk     := .F.
            fCodigo := ""
            fRecibo := ""
            fStatus := ""
            oARegua:SetRegua2(2)
            oARegua:SetRegua2(nRecs)
			
            FT_FGoTop()
			While !FT_FEOF()		   

        	    oARegua:IncRegua2("Processano arquivo " + aFiles[nX,01])
                nLineFile:= nLineFile+1
				cLine    := FT_FReadLN()
				aLinha   := Separa(cLine,";")

                // -> Se for a linha 1
                If nLineFile <= 1

                    // -> Lay out S1005
                    If aEventos[nY,01] == "S1005"
                        fCodigo := "C92_NRINSC"
                        fRecibo := "C92_PROTUL"
                        fStatus := "C92_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S1010"
                        fCodigo := "C8R_CODRUB"
                        fRecibo := "C8R_PROTUL"
                        fStatus := "C8R_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S1020"
                        fCodigo := "C99_CODIGO"
                        fRecibo := "C99_PROTUL"
                        fStatus := "C99_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S1030"
                        fCodigo := "C8V_CODIGO"
                        fRecibo := "C8V_PROTUL"
                        fStatus := "C8V_STATUS"
                        nCodigo := aScan(aLinha,fCodigo) 
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S1050"
                        fCodigo := "C90_CODIGO"
                        fRecibo := "C90_PROTUL"
                        fStatus := "C90_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S1070"
                        fCodigo := "C1G_NUMPRO"
                        fRecibo := "C1G_PROTUL"
                        fStatus := "C1G_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S2200" 
                        fCodigo := "C9V_CPF"
                        fRecibo := "C9V_PROTUL"
                        fStatus := "C9V_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    ElseIf aEventos[nY,01] == "S2300" 
                        fCodigo := "C9V_CPF"
                        fRecibo := "C9V_PROTUL"
                        fStatus := "C9V_STATUS"
                        nCodigo := aScan(aLinha,fCodigo)
                        nRecibo := aScan(aLinha,fRecibo)
                        nStatus := aScan(aLinha,fStatus)
                    EndIf    

				    FT_FSkip()
					Loop				
                EndIf

                // -> Se não encontrou o registro, 
                If AllTrim(fCodigo) == ""
				    FT_FSkip()
					Exit
                EndIf
                
                cCodigo := aLinha[nCodigo]
                cRecibo := aLinha[nRecibo]
                cStatus := aLinha[nStatus]

                // -> Monta a Query
                cAlias	:= GetNextAlias()
                cQuery:="SELECT R_E_C_N_O_ "
                cQuery+="FROM  " + RetSQLName(aEventos[nY,02])  +  "                      "
                cQuery+="WHERE " + fCodigo                      + "=" + "'" + cCodigo + "' AND " 
                cQuery+="      D_E_L_E_T_     <> '*'                                      "
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)				

                DbSelectArea(aEventos[nY,02])
                (cAlias)->(dbGoTop())
                While !(cAlias)->(Eof())                	                    
                    
                    // -> Atualiza os dados
                    (aEventos[nY,02])->(DbGoTo((cAlias)->R_E_C_N_O_)) 
                    If !(aEventos[nY,02])->(Found())                    
                        RecLock(aEventos[nY,02],.F.)
                        &(aEventos[nY,02]+"->"+fRecibo):=cRecibo
                        &(aEventos[nY,02]+"->"+fStatus):=cStatus 
                        (aEventos[nY,02])->(DbCloseArea())
                        lOk:=.T.
                    EndIf    

                    (cAlias)->(DbSkip())
                EndDo
                (cAlias)->(DbCloseArea())
						
                oARegua:SetRegua2(2)
                oARegua:SetRegua2(0)

				FT_FSkip()

            EndDo

            FT_FUSE()

            // -> Move os exclui e move os arquivos integrados
            If lOk
                __CopyFile(cDirBase + aEventos[nY,01] + "\" + aFiles[nX,01], cDirBase + aEventos[nY,01] + "\IMP\" + aFiles[nX,01])
		        FErase(cDirBase + aEventos[nY,01] + "\" + aFiles[nX,01])
            EndIf

        Next nX

    Next nY
return