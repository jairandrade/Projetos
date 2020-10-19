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
/*/{Protheus.doc} 21935630
description Funcao de processamento da gravacao do SX3 - Campos
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 21935630( aTexto , lOrd )

Local aEstrut   := {}
Local aSX3      := {}
Local cAliasAtu := ''
Local cSeqAtu   := ''
Local cPro      := ''
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosPRO   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

LogAdd( @aTexto , 'Inicio da Atualizacao do SX3' )

aEstrut := { 'X3_ARQUIVO', ; 
             'X3_ORDEM', ; 
             'X3_CAMPO', ; 
             'X3_TIPO', ; 
             'X3_TAMANHO', ; 
             'X3_DECIMAL', ; 
             'X3_TITULO', ; 
             'X3_TITSPA', ; 
             'X3_TITENG', ; 
             'X3_DESCRIC', ; 
             'X3_DESCSPA', ; 
             'X3_DESCENG', ; 
             'X3_PICTURE', ; 
             'X3_VALID', ; 
             'X3_USADO', ; 
             'X3_RELACAO', ; 
             'X3_F3', ; 
             'X3_NIVEL', ; 
             'X3_RESERV', ; 
             'X3_CHECK', ; 
             'X3_TRIGGER', ; 
             'X3_PROPRI', ; 
             'X3_BROWSE', ; 
             'X3_VISUAL', ; 
             'X3_CONTEXT', ; 
             'X3_OBRIGAT', ; 
             'X3_VLDUSER', ; 
             'X3_CBOX', ; 
             'X3_CBOXSPA', ; 
             'X3_CBOXENG', ; 
             'X3_PICTVAR', ; 
             'X3_WHEN', ; 
             'X3_INIBRW', ; 
             'X3_GRPSXG', ; 
             'X3_FOLDER', ; 
             'X3_PYME', ; 
             'X3_CONDSQL', ; 
             'X3_CHKSQL', ; 
             'X3_IDXSRV', ; 
             'X3_ORTOGRA', ; 
             'X3_IDXFLD', ; 
             'X3_TELA', ; 
             'X3_PICBRV', ; 
             'X3_AGRUP', ; 
             'X3_POSLGT', ; 
             'X3_MODAL' } 


aAdd( aSX3, { ;
   'SCR' , ; //X3_ARQUIVO
   '29' , ; //X3_ORDEM
   'CR_XHORAS ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    5 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Hora        ' , ; //X3_TITULO
   'Hora        ' , ; //X3_TITSPA
   'Hora        ' , ; //X3_TITENG
   'Hora                     ' , ; //X3_DESCRIC
   'Hora                     ' , ; //X3_DESCSPA
   'Hora                     ' , ; //X3_DESCENG
   '99:99                                        ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SAL' , ; //X3_ARQUIVO
   '29' , ; //X3_ORDEM
   'AL_MSBLQL ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Bloqueado?  ' , ; //X3_TITULO
   'Bloqueado?  ' , ; //X3_TITSPA
   'Bloqueado?  ' , ; //X3_TITENG
   'Registro bloqueado       ' , ; //X3_DESCRIC
   'Registro bloqueado       ' , ; //X3_DESCSPA
   'Registro bloqueado       ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + SIMPLES + '2' + SIMPLES + '                                                                                                                             ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    9 , ; //X3_NIVEL
   '‚€' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'L' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '1=Sim;2=Não                                                                                                                     ' , ; //X3_CBOX
   '1=Si;2=No                                                                                                                       ' , ; //X3_CBOXSPA
   '1=Yes;2=No                                                                                                                      ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL


aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FILIAL ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PREFIXO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUM    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCELA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TIPO   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NATUREZ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ITEMD  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORNECE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NOMFOR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_EMISSAO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VENCTO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VALOR  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'U_AFIN011()                                                 ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VLDESC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IRRF   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_HIST   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_INSS   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CC     ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMBCO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_INDICE ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BAIXA  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_EMIS1  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BARRA  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LA     ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LOTE   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MOTIVO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_OK     ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MOVIMEN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_OP     ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SALDO  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DESCONT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MULTA  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   '@E 99,999,999,999,999.99                     ' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_JUROS  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   '@E 99,999,999,999,999.99                     ' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CORREC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VALLIQ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VENCORI' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VALJUR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PORCJUR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MOEDA  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMBOR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FATPREF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FATURA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PROJETO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CLASCON' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_RATEIO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_DESDOBR == ' + DUPLAS + 'N' + DUPLAS + ' .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DTVARIA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VARURV ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VLCRUZ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DTFATUR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCIR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ARQRAT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITORIG' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IDENTEE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FLUXO  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IMPCHEQ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_OCORREN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCINS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ORDPAGO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ORIGEM ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DESDOBR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_RATEIO == ' + DUPLAS + 'N' + DUPLAS + '  .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BCOPAG ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PORTADO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LOJA   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ISS    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_MULTNAT != ' + DUPLAS + '1' + DUPLAS + '  .AND. U_AFIN011()                     ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BARDIG ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NOSNUM ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODCED ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FLAGFAT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_APROVA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DATALIB' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TIPOFAT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ANOBASE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MESBASE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SDACRES' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SDDECRE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMTIT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_USUALIB' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MULTNAT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'F050RatDes(1)  .AND. U_AFIN011()                            ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PROJPMS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PLLOTE ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODRET ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_DIRF==' + DUPLAS + '1' + DUPLAS + '  .AND. U_AFIN011()                          ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DIRF   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TXMOEDA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'WTxMoe(M->E2_MOEDA)  .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MODSPB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'SpbInUse() .AND. U_AFIN011()                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IDCNAB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCCSS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_RETENC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CONTAD ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODORCA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FILDEB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SEST   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_MULTNAT != ' + DUPLAS + '1' + DUPLAS + ' .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORNISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LOJAISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCSES' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FILORIG' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DEBITO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CCD    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CLVLDB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CREDIT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CCC    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ITEMC  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CLVLCR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_COFINS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PIS    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCCOF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCPIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCSLL' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CSLL   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITPIS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITCOF ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITCSL ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITINS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETPIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETCOF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETCSL' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRETPIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRETCOF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SEQBX  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRETCSL' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODBAR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VENCISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VBASISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDRTISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VARIAC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PERIOD ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDCONTR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDREVIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDPLANI' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDCRON ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FATFOR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FATLOJ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDPARCE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMLIQ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BCOCHQ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_AGECHQ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CTACHQ ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FRETISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TXMDCOR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_APLVLMN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CLEARIN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_HORASPB' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRETIRF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_SEFIP  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TRETISS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETIRF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PLOPELT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODRDA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCFET' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FETHAB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORORI ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LOJORI ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_STATUS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DTDIRF ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITADT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TITPAI ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_INSSRET' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CIDE   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_MULTNAT != ' + SIMPLES + '1' + SIMPLES + ' .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODAGL ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DIACTB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'CtbWDia() .AND. U_AFIN011()                                 ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NODIA  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_RETCNTR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDDESC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDBONI ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MDMULT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODINS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCCID' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCAGL' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODRCOF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TIPOLIQ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODRCSL' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODRPIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DTBORDE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IDDARF ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PROCPCC' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORNPAI' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRETINS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETINS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TEMDOCS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DATAAGE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_USUASUS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_USUACAN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DATASUS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DATACAN' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LIMCAN ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCFAC' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCFAB' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FABOV  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FACS   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODISS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODAPRO' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_STATLIB' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMP5' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MSIDENT' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMP3' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMP1' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMP4' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMP2' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ZITECTA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PREOP  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMPRO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_INDPRO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IDMOV  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRINSS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PRISS  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_RATFIN ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NUMSOL ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODOPE ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FIMP   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORBCO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NFELETR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORAGE ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_AGLIMP ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FAGEDV ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORCTA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NOMOPE ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FCTADV ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_USERLGI' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_USERLGA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TPDESC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FAMAD  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCFAM' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FMPEQ  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARCFMP' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FUNDESA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_IMAMT  ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FASEMT ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARFUND' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARIMA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_PARFASE' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DOCHAB ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_LINDIG ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_DTAPUR ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_DIRF == ' + DUPLAS + '1' + DUPLAS + ' .AND. U_AFIN011()                         ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NROREF ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_DIRF == ' + DUPLAS + '1' + DUPLAS + ' .AND. U_AFIN011()                         ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_NOMERET' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TPINSC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CCUSTO ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_FORMPAG' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_RETINS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_TPESOC ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CLVL   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'CtbInUse()  .AND. U_AFIN011()                               ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_ITEMCTA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'CtbInUse() .AND. U_AFIN011()                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CNPJRET' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CNO    ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XORIGEM' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'PC=Pedido de Compras;FI=Financeiro;CT=Contratos;SP=Solicitacao de Pagamento                                                     ' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'PC=Purchase Orders;CT=Contract;SP=Manual Payment;FI=Exception                                                                   ' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XDCODRF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XDPAPUR' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XDNUMRF' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_MEDNUME' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_BTRISS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'M->E2_MULTNAT != ' + DUPLAS + '1' + DUPLAS + ' .AND. U_AFIN011()                      ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_CODSERV' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_VRETBIS' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XMULTA ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XJUROS ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'Nil' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'Nil' , ; //X3_ORDEM
   'E2_XCONTRA' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   'Nil' , ; //X3_PICTURE
   'Nil' , ; //X3_VALID
   'Nil' , ; //X3_USADO
   'Nil' , ; //X3_RELACAO
   'CN9TCP' , ; //X3_F3
    -1 , ; //X3_NIVEL
   'Nil' , ; //X3_RESERV
   'Nil' , ; //X3_CHECK
   'Nil' , ; //X3_TRIGGER
   'Nil' , ; //X3_PROPRI
   'Nil' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   ' U_AFIN011()                                                ' , ; //X3_WHEN
   'Nil' , ; //X3_INIBRW
   'Nil' , ; //X3_GRPSXG
   'Nil' , ; //X3_FOLDER
   'Nil' , ; //X3_PYME
   'Nil' , ; //X3_CONDSQL
   'Nil' , ; //X3_CHKSQL
   'Nil' , ; //X3_IDXSRV
   'Nil' , ; //X3_ORTOGRA
   'Nil' , ; //X3_IDXFLD
   'Nil' , ; //X3_TELA
   'Nil' , ; //X3_PICBRV
   'Nil' , ; //X3_AGRUP
   'Nil' , ; //X3_POSLGT
   'Nil'  } ) //X3_MODAL

aAdd( aSX3, { ;
   'SE2' , ; //X3_ARQUIVO
   'DV' , ; //X3_ORDEM
   'E2_XCODPGM' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod.Pgto Man' , ; //X3_TITULO
   'Cod.Pgto Man' , ; //X3_TITSPA
   'Cod.Pgto Man' , ; //X3_TITENG
   'Cod. Pagamento Manual    ' , ; //X3_DESCRIC
   'Cod. Pagamento Manual    ' , ; //X3_DESCSPA
   'Cod. Pagamento Manual    ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL


aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'Z99_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    1 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   ' ' , ; //X3_VISUAL
   ' ' , ; //X3_CONTEXT
    Chr(032) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '033' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   ' ' , ; //X3_ORTOGRA
   ' ' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'Z99_CODIGO' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Codigo      ' , ; //X3_TITULO
   'Codigo      ' , ; //X3_TITSPA
   'Codigo      ' , ; //X3_TITENG
   'Codigo                   ' , ; //X3_DESCRIC
   'Codigo                   ' , ; //X3_DESCSPA
   'Codigo                   ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'GETSX8NUM(' + DUPLAS + 'Z99' + DUPLAS + ',' + DUPLAS + 'Z99_CODIGO' + DUPLAS + ')                                                                                                   ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'Z99_USER  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod. Usuario' , ; //X3_TITULO
   'Cod. Usuario' , ; //X3_TITSPA
   'Cod. Usuario' , ; //X3_TITENG
   'Codigo do Usuario        ' , ; //X3_DESCRIC
   'Codigo do Usuario        ' , ; //X3_DESCSPA
   'Codigo do Usuario        ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'USR   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   'UsrExist(FwFldGet(' + DUPLAS + 'Z99_USER' + DUPLAS + '))                                                                                                  ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'Z99_NOME  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    40 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Nome        ' , ; //X3_TITULO
   'Nome        ' , ; //X3_TITSPA
   'Nome        ' , ; //X3_TITENG
   'Nome do usuario          ' , ; //X3_DESCRIC
   'Nome do usuario          ' , ; //X3_DESCSPA
   'Nome do usuario          ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'If( !INCLUI, UsrFullName( Z99->Z99_USER ), ' + DUPLAS + '' + DUPLAS + ' )                                                                                 ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'V' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   'UsrFullName( Z99->Z99_USER )                                                    ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'Z99_ALTALC' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Alt. Alcada?' , ; //X3_TITULO
   'Alt. Alcada?' , ; //X3_TITSPA
   'Alt. Alcada?' , ; //X3_TITENG
   'Altera alcada            ' , ; //X3_DESCRIC
   'Altera alcada            ' , ; //X3_DESCSPA
   'Altera alcada            ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   'Pertence(' + DUPLAS + 'SN' + DUPLAS + ')                                                                                                                  ' , ; //X3_VLDUSER
   'S=Sim;N=Nao                                                                                                                     ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'Z99_GRPAPR' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Grp. Aprov. ' , ; //X3_TITULO
   'Grp. Aprov. ' , ; //X3_TITSPA
   'Grp. Aprov. ' , ; //X3_TITENG
   'Grupo de aprovacao       ' , ; //X3_DESCRIC
   'Grupo de aprovacao       ' , ; //X3_DESCSPA
   'Grupo de aprovacao       ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SAL   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'Vazio() .Or. ExistCpo(' + DUPLAS + 'SAL' + DUPLAS + ',M->Z99_GRAPR)                                                                                       ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'Z99' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'Z99_VISTOD' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Visu. Todos?' , ; //X3_TITULO
   'Visu. Todos?' , ; //X3_TITSPA
   'Visu. Todos?' , ; //X3_TITENG
   'Visualiza todos          ' , ; //X3_DESCRIC
   'Visualiza todos          ' , ; //X3_DESCSPA
   'Visualiza todos          ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   'Pertence(' + DUPLAS + 'SN' + DUPLAS + ')                                                                                                                  ' , ; //X3_VLDUSER
   'S=Sim;N=Nao                                                                                                                     ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZA0_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    1 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   ' ' , ; //X3_VISUAL
   ' ' , ; //X3_CONTEXT
    Chr(032) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '033' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   ' ' , ; //X3_ORTOGRA
   ' ' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZA0_CODIGO' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Solic.Pgto. ' , ; //X3_TITULO
   'Solic.Pgto. ' , ; //X3_TITSPA
   'Solic.Pgto. ' , ; //X3_TITENG
   'Solicitacao de pagamento ' , ; //X3_DESCRIC
   'Solicitacao de pagamento ' , ; //X3_DESCSPA
   'Solicitacao de pagamento ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'GETSXENUM(' + DUPLAS + 'ZA0' + DUPLAS + ',' + DUPLAS + 'ZA0_CODIGO' + DUPLAS + ')                                                                                                   ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZA0_NUM   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    9 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'No. Titulo  ' , ; //X3_TITULO
   'No. Titulo  ' , ; //X3_TITSPA
   'No. Titulo  ' , ; //X3_TITENG
   'Numero do Titulo         ' , ; //X3_DESCRIC
   'Numero do Titulo         ' , ; //X3_DESCSPA
   'Numero do Titulo         ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZA0_TIPO  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Tipo        ' , ; //X3_TITULO
   'Tipo        ' , ; //X3_TITSPA
   'Tipo        ' , ; //X3_TITENG
   'Tipo do Titulo           ' , ; //X3_DESCRIC
   'Tipo do Titulo           ' , ; //X3_DESCSPA
   'Tipo do Titulo           ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   'ExistCpo(' + DUPLAS + 'SX5' + DUPLAS + ',' + DUPLAS + '05' + DUPLAS + '+M->ZA0_TIPO)                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '05    ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZA0_CLIFOR' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Fornecedor  ' , ; //X3_TITULO
   'Fornecedor  ' , ; //X3_TITSPA
   'Fornecedor  ' , ; //X3_TITENG
   'Fornecedor               ' , ; //X3_DESCRIC
   'Fornecedor               ' , ; //X3_DESCSPA
   'Fornecedor               ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   'ExistCpo(' + DUPLAS + 'SA2' + DUPLAS + ',M->ZA0_CLIFOR,,,,.F.)                                                                                            ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SA2   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   'ExistCpo(' + DUPLAS + 'SA2' + DUPLAS + ',M->ZA0_CLIFOR,,,,.F.)                                                                                            ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZA0_LOJA  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Loja        ' , ; //X3_TITULO
   'Loja        ' , ; //X3_TITSPA
   'Loja        ' , ; //X3_TITENG
   'Loja                     ' , ; //X3_DESCRIC
   'Loja                     ' , ; //X3_DESCSPA
   'Loja                     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZA0_NOME  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    20 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Nome        ' , ; //X3_TITULO
   'Nome        ' , ; //X3_TITSPA
   'Nome        ' , ; //X3_TITENG
   'Nome                     ' , ; //X3_DESCRIC
   'Nome                     ' , ; //X3_DESCSPA
   'Nome                     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '08' , ; //X3_ORDEM
   'ZA0_EMISSA' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Emissao     ' , ; //X3_TITULO
   'Emissao     ' , ; //X3_TITSPA
   'Emissao     ' , ; //X3_TITENG
   'Emissao                  ' , ; //X3_DESCRIC
   'Emissao                  ' , ; //X3_DESCSPA
   'Emissao                  ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '09' , ; //X3_ORDEM
   'ZA0_VENCTO' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Vencimento  ' , ; //X3_TITULO
   'Vencimento  ' , ; //X3_TITSPA
   'Vencimento  ' , ; //X3_TITENG
   'Vencimento               ' , ; //X3_DESCRIC
   'Vencimento               ' , ; //X3_DESCSPA
   'Vencimento               ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '10' , ; //X3_ORDEM
   'ZA0_VENCRE' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Vencto Real ' , ; //X3_TITULO
   'Vencto Real ' , ; //X3_TITSPA
   'Vencto Real ' , ; //X3_TITENG
   'Vencimento real          ' , ; //X3_DESCRIC
   'Vencimento real          ' , ; //X3_DESCSPA
   'Vencimento real          ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '11' , ; //X3_ORDEM
   'ZA0_CODBAR' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    48 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod.Barras  ' , ; //X3_TITULO
   'Cod.Barras  ' , ; //X3_TITSPA
   'Cod.Barras  ' , ; //X3_TITENG
   'Codigo de Barras         ' , ; //X3_DESCRIC
   'Codigo de Barras         ' , ; //X3_DESCSPA
   'Codigo de Barras         ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'Vazio() .OR. VldCodBar(M->ZA0_CODBAR)                                                                                           ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '12' , ; //X3_ORDEM
   'ZA0_NATURE' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Natureza    ' , ; //X3_TITULO
   'Natureza    ' , ; //X3_TITSPA
   'Natureza    ' , ; //X3_TITENG
   'Codigo da natureza       ' , ; //X3_DESCRIC
   'Codigo da natureza       ' , ; //X3_DESCSPA
   'Codigo da natureza       ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SED   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '13' , ; //X3_ORDEM
   'ZA0_CC    ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    9 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'C.Custo     ' , ; //X3_TITULO
   'C.Custo     ' , ; //X3_TITSPA
   'C.Custo     ' , ; //X3_TITENG
   'Centro de Custo          ' , ; //X3_DESCRIC
   'Centro de Custo          ' , ; //X3_DESCSPA
   'Centro de Custo          ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'CTT   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'Vazio() .or. CTB105CC()                                                                                                         ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '14' , ; //X3_ORDEM
   'ZA0_TPORC ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Tipo Orc.   ' , ; //X3_TITULO
   'Tipo Orc.   ' , ; //X3_TITSPA
   'Tipo Orc.   ' , ; //X3_TITENG
   'Tipo do orcamento        ' , ; //X3_DESCRIC
   'Tipo do orcamento        ' , ; //X3_DESCSPA
   'Tipo do orcamento        ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   'C=Capex;O=Opex                                                                                                                  ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '15' , ; //X3_ORDEM
   'ZA0_VALOR ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Vlr.Titulo  ' , ; //X3_TITULO
   'Valor       ' , ; //X3_TITSPA
   'Valor       ' , ; //X3_TITENG
   'Valor do Titulo          ' , ; //X3_DESCRIC
   'Valor                    ' , ; //X3_DESCSPA
   'Valor                    ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '16' , ; //X3_ORDEM
   'ZA0_MULTA ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Multa       ' , ; //X3_TITULO
   'Multa       ' , ; //X3_TITSPA
   'Multa       ' , ; //X3_TITENG
   'Valor da Multa           ' , ; //X3_DESCRIC
   'Valor da Multa           ' , ; //X3_DESCSPA
   'Valor da Multa           ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '17' , ; //X3_ORDEM
   'ZA0_JUROS ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Juros       ' , ; //X3_TITULO
   'Juros       ' , ; //X3_TITSPA
   'Juros       ' , ; //X3_TITENG
   'Valor do Juros           ' , ; //X3_DESCRIC
   'Valor do Juros           ' , ; //X3_DESCSPA
   'Valor do Juros           ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '18' , ; //X3_ORDEM
   'ZA0_JUSJUR' , ; //X3_CAMPO
   'M' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Just.Juros  ' , ; //X3_TITULO
   'Just.Juros  ' , ; //X3_TITSPA
   'Just.Juros  ' , ; //X3_TITENG
   'Justificativa do Juros   ' , ; //X3_DESCRIC
   'Justificativa do Juros   ' , ; //X3_DESCSPA
   'Justificativa do Juros   ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '19' , ; //X3_ORDEM
   'ZA0_IRRF  ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    14 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'IRRF        ' , ; //X3_TITULO
   'IRRF        ' , ; //X3_TITSPA
   'IRRF        ' , ; //X3_TITENG
   'Valor do IRRF            ' , ; //X3_DESCRIC
   'Valor do IRRF            ' , ; //X3_DESCSPA
   'Valor do IRRF            ' , ; //X3_DESCENG
   '@E 99,999,999,999.99                         ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '20' , ; //X3_ORDEM
   'ZA0_PIS   ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    14 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'PIS/PASEP   ' , ; //X3_TITULO
   'PIS/PASEP   ' , ; //X3_TITSPA
   'PIS/PASEP   ' , ; //X3_TITENG
   'Valor PIS                ' , ; //X3_DESCRIC
   'Valor PIS                ' , ; //X3_DESCSPA
   'Valor PIS                ' , ; //X3_DESCENG
   '@E 99,999,999,999.99                         ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '21' , ; //X3_ORDEM
   'ZA0_COFINS' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'COFINS      ' , ; //X3_TITULO
   'COFINS      ' , ; //X3_TITSPA
   'COFINS      ' , ; //X3_TITENG
   'Valor COFINS             ' , ; //X3_DESCRIC
   'Valor COFINS             ' , ; //X3_DESCSPA
   'Valor COFINS             ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '22' , ; //X3_ORDEM
   'ZA0_CSLL  ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    14 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'CSLL        ' , ; //X3_TITULO
   'CSLL        ' , ; //X3_TITSPA
   'CSLL        ' , ; //X3_TITENG
   'Valor CSLL               ' , ; //X3_DESCRIC
   'Valor CSLL               ' , ; //X3_DESCSPA
   'Valor CSLL               ' , ; //X3_DESCENG
   '@E 99,999,999,999.99                         ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '23' , ; //X3_ORDEM
   'ZA0_CODREC' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    4 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod.Receita ' , ; //X3_TITULO
   'Cod.Receita ' , ; //X3_TITSPA
   'Cod.Receita ' , ; //X3_TITENG
   'Codigo da Receita        ' , ; //X3_DESCRIC
   'Codigo da Receita        ' , ; //X3_DESCSPA
   'Codigo da Receita        ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '24' , ; //X3_ORDEM
   'ZA0_PERAPU' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Per.Apur.   ' , ; //X3_TITULO
   'Per.Apur.   ' , ; //X3_TITSPA
   'Per.Apur.   ' , ; //X3_TITENG
   'Periodo de apuracao      ' , ; //X3_DESCRIC
   'Periodo de apuracao      ' , ; //X3_DESCSPA
   'Periodo de apuracao      ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '25' , ; //X3_ORDEM
   'ZA0_NUMREF' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    20 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Num Referenc' , ; //X3_TITULO
   'Num Referenc' , ; //X3_TITSPA
   'Num Referenc' , ; //X3_TITENG
   'Numero de Referencia     ' , ; //X3_DESCRIC
   'Numero de Referencia     ' , ; //X3_DESCSPA
   'Numero de Referencia     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '26' , ; //X3_ORDEM
   'ZA0_CODSOL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Solicitante ' , ; //X3_TITULO
   'Solicitante ' , ; //X3_TITSPA
   'Solicitante ' , ; //X3_TITENG
   'Solicitante              ' , ; //X3_DESCRIC
   'Solicitante              ' , ; //X3_DESCSPA
   'Solicitante              ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '27' , ; //X3_ORDEM
   'ZA0_OBS   ' , ; //X3_CAMPO
   'M' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Observacao  ' , ; //X3_TITULO
   'Observacao  ' , ; //X3_TITSPA
   'Observacao  ' , ; //X3_TITENG
   'Observacao               ' , ; //X3_DESCRIC
   'Observacao               ' , ; //X3_DESCSPA
   'Observacao               ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '28' , ; //X3_ORDEM
   'ZA0_STATUS' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Status      ' , ; //X3_TITULO
   'Status      ' , ; //X3_TITSPA
   'Status      ' , ; //X3_TITENG
   'Status                   ' , ; //X3_DESCRIC
   'Status                   ' , ; //X3_DESCSPA
   'Status                   ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '29' , ; //X3_ORDEM
   'ZA0_HIST  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    254 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Historico   ' , ; //X3_TITULO
   'Historico   ' , ; //X3_TITSPA
   'Historico   ' , ; //X3_TITENG
   'Historico do Titulo      ' , ; //X3_DESCRIC
   'Historico do Titulo      ' , ; //X3_DESCSPA
   'Historico do Titulo      ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '30' , ; //X3_ORDEM
   'ZA0_NOMSOL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    30 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Nom.Solicit.' , ; //X3_TITULO
   'Nom.Solicit.' , ; //X3_TITSPA
   'Nom.Solicit.' , ; //X3_TITENG
   'Nome de solicitante      ' , ; //X3_DESCRIC
   'Nome de solicitante      ' , ; //X3_DESCSPA
   'Nome de solicitante      ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZA2_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    1 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   ' ' , ; //X3_VISUAL
   ' ' , ; //X3_CONTEXT
    Chr(032) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '033' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   ' ' , ; //X3_ORTOGRA
   ' ' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZA2_CODIGO' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Codigo      ' , ; //X3_TITULO
   'Codigo      ' , ; //X3_TITSPA
   'Codigo      ' , ; //X3_TITENG
   'Codigo                   ' , ; //X3_DESCRIC
   'Codigo                   ' , ; //X3_DESCSPA
   'Codigo                   ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZA2_NATURE' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Natureza    ' , ; //X3_TITULO
   'Natureza    ' , ; //X3_TITSPA
   'Natureza    ' , ; //X3_TITENG
   'Codigo da natureza       ' , ; //X3_DESCRIC
   'Codigo da natureza       ' , ; //X3_DESCSPA
   'Codigo da natureza       ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SED   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZA2_DESCRI' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    30 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Descricao   ' , ; //X3_TITULO
   'Descricao   ' , ; //X3_TITSPA
   'Descricao   ' , ; //X3_TITENG
   'Descricao da natureza    ' , ; //X3_DESCRIC
   'Descricao da natureza    ' , ; //X3_DESCSPA
   'Descricao da natureza    ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'IIF(INCLUI,' + SIMPLES + '' + SIMPLES + ',POSICIONE(' + SIMPLES + 'SED' + SIMPLES + ',1,XFILIAL(' + SIMPLES + 'SED' + SIMPLES + ')+ZA2->ZA2_NATURE, ' + SIMPLES + 'ED_DESCRIC' + SIMPLES + '))                                                  ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'V' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   'POSICIONE(' + SIMPLES + 'SED' + SIMPLES + ',1,XFILIAL(' + SIMPLES + 'SED' + SIMPLES + ')+ZA2->ZA2_NATURE, ' + SIMPLES + 'ED_DESCRIC' + SIMPLES + ')                 ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZA2_PERC  ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   '% Narureza  ' , ; //X3_TITULO
   '% Narureza  ' , ; //X3_TITSPA
   '% Narureza  ' , ; //X3_TITENG
   '% Narureza               ' , ; //X3_DESCRIC
   '% Narureza               ' , ; //X3_DESCSPA
   '% Narureza               ' , ; //X3_DESCENG
   '@E 999.99                                    ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA2' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZA2_VLRNAT' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Vlr Natureza' , ; //X3_TITULO
   'Vlr Natureza' , ; //X3_TITSPA
   'Vlr Natureza' , ; //X3_TITENG
   'Valor da Natureza        ' , ; //X3_DESCRIC
   'Valor da Natureza        ' , ; //X3_DESCSPA
   'Valor da Natureza        ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZA3_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    1 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   ' ' , ; //X3_VISUAL
   ' ' , ; //X3_CONTEXT
    Chr(032) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '033' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   ' ' , ; //X3_ORTOGRA
   ' ' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZA3_CODIGO' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Codigo      ' , ; //X3_TITULO
   'Codigo      ' , ; //X3_TITSPA
   'Codigo      ' , ; //X3_TITENG
   'Codigo                   ' , ; //X3_DESCRIC
   'Codigo                   ' , ; //X3_DESCSPA
   'Codigo                   ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZA3_NATURE' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Natureza    ' , ; //X3_TITULO
   'Natureza    ' , ; //X3_TITSPA
   'Natureza    ' , ; //X3_TITENG
   'Codigo da Natureza       ' , ; //X3_DESCRIC
   'Codigo da Natureza       ' , ; //X3_DESCSPA
   'Codigo da Natureza       ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZA3_CC    ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    9 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'C.Custo     ' , ; //X3_TITULO
   'C.Custo     ' , ; //X3_TITSPA
   'C.Custo     ' , ; //X3_TITENG
   'Centro de Custo          ' , ; //X3_DESCRIC
   'Centro de Custo          ' , ; //X3_DESCSPA
   'Centro de Custo          ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'CTT   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   'Vazio() .or. CTB105CC()                                                                                                         ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZA3_DESCC ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    40 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Desc.CC.    ' , ; //X3_TITULO
   'Desc.CC.    ' , ; //X3_TITSPA
   'Desc.CC.    ' , ; //X3_TITENG
   'Desc. do Centro de custo ' , ; //X3_DESCRIC
   'Desc. do Centro de custo ' , ; //X3_DESCSPA
   'Desc. do Centro de custo ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'IF(INCLUI,' + SIMPLES + ' ' + SIMPLES + ',POSICIONE( ' + SIMPLES + 'CTT' + SIMPLES + ', 1, XFILIAL(' + SIMPLES + 'CTT' + SIMPLES + ') + ZA3->ZA3_CC, ' + SIMPLES + 'CTT_DESC01' + SIMPLES + '))                                                 ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'V' , ; //X3_VISUAL
   'V' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   'POSICIONE( ' + DUPLAS + 'CTT' + DUPLAS + ', 1, XFILIAL(' + DUPLAS + 'CTT' + DUPLAS + ') + ZA3->ZA3_CC, ' + DUPLAS + 'CTT_DESC01' + DUPLAS + ')                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZA3_PERC  ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   '% Rateio    ' , ; //X3_TITULO
   '% Rateio    ' , ; //X3_TITSPA
   '% Rateio    ' , ; //X3_TITENG
   '% Rateio                 ' , ; //X3_DESCRIC
   '% Rateio                 ' , ; //X3_DESCSPA
   '% Rateio                 ' , ; //X3_DESCENG
   '@E 999.99                                    ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZA3_ITEMCT' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    9 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Item Conta  ' , ; //X3_TITULO
   'Item Conta  ' , ; //X3_TITSPA
   'Item Conta  ' , ; //X3_TITENG
   'Item Conta               ' , ; //X3_DESCRIC
   'Item Conta               ' , ; //X3_DESCSPA
   'Item Conta               ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'CTD   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'Ctb105Item()                                                                                                                    ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA3' , ; //X3_ARQUIVO
   '08' , ; //X3_ORDEM
   'ZA3_VLRRAT' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    16 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Vlr Rateio  ' , ; //X3_TITULO
   'Vlr Rateio  ' , ; //X3_TITSPA
   'Vlr Rateio  ' , ; //X3_TITENG
   'Valor do rateio          ' , ; //X3_DESCRIC
   'Valor do rateio          ' , ; //X3_DESCSPA
   'Valor do rateio          ' , ; //X3_DESCENG
   '@E 9,999,999,999,999.99                      ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(128) , ; //X3_OBRIGAT
   '                                                                                                                                ' , ; //X3_VLDUSER
   '                                                                                                                                ' , ; //X3_CBOX
   '                                                                                                                                ' , ; //X3_CBOXSPA
   '                                                                                                                                ' , ; //X3_CBOXENG
   '                    ' , ; //X3_PICTVAR
   '                                                            ' , ; //X3_WHEN
   '                                                                                ' , ; //X3_INIBRW
   '   ' , ; //X3_GRPSXG
   ' ' , ; //X3_FOLDER
   ' ' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' '  } ) //X3_MODAL


// ----------------------
// Atualizando Dicionário
// ----------------------

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ARQUIVO' } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ORDEM'   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_CAMPO'   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_TAMANHO' } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_GRPSXG'  } )
nPosPRO := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_PROPRI'  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )


dbSelectArea( 'SX3' )
dbSetOrder( 2 )
cAliasAtu := ''

For nI := 1 To Len( aSX3 )

   cPro := ''

   //  ---------------------------------------------------------
   // Verifica se o campo faz parte de um grupo e ajusta tamanho
   //  ---------------------------------------------------------
   If !Empty(nPosSXG) .And. !Empty(nPosTam) .And. NotNull(aSX3[nI][nPosTam]) .And. NotNull(aSX3[nI][nPosSXG])
      SXG->( dbSetOrder( 1 ) )
      If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
         If aSX3[nI][nPosTam] <> SXG->XG_SIZE
            aSX3[nI][nPosTam] := SXG->XG_SIZE
            LogAdd( @aTexto , 'O tamanho do campo ' + aSX3[nI][nPosCpo] + ' no compatibilizador foi ignorado !' )
            LogAdd( @aTexto , 'O mesmo foi mantido em [' + AllTrim( Str( SXG->XG_SIZE ) ) + ']' )
            LogAdd( @aTexto , 'Por pertencer ao grupo de campos [' + SX3->X3_GRPSXG + ']' )
            LogAdd( @aTexto , '' )
         EndIf
      EndIf
   EndIf

   DbSelectArea('SX3')
   DbSetOrder(2)
   If !SX3->( dbSeek( cAudiReg := PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

      If !CanAdd(aEstrut,aSX3[nI])
         LogAdd( @aTexto , 'Warning.: Campo ' + aSX3[nI][nPosCpo] + ' nao pode ser inserido por falta de dados no compatibilizador !')
         Loop
      EndIf

      //----------------------------
      //Obtem a Propriedade do Campo
      //----------------------------
      If Empty(cPro) ; cPro := aSX3[nI][nPosPro] ; EndIf

      //-------------------------------
      //Busca ultima ocorrencia do alias
      //-------------------------------
      If ( aSX3[nI][nPosArq] <> cAliasAtu )
         cSeqAtu   := '00'
         cAliasAtu := aSX3[nI][nPosArq]

         dbSetOrder( 1 )
         SX3->( dbSeek( cAliasAtu + 'ZZ', .T. ) )
         dbSkip( -1 )

         If ( SX3->X3_ARQUIVO == cAliasAtu )
            cSeqAtu := SX3->X3_ORDEM
         EndIf

         nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
      EndIf

      nSeqAtu++
      cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

      RecLock( 'SX3', .T. )
      LogAdd( @aTexto , 'Criado o campo ' + aSX3[nI][nPosCpo] )
      For nJ := 1 To Len( aSX3[nI] )
         If nJ == 2    // Ordem
            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=cSeqAtu )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX3' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) , cPro } )
            LogAdd( @aTexto , 'Propriedade SX3 ' + aEstrut[nJ] + ' definida com o valor ' + AllTrim(AllToChar(aAudiVal[2])) )
         ElseIf (FieldPos( aEstrut[nJ] ) > 0) .And. NotNull(aSX3[nI][nJ])
            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSX3[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX3' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) , cPro } )
            LogAdd( @aTexto , 'Propriedade SX3 ' + aEstrut[nJ] + ' definida com o valor ' + AllTrim(AllToChar(aAudiVal[2])) )
         EndIf
      Next nJ

      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         If Empty(aScan(aArqUpd,aSX3[nI][nPosArq]))
            aAdd( aArqUpd, aSX3[nI][nPosArq] ) 
         EndIf
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   Else

      //----------------------------
      //Obtem a Propriedade do Campo
      //----------------------------
      If Empty(cPro) ; cPro := aSX3[nI][nPosPro] ; EndIf

      //  -----------------------
      // Verifica todos os campos
      //  -----------------------
      For nJ := 1 To Len( aSX3[nI] )

         //  ----------------------------------------
         // Se o campo estiver diferente da estrutura
         //  ----------------------------------------
         If NotNull(aSX3[nI][nJ]) .And. ;
            aEstrut[nJ] == SX3->( FieldName( FieldPos(aEstrut[nJ]) ) ) .And. ;
            PadR( StrTran( AllToChar( SX3->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )    , ' ', '' ), 250 ) <>  ;
            PadR( StrTran( AllToChar( aSX3[nI][nJ] )                                         , ' ', '' ), 250 ) .And. ;
            If( lOrd , .T. , AllTrim( SX3->( FieldName( FieldPos(aEstrut[nJ]) ) ) ) <> 'X3_ORDEM' )

            LogAdd( @aTexto , 'Alterado o campo ' + aSX3[nI][nPosCpo] + '   ' + PadR( SX3->( FieldName( FieldPos(aEstrut[nJ]) ) ), 10 ) ) 
            LogAdd( @aTexto , 'De [' + RTrim( AllToChar( aAudiVal[1]:=SX3->( FieldGet( FieldPos(aEstrut[nJ]) ) ) ) ) + ']' + ' para [' + RTrim( AllToChar( aAudiVal[2]:=aSX3[nI][nJ] ) ) + ']' )

            RecLock( 'SX3', .F. )
            FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
            dbCommit()
            MsUnLock()

            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX3' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) , cPro } )

         EndIf

      Next nJ

      If !Empty( aAuditDic )
         If Empty(aScan(aArqUpd,aSX3[nI][nPosArq]))
            aAdd( aArqUpd, aSX3[nI][nPosArq] ) 
         EndIf
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   EndIf

   oProcess:IncRegua2( 'Atualizando Campos (SX3)...' )

Next nI

//------------------------------------------------------------------ 
//     Verifica se todos os campos existem no Banco de Dados             
//------------------------------------------------------------------ 
For nI := 1 To Len( aSX3 )
   If Empty( aScan( aArqUpd , aSX3[nI][nPosArq] ) )
      If !CheckCol( aSX3[nI][nPosCpo] , Left(Right(RetSQLName(aSX3[nI][nPosArq]),3),2) )
         aAdd( aArqUpd , aSX3[nI][nPosArq] )
      EndIf
   EndIf
Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SX3' )
LogAdd( @aTexto , Replicate( '-', 128 ) )

Return( .T. )


