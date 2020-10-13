#INCLUDE 'TOTVS.CH'

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODUÇÃO                                          !
+------------------+---------------------------------------------------------+
!Nome              ! PCPR001                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão Etiqueta Especificaa                     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! Thiago Berna 21/10/19                                   !
+------------------+---------------------------------------------------------+
*/

User Function PCPR001

Local oDlg1
Local cOp   := Space(TamSX3("D4_OP")[1])
Local cTipo := ''
Local cImp  := Space(TamSX3("ZIA_IMPPAD")[1])
Local nQtd  := 0
Local nCount:= 0
Local lRet  := .F.
Local aTipos:= {}
Local aDados:= {}
Local aImp  := {}

For nCount := 1 to 12
    AAdd(aTipos,StrZero(nCount,TamSX3("ZIA_TPETQ")[1]))
Next nCount

DEFINE MSDIALOG oDlg1 FROM 0,0 TO 200,250 PIXEL TITLE "Imprime Etiqueta Produção"

@ 010,005 SAY   "OP              "     				  	    		   OF oDlg1 PIXEL SIZE 050,09 SHADED
@ 010,045 MSGET cOp 	PICTURE "@!" 					  SIZE 70,10 PIXEL OF oDlg1 F3 'SC2' 
@ 030,005 SAY   "Tipo Etiqueta   "			 				               OF oDlg1 PIXEL SIZE 050,09 SHADED
@ 030,045 MSCOMBOBOX cTipo ITEMS aTipos                                    OF oDlg1 PIXEL SIZE 050,09 
@ 050,005 SAY   "Qtde Etiqueta   "			 				               OF oDlg1 PIXEL SIZE 050,09 SHADED
@ 050,045 MSGET nQtd 	PICTURE "@E 999,999"              SIZE 70,10 PIXEL OF oDlg1 
@ 070,005 SAY   "Impressora      "			 				               OF oDlg1 PIXEL SIZE 050,09 SHADED
@ 070,045 MSGET cImp 	PICTURE "@!"                      SIZE 70,10 PIXEL OF oDlg1 F3 'CB5'

DEFINE SBUTTON FROM 085,060 TYPE 1 OF oDlg1 ENABLE ONSTOP "Imprimir" ACTION ( lRet := .T., oDlg1:End() )
DEFINE SBUTTON FROM 085,090 TYPE 2 OF oDlg1 ENABLE ONSTOP "Sair    " ACTION ( lRet := .F., oDlg1:End() )
			
ACTIVATE MSDIALOG oDlg1 CENTER

If lRet
    
    DbSelectArea('SC2')
    SC2->(DbSetOrder(1))
    If SC2->(DbSeek(xFilial('SC2') + cOp))

        DbSelectArea('ZIB')
        ZIB->(DbSetOrder(1))
        If ZIB->(DbSeek(xFilial('ZIB') + SC2->C2_PRODUTO + cTipo))
           
               //Somente etiquetas de apontamento
                If ZIB->ZIB_APONTA == 'N'
                                
                    DbSelectArea('ZIA')
                    ZIA->(DbSetOrder(1))
                    If ZIA->(DbSeek(xFilial('ZIA') + ZIB->ZIB_TPETQ))
                        If ZIA->ZIA_PROC == '1'
        
                            cImpPad := ZIA->ZIA_IMPPAD
                                
                            //Impressora padrao da linha tem prioridade
                            DbSelectArea('Z55')
                            Z55->(DbSetOrder(1))
                            If Z55->(DbSeek(xFilial('Z55') + cLinha))
                                    
                                If !Empty(Z55_CODIMP)
                                    cImpPad := Z55->Z55_CODIMP
                                EndIf

                            EndIf
                        //#TB20191129 Thiago Berna -  Ajuste para considerar a impressora definida no ZIA_IMPPAD quando o ZIA_PROC for 0
                        ElseIf ZIA->ZIA_PROC == '0'

                            cImpPad := ZIA->ZIA_IMPPAD
                        
                        Else
                                
                            cImpPad := ''
                        
                        EndIf
                    
                    EndIf           
                    
                    AAdd(aDados,{SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),SC2->C2_PRODUTO,SC2->C2_XLOTE,ZIB->ZIB_QTDE,cImpPad,lRimp,lSubProd})
                      

                    AAdd(aImp,{'U_ETQ'+ZIB->ZIB_TPETQ,aDados})
                    aDados := {}            
                    
                EndIf
            
        EndIf

        For nCount := 1 to Len(aImp)

            &(aImp[nCount,1] + '(aImp[nCount,2])')

        Next nCount

    EndIf

EndIf

Return