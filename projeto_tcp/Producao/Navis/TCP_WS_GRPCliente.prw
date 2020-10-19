#include "Protheus.ch"
#include "apwebsrv.ch"
#include "TOPCONN.CH"
/*/{Protheus.doc} Cliente
Web services para inclusão/Alteração/Exclusao de cliente
@author  Luiz Fernando
@since   12/04/2016
/*/
wsService TCPGrupo description "Webservice integracao de Cliente."

	wsData Grupo	as TCPGrupoAtualizar
	wsData Retorno	as TCPGrupoRetorno

	//Metodos
	wsMethod Atualizar  description "Realiza a inclusão/alteração dos grupos de Grupos no protheus."

endWsService


/*/{Protheus.doc} Atualizar
Método utilizado para Incluir/Alterar Grupo

@author  Luiz 
@since   13/04/2016
@param Estrutura, Objeto, Dados XML para atualizar a estrutura.
@return  Retorno, Objeto, Retorna se conseguiu atualizar a estrutura e o erro, caso ocorra.
/*/
wsMethod Atualizar wsReceive Grupo  wsSend Retorno wsService TCPGrupo
Local lRet      := .t.
Local cTabSX5   := "Z2"	
Local xmlGrupo  := ::Grupo
Local cGrpCli   := Space(06)
Local nTamCli   := TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1]
Local aCustomers:= {StrZero(Val(::Grupo:ClientePai),nTamCli)}

if  TYPE( "Grupo:CLIENTEFILHO") != 'U'
	aadd(aCustomers,StrZero(Val(::Grupo:ClienteFilho),nTamCli))
endif

If .Not. (::Grupo:Excluir)
    cGrpCli := aCustomers[1]
EndIf

If .Not. (::Grupo:Excluir)
    If   TYPE( "Grupo:CLIENTEFILHO") == 'U' .OR. Empty(::Grupo:ClienteFilho)
        dbSelectArea('SA1')
        SA1->(DBSETORDER( 1 ))
        If SA1->(DBSEEK( xFilial("SA1")+aCustomers[1]))
            If RecLock("SA1",.F.)
                xFwPutSX5(cTabSX5,aCustomers[1],SA1->A1_NREDUZ,SA1->A1_NREDUZ,SA1->A1_NREDUZ)
                Replace SA1->A1_XGREMPR With cGrpCli
                MsUnlock()
            EndIf
        else
            //::Retorno:Status := .F.
            ::Retorno:Codigo := "Codigo nao existe"
        EndIf   
    else
        dbSelectArea('SA1')
        SA1->(DBSETORDER( 1 ))
        If SA1->(DBSEEK( xFilial("SA1")+aCustomers[2]))
            If RecLock("SA1",.F.)
                Replace SA1->A1_XGREMPR With cGrpCli
                MsUnlock()
            EndIf
        else
            //::Retorno:Status := .F.
            ::Retorno:Codigo := "Codigo nao existe"
        EndIf  
    EndIf
Else
    If   TYPE( "Grupo:CLIENTEFILHO") != 'U' .AND. !Empty(::Grupo:ClienteFilho)
        dbSelectArea('SA1')
        SA1->(DBSETORDER( 1 ))
        If SA1->(DBSEEK( xFilial("SA1")+aCustomers[2]))
            If RecLock("SA1",.F.)
                Replace SA1->A1_XGREMPR With cGrpCli
                MsUnlock()
            EndIf
        else
            //::Retorno:Status := .F.
            ::Retorno:Codigo := "Codigo nao existe"
        EndIf
    Else
        cUpdate := "UPDATE " + RetSqlName("SA1") + Space(01)
        cUpdate += "SET A1_XGREMPR = '" + cGrpCli + "' " 
        cUpdate += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND"
        cUpdate += "      A1_XGREMPR = '" + aCustomers[1] + "' AND"
        cUpdate += "      D_E_L_E_T_ = ' '"
        TCSQLEXEC( cUpdate )
    EndIf
    
    If Empty(FwGetGrupo(aCustomers[1]))
        xFwDelSX5(cTabSX5,SUBSTR(aCustomers[1],1,6))
    EndIf
    
EndIf

Self:Retorno:Status := .T.

Return ( lRet )


/*/{Protheus.doc} TCPClienteAtualizar
Estrtuura de dados para atualização(Inclusão/alteração) de clientes.
@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPGrupoAtualizar

	wsData ClientePai			as String
	wsData ClienteFilho			as String Optional
	wsData Excluir 				as boolean

endWsStruct



/*/{Protheus.doc} TCPClienteRetorno
Estrutura de retorno para webservices.

@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPGrupoRetorno

	wsData Status  as Boolean
	wsData Codigo  as String //Codigo do cliente+Loja	

endWsStruct

/*/{Protheus.doc} xFwPutSX5
Função utilizada para Incluir/Alterar determinado registro da SX5

@author  Kaique Mathias 
@since   13/04/2016
@param   cTabela, String, Tabela da SX5
         cChave, String, Chave da SX5
         cDescr, String, Descricao em PT
         cDescEsp, String, Descricao em ES
         cDescEng, String, Descricao em ENG
@return  Retorno, Nil, Nil
/*/

Static Function xFwPutSX5(cTabela,cChave,cDescr,cDescEsp,cDescEng)
    
    Local cScript := ""

    If Empty( FwGetSX5(cTabela,cChave) )
        cScript := "INSERT INTO " + RetSqlName("SX5") + " "
        cScript += "(X5_FILIAL,X5_TABELA,X5_CHAVE,X5_DESCRI,X5_DESCSPA,X5_DESCENG,R_E_C_N_O_) "
        cScript += "VALUES (' ','"+cTabela+"','"+SUBSTR(cChave,1,6)+"','"+SUBSTR(cDescr,1,50)+"','"+SUBSTR(cDescEsp,1,50)+"','"+SUBSTR(cDescEng,1,50)+"',(SELECT MAX(R_E_C_N_O_)+1 FROM "+RetSqlName("SX5")+")  ) "
    else
        cScript := "UPDATE " + RetSqlName("SX5") + " " 
        cScript += "SET X5_DESCRI = '" + SUBSTR(cDescr,1,50) + "',"
        cScript += "    X5_DESCSPA = '" + SUBSTR(cDescEsp,1,50) + "',"
        cScript += "    X5_DESCENG = '" + SUBSTR(cDescEng,1,50) + "' "
        cScript += "WHERE   X5_FILIAL = '" + xFilial("SX5") + "' AND "
        cScript += "        X5_CHAVE = '" + SUBSTR(cChave,1,6) + "' AND "
        cScript += "        D_E_L_E_T_ = ' '"
    EndIf
    
    TCSQLEXEC( cScript )

Return( Nil )

/*/{Protheus.doc} xFwDelSX5
Função utilizada para deletar determinado registro da SX5

@author  Kaique Mathias 
@since   13/04/2016
@param   cTabela, String, Tabela da SX5
        cChave, String, Chave da SX5
@return  Retorno, Nil, Nil
/*/

Static Function xFwDelSX5(cTabela,cChave)
    
    cScript := "UPDATE " + RetSqlName("SX5") + " "
    cScript += "SET D_E_L_E_T_='*',R_E_C_D_E_L_=R_E_C_N_O_ " 
    cScript += "WHERE   X5_FILIAL = '" + xFilial("SX5") + "' AND "
    cScript += "        X5_TABELA = '" + cTabela + "' AND "
    cScript += "        X5_CHAVE = '" + cChave + "' AND "
    cScript += "        D_E_L_E_T_ = ' '"
    
    TCSQLEXEC( cScript )

Return( Nil )

Static Function FwGetGrupo(cGrupoCli)

    Local cAlias    := GetNextAlias()
    Local cRet      := ""

    BeginSql Alias cAlias
        Select A1_XGREMPR
        From %Table:SA1% SA1
        Where   SA1.A1_FILIAL = %xFilial:SA1% And
                SA1.A1_XGREMPR = %Exp:cGrupoCli% And
                SA1.%NotDel%
    EndSql
    
    dbSelectArea(cAlias)
    (cAlias)->(dbGoTop())

    If (cAlias)->(!Eof())
        cRet := (CALIAS)->A1_XGREMPR
    EndIf

    (cAlias)->(DBCLOSEAREA())

Return( cRet )