#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )


//-------------------------------------------------------------------
/*/{Protheus.doc} 202024  
description Funcao de update dos dicion�rios para compatibiliza��o
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 202024()

Local aSay         := {}
Local aButton      := {}
Local aMarcadas    := {}
Local lExclu       := .F.
Local cTitulo      := '202024 - Atualiza��o de dicion�rios e Tabelas'
Local cDesc1       := 'Esta rotina tem como objetivo realizar a atualiza��o  dos dicion�rios do Sistema ( SX?/SIX )'
Local cDesc2       := Replicate('-',110)
Local cDesc3       := 'Esta atualiza��o ' + if(lExclu,'deve','pode') + ' ser executada em modo [ ** ' + if(lExclu,'E X C L U S I V O','C O M P A R T I L H A D O') + ' ** ]'
Local cDesc4       := Replicate('-',110)
Local cDesc5       := '[DIVERSOS] :SX1'
Local cDesc6       := Replicate('-',110)
Local cDesc7       := '*******  [  Fa�a sempre BACKUP antes de aplicar qualquer compatibilizador  ]  *******'
Local cLibCli      := ''
Local lOk          := .F.

Private cDevName   := 'Kaique Mathias    '
Private cTicket    := '202024'
Private lAuditDic  := .F.
Private aAudiVal   := {,}
Private cAudiReg   := '' 
Private cTimeIni   := '' 
Private cTimeFim   := '' 
Private lOpen
Private lMacOS     := (GetRemoteType(@cLibCli),('MAC' $ cLibCli))
Private cComando   := If(lMacOS,'Open ','Cmd /c Start ')

Private oMainWnd   := Nil
Private oProcess   := Nil
Private cFixEmp    := '??'
Private lChkOrd    := .F.
Private lChkPar    := .F.
Private lChkTod    := .F.
Private cEmpSel    := ''
Private _nTamFil   := 0 

#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := Nil
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
aAdd( aSay, cDesc6 )
aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk

   aMarcadas := EscEmpresa(lExclu)

   If !Empty( aMarcadas )
      If  ApMsgNoYes( 'Confirma a atualiza��o dos dicion�rios ?', cTitulo )

         oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lExclu ) }, cTicket + ' - Atualizando', 'Aguarde, atualizando ...', .F. )
         oProcess:Activate()

         If !lOk
            MsgStop( 'Atualiza��o n�o Realizada.' )
         EndIf

      Else
         MsgStop( 'Atualiza��o n�o Realizada.' )
      EndIf
   Else
      MsgStop( 'Voc� n�o selecionou nenhuma empresa !' )
   EndIf

EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
description Funcao de processamento da grava��o dos arquivos
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lExclu )

Local   aTexto    := {}
Local   aLog      := {}
Local   cFile     := ''
Local   cSave     := ''
Local   cFileLog  := ''
Local   cAux      := ''
Local   cMask     := 'Arquivos Texto (*.LOG)|*.log|'
Local   nRecno    := 0
Local   nI        := 0
Local   nX        := 0
Local   nZ        := 0
Local   nPos      := 0
Local   aRecnoSM0 := {}
Local   aInfo     := {}
Local   lOpen     := .F.
Local   lRet      := .T.
Local   oDlg      := Nil
Local   oMemo     := Nil
Local   oFont     := Nil
Local   lAlertLog := .F.

Private aArqUpd   := {}
Private aAuditDic := {}

//Marca a hora de inicio do compatibilizador
cTimeIni := Time()

If ( lOpen := MyOpenSm0Ex(lExclu) )

   dbSelectArea( 'SM0' )
   dbGoTop()

   While !SM0->( EOF() )
      // So adiciona no aRecnoSM0 se tiver sido escolhida e ainda nao estiver no array
      If Empty( nZ := aScan( aRecnoSM0, { |x| x[1] == SM0->M0_CODIGO } )) .And. (aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0)
            aAdd( aRecnoSM0, { SM0->M0_CODIGO , SM0->M0_CODFIL , SM0->M0_NOME , {} } )
            cEmpSel += If(Empty(cEmpSel),'','-') + SM0->M0_CODIGO
            nZ := Len(aRecnoSM0)
      EndIf

      If !Empty(nZ)
         aAdd( aRecnoSM0[nZ][4] , AllTrim(SM0->M0_CODFIL) )
      EndIf

      SM0->( dbSkip() )
   End

   If lOpen

      oProcess:SetRegua1( ( Len(aRecnoSM0) * DefRegua(1) ) )
      oProcess:SetRegua2( DefRegua(2) )

      For nI := 1 To Len( aRecnoSM0 )

         aArqUpd := {} 

         RpcSetType( 2 )
         RpcSetEnv( aRecnoSM0[nI][1] , aRecnoSM0[nI][2] , 'administrador' )

         lMsFinalAuto := .F.
         lMsHelpAuto  := .F.

         LogAdd( @aTexto , Replicate( '-', 128 ) )
         LogAdd( @aTexto , 'Empresa : ' + aRecnoSM0[nI][1] + '/' + aRecnoSM0[nI][3] )

         _nTamFil := Len(AllTrim(aRecnoSM0[nI][2]))


         //����������������������������������Ŀ
         //�Atualiza o dicion�rio SX1         �
         //������������������������������������
         oProcess:IncRegua1( 'Dicion�rio SX1 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x| AT00SX1(@x) }')
         Eval( bBloco , aTexto )


         //------------------------------
         // Alteracao fisica dos arquivos
         //------------------------------
         __SetX31Mode( .F. )
         oProcess:SetRegua2( DefRegua(2) )

         For nX := 1 To Len( aArqUpd )

            //Se a Tabela for encontrada neste array, significa que alguma empresa anterior
            //aponta para ela e ja fez toda aplicacao das alteracoes, pulo sem fazer nada
            If !(SubStr(RetSQLName(aArqUpd[nx]),4,2)==aRecnoSM0[nI][1]) .AND. (SubStr(RetSQLName(aArqUpd[nx]),4,2) == '10' .And. aRecnoSM0[nI][1] <> '01')
               oProcess:IncRegua2('Aplicando altera��es na base de dados...')
               Loop
            EndIf

            If Select( aArqUpd[nx] ) > 0
               dbSelectArea( aArqUpd[nx] )
               dbCloseArea()
            EndIf

            X31UpdTable( aArqUpd[nx] )

            If __GetX31Error()
               LogAdd( @aTexto , 'Erro.: Ocorreu um erro desconhecido durante a atualiza��o da estrutura da tabela : ' + aArqUpd[nx] )
               LogAdd( @aTexto , __GetX31Trace() )
            Else
               ChkFile(aArqUpd[nx])
               DbSelectArea(aArqUpd[nx])
            EndIf

            oProcess:IncRegua2('Aplicando altera��es na base de dados...')

         Next nX

         __SetX31Mode( .T. )

         If nI = Len( aRecnoSM0 )
            LibTable( @aTexto )
         EndIf

         RpcClearEnv()

         If !( lOpen := MyOpenSm0Ex(lExclu) )
            lRet := .F.
            Exit
         EndIf

      Next nI

      //Marca a hora Fim do compatibilizador
      cTimeFim := Time()

      If lOpen

         If !Empty(aTexto) .And. ValType(aTexto[1])=='C'
            aTexto := {aTexto}
         EndIf

         For nI := 1 To Len(aTexto)
            For nZ := 1 To Len(aTexto[nI])
               If (lAlertLog := ('warning.' $ lower(aTexto[nI][nZ])) .Or. ('erro.' $ lower(aTexto[nI][nZ])))
                  Exit
               EndIf
            Next nZ
         Next nI

         aSize( aTexto , Len(aTexto)+1 )
         aIns( aTexto , 1 )
         aTexto[1] := {}

         aAdd( aTexto[1] , Replicate( '-', 128 ) )
         aAdd( aTexto[1] , 'LOG DA ATUALIZACAO DOS DICIONARIOS' )
         aAdd( aTexto[1] , Replicate( '-', 128 ) )

         aAdd( aTexto[1] , ' Dados Ambiente'        )
         aAdd( aTexto[1] , ' --------------------'  )
         aAdd( aTexto[1] , ' Data/Hora Inicio ..:' + cTimeIni )
         aAdd( aTexto[1] , ' Data/Hora Fim......: ' + cTimeFim )
         aAdd( aTexto[1] , ' Duracao............: ' + ElapTime(cTimeIni,cTimeFim) )
         aAdd( aTexto[1] , ' Environment........: ' + GetEnvServer() )
         aAdd( aTexto[1] , ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' ) )
         aAdd( aTexto[1] , ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' ) )
         aAdd( aTexto[1] , ' Versao.............: ' + GetVersao(.T.) )
         aAdd( aTexto[1] , ' Usuario Microsiga..: ' + If(Empty(__cUserID),'000000 Administrador', __cUserId + ' ' +  cUserName) )
         aAdd( aTexto[1] , ' Computer Name......: ' + GetComputerName() )

         aInfo   := GetUserInfo()
         If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
            aAdd( aTexto[1] , ' '  + CRLF )
            aAdd( aTexto[1] , ' Dados Thread' )
            aAdd( aTexto[1] , ' --------------------' )
            aAdd( aTexto[1] , ' Usuario da Rede....: ' + aInfo[nPos][1] )
            aAdd( aTexto[1] , ' Estacao............: ' + aInfo[nPos][2] )
            aAdd( aTexto[1] , ' Programa Inicial...: ' + aInfo[nPos][5] )
            aAdd( aTexto[1] , ' Environment........: ' + aInfo[nPos][6] )
            aAdd( aTexto[1] , ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) ) )
         EndIf

         aAdd( aTexto[1] , ' '  + CRLF )
         aAdd( aTexto[1] , ' Parametros de execucao' )
         aAdd( aTexto[1] , ' ----------------------' )
         aAdd( aTexto[1] , ' Modo do Compat.....: ' + If(lExclu,'Exclusivo','Compartilhado') )
         aAdd( aTexto[1] , ' Check Todos........: ' + If(lChkTod,'.T.','.F.') )
         aAdd( aTexto[1] , ' Check Param p/ Fil.: ' + If(lChkPar,'.T.','.F.') )
         aAdd( aTexto[1] , ' Fixar Empresa......: ' + cFixEmp )
         aAdd( aTexto[1] , ' Check Altera Ordem.: ' + If(lChkOrd,'.T.','.F.') )
         aAdd( aTexto[1] , ' Empresas Selec.....: ' + cEmpSel )

         aAdd( aTexto[1] , ' '  + CRLF )
         aAdd( aTexto[1] , ' Para ver o LOG Completo clique no bot�o abaixo !' )

         Define Font oFont Name 'Mono AS' Size 5, 12

         oDlg    := TDialog():New( 003, 000, 340, 417, cTicket + ' - Atualizacao concluida', , , , , CLR_BLACK, CLR_WHITE, , , .T. )
         oTimer  := TTimer():New( 0, { || (If(lAlertLog,MsgStop('Aten��o...'+CRLF+'Houve erros/warnings durante a execu��o'+CRLF+'Verifique atentamente o LOG !!!'),Nil),oTimer:DeActivate()) }, oDlg )
         oBrowse := TCBrowse():New( 05 , 05, 200, 145,,{'Log de Atualiza��o - Resumo'},{100},oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,/*bValid*/,.T.,.F.)
         oBrowse:SetArray(aTexto[1])
         oBrowse:oFont := oFont
         oBrowse:AddColumn( TCColumn():New('Log de Atualiza��o'     ,{ || aTexto[1][oBrowse:nAt] },,,,'LEFT',,.F.,.T.,,,,.F.,) )

         oTBut1  := TButton():New(153,165,'Encerrar',oDlg,{|| oDlg:End()}, 040, 010, , , .F., .T., .F., , .F., , , .F. )     
         oTBut2  := TButton():New(153,125,'Salvar',oDlg,{|| (cFile:=cGetFile(cMask,'Salvar LOG',1,,.T.),If(!Empty(cFile),SaveLog(cFile,aTexto),Nil))}, 040, 010, , , .F., .T., .F., , .F., , , .F. )
         oTBut3  := TButton():New(153,005,'Ver Log Completo',oDlg,{|| (cFile:=CriaTrab(Nil,.F.)+'.Log',cSave:=GetTempPath(),SaveLog(if(lMacOS,'I:','')+cSave+cFile,aTexto),WaitRun(cComando+AllTrim(cSave+cFile),0),cFile:='')},070,010,,,.F.,.T.,.F.,,.F.,,,.F.)

         oDlg:Activate( , , , .T., { || .T. }, , { || oTimer:Activate() } )

      EndIf

   EndIf

Else

   lRet := .F.

EndIf

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} SAVELOG
description Funcao Generica para salvar o Log da Operacao do Patch
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function SaveLog(cFile,aLog)

Local nHdlLog := 0
Local nI,nZ   := 0

If At('.',cFile) = 0
   cFile := cFile + '.log'
EndIf

_nHdlLog := fCreate(cFile,Nil,Nil,!lMacOs)

For nI := 1 To Len(aLog)
   For nZ := 1 To Len(aLog[nI])
      If ValType(aLog[nI][nZ]) = 'C' .And. !(aLog[nI][nZ]==' Para ver o LOG Completo clique no bot�o abaixo !')
         fWrite(_nHdlLog,aLog[nI][nZ] + CRLF)
      EndIf
   Next nZ
Next nI

fClose(_nHdlLog)

Return( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} ESCEMPRESA
description Funcao Generica para escolha de Empresa, montado pelo SM0_
Retorna vetor contendo as selecoes feitas.
Se nao For marcada nenhuma o vetor volta vazio.
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function EscEmpresa(lExclu)

Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := Nil
Local   oChkMar  := Nil
Local   oChkPar  := Nil
Local   oChkOrd  := Nil
Local   oLbx     := Nil
Local   oFixEmp  := Nil
Local   oButInv  := Nil
Local   oSay     := Nil
Local   oOk      := LoadBitmap( GetResources(), 'LBOK' )
Local   oNo      := LoadBitmap( GetResources(), 'LBNO' )
Local   lOk      := .F.
Local   cVar     := ''
Local   cNomEmp  := ''
Local   aSelEmp  := {'01','02','03','04','05','90'}


If !MyOpenSm0Ex(lExclu)
   Return( aRet )
EndIf


dbSelectArea( 'SM0' )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

   If aScan( aSelEmp , {|x| x==AllTrim(SM0->M0_CODIGO)} ) == 0
      DbSkip()
      Loop
   EndIf

   If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
      aAdd(  aVetor, { .F. , SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
   EndIf

   DBSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title '' From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := 'Tela para Multiplas Sele��es de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para Atualiza��o'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| { IIf(aVetor[oLbx:nAt,1],oOk,oNo), aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,4] } }
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChkTod, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 109, 10 CheckBox oChkMar Var lChkTod Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of oDlg on Click MarcaTodos( lChkTod, @aVetor, oLbx )


@ 123, 10 Button oButInv Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChkTod, oChkMar ), VerTodos( aVetor, @lChkTod, oChkMar ) ) ;
Message 'Inverter Sele��o' Of oDlg

Define SButton From 124, 127 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a Sele��o'  Enable Of oDlg
Define SButton From 124, 160 Type 2 Action ( oDlg:End() ) OnStop 'Abandona a Sele��o' Enable Of oDlg

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MARCATODOS
description FFuncao Auxiliar para marcar/desmarcar todos os itens do
ListBox ativo.
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
   aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} INVSELECAO
description Funcao Auxiliar para inverter selecao do ListBox Ativo
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
   aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} RETSELECAO
description Funcao Auxiliar que monta o retorno com as selecoes
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
   If aVetor[nI][1]
      aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
   EndIf
Next nI

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} VERTODOS
description Funcao auxiliar para verificar se estao todos marcardos ou nao
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )

Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
   lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0Ex
description Funcao de processamento abertura do SM0 modo exclusivo
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function MyOpenSM0Ex(lExclu)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
   dbUseArea( .T.,, 'SIGAMAT.EMP', 'SM0', !lExclu , .F. )

   If !Empty( Select( 'SM0' ) )
      lOpen := .T.
      dbSetIndex( 'SIGAMAT.IND' )
      Exit
   EndIf

   Sleep( 500 )

Next nLoop

If !lOpen
   ApMsgStop( 'n�o foi poss�vel a abertura da tabela ' + ;
              'de empresas' + If(lExclu,' de forma exclusiva.','.') , 'ATEN��o' )
EndIf

Return( lOpen )


//-------------------------------------------------------------------
/*/{Protheus.doc} LIBTABLE
description Executa a liberacao da role no Oracle para acessos aos
objetos porventura criados (executa no final do compatib.)
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function LibTable( aTexto )

If TcGetDB() == 'ORACLE' 

   oProcess:IncRegua1( 'Atualizando regras do Banco de dados...' )
   oProcess:IncRegua2( 'Atualizando regras do Banco de dados...' )

   TCSPEXEC('ap_atualizarolep11')

   LogAdd( @aTexto , 'Regras do Banco de dados atualizadas...' )

EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} LogAdd
description Funcao de gravacao do Log de processamento do compatibili
zador.@author Kaique Mathias    
@since 02/06/20
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
/*/{Protheus.doc} NOTNULL
description Funcao Generica para validar o valor do campo, caso esteja
com valor Nil, o campo � desconsiderado para fins de updatda tabela. 
@author Kaique Mathias    
@since 02/06/20
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
@since 02/06/20
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
@since 02/06/20
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
@since 02/06/20
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
@since 02/06/20
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
/*/{Protheus.doc}  AT00SX1  
description uncao de processamento da gravacao do SX1 - Perguntas
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SX1( aTexto )

Local aEstrut   := {}
Local aSX1      := {}
Local lContinua := .T.
Local lReclock  := .T.
Local I,j,nJ,nI := 0
Local nPosGrp   := 0
Local nPosPer   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0

LogAdd( @aTexto , 'Inicio da Atualizacao do SX1' )

aEstrut := { 'X1_GRUPO', ; 
             'X1_ORDEM', ; 
             'X1_PERGUNT', ; 
             'X1_PERSPA', ; 
             'X1_PERENG', ; 
             'X1_VARIAVL', ; 
             'X1_TIPO', ; 
             'X1_TAMANHO', ; 
             'X1_DECIMAL', ; 
             'X1_PRESEL', ; 
             'X1_GSC', ; 
             'X1_VALID', ; 
             'X1_VAR01', ; 
             'X1_DEF01', ; 
             'X1_DEFSPA1', ; 
             'X1_DEFENG1', ; 
             'X1_CNT01', ; 
             'X1_VAR02', ; 
             'X1_DEF02', ; 
             'X1_DEFSPA2', ; 
             'X1_DEFENG2', ; 
             'X1_CNT02', ; 
             'X1_VAR03', ; 
             'X1_DEF03', ; 
             'X1_DEFSPA3', ; 
             'X1_DEFENG3', ; 
             'X1_CNT03', ; 
             'X1_VAR04', ; 
             'X1_DEF04', ; 
             'X1_DEFSPA4', ; 
             'X1_DEFENG4', ; 
             'X1_CNT04', ; 
             'X1_VAR05', ; 
             'X1_DEF05', ; 
             'X1_DEFSPA5', ; 
             'X1_DEFENG5', ; 
             'X1_CNT05', ; 
             'X1_F3', ; 
             'X1_PYME', ; 
             'X1_GRPSXG', ; 
             'X1_HELP', ; 
             'X1_PICTURE', ; 
             'X1_IDFIL' } 


aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '01' , ; //X1_ORDEM
   'Filial De                     ' , ; //X1_PERGUNT
   'Filial De                     ' , ; //X1_PERSPA
   'Filial De                     ' , ; //X1_PERENG
   'MV_CH0' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR01       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '                                                            ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '02' , ; //X1_ORDEM
   'Filial At�                    ' , ; //X1_PERGUNT
   'Filial At�                    ' , ; //X1_PERSPA
   'Filial At�                    ' , ; //X1_PERENG
   'MV_CH1' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR02       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   'ZZZZZZZZ                                                    ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '03' , ; //X1_ORDEM
   'C�digo De                     ' , ; //X1_PERGUNT
   'C�digo De                     ' , ; //X1_PERSPA
   'C�digo De                     ' , ; //X1_PERENG
   'MV_CH2' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    6 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR03       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '                                                            ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '04' , ; //X1_ORDEM
   'C�digo At�                    ' , ; //X1_PERGUNT
   'C�digo At�                    ' , ; //X1_PERSPA
   'C�digo At�                    ' , ; //X1_PERENG
   'MV_CH3' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    6 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR04       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   'ZZZZZZ                                                      ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '05' , ; //X1_ORDEM
   'Fun��o De                     ' , ; //X1_PERGUNT
   'Fun��o De                     ' , ; //X1_PERSPA
   'Fun��o De                     ' , ; //X1_PERENG
   'MV_CH4' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    5 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR05       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '                                                            ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '06' , ; //X1_ORDEM
   'Fun��o At�                    ' , ; //X1_PERGUNT
   'Fun��o At�                    ' , ; //X1_PERSPA
   'Fun��o At�                    ' , ; //X1_PERENG
   'MV_CH5' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    5 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR06       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   'ZZZZZ                                                       ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '07' , ; //X1_ORDEM
   'Usu�rio Portal                ' , ; //X1_PERGUNT
   'Usu�rio Portal                ' , ; //X1_PERSPA
   'Usu�rio Portal                ' , ; //X1_PERENG
   'MV_CH6' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    6 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR07       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '000006                                                      ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   '               ' , ; //X1_DEF02
   '               ' , ; //X1_DEFSPA2
   '               ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'APD20U    ' , ; //X1_GRUPO
   '08' , ; //X1_ORDEM
   'Alterar j� preenchidos?       ' , ; //X1_PERGUNT
   'Alterar j� preenchidos?       ' , ; //X1_PERSPA
   'Alterar j� preenchidos?       ' , ; //X1_PERENG
   'MV_CH7' , ; //X1_VARIAVL
   'N' , ; //X1_TIPO
    1 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    2 , ; //X1_PRESEL
   'C' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR08       ' , ; //X1_VAR01
   'N�o            ' , ; //X1_DEF01
   'N�o            ' , ; //X1_DEFSPA1
   'N�o            ' , ; //X1_DEFENG1
   '                                                            ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   'Sim            ' , ; //X1_DEF02
   'Sim            ' , ; //X1_DEFSPA2
   'Sim            ' , ; //X1_DEFENG2
   '                                                            ' , ; //X1_CNT02
   '               ' , ; //X1_VAR03
   '               ' , ; //X1_DEF03
   '               ' , ; //X1_DEFSPA3
   '               ' , ; //X1_DEFENG3
   '                                                            ' , ; //X1_CNT03
   '               ' , ; //X1_VAR04
   '               ' , ; //X1_DEF04
   '               ' , ; //X1_DEFSPA4
   '               ' , ; //X1_DEFENG4
   '                                                            ' , ; //X1_CNT04
   '               ' , ; //X1_VAR05
   '               ' , ; //X1_DEF05
   '               ' , ; //X1_DEFSPA5
   '          ' , ; //X1_DEFENG5
   '                                                            ' , ; //X1_CNT05
   '      ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

nPosGrp := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_GRUPO' } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_ORDEM'   } )
nPosPer := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_PERGUNT'   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_TAMANHO' } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_GRPSXG'  } )


// ----------------------
// Atualizando Dicion�rio
// ----------------------

dbSelectArea( 'SX1' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX1 )

   //  ---------------------------------------------------------
   // Verifica se o campo faz parte de um grupo e ajsuta tamanho
   //  ---------------------------------------------------------
   If !Empty(nPosSXG) 
         If !Empty( aSX1[nI][nPosSXG] )
             SXG->( dbSetOrder( 1 ) )
             If SXG->( MSSeek( aSX1[nI][nPosSXG] ) )
                 If aSX1[nI][nPosTam] <> SXG->XG_SIZE
                 aSX1[nI][nPosTam] := SXG->XG_SIZE
                 LogAdd( @aTexto , 'O tamanho da pergunta ' + aSX1[nI][nPosGrp] + '/' + aSX1[nI][nPosPer] + ' nao foi atualizado !' )
                LogAdd( @aTexto , 'O mesmo foi mantido em [' + AllTrim( Str( SXG->XG_SIZE ) ) + '] por pertencer ao grupo de campos [' + SX1->X1_GRPSXG + ']' )
                LogAdd( @aTexto , '' )
                 EndIf
             EndIf
         EndIf
   EndIf

   If !SX1->( dbSeek( cAudiReg := aSX1[nI][1]+aSX1[nI][2] ) )

      If !CanAdd(aEstrut,aSX1[nI])
         LogAdd( @aTexto , 'Warning.: Grupo de Pergunta ' + aSX1[nI][1] + ' nao pode ser inserido por falta de dados no compatibilizador !')
         Loop
      EndIf

      RecLock( 'SX1', .T. )
      For nJ := 1 To Len( aSX1[nI] )
         If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX1[nI][nJ]) 
            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSX1[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SX1' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
         EndIf
      Next nJ
      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'Foi incluido o grupo de pergunta ' + aSX1[nI][1] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   Else

      RecLock( 'SX1', .F. )
      For nJ := 1 To Len( aSX1[nI] )
         If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSX1[nI][nJ]) .And. ;
            PadR( StrTran( AllToChar( aAudiVal[1]:=SX1->( FieldGet( FieldPos(aEstrut[nJ]) ) ) )   , ' ' , '' ), 250 ) <> ;
            PadR( StrTran( AllToChar( aAudiVal[2]:=aSX1[nI][nJ] )                                , ' ' , '' ), 250 ) 
            FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SX1' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
         EndIf
      Next nJ
      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'Foi atualizado o grupo de pergunta ' + aSX1[nI][1] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   EndIf

   oProcess:IncRegua2( 'Atualizando Perguntas (SX1)...')

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SX1' )
LogAdd( @aTexto , Replicate( '-', 128 ) )

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} DEFREGUA
description uFuncao Generica para informar a quantidade de registros a
a ser processada pela regua2.
@author Kaique Mathias    
@since 02/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function DefRegua( nI )

Local nRegua := 0 

If nI = 1
   nRegua := 1
Else
   nRegua := 8
EndIf

Return( nRegua )