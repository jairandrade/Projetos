#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )


//-------------------------------------------------------------------
/*/{Protheus.doc} NOTNULL
description Funcao Generica para validar o valor do campo, caso esteja
com valor Nil, o campo é desconsiderado para fins de updatda tabela. 
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function NotNull(xVal)

Local   lRet := .T. 

If ( ValType(xVal) = 'U' ) .Or. ;
   ( ValType(xVal) = 'C' .And. xVal = 'Nil' ) .Or. ;
   ( ValType(xVal) = 'N' .And. xVal < 0     )       
   lRet := .F.
EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckCol
description Verifica se um campo exisste no Banco de Dados.
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function CheckCol(_cCampo,_cEmpresa)

Local    _cQry   := ''

If TcGetDB() == 'ORACLE' 
   _cQry := ' SELECT COUNT(*) EXISTE '
   _cQry += ' FROM ALL_TAB_COLUMNS '
   _cQry += ' WHERE OWNER = (SELECT USERNAME FROM V$SESSION WHERE AUDSID = SYS_CONTEXT(' + SIMPLES + 'userenv' + SIMPLES + ',' + SIMPLES + 'sessionid' + SIMPLES + '))' 
   _cQry += ' AND COLUMN_NAME = ' + SIMPLES + _cCampo + SIMPLES 
   _cQry += ' AND TABLE_NAME = SUBSTR(COLUMN_NAME,1,INSTR(COLUMN_NAME,' + SIMPLES + '_' + SIMPLES + ')-1) || ' +  SIMPLES + _cEmpresa + '0' + SIMPLES 
Else 
   _cQry := ' SELECT COUNT(*) EXISTE ' 
   _cQry += ' FROM syscolumns '
   _cQry += ' WHERE name = ' + SIMPLES + _cCampo + SIMPLES 
EndIf 

If Select('XCOL') > 0
   XCOL->(DbCloseArea())
EndIf

DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQry),'XCOL',.F.,.T.)

_lRet := ( XCOL->EXISTE > 0 )

XCOL->(DbCloseArea())

Return( _lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} AUDITDIC
description Grava a auditoria das alteracoes realizadas no dicionario
no banco de dados do AUDIT_TRAIL.@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AuditDic( aAudit , aTexto )

Local _nI     := 0
Local _nF     := 0
Local _lErro  := .F.
Local _lExec  := .F.
Local _cQuery := ''

If !lAuditDic
   aAudit := {}
   Return( Nil )
EndIf

For _nI := 1 To Len( aAudit )

   _lExec := .T.

   _cQuery := 'INSERT INTO AUDITTRAIL.AUDIT_DICT(AD_DEVNAME, AD_TICKET, AD_EMPRESA, AD_TIME, AD_DATE, AD_OP, AD_TABLE, AD_REGISTRO, AD_FIELD, AD_CONTENT, AD_NEWCONT) '
   _cQuery += 'VALUES(' + SIMPLES + '%VL01%' + SIMPLES + ',' + SIMPLES + '%VL02%' + SIMPLES + ',' + SIMPLES + '%VL03%' + SIMPLES + ','
   _cQuery +=             SIMPLES + '%VL04%' + SIMPLES + ',' + SIMPLES + '%VL05%' + SIMPLES + ',' + SIMPLES + '%VL06%' + SIMPLES + ','
   _cQuery +=             SIMPLES + '%VL07%' + SIMPLES + ',' + SIMPLES + '%VL08%' + SIMPLES + ',' + SIMPLES + '%VL09%' + SIMPLES + ','
   _cQuery +=             SIMPLES + '%VL10%' + SIMPLES + ',' + SIMPLES + '%VL11%' + SIMPLES + ')'

   For _nF := 1 To Len( aAudit[_nI] )

      If (AllTrim(aAudit[_nI][09]) $ 'X3_USADO~X3_OBRIGAT') .And. _nF>9
         _cQuery := StrTran(_cQuery,Chr(39)+'%VL'+StrZero(_nF,2)+'%'+Chr(39),If(Empty(aAudit[_nI][_nF]),Chr(39)+' '+Chr(39),MakeChr(aAudit[_nI][_nF])))
      Else
         _cQuery := StrTran(_cQuery,'%VL'+StrZero(_nF,2)+'%',If(Empty(aAudit[_nI][_nF]),' ',StrTran(aAudit[_nI][_nF],Chr(39),Chr(39)+Chr(39))))
      EndIf

   Next _nF

   If ( TCSQLExec(_cQuery) < 0 )
      LogAdd( @aTexto , 'Warning.: Auditoria nao inserida...' )
      LogAdd( @aTexto , 'Script..: ' + _cQuery     )
      LogAdd( @aTexto , 'Retorno.: ' + TCSQLError())
      _lErro := .T.
   EndIf

Next _nI

If _lExec .And. !_lErro
   LogAdd( @aTexto , 'Auditoria registrada com sucesso...' )
EndIf

aAudit := {}

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} CANADD
description Valida se os dados constantes do compatibilizador sao
suficientes para criar um novo registro no dicionario.@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function CanAdd( aEstru , aDados )

Local _lRet      := .F.
Local _nI        := 0

For _nI := 1 To Len(aEstru)
   If !(_lRet := NotNull(aDados[_nI]))
      Exit
   EndIf
Next _nI

Return( _lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MAKECHR
description  ROTINA PARA PREPARAR OS DADOS DOS CAMPOS USADO/OBRIGATORIO
DO DICIONARIO PARA O BANCO ORACLE (AUDITORIA).@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function MakeCHR( cTxt )

Local _cRet  := ''
Local _nI    := 0

For _nI := 1 To Len(cTxt)
   _cRet += IIF(!Empty(_cRet),' || ','') + 'CHR(' + StrZero(Asc(SubStr(cTxt,_nI,1)),3) + ')'
Next

Return( _cRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} LogAdd
description Funcao de gravacao do Log de processamento do compatibili
zador.@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function LogAdd(aTxt,cTxt)

If Empty(aTxt)
   aAdd( aTxt , cTxt )
ElseIf ValType(aTxt[1])=='C'
   If Len(aTxt) >= 3000
     aTxt := {aTxt,{}}       
     aAdd( aTxt[2] , cTxt )
   Else
      aAdd( aTxt , cTxt )
   EndIf
Else
   If Len(aTxt[Len(aTxt)]) >= 3000
      aAdd( aTxt , {} )
      aAdd( aTxt[Len(aTxt)] , cTxt )
 Else
      aAdd( aTxt[Len(aTxt)] , cTxt ) 
   EndIf
EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} 219356X0
description Funcao de processamento da gravacao do SIX - Indices
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 219356X0( aTexto )

Local aEstrut   := {}
Local aSIX      := {}
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

LogAdd( @aTexto , 'Inicio da Atualizacao do SIX' )

aEstrut := {'INDICE','ORDEM','CHAVE','DESCRICAO','DESCSPA','DESCENG','PROPRI','F3','NICKNAME','SHOWPESQ','IX_VIRTUAL','IX_VIRCUST'}

 aAdd( aSIX, {                            ; 
        'Z99', ; //INDICE
        '1', ; //ORDEM
        'Z99_FILIAL+Z99_CODIGO                                                                                                                                           ', ; //CHAVE
        'Codigo                                                                ', ; //DESCRICAO
        'Codigo                                                                ', ; //DESCSPA
        'Codigo                                                                ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'Z99', ; //INDICE
        '2', ; //ORDEM
        'Z99_FILIAL+Z99_USER                                                                                                                                             ', ; //CHAVE
        'Cod. Usuario                                                          ', ; //DESCRICAO
        'Cod. Usuario                                                          ', ; //DESCSPA
        'Cod. Usuario                                                          ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZA0', ; //INDICE
        '1', ; //ORDEM
        'ZA0_FILIAL+ZA0_CODIGO                                                                                                                                           ', ; //CHAVE
        'Sol. Pgto.                                                            ', ; //DESCRICAO
        'Sol. Pgto.                                                            ', ; //DESCSPA
        'Sol. Pgto.                                                            ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZA2', ; //INDICE
        '1', ; //ORDEM
        'ZA2_FILIAL+ZA2_CODIGO                                                                                                                                           ', ; //CHAVE
        'Codigo                                                                ', ; //DESCRICAO
        'Codigo                                                                ', ; //DESCSPA
        'Codigo                                                                ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'N', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZA2', ; //INDICE
        '2', ; //ORDEM
        'ZA2_FILIAL+ZA2_CODIGO+ZA2_NATURE                                                                                                                                ', ; //CHAVE
        'Codigo+Natureza                                                       ', ; //DESCRICAO
        'Codigo+Natureza                                                       ', ; //DESCSPA
        'Codigo+Natureza                                                       ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'N', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZA3', ; //INDICE
        '1', ; //ORDEM
        'ZA3_FILIAL+ZA3_CODIGO+ZA3_NATURE                                                                                                                                ', ; //CHAVE
        'Codigo+Natureza                                                       ', ; //DESCRICAO
        'Codigo+Natureza                                                       ', ; //DESCSPA
        'Codigo+Natureza                                                       ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'N', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZA3', ; //INDICE
        '2', ; //ORDEM
        'ZA3_FILIAL+ZA3_CODIGO+ZA3_NATURE+ZA3_CC                                                                                                                         ', ; //CHAVE
        'Codigo+Natureza+C.Custo                                               ', ; //DESCRICAO
        'Codigo+Natureza+C.Custo                                               ', ; //DESCSPA
        'Codigo+Natureza+C.Custo                                               ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'N', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST



// ----------------------
// Atualizando Dicionário
// ----------------------

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

   If !SIX->( dbSeek( cAudiReg := aSIX[nI][1] + aSIX[nI][2] ) )

      If !CanAdd(aEstrut,aSIX[nI])
         LogAdd( @aTexto , 'Warning.: Indice ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + ' nao pode ser inserido por falta de dados no compatibilizador !')
         Loop
      EndIf

      If Empty(aScan(aArqUpd,aSIX[nI][1]))
         aAdd( aArqUpd, aSIX[nI][1] ) 
      EndIf

      RecLock( 'SIX', .T. )

      For nJ := 1 To Len( aSIX[nI] )

         If (FieldPos( aEstrut[nJ] ) > 0) .And. NotNull(aSIX[nI][nJ])

            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSIX[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SIX' , cAudiReg , aEstrut[nJ] , ' ' , AllTrim(AllToChar(aAudiVal[2])) } )

         EndIf
      Next nJ

      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'indice incluido ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   Else

      RecLock( 'SIX', .F. )

      For nJ := 1 To Len( aSIX[nI] )

         If (FieldPos( aEstrut[nJ] ) > 0) .And. NotNull(aSIX[nI][nJ]) .And. ;
            PadR( StrTran( AllToChar( aAudiVal[1]:=SIX->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )  , ' ' , '' ), 250 ) <> ;
            PadR( StrTran( AllToChar( aAudiVal[2]:=aSIX[nI][nJ] )                                , ' ' , '' ), 250 ) 

            FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SIX' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )

            //Se for alteracao na chave do indice, excluo o indice sem baixar Top e adiciono a tabela na lista de arquivos a atualizar
            If aEstrut[nJ]=='CHAVE'
               TcInternal( 60, RetSqlName( aSIX[nI][1] ) + '|' + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
               If Empty(aScan(aArqUpd,aSIX[nI][1]))
                  aAdd( aArqUpd, aSIX[nI][1] ) 
               EndIf
            EndIf

         EndIf
      Next nJ

      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'indice alterado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   EndIf

   oProcess:IncRegua2( 'Atualizando indices (SIX)...' )

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SIX' )
LogAdd( @aTexto , Replicate( '-', 128) )

Return( .T. )

