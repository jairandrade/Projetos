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
/*/{Protheus.doc} 21935620
description Funcao de processamento da gravacao do SX2 - Arquivos
@author Kaique Mathias    
@since 16/04/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 21935620( aTexto , cEmpr )

Local aEstrut      := {}
Local aSX2Temp     := {}
Local aSX2         := {}
Local cPath        := ''
Local nI           := 0
Local nJ           := 0
Local nPosModoUn   := 0
Local nPosModoEmp  := 0

dbSelectArea( 'SX2' )
dbSetOrder( 1 )

nPosModoUn := SX2->(FieldPos('X2_MODOUN'))
nPosModoEmp:= SX2->(FieldPos('X2_MODOEMP'))

LogAdd( @aTexto , 'Inicio da Atualizacao do SX2' )

aAdd( aEstrut , 'X2_CHAVE' )
aAdd( aEstrut , 'X2_PATH' )
aAdd( aEstrut , 'X2_ARQUIVO' )
aAdd( aEstrut , 'X2_NOME' )
aAdd( aEstrut , 'X2_NOMESPA' )
aAdd( aEstrut , 'X2_NOMEENG' )
aAdd( aEstrut , 'X2_ROTINA' )
aAdd( aEstrut , 'X2_MODO' )

If nPosModoUn > 0
   aAdd( aEstrut , 'X2_MODOUN' ) 
EndIf

If nPosModoEmp > 0
   aAdd( aEstrut , 'X2_MODOEMP' ) 
EndIf

aAdd( aEstrut , 'X2_DELET' )
aAdd( aEstrut , 'X2_TTS',  )
aAdd( aEstrut , 'X2_UNICO' )
aAdd( aEstrut , 'X2_PYME' )
aAdd( aEstrut , 'X2_MODULO' )
aAdd( aEstrut , 'X2_DISPLAY' )

SX2->( dbGoTop() )
cPath := SX2->X2_PATH

aSX2Temp := {}

aAdd( aSX2Temp , 'Z99' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'Z99020  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'Solicitantes Pgto Manual      ' )     //X2_NOME
aAdd( aSX2Temp , 'Solicitantes Pgto Manual      ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'Solicitantes Pgto Manual      ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'E' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOUN 
EndIf

If nPosModoEmp > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOEMP
EndIf
aAdd( aSX2Temp ,  0  )    //X2_DELET  
aAdd( aSX2Temp , ' ' )  //X2_TTS    
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                          ' )  //X2_UNICO  
aAdd( aSX2Temp , ' ' )  //X2_PYME   
aAdd( aSX2Temp ,  0  )   //X2_MODULO 
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                              ' )  //X2_DISPLAY

aAdd( aSX2 , aSX2Temp )

aSX2Temp := {}

aAdd( aSX2Temp , 'ZA0' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZA0020  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'Solicitacao de Pagamento      ' )     //X2_NOME
aAdd( aSX2Temp , 'Solicitacao de Pagamento      ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'Solicitacao de Pagamento      ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'E' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOUN 
EndIf

If nPosModoEmp > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOEMP
EndIf
aAdd( aSX2Temp ,  0  )    //X2_DELET  
aAdd( aSX2Temp , ' ' )  //X2_TTS    
aAdd( aSX2Temp , 'ZA0_FILIAL+ZA0_CODIGO                                                                                                                                                                                                                     ' )  //X2_UNICO  
aAdd( aSX2Temp , ' ' )  //X2_PYME   
aAdd( aSX2Temp ,  0  )   //X2_MODULO 
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                              ' )  //X2_DISPLAY

aAdd( aSX2 , aSX2Temp )

aSX2Temp := {}

aAdd( aSX2Temp , 'ZA2' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZA2020  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'Mult. Nat. Solic. De Pagamento' )     //X2_NOME
aAdd( aSX2Temp , 'Mult. Nat. Solic. De Pagamento' )     //X2_NOMESPA
aAdd( aSX2Temp , 'Mult. Nat. Solic. De Pagamento' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'E' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOUN 
EndIf

If nPosModoEmp > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOEMP
EndIf
aAdd( aSX2Temp ,  0  )    //X2_DELET  
aAdd( aSX2Temp , ' ' )  //X2_TTS    
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                          ' )  //X2_UNICO  
aAdd( aSX2Temp , ' ' )  //X2_PYME   
aAdd( aSX2Temp ,  0  )   //X2_MODULO 
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                              ' )  //X2_DISPLAY

aAdd( aSX2 , aSX2Temp )

aSX2Temp := {}

aAdd( aSX2Temp , 'ZA3' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZA3020  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'Natureza x Centro de Custo    ' )     //X2_NOME
aAdd( aSX2Temp , 'Natureza x Centro de Custo    ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'Natureza x Centro de Custo    ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'E' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOUN 
EndIf

If nPosModoEmp > 0
aAdd( aSX2Temp , 'E' )    //X2_MODOEMP
EndIf
aAdd( aSX2Temp ,  0  )    //X2_DELET  
aAdd( aSX2Temp , ' ' )  //X2_TTS    
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                          ' )  //X2_UNICO  
aAdd( aSX2Temp , ' ' )  //X2_PYME   
aAdd( aSX2Temp ,  0  )   //X2_MODULO 
aAdd( aSX2Temp , '                                                                                                                                                                                                                                                              ' )  //X2_DISPLAY

aAdd( aSX2 , aSX2Temp )


// ----------------------
// Atualizando Dicionário
// ----------------------

For nI := 1 To Len( aSX2 )

   If !SX2->( dbSeek( cAudiReg := aSX2[nI][1] ) )

      If !CanAdd(aEstrut,aSX2[nI])
         LogAdd( @aTexto , 'Warning.: Tabela ' + aSIX[nI][1] + ' nao pode ser inserida por falta de dados no compatibilizador !')
         Loop
      EndIf

      RecLock( 'SX2', .T. )
      For nJ := 1 To Len( aSX2[nI] )
         If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX2[nI][nJ]) 

              If aEstrut[nJ] = 'X2_PATH' 
               FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=cPath ) 
               aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX2' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
              ElseIf aEstrut[nJ] = 'X2_ARQUIVO' 
               FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=Left(aSX2[nI][nJ],3) + cEmpr + '0' ) 
               aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX2' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
              Else 
               FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSX2[nI][nJ] )
               aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX2' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
              EndIf 

         EndIf
      Next nJ
      dbCommit()
      MsUnLock()


      If !Empty( aAuditDic )
         If Empty(aScan(aArqUpd,aSX2[nI][1]))
            aAdd( aArqUpd, aSX2[nI][1] ) 
         EndIf
         LogAdd( @aTexto , 'Foi incluida a tabela ' + aSX2[nI][1] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf


     Else

         RecLock( 'SX2', .F. )
         For nJ := 1 To Len( aSX2[nI] )
            If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX2[nI][nJ]) 

                 If aEstrut[nJ] = 'X2_PATH' .And. ;
                  PadR( StrTran( AllToChar( aAudiVal[1]:=SX2->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )  , ' ' , '' ), 250 ) <> ;
                  PadR( StrTran( AllToChar( aAudiVal[2]:=cPath )                                       , ' ' , '' ), 250 ) 
                  FieldPut( FieldPos( aEstrut[nJ] ), cPath ) 
                  aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX2' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
                 ElseIf aEstrut[nJ] = 'X2_ARQUIVO' .And. ;
                  PadR( StrTran( AllToChar( aAudiVal[1]:=SX2->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )  , ' ' , '' ), 250 ) <> ;
                  PadR( StrTran( AllToChar( aAudiVal[2]:=Left(aSX2[nI][nJ],3) + cEmpr + '0' )          , ' ' , '' ), 250 ) 
                  FieldPut( FieldPos( aEstrut[nJ] ), Left(aSX2[nI][nJ],3) + cEmpr + '0' ) 
                  aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX2' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
                 ElseIf aEstrut[nJ] <> 'X2_ARQUIVO' .And.  1=1 .And. ;
                  PadR( StrTran( AllToChar( aAudiVal[1]:=SX2->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )  , ' ' , '' ), 250 ) <> ;
                  PadR( StrTran( AllToChar( aAudiVal[2]:=aSX2[nI][nJ] )                                , ' ' , '' ), 250 ) 
                  FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
                  aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX2' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
               EndIf 

            EndIf
         Next nJ
         dbCommit()
         MsUnLock()

         If !Empty( aAuditDic )
            If Empty(aScan(aArqUpd,aSX2[nI][1]))
               aAdd( aArqUpd, aSX2[nI][1] ) 
            EndIf
            LogAdd( @aTexto , 'Foi atualizada a tabela ' + aSX2[nI][1] )
            AuditDic( @aAuditDic , @aTexto )
         EndIf

   EndIf

   oProcess:IncRegua2( 'Atualizando Arquivos (SX2)...')

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SX2' )
LogAdd( @aTexto , Replicate( '-', 128 ) )

Return( .T. )

