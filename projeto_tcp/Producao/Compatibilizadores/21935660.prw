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
/*/{Protheus.doc} 21935660
description uncao de processamento da gravacao do SX6 - Parâmetros
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 21935660( aTexto , aFils )

Local aEstrut   := {}
Local aSX6Temp  := {}
Local aSX6      := {}
Local cFilPar   := ''
Local lReclock  := .T.
Local nI        := 0
Local nJ        := 0
Local nY        := 0

Default aFils   := {1}

LogAdd( @aTexto , 'Inicio da Atualizacao do SX6' )
aEstrut := { 'X6_FIL', ; 
             'X6_VAR', ; 
             'X6_TIPO', ; 
             'X6_DESCRIC', ; 
             'X6_DSCSPA', ; 
             'X6_DSCENG', ; 
             'X6_DESC1', ; 
             'X6_DSCSPA1', ; 
             'X6_DSCENG1', ; 
             'X6_DESC2', ; 
             'X6_DSCSPA2', ; 
             'X6_DSCENG2', ; 
             'X6_CONTEUD', ; 
             'X6_CONTSPA', ; 
             'X6_CONTENG', ; 
             'X6_PROPRI', ; 
             'X6_PYME', ; 
             'X6_VALID', ; 
             'X6_INIT', ; 
             'X6_DEFPOR', ; 
             'X6_DEFSPA', ; 
             'X6_DEFENG' } 


aSX6Temp := {}
If NotNull('  ') .And. Len('  ') <>  _nTamFil
   If Empty('  ')
         //Ajusta o tamanho em espacos
       aAdd( aSX6Temp , Space(_nTamFil) )  //X6_FIL
   Else
      //Pega a filial desta empresa que estou posicionado
      aAdd( aSX6Temp , cFilAnt )   //X6_FIL
   EndIf
Else
   aAdd( aSX6Temp , '  ' )  //X6_FIL
EndIf
aAdd( aSX6Temp , 'TCP_TPTIEX' )  //X6_VAR
aAdd( aSX6Temp , 'C' )  //X6_TIPO
aAdd( aSX6Temp , 'Indica quais os tipos de titulos que nao deversao ' )  //X6_DESCRIC
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG
aAdd( aSX6Temp , 'ser considerados na regra dos 13 dias de venciment' )  //X6_DESC1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG1
aAdd( aSX6Temp , 'o real.                                           ' )  //X6_DESC2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG2
aAdd( aSX6Temp , 'FOL;FER;JPY;INS;TX ;ISS;RES;VTR;PEN;                                                                                                                                                                                                                      ' )  //X6_CONTEUD
aAdd( aSX6Temp , 'FOL;FER;                                                                                                                                                                                                                                                  ' )  //X6_CONTSPA
aAdd( aSX6Temp , 'FOL;FER;                                                                                                                                                                                                                                                  ' )  //X6_CONTENG
aAdd( aSX6Temp , 'U' )  //X6_PROPRI
aAdd( aSX6Temp , ' ' )  //X6_PYME
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_VALID
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_INIT
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFPOR
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFSPA
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFENG
aAdd( aSX6 , aSX6Temp )

aSX6Temp := {}
If NotNull('  ') .And. Len('  ') <>  _nTamFil
   If Empty('  ')
         //Ajusta o tamanho em espacos
       aAdd( aSX6Temp , Space(_nTamFil) )  //X6_FIL
   Else
      //Pega a filial desta empresa que estou posicionado
      aAdd( aSX6Temp , cFilAnt )   //X6_FIL
   EndIf
Else
   aAdd( aSX6Temp , '  ' )  //X6_FIL
EndIf
aAdd( aSX6Temp , 'TCP_MAILPA' )  //X6_VAR
aAdd( aSX6Temp , 'C' )  //X6_TIPO
aAdd( aSX6Temp , 'E-mails que serao notificados da aprovacao ou reje' )  //X6_DESCRIC
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG
aAdd( aSX6Temp , 'icao de pagamentos                                ' )  //X6_DESC1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG1
aAdd( aSX6Temp , '                                                  ' )  //X6_DESC2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG2
aAdd( aSX6Temp , '                                                                                                                                                                                                     ' )  //X6_CONTEUD
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_CONTSPA
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_CONTENG
aAdd( aSX6Temp , 'U' )  //X6_PROPRI
aAdd( aSX6Temp , ' ' )  //X6_PYME
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_VALID
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_INIT
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFPOR
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFSPA
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFENG
aAdd( aSX6 , aSX6Temp )
// ----------------------
// Atualizando Dicionário
// ----------------------

dbSelectArea( 'SX6' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )

   For nY    := 1 To Len( aFils )

      cFilPar := If(lChkPar,aFils[nY],aSX6[nI][1])

      If !SX6->( dbSeek( cAudiReg := cFilPar + aSX6[nI][2] ) )
         If !CanAdd(aEstrut,aSX6[nI])
            LogAdd( @aTexto , 'Warning.: Parametro ' + cFilPar + '/' + aSX6[nI][2] + ' nao pode ser inserido por falta de dados no compatibilizador !')
            Loop
         EndIf

         RecLock( 'SX6', .T. )

         For nJ := 1 To Len( aSX6[nI] )

            If nJ = 1    //Filial
               FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=cFilPar )
               aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX6' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
            Else
               If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX6[nI][nJ])
                  FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSX6[nI][nJ] )
                  aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX6' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
               EndIf

            EndIf

         Next nJ

         dbCommit()
         MsUnLock()

         If !Empty( aAuditDic )
            LogAdd( @aTexto , 'Foi incluido o parametro ' + cFilPar + '/' + aSX6[nI][2] )
            AuditDic( @aAuditDic , @aTexto )
         EndIf

      Else

         RecLock( 'SX6', .F. )

         //Comeco do 3 pois o 1 eh filial e o 2 eh o parametro, e foi encontrado, entao sao iguais.
         For nJ := 3 To Len( aSX6[nI] )

            If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX6[nI][nJ]) .And. ;
               PadR( StrTran( AllToChar( aAudiVal[1]:=SX6->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )    , ' ' , '' ), 250 ) <> ;
               PadR( StrTran( AllToChar( aAudiVal[2]:=aSX6[nI][nJ] )                                , ' ' , '' ), 250 ) 
               FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
               aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX6' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
            EndIf

         Next nJ

         dbCommit()
         MsUnLock()

         If !Empty( aAuditDic )
            LogAdd( @aTexto , 'Foi alterado o parametro ' + cFilPar + '/' + aSX6[nI][2] )
            AuditDic( @aAuditDic , @aTexto )
         EndIf

      EndIf
   Next nY

   oProcess:IncRegua2( 'Atualizando Parâmetros (SX6)...')

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SX6' )
LogAdd( @aTexto , Replicate( '-', 128 ) )

Return( .T. )