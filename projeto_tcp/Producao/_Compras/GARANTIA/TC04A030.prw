#include "tbiconn.ch"   
#include "protheus.ch"        
/*
Programa: TC04A030
Autor: ELIAS RICARDO KUCHAK
Data: 16/12/2019
Desc: AxCadastro para a tabela ZPE-Cadastro de Equipamentos
Uso: TCP S.A.
*/

User Function TC04A030     
    Private cCadastro := "Cadastro de equipamentos " 
    Private aRotina := {{"Pesquisar"          ,"AxPesqui"    , 0, 1},;
                        {"Visualizar"         ,"u_A0403MAN"  , 0, 2},;
                        {"Incluir"            ,"u_A0403MAN"  , 0, 3},; 
                        {"Alterar"            ,"u_A0403MAN"  , 0, 4},;
                        {"Excluir"            ,"u_A0403MAN"  , 0, 5}}

    dbSelectArea('ZPE') 
    dbGoTop()
    mBrowse(006,001,022,075,"ZPE", ,,,,,,,,,,.T.)
                                        
    Return
    
User Function ZPE_CODIGO
    cQuery := " Select max(ZPE_CODIGO) ZPE_CODIGO "
    cQuery += " From " + RetSqlName("ZPE") + " ZPE "
    cQuery += " Where ZPE_FILIAL = '" + xFilial("ZPE") + "'"
    cQuery += "   and ZPE.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    If Select("QRY") <> 0
        QRY->(dbCloseArea())
    EndIf       
  
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY',.F.,.T.)
    
    if EMPTY(QRY->ZPE_CODIGO)
        return '000001'
    else
        return Soma1(QRY->ZPE_CODIGO)
    endif 

User Function ZPE_DELETE
    cQuery := " Select ZPB_EQUIPA "
    cQuery += " From " + RetSqlName("ZPB") + " ZPB "
    cQuery += " Where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
    cQuery += "   and ZPB_EQUIPA = '" + ZPE->ZPE_CODIGO + "'"
    cQuery += "   and D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    If Select("QRY") <> 0
        QRY->(dbCloseArea())
    EndIf       
  
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY',.F.,.T.)
    
    if Empty(QRY->ZPB_EQUIPA)
        return .T.
    else
        MSGALERT("Equipamento não pode ser excluído pois esta sendo usado em processo de garantia/reparo.", "Alerta")
        return .F.
    endif       
    
 User Function A0403MAN(cAlias,nReg,nOpc)
    Local _nRetAx   := 0
    Local aButtons  := {}
    Local cAlias    := "ZPE" 
    
    Do case
    Case nOpc == 2  //Visualizar
    //        AxVisual(cAlias, nReg, nOpc, aAcho    , nColMens, cMensagem, cFunc, aButtons, lMaximized)
      _nRetAx := AxVisual(cAlias, nReg, nOpc,        ,         ,          ,      , aButtons, .f.       )
    Case nOpc == 3  //Incluir 1-3
    //        AxInclui(cAlias, nReg, nOpc, aAcho    , cFunc, aCpos, cTudoOk, lF3, cTransact, aButtons, aParam, aAuto, lVirtual, lMaximized)
      _nRetAx := AxInclui(cAlias, nReg, nOpc,          ,      ,      ,        ,    ,          , aButtons,       ,      ,         , .f.       )
    Case nOpc == 4  //Alterar 1-3
    //        AxAltera(cAlias, nReg, nOpc, aAcho    , aCpos, nColMens, cMensagem, cTudoOk, cTransact, cFunc, aButtons, aParam, aAuto, lVirtual, lMaximized)
      _nRetAx := AxAltera(cAlias, nReg, nOpc,          ,      ,         ,          ,        ,        ,      , aButtons,       ,      ,         , .f.       )
    Case nOpc == 5  //Excluir 2-1  
       if U_ZPE_DELETE ()
            //        AxDeleta( cAlias, nReg, nOpc, cTransact, aCpos    , aButtons, aParam, aAuto, lMaximized)
          _nRetAx := AxDeleta( cAlias, nReg, nOpc,          ,  ,         ,       ,      , .f.       )
       endif
    EndCase
    
    Return