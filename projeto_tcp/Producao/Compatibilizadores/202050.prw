#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )


//-------------------------------------------------------------------
/*/{Protheus.doc} 202050  
description Funcao de update dos dicion�rios para compatibiliza��o
@author Kaique Mathias    
@since 05/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
User Function 202050()

Local aSay         := {}
Local aButton      := {}
Local aMarcadas    := {}
Local lExclu       := .T.
Local cTitulo      := '202050 - Atualiza��o de dicion�rios e Tabelas'
Local cDesc1       := 'Esta rotina tem como objetivo realizar a atualiza��o  dos dicion�rios do Sistema ( SX?/SIX )'
Local cDesc2       := Replicate('-',110)
Local cDesc3       := 'Esta atualiza��o ' + if(lExclu,'deve','pode') + ' ser executada em modo [ ** ' + if(lExclu,'E X C L U S I V O','C O M P A R T I L H A D O') + ' ** ]'
Local cDesc4       := Replicate('-',110)
Local cDesc5       := '[DIVERSOS] :SX3,SX6,SIX'
Local cDesc6       := Replicate('-',110)
Local cDesc7       := '*******  [  Fa�a sempre BACKUP antes de aplicar qualquer compatibilizador  ]  *******'
Local cLibCli      := ''
Local lOk          := .F.

Private cDevName   := 'Kaique Mathias    '
Private cTicket    := '202050'
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
@since 05/06/20
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
         //�Atualiza o dicion�rio SX3         �
         //������������������������������������
         oProcess:IncRegua1( 'Dicion�rio SX3 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x,y| AT00SX3(@x,y) }')
         Eval( bBloco , aTexto , lChkOrd )

         //����������������������������������Ŀ
         //�Atualiza o dicion�rio SX6         �
         //������������������������������������
         oProcess:IncRegua1( 'Dicion�rio SX6 ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x,y| AT00SX6(@x,y) }')
         Eval( bBloco , aTexto , If(lChkPar,aRecnoSM0[nI][4],Nil) )

         //����������������������������������Ŀ
         //�Atualiza o dicion�rio SIX         �
         //������������������������������������
         oProcess:IncRegua1( 'Dicion�rio SIX ' + Left( aRecnoSM0[nI][1] + ' ' + aRecnoSM0[nI][3] , 20 ) )
         bBloco := MontaBlock('{|x| AT00SIX(@x) }')
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
@since 05/06/20
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
/*/{Protheus.doc}  AT00SX3  
description Funcao de processamento da gravacao do SX3 - Campos
@author Kaique Mathias    
@since 05/06/20
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
             'X3_MODAL' } 


aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '03' , ; //X3_ORDEM
   'ZA0_DTSOLI' , ; //X3_CAMPO
   'D' , ; //X3_TIPO
    8 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Dt Inclusao ' , ; //X3_TITULO
   'Dt Inclusao ' , ; //X3_TITSPA
   'Dt Inclusao ' , ; //X3_TITENG
   'Data de Inclusao         ' , ; //X3_DESCRIC
   'Data de Inclusao         ' , ; //X3_DESCSPA
   'Data de Inclusao         ' , ; //X3_DESCENG
   '                                             ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) , ; //X3_USADO
   'DDATABASE                                                                                                                       ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   '��' , ; //X3_RESERV
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
   ' '  } ) //X3_MODAL

aAdd( aSX3, { ;
   'ZA0' , ; //X3_ARQUIVO
   '04' , ; //X3_ORDEM
   'ZA0_NUM   ' , ; //X3_CAMPO
   'Nil' , ; //X3_TIPO
    -1 , ; //X3_TAMANHO
    -1 , ; //X3_DECIMAL
   'Nil' , ; //X3_TITULO
   'Nil' , ; //X3_TITSPA
   'Nil' , ; //X3_TITENG
   'Nil' , ; //X3_DESCRIC
   'Nil' , ; //X3_DESCSPA
   'Nil' , ; //X3_DESCENG
   '@R 999999999' , ; //X3_PICTURE
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '05' , ; //X3_ORDEM
   'ZA0_TIPO  ' , ; //X3_CAMPO
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
   'S' , ; //X3_BROWSE
   'Nil' , ; //X3_VISUAL
   'Nil' , ; //X3_CONTEXT
   'Nil' , ; //X3_OBRIGAT
   'Nil' , ; //X3_VLDUSER
   'Nil' , ; //X3_CBOX
   'Nil' , ; //X3_CBOXSPA
   'Nil' , ; //X3_CBOXENG
   'Nil' , ; //X3_PICTVAR
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '06' , ; //X3_ORDEM
   'ZA0_CLIFOR' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '07' , ; //X3_ORDEM
   'ZA0_LOJA  ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '08' , ; //X3_ORDEM
   'ZA0_NOME  ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '09' , ; //X3_ORDEM
   'ZA0_EMISSA' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '10' , ; //X3_ORDEM
   'ZA0_VENCTO' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '11' , ; //X3_ORDEM
   'ZA0_VENCRE' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '12' , ; //X3_ORDEM
   'ZA0_CODBAR' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '13' , ; //X3_ORDEM
   'ZA0_NATURE' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '14' , ; //X3_ORDEM
   'ZA0_CC    ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '15' , ; //X3_ORDEM
   'ZA0_TPORC ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '16' , ; //X3_ORDEM
   'ZA0_VALOR ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '17' , ; //X3_ORDEM
   'ZA0_MULTA ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '18' , ; //X3_ORDEM
   'ZA0_JUROS ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '19' , ; //X3_ORDEM
   'ZA0_JUSJUR' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '20' , ; //X3_ORDEM
   'ZA0_IRRF  ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '21' , ; //X3_ORDEM
   'ZA0_PIS   ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '22' , ; //X3_ORDEM
   'ZA0_COFINS' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '23' , ; //X3_ORDEM
   'ZA0_CSLL  ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '24' , ; //X3_ORDEM
   'ZA0_CODREC' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '25' , ; //X3_ORDEM
   'ZA0_PERAPU' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '26' , ; //X3_ORDEM
   'ZA0_NUMREF' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '27' , ; //X3_ORDEM
   'ZA0_CODSOL' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '28' , ; //X3_ORDEM
   'ZA0_OBS   ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '29' , ; //X3_ORDEM
   'ZA0_STATUS' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '30' , ; //X3_ORDEM
   'ZA0_HIST  ' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'ZA0' , ; //X3_ARQUIVO
   '31' , ; //X3_ORDEM
   'ZA0_NOMSOL' , ; //X3_CAMPO
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
   'Nil' , ; //X3_WHEN
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
   'SAL' , ; //X3_ARQUIVO
   '29' , ; //X3_ORDEM
   'AL_XDOCPGM' , ; //X3_CAMPO
   'C' , ; //X3_TIPO
    1 , ; //X3_TAMANHO
    0 , ; //X3_DECIMAL
   'Pgto. Manual' , ; //X3_TITULO
   'Pgto. Manual' , ; //X3_TITSPA
   'Pgto. Manual' , ; //X3_TITENG
   'Pagamento Manual         ' , ; //X3_DESCRIC
   'Pagamento Manual         ' , ; //X3_DESCSPA
   'Pagamento Manual         ' , ; //X3_DESCENG
   '@!                                           ' , ; //X3_PICTURE
   '                                                                                                                                ' , ; //X3_VALID
    Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160) , ; //X3_USADO
   '' + DUPLAS + '2' + DUPLAS + '                                                                                                                             ' , ; //X3_RELACAO
   '      ' , ; //X3_F3
    0 , ; //X3_NIVEL
   '��' , ; //X3_RESERV
   ' ' , ; //X3_CHECK
   ' ' , ; //X3_TRIGGER
   'U' , ; //X3_PROPRI
   'N' , ; //X3_BROWSE
   'A' , ; //X3_VISUAL
   'R' , ; //X3_CONTEXT
    Chr(000) , ; //X3_OBRIGAT
   'Pertence(' + DUPLAS + '12' + DUPLAS + ')                                                                                                                  ' , ; //X3_VLDUSER
   '1=Sim;2=N�o                                                                                                                     ' , ; //X3_CBOX
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
// Atualizando Dicion�rio
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
@author Kaique Mathias    
@since 05/06/20
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
        'ZA0', ; //INDICE
        '2', ; //ORDEM
        'ZA0_FILIAL+ZA0_NUM+ZA0_TIPO+ZA0_CLIFOR+ZA0_LOJA                                                                                                                 ', ; //CHAVE
        'No. Titulo+Tipo+Fornecedor+Loja                                       ', ; //DESCRICAO
        'No. Titulo+Tipo+Fornecedor+Loja                                       ', ; //DESCSPA
        'No. Titulo+Tipo+Fornecedor+Loja                                       ', ; //DESCENG
        'U', ; //PROPRI
        '                                                                                                                                                                ', ; //F3
        '          ', ; //NICKNAME
        'S', ; //SHOWPESQ
        ' ', ; //IX_VIRTUAL
        ' '})  //IX_VIRCUST



// ----------------------
// Atualizando Dicion�rio
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
/*/{Protheus.doc}  AT00SX6  
description uncao de processamento da gravacao do SX6 - Par�metros
@author Kaique Mathias    
@since 08/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function AT00SX6( aTexto , aFils )

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
             'X6_DEFENG', ; 
             'X6_EXPDEST' } 


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
aAdd( aSX6Temp , 'TCP_ALTSP ' )  //X6_VAR
aAdd( aSX6Temp , 'L' )  //X6_TIPO
aAdd( aSX6Temp , 'Habilita alteracao dos campos no contas a pagar de' )  //X6_DESCRIC
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG
aAdd( aSX6Temp , 'titulos oriundos do fluxo de pagamentos manuais.  ' )  //X6_DESC1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA1
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG1
aAdd( aSX6Temp , '                                                  ' )  //X6_DESC2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCSPA2
aAdd( aSX6Temp , '                                                  ' )  //X6_DSCENG2
aAdd( aSX6Temp , '.T.                                                                                                                                                                                                                                                       ' )  //X6_CONTEUD
aAdd( aSX6Temp , '.T.                                                                                                                                                                                                                                                       ' )  //X6_CONTSPA
aAdd( aSX6Temp , '.T.                                                                                                                                                                                                                                                       ' )  //X6_CONTENG
aAdd( aSX6Temp , 'U' )  //X6_PROPRI
aAdd( aSX6Temp , ' ' )  //X6_PYME
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_VALID
aAdd( aSX6Temp , '                                                                                                                                ' )  //X6_INIT
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFPOR
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFSPA
aAdd( aSX6Temp , '                                                                                                                                                                                                                                                          ' )  //X6_DEFENG
aAdd( aSX6Temp , '2' )  //X6_EXPDEST
aAdd( aSX6 , aSX6Temp )

// ----------------------
// Atualizando Dicion�rio
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

   oProcess:IncRegua2( 'Atualizando Par�metros (SX6)...')

Next nI

LogAdd( @aTexto , 'Final da Atualizacao do SX6' )
LogAdd( @aTexto , Replicate( '-', 128 ) )

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} DEFREGUA
description uFuncao Generica para informar a quantidade de registros a
a ser processada pela regua2.
@author Kaique Mathias    
@since 05/06/20
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function DefRegua( nI )

Local nRegua := 0 

If nI = 1
   nRegua := 2
Else
   nRegua := 30
EndIf

Return( nRegua )