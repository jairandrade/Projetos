#include "protheus.ch"
#INCLUDE "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "rwmake.ch"

Static lJob := IsBlind() 

/*/{Protheus.doc} TCES01KM
Função responsável por emitir o relatorio de movimentação diaria
de movimentos baixados em formato excel e enviar por email
@type  User Function
@author Kaique Sousa
@since 16/07/2019
@version 1.0 
@param param_name, param_type, param_descr
@return Nil
/*/
User Function TCES01KM()
    
    Local cTimeStart    := ""
    Local cRelease      := GetRPORelease()
    Local cPerg 		:= PadR("TCES01KM",10)
    
    If !lJob
        //If ( cRelease <= '12.1.017' )
        //    CriaSX1(cPerg)
        //EndIf
		
		If !Pergunte(cPerg,.T.)
			Return( Nil )
		EndIf
		
        cTimeStart := Time()
        cPath := cGetFile( "Diretório" + "|*.*", "Procurar", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )
        If Empty( cPath )
			MsgAlert( "Diretório não selecionado!" )
		Else
            FWMsgRun( ,{ || fGeraExcel( cPath ) }, "Aguarde...", "Gerando relatorio em excel..." )
            cTimeTotal := ElapTime( cTimeStart, Time() )
            MsgInfo( "Processo finalizado. Tempo Total: " + cTimeTotal, "Relatório" )
        EndIf
    
    Else 
        fGeraExcel() 
    EndIf 
    
Return( Nil )

/*/{Protheus.doc} fGeraExcel
Função responsável por realizar a geração do excel
@type  User Function
@author Kaique Sousa
@since 16/07/2019
@version 1.0 
@param param_name, param_type, param_descr
@return Nil
/*/

Static Function fGeraExcel( cPath )

    Local oExcel		:=	FWMSExcel():New()
    Local cArquivo      := "REL_TCES01KM" + "_" + DToS( dDataBase ) + "_" + StrTran( Time(), ":", "" ) + ".XLS"
    Local cAliasTMP     := GetNextAlias()
    Local cAba          := "PILA"
    Local cTabela       := "Movimentos Baixas x Coletor"
    Local cDefPath		:=	GetSrvProfString( "StartPath", "\system\" )
    Local cErro         := ""
    Local oMail,oHtml   := Nil
     
    oExcel:AddWorkSheet( cAba )
    oExcel:AddTable( cAba, cTabela ) 
    
    oExcel:AddColumn( cAba, cTabela, "Dt. Protheus", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Dt. Ord. Sep.", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Dt. Coletor", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Codigo", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Descrição", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Quant.Baixado", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Quant.Coletor", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Quant.Divergente", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Ordem Manutenção", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Ordem Produção", 1, 1, .F. )
    oExcel:AddColumn( cAba, cTabela, "Usuário", 1, 1, .F. )

    _cQuery := "SELECT	EMISSAO, " + CRLF
    _cQuery += "DTORDSEP, " + CRLF
    _cQuery += "DTCOLETOR, " + CRLF
    _cQuery += "CODIGO, "  + CRLF
    _cQuery += "DESCRICAO, " + CRLF
    _cQuery += "SUM(QTD_SD3) QTD_SD3, " + CRLF
    _cQuery += "SUM(QTD_CB8) QTD_CB8, " + CRLF
    _cQuery += "ORDEM_MANUTENCAO, " + CRLF
    _cQuery += "ORDEM_PRODUCAO, " + CRLF
    _cQuery += "ISNULL(USUARIO,'') USUARIO " + CRLF
    _cQuery += "FROM (" + CRLF
    _cQuery += "SELECT  D3_EMISSAO EMISSAO, " + CRLF
    _cQuery += "CB7_DTEMIS DTORDSEP,  " + CRLF
    _cQuery += "CB7_DTINIS DTCOLETOR,  " + CRLF
    _cQuery += "CB8_PROD CODIGO,  " + CRLF
    _cQuery += "B1_DESC DESCRICAO, " + CRLF
    _cQuery += "ISNULL(D3_QUANT,0) QTD_SD3, " + CRLF
    _cQuery += "ISNULL(CB8_QTDORI,0) QTD_CB8, " + CRLF
    _cQuery += "CB7_XOM ORDEM_MANUTENCAO, " + CRLF
    _cQuery += "CB7_OP ORDEM_PRODUCAO, " + CRLF
    _cQuery += "D3_USUARIO USUARIO"
    _cQuery += "FROM " + RetSqlName("CB7") + " CB7 " + CRLF
    _cQuery += "LEFT JOIN " + RetSqlName("CB8") + " CB8 ON CB8_FILIAL = CB7_FILIAL AND " + CRLF
    _cQuery += "CB8_ORDSEP = CB7_ORDSEP AND " + CRLF
    _cQuery += "CB8_OP = CB7_OP AND " + CRLF
    _cQuery += "CB8.D_E_L_E_T_=' ' " + CRLF
    _cQuery += "LEFT JOIN " + RetSqlName("CB9") + " CB9 ON CB9.CB9_FILIAL = CB8.CB8_FILIAL AND " + CRLF
    _cQuery += "CB9.CB9_ORDSEP = CB8_ORDSEP AND " + CRLF
    _cQuery += "CB9.CB9_PROD = CB8_PROD AND " + CRLF
    _cQuery += "CB9.CB9_ITESEP = CB8_ITEM AND " + CRLF
    _cQuery += "CB9.CB9_LCALIZ = CB8_LCALIZ AND " + CRLF
    _cQuery += "CB9.D_E_L_E_T_=' ' " + CRLF
    _cQuery += "LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = CB8_PROD AND " + CRLF
    _cQuery += "SB1.D_E_L_E_T_=' ' " + CRLF
    _cQuery += "LEFT JOIN " + RetSqlName("SD3") + " SD3 ON SD3.D3_FILIAL = CB8.CB8_FILIAL" + CRLF 
	_cQuery += "AND SD3.D3_OP = CB8_OP "
    _cQuery += "AND SD3.D3_COD = CB8_PROD "
    _cQuery += "AND SD3.D3_LOCAL = CB8_LOCAL "
    _cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
    _cQuery += "AND SD3.D3_TM >= '500' "
    _cQuery += "WHERE   CB7.D_E_L_E_T_ = ' ' AND " + CRLF
    
    //If UPPER(GetEnvServer()) == "PRODUCAO"
        //_cQuery += "SUBSTRING(CB7.CB7_DTEMIS,1,6) = '" + SubStr(DtoS( dDataBase ),1,6) + "'" + CRLF
    //Else
    if lJob
        _cQuery += "CB7.CB7_DTINIS = '" + DtoS( dDataBase-1 ) + "'" + CRLF
    Else
        _cQuery += "CB7.CB7_DTINIS >= '" + DtoS( MV_PAR01 ) + "' AND CB7.CB7_DTINIS <= '" + DtoS( MV_PAR02 ) + "'" + CRLF
    Endif
    //EndIf

    _cQuery += "AND CB7_STATUS NOT IN ('0','1')  "  + CRLF
    _cQuery += ") QRY1  " + CRLF
    _cQuery += "GROUP BY EMISSAO,DTORDSEP,DTCOLETOR,CODIGO,DESCRICAO,ORDEM_MANUTENCAO,ORDEM_PRODUCAO,USUARIO" + CRLF
    
    _cQuery := ChangeQuery(_cQuery)
		
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP,.T.,.T.) 
 
    dbSelectArea(cAliasTMP)
    (cAliasTMP)->(dbGotop())
 
    While (cAliasTMP)->(!Eof()) 
        oExcel:AddRow(  cAba,;
                        cTabela,;
                        {;
                            DTOC(STOD((cAliasTMP)->EMISSAO)),;
                            DTOC(STOD((cAliasTMP)->DTORDSEP)),;
                            DTOC(STOD((cAliasTMP)->DTCOLETOR)),;
                            (cAliasTMP)->CODIGO,;
                            (cAliasTMP)->DESCRICAO,;
                            (cAliasTMP)->QTD_SD3,;
                            (cAliasTMP)->QTD_CB8,;
                            ( (cAliasTMP)->QTD_SD3 - (cAliasTMP)->QTD_CB8 ),;
                            (cAliasTMP)->ORDEM_MANUTENCAO,;
                            (cAliasTMP)->ORDEM_PRODUCAO,;
                            (cAliasTMP)->USUARIO;
                        })
        (cAliasTMP)->(DbSkip())
    EndDo

    (cAliasTMP)->(DBCLOSEAREA())

    If !Empty( oExcel:aWorkSheet )
        oExcel:Activate()
        oExcel:GetXMLFile( cArquivo )
    EndIf

    If !lJob
        __CopyFile( cDefPath + cArquivo, cPath + cArquivo ) 
        If ApOleClient( "MSExcel" )
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath + cArquivo ) //Abre a planilha
            oExcelApp:SetVisible( .T. )
        EndIf
    Else 
        oMail := TCPMail():New()
        oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILAVISO.HTML")
        oHtml:ValByName("CHEADER","Relação de Baixas")
        oHtml:ValByName("CBODY","Segue em anexo arquivo com relação de baixas referente ao dia " + DTOC(dDataBase-1) + ".")
        oMail:SendMail(GetMv('TCP_RESPBX'),"Relação de Baixas do dia " + DTOC(dDataBase-1) ,oHtml:HtmlCode(),@cErro,{cDefPath + cArquivo})
        FreeObj(oMail)
        FreeObj(oHtml)
    EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
description Cria pergunta no arquivo de dados SX1
CSV
@author  Kaique Mathias
@since   20/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------

/*Static Function CriaSX1(cPerg)

    Local aSX1    := {}
    Local aEstrut := {}
    Local i       := 0
    Local j       := 0
    Local lSX1	  := .F.
    
    dbSelectArea("SX1")
    dbSetOrder(1)

    cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

    aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
                "X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
                "X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
                "X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME","X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

    aAdd(aSX1,{cPerg,"01","Data de  ?"           ,"","","MV_CH1","D",08,0,0,"G","!Vazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","   ","","S","","",""})
    aAdd(aSX1,{cPerg,"02","Data Até ?"           ,"","","MV_CH2","D",08,0,0,"G","!Vazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","   ","","S","","",""})
	
    ProcRegua(Len(aSX1))

    For i:= 1 To Len(aSX1)
        If !Empty(aSX1[i][1])
            If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
                lSX1 := .T.
                RecLock("SX1",.T.)
                
                For j:=1 To Len(aSX1[i])
                    If !Empty(FieldName(FieldPos(aEstrut[j])))
                        FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
                    EndIf
                Next j
                
                dbCommit()
                MsUnLock()
            EndIf
        EndIf
    Next i

Return( Nil )*/

static function FWGetCodUsr(_cUserName)

    Local aArea		    := GetArea()
    Local _cCodUsr      := ""
    Default _cUserName  := ""

    PswOrder(2)
    If PswSeek(_cUserName)
        _cCodUsr := PswRet(1)[1][1]
    EndIf
    
    RestArea(aArea)

Return(_cCodUsr)