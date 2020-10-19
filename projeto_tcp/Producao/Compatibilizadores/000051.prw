#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )


//-------------------------------------------------------------------
/*/{Protheus.doc} 000051  
description Funcao de update dos dicionários para compatibilização
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 000051()

Local aSay         := {}
Local aButton      := {}
Local aMarcadas    := {}
Local lExclu       := .T.
Local cTitulo      := '000051 - Atualização de dicionários e Tabelas'
Local cDesc1       := 'Esta rotina tem como objetivo realizar a atualização  dos dicionários do Sistema ( SX?/SIX )'
Local cDesc2       := Replicate('-',110)
Local cDesc3       := 'Esta atualização ' + if(lExclu,'deve','pode') + ' ser executada em modo [ ** ' + if(lExclu,'E X C L U S I V O','C O M P A R T I L H A D O') + ' ** ]'
Local cDesc4       := Replicate('-',110)
Local cDesc5       := '[DIVERSOS] :SX2,SX3,SIX,SXB,SX1'
Local cDesc6       := Replicate('-',110)
Local cDesc7       := '*******  [  Faça sempre BACKUP antes de aplicar qualquer compatibilizador  ]  *******'
Local cLibCli      := ''
Local lOk          := .F.

Private cDevName   := 'Kaique Sousa      '
Private cTicket    := '000051'
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
      If  ApMsgNoYes( 'Confirma a atualização dos dicionários ?', cTitulo )

         oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lExclu ) }, cTicket + ' - Atualizando', 'Aguarde, atualizando ...', .F. )
         oProcess:Activate()

         If !lOk
            MsgStop( 'Atualização não Realizada.' )
         EndIf

      Else
         MsgStop( 'Atualização não Realizada.' )
      EndIf
   Else
      MsgStop( 'Você não selecionou nenhuma empresa !' )
   EndIf

EndIf

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
description Funcao de processamento da gravação dos arquivos
@author Kaique Sousa      
@since 14/10/19
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


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX2         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX2 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x,y| AT00SX2(@x,y) }')
         Eval( bBloco , aTexto , If(!Empty(cFixEmp).And.cFixEmp!='??',cFixEmp,aRecnoSM0[nI][1]) )


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX3         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX3 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x,y| AT00SX3(@x,y) }')
         Eval( bBloco , aTexto , lChkOrd )


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SIX         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SIX ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x| AT00SIX(@x) }')
         Eval( bBloco , aTexto )


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SXB         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SXB ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x| AT00SXB(@x) }')
         Eval( bBloco , aTexto )


         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Atualiza o dicionário SX1         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         oProcess:IncRegua1( 'Dicionário SX1 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
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
               oProcess:IncRegua2('Aplicando alterações na base de dados...')
               Loop
            EndIf

            If Select( aArqUpd[nx] ) > 0
               dbSelectArea( aArqUpd[nx] )
               dbCloseArea()
            EndIf

            X31UpdTable( aArqUpd[nx] )

            If __GetX31Error()
               LogAdd( @aTexto , 'Erro.: Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : ' + aArqUpd[nx] )
               LogAdd( @aTexto , __GetX31Trace() )
            Else
               ChkFile(aArqUpd[nx])
               DbSelectArea(aArqUpd[nx])
            EndIf

            oProcess:IncRegua2('Aplicando alterações na base de dados...')

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
         aAdd( aTexto[1] , ' Para ver o LOG Completo clique no botão abaixo !' )

         Define Font oFont Name 'Mono AS' Size 5, 12

         oDlg    := TDialog():New( 003, 000, 340, 417, cTicket + ' - Atualizacao concluida', , , , , CLR_BLACK, CLR_WHITE, , , .T. )
         oTimer  := TTimer():New( 0, { || (If(lAlertLog,MsgStop('Atenção...'+CRLF+'Houve erros/warnings durante a execução'+CRLF+'Verifique atentamente o LOG !!!'),Nil),oTimer:DeActivate()) }, oDlg )
         oBrowse := TCBrowse():New( 05 , 05, 200, 145,,{'Log de Atualização - Resumo'},{100},oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,/*bValid*/,.T.,.F.)
         oBrowse:SetArray(aTexto[1])
         oBrowse:oFont := oFont
         oBrowse:AddColumn( TCColumn():New('Log de Atualização'     ,{ || aTexto[1][oBrowse:nAt] },,,,'LEFT',,.F.,.T.,,,,.F.,) )

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
@author Kaique Sousa      
@since 14/10/19
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
      If ValType(aLog[nI][nZ]) = 'C' .And. !(aLog[nI][nZ]==' Para ver o LOG Completo clique no botão abaixo !')
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
@author Kaique Sousa      
@since 14/10/19
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

oDlg:cToolTip := 'Tela para Multiplas Seleções de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para Atualização'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| { IIf(aVetor[oLbx:nAt,1],oOk,oNo), aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,4] } }
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChkTod, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 109, 10 CheckBox oChkMar Var lChkTod Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of oDlg on Click MarcaTodos( lChkTod, @aVetor, oLbx )


@ 123, 10 Button oButInv Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChkTod, oChkMar ), VerTodos( aVetor, @lChkTod, oChkMar ) ) ;
Message 'Inverter Seleção' Of oDlg

Define SButton From 124, 127 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a Seleção'  Enable Of oDlg
Define SButton From 124, 160 Type 2 Action ( oDlg:End() ) OnStop 'Abandona a Seleção' Enable Of oDlg

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MARCATODOS
description FFuncao Auxiliar para marcar/desmarcar todos os itens do
ListBox ativo.
@author Kaique Sousa      
@since 14/10/19
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
@author Kaique Sousa      
@since 14/10/19
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
@author Kaique Sousa      
@since 14/10/19
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
@author Kaique Sousa      
@since 14/10/19
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
@author Kaique Sousa      
@since 14/10/19
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
   ApMsgStop( 'não foi possóvel a abertura da tabela ' + ;
              'de empresas' + If(lExclu,' de forma exclusiva.','.') , 'ATENção' )
EndIf

Return( lOpen )


//-------------------------------------------------------------------
/*/{Protheus.doc} LIBTABLE
description Executa a liberacao da role no Oracle para acessos aos
objetos porventura criados (executa no final do compatib.)
@author Kaique Sousa      
@since 14/10/19
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
zador.@author Kaique Sousa      
@since 14/10/19
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
com valor Nil, o campo é desconsiderado para fins de updatda tabela. 
@author Kaique Sousa      
@since 14/10/19
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
@author Kaique Sousa      
@since 14/10/19
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
no banco de dados do AUDIT_TRAIL.@author Kaique Sousa      
@since 14/10/19
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
suficientes para criar um novo registro no dicionario.@author Kaique Sousa      
@since 14/10/19
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
DO DICIONARIO PARA O BANCO ORACLE (AUDITORIA).@author Kaique Sousa      
@since 14/10/19
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
/*/{Protheus.doc}  AT00SX2  
description Funcao de processamento da gravacao do SX2 - Arquivos
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SX2( aTexto , cEmpr )

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

aAdd( aSX2Temp , 'ZP6' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZP6010  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'PARAMETROS PEFIN              ' )     //X2_NOME
aAdd( aSX2Temp , 'PARAMETROS PEFIN              ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'PARAMETROS PEFIN              ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'C' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'C' )    //X2_MODOUN 
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

aAdd( aSX2Temp , 'ZP2' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZP2010  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'MOTIVOS DE BAIXA PEFIN        ' )     //X2_NOME
aAdd( aSX2Temp , 'MOTIVOS DE BAIXA PEFIN        ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'MOTIVOS DE BAIXA PEFIN        ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'C' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'C' )    //X2_MODOUN 
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

aAdd( aSX2Temp , 'ZP7' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZP7010  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'NATUREZAS DIVIDA PEFIN        ' )     //X2_NOME
aAdd( aSX2Temp , 'NATUREZAS DIVIDA PEFIN        ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'NATUREZAS DIVIDA PEFIN        ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'C' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'C' )    //X2_MODOUN 
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

aAdd( aSX2Temp , 'ZP4' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZP4010  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'OCORRENCIAS PEFIN SERASA      ' )     //X2_NOME
aAdd( aSX2Temp , 'OCORRENCIAS PEFIN SERASA      ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'OCORRENCIAS PEFIN SERASA      ' )     //X2_NOMEENG
aAdd( aSX2Temp , '                                        ' )     //X2_ROTINA 
aAdd( aSX2Temp , 'C' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'C' )    //X2_MODOUN 
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

aAdd( aSX2Temp , 'ZP5' )    //X2_CHAVE
aAdd( aSX2Temp , '                                        ' )     //X2_PATH
aAdd( aSX2Temp , 'ZP5010  ' )    //X2_ARQUIVO
aAdd( aSX2Temp , 'ALERTAS CLIENTE               ' )     //X2_NOME
aAdd( aSX2Temp , 'ALERTAS CLIENTE               ' )     //X2_NOMESPA
aAdd( aSX2Temp , 'ALERTAS CLIENTE               ' )     //X2_NOMEENG
aAdd( aSX2Temp , 'ZP5_ENTIDA+ZP5_CODENT+ZP5_CODCON+ZP5_DAT' )     //X2_ROTINA 
aAdd( aSX2Temp , 'C' )     //X2_MODO   

If nPosModoUn > 0
aAdd( aSX2Temp , 'C' )    //X2_MODOUN 
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

//-------------------------------------------------------------------
/*/{Protheus.doc}  AT00SX3  
description Funcao de processamento da gravacao do SX3 - Campos
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SX3( aTexto , lOrd )

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
             'X3_MODAL', ; 
             'X3_LGPD' } 


aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T2' , ; //X3_ORDEM
   'E1_DTPEFIN' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Data Pefin  ' , ; //X3_TITULO
   'Data Pefin  ' , ; //X3_TITSPA
   'Data Pefin  ' , ; //X3_TITENG
   'Data Pefin               ' , ; //X3_DESCRIC
   'Data Pefin               ' , ; //X3_DESCSPA
   'Data Pefin               ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T3' , ; //X3_ORDEM
   'E1_OBPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    23 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Obs Pefin   ' , ; //X3_TITULO
   'Obs Pefin   ' , ; //X3_TITSPA
   'Obs Pefin   ' , ; //X3_TITENG
   'Obs Pefin                ' , ; //X3_DESCRIC
   'Obs Pefin                ' , ; //X3_DESCSPA
   'Obs Pefin                ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T4' , ; //X3_ORDEM
   'E1_USPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    15 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Usuar Pefin ' , ; //X3_TITULO
   'Usuar Pefin ' , ; //X3_TITSPA
   'Usuar Pefin ' , ; //X3_TITENG
   'Usuar Pefin              ' , ; //X3_DESCRIC
   'Usuar Pefin              ' , ; //X3_DESCSPA
   'Usuar Pefin              ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T5' , ; //X3_ORDEM
   'E1_ACPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Acao Pefin  ' , ; //X3_TITULO
   'Acao Pefin  ' , ; //X3_TITSPA
   'Acao Pefin  ' , ; //X3_TITENG
   'Acao Pefin               ' , ; //X3_DESCRIC
   'Acao Pefin               ' , ; //X3_DESCSPA
   'Acao Pefin               ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T6' , ; //X3_ORDEM
   'E1_ANPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    80 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Anot Pefin  ' , ; //X3_TITULO
   'Anot Pefin  ' , ; //X3_TITSPA
   'Anot Pefin  ' , ; //X3_TITENG
   'Anot Pefin               ' , ; //X3_DESCRIC
   'Anot Pefin               ' , ; //X3_DESCSPA
   'Anot Pefin               ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T7' , ; //X3_ORDEM
   'E1_STPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Status Pefin' , ; //X3_TITULO
   'Status Pefin' , ; //X3_TITSPA
   'Status Pefin' , ; //X3_TITENG
   'Status Pefin             ' , ; //X3_DESCRIC
   'Status Pefin             ' , ; //X3_DESCSPA
   'Status Pefin             ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T8' , ; //X3_ORDEM
   'E1_OCPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    23 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Ocorr Pefin ' , ; //X3_TITULO
   'Ocorr Pefin ' , ; //X3_TITSPA
   'Ocorr Pefin ' , ; //X3_TITENG
   'Ocorr Pefin              ' , ; //X3_DESCRIC
   'Ocorr Pefin              ' , ; //X3_DESCSPA
   'Ocorr Pefin              ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'T9' , ; //X3_ORDEM
   'E1_ODPEFIN' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Data Ocorr  ' , ; //X3_TITULO
   'Data Ocorr  ' , ; //X3_TITSPA
   'Data Ocorr  ' , ; //X3_TITENG
   'Data Ocorr               ' , ; //X3_DESCRIC
   'Data Ocorr               ' , ; //X3_DESCSPA
   'Data Ocorr               ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U0' , ; //X3_ORDEM
   'E1_UEPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    80 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'UltArq Envio' , ; //X3_TITULO
   'UltArq Envio' , ; //X3_TITSPA
   'UltArq Envio' , ; //X3_TITENG
   'UltArq Envio             ' , ; //X3_DESCRIC
   'UltArq Envio             ' , ; //X3_DESCSPA
   'UltArq Envio             ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U1' , ; //X3_ORDEM
   'E1_URPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    80 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'UltArq Retor' , ; //X3_TITULO
   'UltArq Retor' , ; //X3_TITSPA
   'UltArq Retor' , ; //X3_TITENG
   'UltArq Retor             ' , ; //X3_DESCRIC
   'UltArq Retor             ' , ; //X3_DESCSPA
   'UltArq Retor             ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U2' , ; //X3_ORDEM
   'E1_MOPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Motivo Pefin' , ; //X3_TITULO
   'Motivo Pefin' , ; //X3_TITSPA
   'Motivo Pefin' , ; //X3_TITENG
   'Motivo Pefin             ' , ; //X3_DESCRIC
   'Motivo Pefin             ' , ; //X3_DESCSPA
   'Motivo Pefin             ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U3' , ; //X3_ORDEM
   'E1_OLPEFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Hist Ctr Pef' , ; //X3_TITULO
   'Hist Ctr Pef' , ; //X3_TITSPA
   'Hist Ctr Pef' , ; //X3_TITENG
   'Hist Ctr Pef             ' , ; //X3_DESCRIC
   'Hist Ctr Pef             ' , ; //X3_DESCSPA
   'Hist Ctr Pef             ' , ; //X3_DESCENG
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
   'S' , ; //X3_PYME
   '                                                                                                                                                                                                                                                          ' , ; //X3_CONDSQL
   '                                                                                                                                                                                                                                                          ' , ; //X3_CHKSQL
   ' ' , ; //X3_IDXSRV
   'N' , ; //X3_ORTOGRA
   'N' , ; //X3_IDXFLD
   '               ' , ; //X3_TELA
   '                                                  ' , ; //X3_PICBRV
   '   ' , ; //X3_AGRUP
   ' ' , ; //X3_POSLGT
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U4' , ; //X3_ORDEM
   'E1_YNF1OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 1 ' , ; //X3_TITULO
   'Id Sel NF 1 ' , ; //X3_TITSPA
   'Id Sel NF 1 ' , ; //X3_TITENG
   'Identificador Selecao NF1' , ; //X3_DESCRIC
   'Identificador Selecao NF1' , ; //X3_DESCSPA
   'Identificador Selecao NF1' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '08' , ; //X3_ORDEM
   'ZP6_ARQCFG' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    12 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Arq Configur' , ; //X3_TITULO
   'Arq Configur' , ; //X3_TITSPA
   'Arq Configur' , ; //X3_TITENG
   'Arquivo de Configuracao  ' , ; //X3_DESCRIC
   'Arquivo de Configuracao  ' , ; //X3_DESCSPA
   'Arquivo de Configuracao  ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '13' , ; //X3_ORDEM
   'ZP6_ARQGER' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    80 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Arq Geracao ' , ; //X3_TITULO
   'Arq Geracao ' , ; //X3_TITSPA
   'Arq Geracao ' , ; //X3_TITENG
   'Arquivo de Geracao       ' , ; //X3_DESCRIC
   'Arquivo de Geracao       ' , ; //X3_DESCSPA
   'Arquivo de Geracao       ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '09' , ; //X3_ORDEM
   'ZP6_ARQRET' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    12 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Ret Configur' , ; //X3_TITULO
   'Ret Configur' , ; //X3_TITSPA
   'Ret Configur' , ; //X3_TITENG
   'Retorno Configuracao     ' , ; //X3_DESCRIC
   'Retorno Configuracao     ' , ; //X3_DESCSPA
   'Retorno Configuracao     ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '11' , ; //X3_ORDEM
   'ZP6_BYTES ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Bytes Retorn' , ; //X3_TITULO
   'Bytes Retorn' , ; //X3_TITSPA
   'Bytes Retorn' , ; //X3_TITENG
   'Tam arquivo retorno      ' , ; //X3_DESCRIC
   'Tam arquivo retorno      ' , ; //X3_DESCSPA
   'Tam arquivo retorno      ' , ; //X3_DESCENG
   '@E 999,999' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '600                                                                                                                             ' , ; //X3_RELACAO
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
   'Positivo()                                                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZP6_CONVEN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod Convenio' , ; //X3_TITULO
   'Cod Convenio' , ; //X3_TITSPA
   'Cod Convenio' , ; //X3_TITENG
   'Cod Convenio             ' , ; //X3_DESCRIC
   'Cod Convenio             ' , ; //X3_DESCSPA
   'Cod Convenio             ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '22' , ; //X3_ORDEM
   'ZP6_CPCORR' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    12 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cpo Cta Corr' , ; //X3_TITULO
   'Cpo Cta Corr' , ; //X3_TITSPA
   'Cpo Cta Corr' , ; //X3_TITENG
   'Conta Corrente Cliente   ' , ; //X3_DESCRIC
   'Conta Corrente Cliente   ' , ; //X3_DESCSPA
   'Conta Corrente Cliente   ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þA' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(032) , ; //X3_OBRIGAT
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '21' , ; //X3_ORDEM
   'ZP6_CPNOMA' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cpo Nome Mae' , ; //X3_TITULO
   'Cpo Nome Mae' , ; //X3_TITSPA
   'Cpo Nome Mae' , ; //X3_TITENG
   'Campo Nome da Mae        ' , ; //X3_DESCRIC
   'Campo Nome da Mae        ' , ; //X3_DESCSPA
   'Campo Nome da Mae        ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '20' , ; //X3_ORDEM
   'ZP6_CPNOPA' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cpo Nome Pai' , ; //X3_TITULO
   'Cpo Nome Pai' , ; //X3_TITSPA
   'Cpo Nome Pai' , ; //X3_TITENG
   'Campo Nome do Pai        ' , ; //X3_DESCRIC
   'Campo Nome do Pai        ' , ; //X3_DESCSPA
   'Campo Nome do Pai        ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '19' , ; //X3_ORDEM
   'ZP6_CPUFRG' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    10 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cpo UF RG   ' , ; //X3_TITULO
   'Cpo UF RG   ' , ; //X3_TITSPA
   'Cpo UF RG   ' , ; //X3_TITENG
   'Campo UF do RG           ' , ; //X3_DESCRIC
   'Campo UF do RG           ' , ; //X3_DESCSPA
   'Campo UF do RG           ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '17' , ; //X3_ORDEM
   'ZP6_DIASVE' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    4 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Dias Vencido' , ; //X3_TITULO
   'Dias Vencido' , ; //X3_TITSPA
   'Dias Vencido' , ; //X3_TITENG
   'Dias de Vencido          ' , ; //X3_DESCRIC
   'Dias de Vencido          ' , ; //X3_DESCSPA
   'Dias de Vencido          ' , ; //X3_DESCENG
   '9999                                         ' , ; //X3_PICTURE
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
   'Positivo()                                                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZP6_DIFERE' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    4 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Diferencial ' , ; //X3_TITULO
   'Diferencial ' , ; //X3_TITSPA
   'Diferencial ' , ; //X3_TITENG
   'Diferencial Mesmo dia    ' , ; //X3_DESCRIC
   'Diferencial Mesmo dia    ' , ; //X3_DESCSPA
   'Diferencial Mesmo dia    ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZP6_DTUENV' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Dt Ult Env  ' , ; //X3_TITULO
   'Dt Ult Env  ' , ; //X3_TITSPA
   'Dt Ult Env  ' , ; //X3_TITENG
   'Data Ultimo Envio        ' , ; //X3_DESCRIC
   'Data Ultimo Envio        ' , ; //X3_DESCSPA
   'Data Ultimo Envio        ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '10' , ; //X3_ORDEM
   'ZP6_EXTRET' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Ext. Retorno' , ; //X3_TITULO
   'Ext. Retorno' , ; //X3_TITSPA
   'Ext. Retorno' , ; //X3_TITENG
   'Ext do Arquivo de Retorno' , ; //X3_DESCRIC
   'Ext do Arquivo de Retorno' , ; //X3_DESCSPA
   'Ext do Arquivo de Retorno' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '24' , ; //X3_ORDEM
   'ZP6_FILFIN' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial Final' , ; //X3_TITULO
   'Filial Final' , ; //X3_TITSPA
   'Filial Final' , ; //X3_TITENG
   'Filial Final             ' , ; //X3_DESCRIC
   'Filial Final             ' , ; //X3_DESCSPA
   'Filial Final             ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SM0   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZP6_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '23' , ; //X3_ORDEM
   'ZP6_FILINI' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial Inici' , ; //X3_TITULO
   'Filial Inici' , ; //X3_TITSPA
   'Filial Inici' , ; //X3_TITENG
   'Filial Inicial           ' , ; //X3_DESCRIC
   'Filial Inicial           ' , ; //X3_DESCSPA
   'Filial Inicial           ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'SM0   ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '16' , ; //X3_ORDEM
   'ZP6_IDADE ' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Idade Min   ' , ; //X3_TITULO
   'Idade Min   ' , ; //X3_TITSPA
   'Idade Min   ' , ; //X3_TITENG
   'Idade Minima             ' , ; //X3_DESCRIC
   'Idade Minima             ' , ; //X3_DESCSPA
   'Idade Minima             ' , ; //X3_DESCENG
   '99                                           ' , ; //X3_PICTURE
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
   'Positivo()                                                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZP6_LOGON ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Logon Carta ' , ; //X3_TITULO
   'Logon Carta ' , ; //X3_TITSPA
   'Logon Carta ' , ; //X3_TITENG
   'Logon Carta Pefin        ' , ; //X3_DESCRIC
   'Logon Carta Pefin        ' , ; //X3_DESCSPA
   'Logon Carta Pefin        ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZP6_NOMRES' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    70 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Responsavel ' , ; //X3_TITULO
   'Responsavel ' , ; //X3_TITSPA
   'Responsavel ' , ; //X3_TITENG
   'Nome do Responsavel      ' , ; //X3_DESCRIC
   'Nome do Responsavel      ' , ; //X3_DESCSPA
   'Nome do Responsavel      ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '18' , ; //X3_ORDEM
   'ZP6_PRACA ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    4 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Pr Embratel ' , ; //X3_TITULO
   'Pr Embratel ' , ; //X3_TITSPA
   'Pr Embratel ' , ; //X3_TITENG
   'Praca Embratel           ' , ; //X3_DESCRIC
   'Praca Embratel           ' , ; //X3_DESCSPA
   'Praca Embratel           ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '12' , ; //X3_ORDEM
   'ZP6_TIPODT' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Tipo de Data' , ; //X3_TITULO
   'Tipo de Data' , ; //X3_TITSPA
   'Tipo de Data' , ; //X3_TITENG
   'Tipo de Data             ' , ; //X3_DESCRIC
   'Tipo de Data             ' , ; //X3_DESCSPA
   'Tipo de Data             ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + DUPLAS + '4' + DUPLAS + '                                                                                                                             ' , ; //X3_RELACAO
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
   '1=ddmmaa;2=mmddaa;3=aammdd;4=ddmmaaaa;5=aaaammdd;6=mmddaaaa                                                                     ' , ; //X3_CBOX
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZP6_ULTDSK' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Ult Disco   ' , ; //X3_TITULO
   'Ult Disco   ' , ; //X3_TITSPA
   'Ult Disco   ' , ; //X3_TITENG
   'Ultimo Disco             ' , ; //X3_DESCRIC
   'Ultimo Disco             ' , ; //X3_DESCSPA
   'Ultimo Disco             ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '15' , ; //X3_ORDEM
   'ZP6_VLRMAX' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    15 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Vlr Maximo  ' , ; //X3_TITULO
   'Vlr Maximo  ' , ; //X3_TITSPA
   'Vlr Maximo  ' , ; //X3_TITENG
   'Vlr Maximo p/ Envio      ' , ; //X3_DESCRIC
   'Vlr Maximo p/ Envio      ' , ; //X3_DESCSPA
   'Vlr Maximo p/ Envio      ' , ; //X3_DESCENG
   '@E 999,999,999,999.99                        ' , ; //X3_PICTURE
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
    Chr(000) , ; //X3_OBRIGAT
   'Positivo()                                                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP6' , ; //X3_ARQUIVO
   '14' , ; //X3_ORDEM
   'ZP6_VLRMIN' , ; //X3_CAMPO
   'N' , ; //X3_TIPO
    15 , ; //X3_TAMANHO
    2 , ; //X3_DECIMAL
   'Vlr Minimo  ' , ; //X3_TITULO
   'Vlr Minimo  ' , ; //X3_TITSPA
   'Vlr Minimo  ' , ; //X3_TITENG
   'Valor Minimo p/ Envio    ' , ; //X3_DESCRIC
   'Valor Minimo p/ Envio    ' , ; //X3_DESCSPA
   'Valor Minimo p/ Envio    ' , ; //X3_DESCENG
   '@E 999,999,999,999.99                        ' , ; //X3_PICTURE
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
    Chr(000) , ; //X3_OBRIGAT
   'Positivo()                                                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZP2_COD   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Codigo Mot  ' , ; //X3_TITULO
   'Codigo Mot  ' , ; //X3_TITSPA
   'Codigo Mot  ' , ; //X3_TITENG
   'Codigo do Motivo         ' , ; //X3_DESCRIC
   'Codigo do Motivo         ' , ; //X3_DESCSPA
   'Codigo do Motivo         ' , ; //X3_DESCENG
   '99                                           ' , ; //X3_PICTURE
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
   'M->ZP2_SEQ:=U_GETPROX(' + SIMPLES + 'ZP2' + SIMPLES + ',' + SIMPLES + '  ' + SIMPLES + '+M->ZP2_COD,' + SIMPLES + 'ZP2_FILIAL+ZP2_COD' + SIMPLES + ',1,' + SIMPLES + 'ZP2_SEQ' + SIMPLES + '),ExistChav(' + SIMPLES + 'ZP2' + SIMPLES + ',&(ReadVar())+M->ZP2_SEQ,1)        ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZP2_DESCRI' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    50 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Descr Motivo' , ; //X3_TITULO
   'Descr Motivo' , ; //X3_TITSPA
   'Descr Motivo' , ; //X3_TITENG
   'Descricao do Motivo      ' , ; //X3_DESCRIC
   'Descricao do Motivo      ' , ; //X3_DESCSPA
   'Descricao do Motivo      ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZP2_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZP2_MOTPRO' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Mot Protheus' , ; //X3_TITULO
   'Mot Protheus' , ; //X3_TITSPA
   'Mot Protheus' , ; //X3_TITENG
   'Motivo Baixa Protheus    ' , ; //X3_DESCRIC
   'Motivo Baixa Protheus    ' , ; //X3_DESCSPA
   'Motivo Baixa Protheus    ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '                                                                                                                                ' , ; //X3_RELACAO
   'MOTSYS' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'U_CECF002J(1,{&(ReadVar())}).AND.(Vazio().or.EXISTCHAV(' + SIMPLES + 'ZP2' + SIMPLES + ',M->ZP2_STATUS+&(ReadVar()),2))                                     ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZP2_SEQ   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Seq Codigo  ' , ; //X3_TITULO
   'Seq Codigo  ' , ; //X3_TITSPA
   'Seq Codigo  ' , ; //X3_TITENG
   'Sequencia de Codigo      ' , ; //X3_DESCRIC
   'Sequencia de Codigo      ' , ; //X3_DESCSPA
   'Sequencia de Codigo      ' , ; //X3_DESCENG
   '999                                          ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP2' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZP2_STATUS' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Status      ' , ; //X3_TITULO
   'Status      ' , ; //X3_TITSPA
   'Status      ' , ; //X3_TITENG
   'Status do Motivo         ' , ; //X3_DESCRIC
   'Status do Motivo         ' , ; //X3_DESCSPA
   'Status do Motivo         ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + DUPLAS + 'A' + DUPLAS + '                                                                                                                             ' , ; //X3_RELACAO
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
   ' Empty(M->ZP2_MOTPRO).or.EXISTCHAV(' + SIMPLES + 'ZP2' + SIMPLES + ',&(ReadVar())+M->ZP2_MOTPRO,2)                                                          ' , ; //X3_VLDUSER
   'A=Ativo;I=Inativo                                                                                                               ' , ; //X3_CBOX
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZP7_COD   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod Natureza' , ; //X3_TITULO
   'Cod Natureza' , ; //X3_TITSPA
   'Cod Natureza' , ; //X3_TITENG
   'Codigo da Natureza       ' , ; //X3_DESCRIC
   'Codigo da Natureza       ' , ; //X3_DESCSPA
   'Codigo da Natureza       ' , ; //X3_DESCENG
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
   'ExistChav(' + SIMPLES + 'ZP7' + SIMPLES + ',M->ZP7_SEQ+&(ReadVar()),1)                                                                                      ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZP7_DESCR ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    12 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Desc Resumid' , ; //X3_TITULO
   'Desc Resumid' , ; //X3_TITSPA
   'Desc Resumid' , ; //X3_TITENG
   'Descricao Resumida       ' , ; //X3_DESCRIC
   'Descricao Resumida       ' , ; //X3_DESCSPA
   'Descricao Resumida       ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZP7_DESCRI' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    120 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Desc Naturez' , ; //X3_TITULO
   'Desc Naturez' , ; //X3_TITSPA
   'Desc Naturez' , ; //X3_TITENG
   'Descricao da Natureza    ' , ; //X3_DESCRIC
   'Descricao da Natureza    ' , ; //X3_DESCSPA
   'Descricao da Natureza    ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZP7_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZP7_REGSA1' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    255 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Regra Client' , ; //X3_TITULO
   'Regra Client' , ; //X3_TITSPA
   'Regra Client' , ; //X3_TITENG
   'Regra sob tabela cliente ' , ; //X3_DESCRIC
   'Regra sob tabela cliente ' , ; //X3_DESCSPA
   'Regra sob tabela cliente ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '08' , ; //X3_ORDEM
   'ZP7_REGSE1' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    255 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Regra Titulo' , ; //X3_TITULO
   'Regra Titulo' , ; //X3_TITSPA
   'Regra Titulo' , ; //X3_TITENG
   'Regra Tab Titulos        ' , ; //X3_DESCRIC
   'Regra Tab Titulos        ' , ; //X3_DESCSPA
   'Regra Tab Titulos        ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '09' , ; //X3_ORDEM
   'ZP7_REGSEF' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    255 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Regra Cheque' , ; //X3_TITULO
   'Regra Cheque' , ; //X3_TITSPA
   'Regra Cheque' , ; //X3_TITENG
   'Regra Tagela Cheques     ' , ; //X3_DESCRIC
   'Regra Tagela Cheques     ' , ; //X3_DESCSPA
   'Regra Tagela Cheques     ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZP7_SEQ   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Sequencia   ' , ; //X3_TITULO
   'Sequencia   ' , ; //X3_TITSPA
   'Sequencia   ' , ; //X3_TITENG
   'Sequencia                ' , ; //X3_DESCRIC
   'Sequencia                ' , ; //X3_DESCSPA
   'Sequencia                ' , ; //X3_DESCENG
   '999                                          ' , ; //X3_PICTURE
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
   ' &(ReadVar()) := PadL(AllTrim(&(ReadVar())),3,' + SIMPLES + '0' + SIMPLES + '),ExistChav(' + SIMPLES + 'ZP7' + SIMPLES + ',&(ReadVar())+M->ZP7_COD,1)                                   ' , ; //X3_VLDUSER
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP7' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZP7_STATUS' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Status      ' , ; //X3_TITULO
   'Status      ' , ; //X3_TITSPA
   'Status      ' , ; //X3_TITENG
   'Status da Natureza       ' , ; //X3_DESCRIC
   'Status da Natureza       ' , ; //X3_DESCSPA
   'Status da Natureza       ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + DUPLAS + 'A' + DUPLAS + '                                                                                                                             ' , ; //X3_RELACAO
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
   'A=Ativo;I=Inativo                                                                                                               ' , ; //X3_CBOX
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP4' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZP4_COD   ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Cod Ocorrenc' , ; //X3_TITULO
   'Cod Ocorrenc' , ; //X3_TITSPA
   'Cod Ocorrenc' , ; //X3_TITENG
   'Codigo da Ocorrencia     ' , ; //X3_DESCRIC
   'Codigo da Ocorrencia     ' , ; //X3_DESCSPA
   'Codigo da Ocorrencia     ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP4' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZP4_DESCRI' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    40 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Descricao   ' , ; //X3_TITULO
   'Descricao   ' , ; //X3_TITSPA
   'Descricao   ' , ; //X3_TITENG
   'Descricao da Ocorrencia  ' , ; //X3_DESCRIC
   'Descricao da Ocorrencia  ' , ; //X3_DESCSPA
   'Descricao da Ocorrencia  ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP4' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZP4_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZP5_CODCON' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    30 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'AUTOR       ' , ; //X3_TITULO
   'AUTOR       ' , ; //X3_TITSPA
   'AUTOR       ' , ; //X3_TITENG
   'AUTOR DO ALERTA          ' , ; //X3_DESCRIC
   'AUTOR DO ALERTA          ' , ; //X3_DESCSPA
   'AUTOR DO ALERTA          ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'ALLTRIM(CUSERNAME)                                                                                                              ' , ; //X3_RELACAO
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZP5_CODENT' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    25 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'COD ENTIDADE' , ; //X3_TITULO
   'COD ENTIDADE' , ; //X3_TITSPA
   'COD ENTIDADE' , ; //X3_TITENG
   'COD ENTIDADE             ' , ; //X3_DESCRIC
   'COD ENTIDADE             ' , ; //X3_DESCSPA
   'COD ENTIDADE             ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZP5_DATA  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    20 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Data/Hora   ' , ; //X3_TITULO
   'Data/Hora   ' , ; //X3_TITSPA
   'Data/Hora   ' , ; //X3_TITENG
   'Data/Hora                ' , ; //X3_DESCRIC
   'Data/Hora                ' , ; //X3_DESCSPA
   'Data/Hora                ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   'DTOC(DDATABASE) + ' + DUPLAS + ' ' + DUPLAS + ' + TIME()                                                                                                  ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   'þÀ' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'S' , ; //X3_BROWSE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZP5_ENTIDA' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    3 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'ENTIDADE    ' , ; //X3_TITULO
   'ENTIDADE    ' , ; //X3_TITSPA
   'ENTIDADE    ' , ; //X3_TITENG
   'ENTIDADE                 ' , ; //X3_DESCRIC
   'ENTIDADE                 ' , ; //X3_DESCSPA
   'ENTIDADE                 ' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '02' , ; //X3_ORDEM
   'ZP5_FILENT' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    6 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'FIL ENT     ' , ; //X3_TITULO
   'FIL ENT     ' , ; //X3_TITSPA
   'FIL ENT     ' , ; //X3_TITENG
   'FILIAL ENTIDADE          ' , ; //X3_DESCRIC
   'FILIAL ENTIDADE          ' , ; //X3_DESCSPA
   'FILIAL ENTIDADE          ' , ; //X3_DESCENG
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
   '090' , ; //X3_GRPSXG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '01' , ; //X3_ORDEM
   'ZP5_FILIAL' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    _nTamFil , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Filial      ' , ; //X3_TITULO
   'Sucursal    ' , ; //X3_TITSPA
   'Branch      ' , ; //X3_TITENG
   'Filial do Sistema        ' , ; //X3_DESCRIC
   'Sucursal                 ' , ; //X3_DESCSPA
   'Branch of the System     ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'ZP5' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZP5_OCORR ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    200 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Ocorrencia  ' , ; //X3_TITULO
   'Ocorrencia  ' , ; //X3_TITSPA
   'Ocorrencia  ' , ; //X3_TITENG
   'Ocorrencia               ' , ; //X3_DESCRIC
   'Ocorrencia               ' , ; //X3_DESCSPA
   'Ocorrencia               ' , ; //X3_DESCENG
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
   'INCLUI                                                      ' , ; //X3_WHEN
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U5' , ; //X3_ORDEM
   'E1_YNF2OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 2 ' , ; //X3_TITULO
   'Id Sel NF 2 ' , ; //X3_TITSPA
   'Id Sel NF 2 ' , ; //X3_TITENG
   'Identificador Selecao NF2' , ; //X3_DESCRIC
   'Identificador Selecao NF2' , ; //X3_DESCSPA
   'Identificador Selecao NF2' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U6' , ; //X3_ORDEM
   'E1_YNF3OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 3 ' , ; //X3_TITULO
   'Id Sel NF 3 ' , ; //X3_TITSPA
   'Id Sel NF 3 ' , ; //X3_TITENG
   'Identificador Selecao NF3' , ; //X3_DESCRIC
   'Identificador Selecao NF3' , ; //X3_DESCSPA
   'Identificador Selecao NF3' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U7' , ; //X3_ORDEM
   'E1_YNF4OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 4 ' , ; //X3_TITULO
   'Id Sel NF 4 ' , ; //X3_TITSPA
   'Id Sel NF 4 ' , ; //X3_TITENG
   'Identificador Selecao NF4' , ; //X3_DESCRIC
   'Identificador Selecao NF4' , ; //X3_DESCSPA
   'Identificador Selecao NF4' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U8' , ; //X3_ORDEM
   'E1_YNF5OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 5 ' , ; //X3_TITULO
   'Id Sel NF 5 ' , ; //X3_TITSPA
   'Id Sel NF 5 ' , ; //X3_TITENG
   'Identificador Selecao NF5' , ; //X3_DESCRIC
   'Identificador Selecao NF5' , ; //X3_DESCSPA
   'Identificador Selecao NF5' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD

aAdd( aSX3, { ;
   'SE1' , ; //X3_ARQUIVO
   'U9' , ; //X3_ORDEM
   'E1_YNF6OK ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    2 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Id Sel NF 6 ' , ; //X3_TITULO
   'Id Sel NF 6 ' , ; //X3_TITSPA
   'Id Sel NF 6 ' , ; //X3_TITENG
   'Identificador Selecao NF6' , ; //X3_DESCRIC
   'Identificador Selecao NF6' , ; //X3_DESCSPA
   'Identificador Selecao NF6' , ; //X3_DESCENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


aAdd( aSX3, { ;
   'SA1' , ; //X3_ARQUIVO
   'S8' , ; //X3_ORDEM
   'A1_PEFIN  ' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Envia Pefin ' , ; //X3_TITULO
   'Envia Pefin ' , ; //X3_TITSPA
   'Envia Pefin ' , ; //X3_TITENG
   'Envia Pefin              ' , ; //X3_DESCRIC
   'Envia Pefin              ' , ; //X3_DESCSPA
   'Envia Pefin              ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + DUPLAS + 'S' + DUPLAS + '                                                                                                                             ' , ; //X3_RELACAO
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
   'S=Sim;N=Nao                                                                                                                     ' , ; //X3_CBOX
   'S=Sim;N=Nao                                                                                                                     ' , ; //X3_CBOXSPA
   'S=Sim;N=Nao                                                                                                                     ' , ; //X3_CBOXENG
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
   ' ' , ; //X3_MODAL
   ' '  } ) //X3_LGPD


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


//-------------------------------------------------------------------
/*/{Protheus.doc}  AT00SIX  
description Funcao de processamento da gravacao do SIX - Indices
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc}  AT00SIX  
description Funcao de processamento da gravacao do SIX - Indices
@author Kaique Sousa      
@since 01/08/19
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SIX( aTexto )

Local aEstrut   := {}
Local aSIX      := {}
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

LogAdd( @aTexto , 'Inicio da Atualizacao do SIX' )

aEstrut := {'INDICE','ORDEM','CHAVE','DESCRICAO','DESCSPA','DESCENG','PROPRI','F3','NICKNAME','SHOWPESQ','IX_VIRTUAL','IX_VIRCUST'}

 aAdd( aSIX, {                            ; 
        'ZP6', ; //INDICE
        '1', ; //ORDEM
        'ZP6_FILIAL+ZP6_CONVEN                                                                                                                                           ', ; //CHAVE
        'Cod Convenio                                                          ', ; //DESCRICAO
        'Cod Convenio                                                          ', ; //DESCSPA
        'Cod Convenio                                                          ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP2', ; //INDICE
        '1', ; //ORDEM
        'ZP2_FILIAL+ZP2_COD+ZP2_SEQ                                                                                                                                      ', ; //CHAVE
        'Codigo Mot+Seq Codigo                                                 ', ; //DESCRICAO
        'Codigo Mot+Seq Codigo                                                 ', ; //DESCSPA
        'Codigo Mot+Seq Codigo                                                 ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP2', ; //INDICE
        '2', ; //ORDEM
        'ZP2_FILIAL+ZP2_STATUS+ZP2_MOTPRO                                                                                                                                ', ; //CHAVE
        'Status+Mot Protheus                                                   ', ; //DESCRICAO
        'Status+Mot Protheus                                                   ', ; //DESCSPA
        'Status+Mot Protheus                                                   ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP7', ; //INDICE
        '1', ; //ORDEM
        'ZP7_FILIAL+ZP7_SEQ+ZP7_COD                                                                                                                                      ', ; //CHAVE
        'Sequencia+Cod Natureza                                                ', ; //DESCRICAO
        'Sequencia+Cod Natureza                                                ', ; //DESCSPA
        'Sequencia+Cod Natureza                                                ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP4', ; //INDICE
        '1', ; //ORDEM
        'ZP4_FILIAL+ZP4_COD                                                                                                                                              ', ; //CHAVE
        'Cod Ocorrenc                                                          ', ; //DESCRICAO
        'Cod Ocorrenc                                                          ', ; //DESCSPA
        'Cod Ocorrenc                                                          ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP5', ; //INDICE
        '1', ; //ORDEM
        'ZP5_FILIAL+ZP5_CODCON+ZP5_DATA+ZP5_ENTIDA+ZP5_FILENT+ZP5_CODENT                                                                                                 ', ; //CHAVE
        'Contato + Data + Entidade + Fil.Entidade + Cod.Entidade               ', ; //DESCRICAO
        'Contato + Data + Entidade + Fil.Entidade + Cod.Entidade               ', ; //DESCSPA
        'Contato + Data + Entidade + Fil.Entidade + Cod.Entidade               ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST

 aAdd( aSIX, {                            ; 
        'ZP5', ; //INDICE
        '2', ; //ORDEM
        'ZP5_FILIAL+ZP5_ENTIDA+ZP5_FILENT+ZP5_CODENT+ZP5_CODCON+ZP5_DATA                                                                                                 ', ; //CHAVE
        'Entidade + Fil.Entidade + Cod.Entidade + Contato + Data               ', ; //DESCRICAO
        'Entidade + Fil.Entidade + Cod.Entidade + Contato + Data               ', ; //DESCSPA
        'Entidade + Fil.Entidade + Cod.Entidade + Contato + Data               ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
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

//-------------------------------------------------------------------
/*/{Protheus.doc}  AT00SXB  
description uncao de processamento da gravacao do SXB - Consulta Padrao
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SXB( aTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local nI        := 0
Local nJ        := 0

LogAdd( @aTexto , 'Inicio da Atualizacao do SXB' )

aEstrut := { 'XB_ALIAS',  'XB_TIPO'   , 'XB_SEQ'    , 'XB_COLUNA' , 'XB_DESCRI', ; 
             'XB_DESCSPA', 'XB_DESCENG', 'XB_CONTEM', 'XB_WCONTEM' }

aAdd( aSXB, { ; 
   'ZP2   ' , ; //XB_ALIAS
   '1' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   'DB' , ; //XB_COLUNA
   'Mot Baixa PEFIN     ' , ; //XB_DESCRI
   'Mot Baixa PEFIN     ' , ; //XB_DESCSPA
   'Mot Baixa PEFIN     ' , ; //XB_DESCENG
   'ZP2                                                                                                                                                                                                                                                       ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP2   ' , ; //XB_ALIAS
   '2' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '01' , ; //XB_COLUNA
   'Codigo Mot+seq Codig' , ; //XB_DESCRI
   'Codigo Mot+seq Codig' , ; //XB_DESCSPA
   'Codigo Mot+seq Codig' , ; //XB_DESCENG
   '                                                                                                                                                                                                                                                          ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP2   ' , ; //XB_ALIAS
   '4' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '01' , ; //XB_COLUNA
   'Codigo Mot          ' , ; //XB_DESCRI
   'Codigo Mot          ' , ; //XB_DESCSPA
   'Codigo Mot          ' , ; //XB_DESCENG
   'ZP2_COD                                                                                                                                                                                                                                                   ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP2   ' , ; //XB_ALIAS
   '4' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '02' , ; //XB_COLUNA
   'Descr Motivo        ' , ; //XB_DESCRI
   'Descr Motivo        ' , ; //XB_DESCSPA
   'Descr Motivo        ' , ; //XB_DESCENG
   'ZP2_DESCRI                                                                                                                                                                                                                                                ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP2   ' , ; //XB_ALIAS
   '5' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '  ' , ; //XB_COLUNA
   '                    ' , ; //XB_DESCRI
   '                    ' , ; //XB_DESCSPA
   '                    ' , ; //XB_DESCENG
   'ZP2->ZP2_COD                                                                                                                                                                                                                                              ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP6   ' , ; //XB_ALIAS
   '1' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   'DB' , ; //XB_COLUNA
   'Convenio            ' , ; //XB_DESCRI
   'Convenio            ' , ; //XB_DESCSPA
   'Convenio            ' , ; //XB_DESCENG
   'ZP6                                                                                                                                                                                                                                                       ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP6   ' , ; //XB_ALIAS
   '2' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '01' , ; //XB_COLUNA
   'Cod Convenio        ' , ; //XB_DESCRI
   'Cod Convenio        ' , ; //XB_DESCSPA
   'Cod Convenio        ' , ; //XB_DESCENG
   '                                                                                                                                                                                                                                                          ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP6   ' , ; //XB_ALIAS
   '4' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '01' , ; //XB_COLUNA
   'Cod Convenio        ' , ; //XB_DESCRI
   'Cod Convenio        ' , ; //XB_DESCSPA
   'Cod Convenio        ' , ; //XB_DESCENG
   'ZP6_CONVEN                                                                                                                                                                                                                                                ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP6   ' , ; //XB_ALIAS
   '4' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '02' , ; //XB_COLUNA
   'Responsavel         ' , ; //XB_DESCRI
   'Responsavel         ' , ; //XB_DESCSPA
   'Responsavel         ' , ; //XB_DESCENG
   'ZP6_NOMRES                                                                                                                                                                                                                                                ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM

aAdd( aSXB, { ; 
   'ZP6   ' , ; //XB_ALIAS
   '5' , ; //XB_TIPO
   '01' , ; //XB_SEQ
   '  ' , ; //XB_COLUNA
   '                    ' , ; //XB_DESCRI
   '                    ' , ; //XB_DESCSPA
   '                    ' , ; //XB_DESCENG
   'ZP6->ZP6_CONVEN                                                                                                                                                                                                                                           ' , ; //XB_CONTEM
   '                                                                                                                                                                                                                                                          ' } ) //XB_WCONTEM


// ----------------------
// Atualizando Dicionário
// ----------------------

dbSelectArea( 'SXB' )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

   If Empty( aSXB[nI][1] )
      Loop
   EndIf

   If !SXB->( dbSeek( cAudiReg := PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

      If !CanAdd(aEstrut,aSXB[nI])
         LogAdd( @aTexto , 'Warning.: Consulta Padrao ' + aSXB[nI][1] + ' nao pode ser inserido por falta de dados no compatibilizador !')
         Loop
      EndIf

      RecLock( 'SXB', .T. )

      For nJ := 1 To Len( aSXB[nI] )
         If FieldPos( aEstrut[nJ] ) > 0 .And. NotNull(aSXB[nI][nJ])
            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSXB[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'I' , 'SXB' , cAudiReg , aEstrut[nJ] , '' , AllTrim(AllToChar(aAudiVal[2])) } )
         EndIf
      Next nJ

      dbCommit()
      MsUnLock()

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'Foi incluida a consulta padrão ' + aSXB[nI][1] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   Else

      // ------------------------
      // Verifica todos os campos
      // ------------------------
      For nJ := 1 To Len( aSXB[nI] )

         // -----------------------------------------
         // Se o campo estiver diferente da estrutura
         // -----------------------------------------
         If NotNull(aSXB[nI][nJ]) .And. ;
            aEstrut[nJ] == SXB->( FieldName( nJ ) ) .And. ; 
            StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), ' ', '' ) <> ; 
            StrTran( AllToChar( aSXB[nI][nJ]            ), ' ', '' )

            RecLock( 'SXB', .F. )
            aAudiVal[1]:=SXB->(FieldGet(FieldPos(aEstrut[nJ])))
            FieldPut( FieldPos( aEstrut[nJ] ), aAudiVal[2]:=aSXB[nI][nJ] )
            aAdd( aAuditDic , { cDevName , cTicket , cEmpAnt , Time() , DtoS(Date()) , 'U' , 'SXB' , cAudiReg , aEstrut[nJ] , AllTrim(AllToChar(aAudiVal[1])) , AllTrim(AllToChar(aAudiVal[2])) } )
            dbCommit()
            MsUnLock()

         EndIf

      Next nJ

      If !Empty( aAuditDic )
         LogAdd( @aTexto , 'Foi Alterada a consulta padrao ' + aSXB[nI][1] )
         AuditDic( @aAuditDic , @aTexto )
      EndIf

   EndIf

   oProcess:IncRegua2( 'Atualizando Consultas Padrões (SXB)...' )

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SXB' )
LogAdd( @aTexto , Replicate( '-', 128 ) )


Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc}  AT00SX1  
description uncao de processamento da gravacao do SX1 - Perguntas
@author Kaique Sousa      
@since 14/10/19
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
   'PEFIN2    ' , ; //X1_GRUPO
   '01' , ; //X1_ORDEM
   'Convenio                      ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH1' , ; //X1_VARIAVL
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
   '39096                                                       ' , ; //X1_CNT01
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
   'ZP6   ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'PEFIN2    ' , ; //X1_GRUPO
   '04' , ; //X1_ORDEM
   'Cliente De                    ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH4' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    6 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR02       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '000057                                                      ' , ; //X1_CNT01
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
   'SA1   ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'PEFIN2    ' , ; //X1_GRUPO
   '05' , ; //X1_ORDEM
   'Cliente Ate                   ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH5' , ; //X1_VARIAVL
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
   '000057                                                      ' , ; //X1_CNT01
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
   'SA1   ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'PEFIN2    ' , ; //X1_GRUPO
   '06' , ; //X1_ORDEM
   'Emitidos De                   ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH6' , ; //X1_VARIAVL
   'D' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR04       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '20190101                                                    ' , ; //X1_CNT01
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
   'PEFIN2    ' , ; //X1_GRUPO
   '07' , ; //X1_ORDEM
   'Emitidos Ate                  ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH7' , ; //X1_VARIAVL
   'D' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR05       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '20191231                                                    ' , ; //X1_CNT01
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
   'PEFIN2    ' , ; //X1_GRUPO
   '08' , ; //X1_ORDEM
   'Vencidos De                   ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH8' , ; //X1_VARIAVL
   'D' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR06       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '20190101                                                    ' , ; //X1_CNT01
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
   'PEFIN2    ' , ; //X1_GRUPO
   '09' , ; //X1_ORDEM
   'Vencidos Ate                  ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CH9' , ; //X1_VARIAVL
   'D' , ; //X1_TIPO
    8 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR07       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '20191011                                                    ' , ; //X1_CNT01
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
   'PEFIN2    ' , ; //X1_GRUPO
   '10' , ; //X1_ORDEM
   'Excluir Tipos                 ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CHA' , ; //X1_VARIAVL
   'C' , ; //X1_TIPO
    99 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    0 , ; //X1_PRESEL
   'G' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR08       ' , ; //X1_VAR01
   '               ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   'NCC;FT                                                      ' , ; //X1_CNT01
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
   'SPEF1 ' , ; //X1_F3
   ' ' , ; //X1_PYME
   '   ' , ; //X1_GRPSXG
   '              ' , ; //X1_HELP
   '                                        ' , ; //X1_PICTURE
   '      '  } ) //X1_IDFIL

aAdd( aSX1, { ;
   'PEFIN2    ' , ; //X1_GRUPO
   '11' , ; //X1_ORDEM
   'Filtrar Somente Válidos?      ' , ; //X1_PERGUNT
   '                              ' , ; //X1_PERSPA
   '                              ' , ; //X1_PERENG
   'MV_CHB' , ; //X1_VARIAVL
   'N' , ; //X1_TIPO
    1 , ; //X1_TAMANHO
    0 , ; //X1_DECIMAL
    1 , ; //X1_PRESEL
   'C' , ; //X1_GSC
   '                                                            ' , ; //X1_VALID
   'MV_PAR09       ' , ; //X1_VAR01
   'Sim            ' , ; //X1_DEF01
   '               ' , ; //X1_DEFSPA1
   '               ' , ; //X1_DEFENG1
   '                                                            ' , ; //X1_CNT01
   '               ' , ; //X1_VAR02
   'Não            ' , ; //X1_DEF02
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

nPosGrp := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_GRUPO' } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_ORDEM'   } )
nPosPer := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_PERGUNT'   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_TAMANHO' } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == 'X1_GRPSXG'  } )


// ----------------------
// Atualizando Dicionário
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
@author Kaique Sousa      
@since 14/10/19
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function DefRegua( nI )

Local nRegua := 0 

If nI = 1
   nRegua := 5
Else
   nRegua := 37
EndIf

Return( nRegua )