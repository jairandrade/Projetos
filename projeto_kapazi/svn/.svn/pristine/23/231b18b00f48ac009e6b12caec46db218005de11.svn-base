
/**********************************************************************************************************************************/
/** FATURAMENTO                                                                                                                  **/
/** Tela Status Pedido                                                                                             **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 13/08/2015 | Marcos Sulivan          | Criação da rotina/procedimento.                                                       **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

#Define ENTER chr(13)+chr(10)

/**********************************************************************************************************************************/
/** user function U_KPFATA06()                                                                                                     **/
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/ 

User Function KPFATA06() 

Local aArea :=	GetArea()


Local aBotoes				:= {}         //Variável onde será incluido o botão para a legenda
Local cEstilo1			:=	""
Local oBtnExp				:=	Nil
Local oBtnExi		 		:=	Nil
Local aBotoes		 		:= {}         //Variável onde será incluido o botão para a legenda  
Private aCPos				:= {"Posicao Pedido - Todos","PC-Cadastrado","PL-Liberacao","PF-Financeiro","PE-Estoque","NF-Faturamento","Nenhum"} 
Private cCombo		:= ""
Private aCPos2				:= {"Prazo - Todos","Vencido","No Prazo"} 
Private cCombo2		:= ""
Private aCPos3				:= {"Finalizado","Sim","Nao"} 
Private cCombo3		:= ""     
Private lRetC1		:= .F.
Private lRetC2		:= .F.
Private oCPos				:= Nil
Private oCombo		:= Nil
Private oLista    	:= Nil                //Declarando o objeto do browser
Private oLista      := Nil              //Declarando o objeto do browser
Private aCabecalho  := {}        //Variavel que montará o aHeader do grid
Private	aPedidos		:={}
Private aColsEx 	:= {}         //Variável que receberá os dados
Private cPerg   := "KPFATA06"		//Nome da pergunta de parâmetros
Private	lRetP		:= .F. 
Private oTpCli	:= Nil
Private oTpClf	:= Nil
Private oCheck1	:= Nil 
Private oCheck2	:= Nil
  
//Declarando os objetos de cores para usar na coluna de status do grid
Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
Private oAzul  		:= LoadBitmap( GetResources(), "BR_AZUL")
Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")  
Private oPink		:= LoadBitmap( GetResources(), "BR_PINK") 
Private oLaranja	:= LoadBitmap( GetResources(), "BR_LARANJA")
Private oMarron		:= LoadBitmap( GetResources(), "BR_MARROM")
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oPreto		:= LoadBitmap( GetResources(), "BR_PRETO") 	
Private oBranco		:= LoadBitmap( GetResources(), "BR_BRANCO")

  //Faz o processamento das perguntas
  Processa( {|lEnd| ProcSx1()} )
  Pergunte(cPerg, .T.)

DEFINE MSDIALOG oTela1 FROM 0,0 TO 550,1300 PIXEL TITLE 'Monitor de Pedido'
//DEFINE MSDIALOG oTela Title "Pedido Bloqueado - Acima do Estoque Máximo" Pixel Style 128 From 145,000 To 550, 800 
    
    
      //Bloqueia a tecla ESC
  	oTela1:lEscClose := .F.
  	//oDlg:lMaximized := .T.
		
		// Cria objeto de fonte que sera usado na Browse
		Define Font oFont Name 'Courier New' Size 0, -12 
		
  			//chamar a função que cria a estrutura do aHeader
        CriaCabec()
        
				//PROCESSA FILTRO
				Pergunte(cPerg, .F.)
				
        //Monta o browser com inclusão, remoção e atualização
        oLista := MsNewGetDados():New( 000, 002, 220, 652,, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue",,1, 99999, "AllwaysTrue", "", "AllwaysTrue", oTela1, aCabecalho, aColsEx)
        //oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oTela1, aCabecalho, aColsEx)

        //Carregar os itens que irão compor o conteudo do grid
        Carregar()

        //Ao abrir a janela o cursor está posicionado no meu objeto
        oLista:oBrowse:SetFocus()

        //Crio o menu que irá aparece no botão Ações relacionadas
        aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})
        aadd(aBotoes,{"NG_ICO_FILTRO", {||Pergunte(cPerg, .T.),Carregar()},"Filtro","Filtro"})     
    
    //Grupo dos Filtros
  	@ 220, 006 To 260, 652 Title "Filtros"
    
    //TIPO DO CLIENTE
  	oTpCli:= tSay():New(230,010,{||' De Tipo Cliente:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,49 MSGET oGet1 VAR mv_par01 SIZE 30,4 OF oTela1 PIXEL F3 "ACY" VALID .T. PICTURE "@!"
                   
  	oTpClf:= tSay():New(245,010,{||'Até Tipo Cliente:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,49 MSGET oGet2 VAR mv_par02 SIZE 30,4 OF oTela1 PIXEL F3 "ACY" VALID .T. PICTURE "@!"
  	
  	//PEDIDO
  	oPedi:= tSay():New(230,75,{||'       De Pedido:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,112 MSGET oGet3 VAR mv_par03 SIZE 30,4 OF oTela1 PIXEL F3 "SC5" VALID .T. PICTURE "@!"
  	
    oPedf:= tSay():New(245,75,{||'      Até Pedido:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,112 MSGET oGet4 VAR mv_par04 SIZE 30,4 OF oTela1 PIXEL F3 "SC5" VALID .T. PICTURE "@!"
  	
		//Cliente
  	oPedi:= tSay():New(230,141,{||'     De Cliente:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,175 MSGET oGet3 VAR mv_par05 SIZE 30,4 OF oTela1 PIXEL F3 "SA1" VALID .T. PICTURE "@!"
  	//Loja
  	@ 227,210 MSGET oGet4 VAR mv_par06 SIZE 10,4 OF oTela1 PIXEL VALID .T. PICTURE "@!"
  	
  	//Cliente
    oPedf:= tSay():New(245,141,{||'    Até Cliente:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,175 MSGET oGet5 VAR mv_par07 SIZE 30,4 OF oTela1 PIXEL F3 "SA1" VALID .T. PICTURE "@!" 
  	//Loja
  	@ 242,210 MSGET oGet6 VAR mv_par08 SIZE 10,4 OF oTela1 PIXEL VALID .T. PICTURE "@!"
  	
  	//Filial
  	oPedi:= tSay():New(230,220,{||'       De Filial:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,250 MSGET oGet3 VAR mv_par09 SIZE 10,4 OF oTela1 PIXEL F3 "SM0" VALID .T. PICTURE "@!"
  	
    oPedf:= tSay():New(245,220,{||'      Até Filial:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,250 MSGET oGet4 VAR mv_par10 SIZE 10,4 OF oTela1 PIXEL F3 "SM0" VALID .T. PICTURE "@!" 
  	
  	//DT CADASTRO
  	oPedi:= tSay():New(230,275,{||'Data de Cadastro:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,319 MSGET oGet7 VAR mv_par11 SIZE 1,4 OF oTela1 PIXEL F3 "" VALID .T. PICTURE "@D"
  	
    oPedf:= tSay():New(245,275,{||'       Até Cadastro:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,319 MSGET oGet8 VAR mv_par12 SIZE 1,4 OF oTela1 PIXEL F3 "" VALID .T. PICTURE "@D"
  	
  	  	//DT CADASTRO
  	oPedi:= tSay():New(230,360,{||' Data Vencimento:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 227,404 MSGET oGet9 VAR mv_par13 SIZE 1,4 OF oTela1 PIXEL F3 "" VALID .T. PICTURE "@D"
  	
    oPedf:= tSay():New(245,360,{||'   Até Vencimento:' },oTela1,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
  	@ 242,404 MSGET oGet10 VAR mv_par14 SIZE 1,4 OF oTela1 PIXEL F3 "" VALID .T. PICTURE "@D"
  	
  	oCPos:= tComboBox():New(227,450,{|u|if( Pcount( )>0, cCombo:= u, cCombo ) },aCPos,070,20,oTela1,,,,,,.T.,,,,,,,,,'cCombo') 
  	oCPos2:= tComboBox():New(227,530,{|u|if( Pcount( )>0, cCombo2:= u, cCombo2 ) },aCPos2,060,20,oTela1,,,,,,.T.,,,,,,,,,'cCombo2')
  	  	
 		oBtnExp := TButton():New(241,450,"Atualizar"	,oTela1,{||Carregar()},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )
 		oBtnExp := TButton():New(241,530,"Exportar"	,oTela1,{||Carregar(),U_TExcel2()},40,15,,,.F.,.T.,.F.,,.F.,,,.F. )   

        //EnchoiceBar(oTela1, {|| oTela1:End() }, {|| oTela1:End() },,aBotoes,,,)
        EnchoiceBar(oTela1, {|| oTela1:End() }, {|| oTela1:End() },,aBotoes,,,.F.,.F.,.F.,.F.,.F.,,)  

ACTIVATE MSDIALOG oTela1 CENTERED

RestArea(aArea)

Return

/**********************************************************************************************************************************/
/** user function U_KPFATA06()                                                                                                     **/
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/ 

Static function Legenda()
    Local aLegenda := {}

    AADD(aLegenda,{"BR_LARANJA"	    	,"Etapa Atrazada" })
    AADD(aLegenda,{"BR_VERDE"   			,"Etapa No Prazo" })
    AADD(aLegenda,{"BR_BRANCO"    		,"Etapa Não Iniciado" })
    AADD(aLegenda,{"BR_VERMELHO" 			,"Embarque Atrazado   " })
    AADD(aLegenda,{"BR_PINK" 					,"Pedido Excluído   " })
    AADD(aLegenda,{"BR_AMARELO" 			,"Pedido Inativo   " })
    AADD(aLegenda,{"BR_PRETO" 				,"Pedido Recadastrado     " })

    BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil


/**********************************************************************************************************************************/
/** user function U_KPFATA06()                                                                                                   **/
/**********************************************************************************************************************************/
/******************************************************************************************'***************************************/  

Static Function Carregar() 


//INICIA EXECUCAO DA CONDULTA O PADRAO
SZ6QRY()

//Inicializa o array
SZ6QRY->(DbGoTop())      

//Limpa o array
aPedidos := {}
aColsEx	 := {}
   
	  //Faz loop sobre a query
	  While (!SZ6QRY->(Eof()))
	  	    
	  	//Adiciona os dados no array
	   	Aadd(aPedidos, { 	SZ6QRY->FILIAL,;   			//1
	   										SZ6QRY->CODIGO,;        //2
	   										SZ6QRY->PEDIDO,;        //3
	   										SZ6QRY->DESCRICAOGP,;     //4
	   										SZ6QRY->DT_CADASTRO,;   //5
	   										SZ6QRY->HR_CADASTRO,;   //6
	   										SZ6QRY->CONTROLE,;      //7
	   										SZ6QRY->CTEX,;          //8
	   										SZ6QRY->VC,;            //9
	   										SZ6QRY->DATAAT,;        //10
	   										SZ6QRY->VP,;						//11
	   										SZ6QRY->VF,;            //12
	   										SZ6QRY->VE,;            //13
	   										SZ6QRY->VFATU,;         //14
	   										SZ6QRY->VEMBA,;					//15
	   										SZ6QRY->LIM,;						//16
	   										SZ6QRY->JUSLIBP,;						//17
	   										SZ6QRY->JUSLIBF,;						//18
	   										SZ6QRY->JUSLIBE,;						//19
	   										SZ6QRY->JUSFATU,;						//20
	   										SZ6QRY->JUSEMBA,;						//21
	   										SZ6QRY->CLIENTE,;						//22
	   										SZ6QRY->LOJA,;						//23
	   										SZ6QRY->DCLIENTE,;						//24
	   										SZ6QRY->DT_VAL_LIB,;						//25
	   										SZ6QRY->DT_VAL_FIN,;						//26
	   										SZ6QRY->DT_VAL_EST,;						//27
	   										SZ6QRY->DT_VAL_FAT,;						//28
	   										SZ6QRY->DT_VAL_EMB,;						//29
	   										SZ6QRY->NF,;						//30
	   										SZ6QRY->SERIE,;						//31
	   										SZ6QRY->USLIB,;						//32 
	   										SZ6QRY->USLIBF,;						//33
	   										SZ6QRY->USLIBE,;						//34
	   										SZ6QRY->USFATU,;						//35
	   										SZ6QRY->USEMBA,;						//36
	   										SZ6QRY->VALORNF,;						//37
	   										SZ6QRY->FRETEVL,;						//38
	   										SZ6QRY->TPFRETE,;						//39
	   										SZ6QRY->TRANSP,;						//40
	  										SZ6QRY->LIBP,;						//41
	   										SZ6QRY->LIBF,;						//42
	   										SZ6QRY->LIBE,;						//43
	   										SZ6QRY->FATU,;						//44
	   										SZ6QRY->EMBA,;						//45
	   										SZ6QRY->DT_EMB,;						//46
	   										SZ6QRY->HR_EMB,;						//47
	   										})        

	   	//Próximo Registro
	  	SZ6QRY->(DbSkip())
	  	
	  EndDo

//Fecha Query
SZ6QRY->(DbCloseArea())

    For i := 1 to len(aPedidos)
			
            aadd(aColsEx,{U_ValCor1(aPedidos[i,8]),;
            oVerde,;
            U_ValCor2(aPedidos[i,10],aPedidos[i,11],0,0,aPedidos[i,41],1),;
            U_ValCor2(aPedidos[i,10],aPedidos[i,12],0,0,aPedidos[i,42]),;
            U_ValCor2(aPedidos[i,10],aPedidos[i,13],0,0,aPedidos[i,43]),;
            U_ValCor2(aPedidos[i,10],aPedidos[i,14],0,0,aPedidos[i,44]),;
            U_ValCor2(aPedidos[i,10],aPedidos[i,15],0,0,aPedidos[i,45]),;
            U_ValCor2(aPedidos[i,10],aPedidos[i,16],1,aPedidos[i,8]),;
            aPedidos[i,1],;
            aPedidos[i,2],;
            aPedidos[i,3],;
            aPedidos[i,4],;
            aPedidos[i,22],;
            aPedidos[i,23],;
            aPedidos[i,24],;
            STOD(aPedidos[i,5]),;
            aPedidos[i,6],;        		//HR CADASTRO
            STOD(aPedidos[i,25]),;    //JUSTIFICATIVA
            aPedidos[i,32],;
            aPedidos[i,17],;		//JUSTIFICATIVA
            STOD(aPedidos[i,26]),;
            aPedidos[i,33],;                  //US
            aPedidos[i,18],;    //JUSTIFICATIVA
            STOD(aPedidos[i,27]),;
            aPedidos[i,34],;                  //US
            aPedidos[i,19],;    //JUSTIFICATIVA
            STOD(aPedidos[i,28]),;
            aPedidos[i,35],;                  //US
            aPedidos[i,20],;    //JUSTIFICATIVA
            STOD(aPedidos[i,29]),;
            aPedidos[i,36],;                 //US
            aPedidos[i,21],;   //JUSTIFICATIVA
            aPedidos[i,30],;
            aPedidos[i,31],;
            aPedidos[i,37],;
            aPedidos[i,38],;
            aPedidos[i,39],;
            aPedidos[i,40],;
            STOD(aPedidos[i,46]),;
            aPedidos[i,47],;
            .F. })
   		
    Next

    //Setar array do aCols do Objeto.
    oLista:SetArray(aColsEx,.T.)

    //Atualiza as informações no grid
    oLista:Refresh()
    
    
Return

/**********************************************************************************************************************************/
/** user function SZ6QRY()                                                                                                     **/
/**1UERY PARA POPULAR TELA DE STATUS */
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/ 

Static Function SZ6QRY(dDtCadi,dDtCadf)

Local aArea 	:= GetArea()
Local dDtCadi := dDtCadi
Local dDtCadf := dDtCadf
Local cQuery  := ""         
Local cdt		:= DDATABASE
Local cHr		:= TIME()
                                          
cQuery := " 	SELECT		 SZ6.Z6_CTRL	CONTROLE
cQuery += "			,SZ6.Z6_CTRLEXC	CTEX
cQuery += "			,SZ6.Z6_FILIAL	FILIAL
cQuery += "			,SZ6.Z6_COD		CODIGO
cQuery += "			,SZ6.Z6_PEDIDO	PEDIDO
cQuery += "			,SZ6.Z6_TPPED	TIPO
cQuery += "			,ACY.ACY_GRPVEN	GRPVEN	
cQuery += "			,SC5.C5_CLIENT	CLIENTE
cQuery += "			,SC5.C5_LOJACLI	LOJA
cQuery += "			,SC5.C5_NOMECLI	DCLIENTE
cQuery += "     ,ACY.ACY_DESCRI DESCRICAOGP
cQuery += "     ,SZ6.Z6_HRCAD HR_CADASTRO
cQuery += "     ,SZ6.Z6_DTCAD DT_CADASTRO
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD))	VC
cQuery += "     ,SZ6.Z6_DTLIM		DTLIM
cQuery += "     ,SZ6.Z6_HRLIMI	HRLIM
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTLIM) + CONVERT(DATETIME,SZ6.Z6_HRLIMI))LIM
cQuery += "     ,SZ6.Z6_DTVP	DT_VAL_LIB
cQuery += "     ,SZ6.Z6_HRVP	HR_VAL_LIB
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVP) + CONVERT(DATETIME,SZ6.Z6_HRVP))	VP
cQuery += "     ,SZ6.Z6_DTVF	DT_VAL_FIN
cQuery += "     ,SZ6.Z6_HRVF	HR_VAL_FIN
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVF) + CONVERT(DATETIME,SZ6.Z6_HRVF))	VF
cQuery += "     ,SZ6.Z6_DTVE	DT_VAL_EST
cQuery += "     ,SZ6.Z6_HRVE	HR_VAL_EST
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVE) + CONVERT(DATETIME,SZ6.Z6_HRVE))VE
cQuery += "     ,SZ6.Z6_DTVFATU	DT_VAL_FAT
cQuery += "     ,SZ6.Z6_HRVFATU	HR_VAL_FAT
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU))VFATU
cQuery += "     ,SZ6.Z6_DTVEMBA	DT_VAL_EMB
cQuery += "     ,SZ6.Z6_HRVEMBA	HR_VAL_EMB
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVEMBA) + CONVERT(DATETIME,SZ6.Z6_HRVEMBA))VEMBA
cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))DATAAT  

cQuery += "     ,SZ6.Z6_DTEMBA	DT_EMB
cQuery += "     ,SZ6.Z6_HREMBA	HR_EMB


cQuery += "     ,SZ6.Z6_JSLIBP	JUSLIBP
cQuery += "     ,SZ6.Z6_JSLIBF	JUSLIBF
cQuery += "     ,SZ6.Z6_JSLIBE	JUSLIBE
cQuery += "     ,SZ6.Z6_JSFATU	JUSFATU
cQuery += "     ,SZ6.Z6_JSEMBA	JUSEMBA
cQuery += "     ,SZ6.Z6_NF			NF
cQuery += "     ,SZ6.Z6_SERIE   SERIE
cQuery += "     ,SZ6.Z6_USLIBP	USLIB
cQuery += "     ,SZ6.Z6_USLIBF	USLIBF
cQuery += "     ,SZ6.Z6_USLIBE	USLIBE
cQuery += "     ,SZ6.Z6_USFATU	USFATU
cQuery += "     ,SZ6.Z6_USEMBA	USEMBA
cQuery += "     ,ISNULL((SELECT SF2.F2_VALMERC	FROM	"+RetSqlName("SF2")+" SF2		WHERE SF2.D_E_L_E_T_ = '' AND SF2.F2_DOC = SZ6.Z6_NF AND SF2.F2_SERIE = SZ6.Z6_SERIE AND SF2.F2_CLIENT = SC5.C5_CLIENT AND SF2.F2_LOJA	= SC5.C5_LOJACLI AND SF2.F2_FILIAL = SZ6.Z6_FILIAL),0)VALORNF
cQuery += "     ,ISNULL(SC5.C5_FRETE,0)	FRETEVL
cQuery += "     ,ISNULL(SC5.C5_TPFRETE,'') TPFRETE
cQuery += "     ,ISNULL((SELECT SA4.A4_NOME	FROM	"+RetSqlName("SA4")+" SA4		WHERE SA4.D_E_L_E_T_ = '' AND SA4.A4_COD = SC5.C5_TRANSP ),'')TRANSP
cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTLIBP) + CONVERT(DATETIME,SZ6.Z6_HRLIBP))	LIBP
cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTLIBF) + CONVERT(DATETIME,SZ6.Z6_HRLIBF))	LIBF
cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTLIBE) + CONVERT(DATETIME,SZ6.Z6_HRLIBE))	LIBE
cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTFATU) + CONVERT(DATETIME,SZ6.Z6_HRFATU))	FATU
cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTEMBA) + CONVERT(DATETIME,SZ6.Z6_HREMBA))	EMBA			
			
cQuery += "		FROM		"+RetSqlName("SZ6")+" SZ6, "
cQuery += "						"+RetSqlName("ACY")+" ACY, "
cQuery += "						"+RetSqlName("SC5")+" SC5 "

cQuery += " 	WHERE		SZ6.D_E_L_E_T_	= '' 

cQuery += "		AND ACY.D_E_L_E_T_	= ''
cQuery += "		AND SZ6.Z6_FILIAL= '" + xFilial("SZ6") + "' " 
cQuery += "		AND SZ6.Z6_PEDIDO	= SC5.C5_NUM
cQuery += "		AND SZ6.Z6_TPPED	= ACY.ACY_GRPVEN
cQuery += "		AND SZ6.Z6_FILIAL	= SC5.C5_FILIAL
cQuery += "		AND SZ6.Z6_TPPED	BETWEEN '"+mv_par01+"'  AND '"+mv_par02+"'
cQuery += "		AND SZ6.Z6_PEDIDO	BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'
cQuery += "		AND SC5.C5_CLIENT	BETWEEN '"+mv_par05+"' AND '"+mv_par07+"'
cQuery += "		AND SC5.C5_LOJACLI	BETWEEN '"+mv_par06+"' AND '"+mv_par08+"'
cQuery += "		AND SZ6.Z6_FILIAL   BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'
cQuery += "		AND SZ6.Z6_DTCAD BETWEEN '"+Dtos(mv_par11) + "' AND '" + Dtos(mv_par12) + "'
cQuery += "		AND SZ6.Z6_DTLIM BETWEEN '"+Dtos(mv_par13) + "' AND '" + Dtos(mv_par14) + "'
//FILTRA LIMITE DE DATAS {"Prazo - Todos","Vencido","No Prazo"} 
									If(cCombo2 = "Vencido") 
									
											cQuery += "      AND
											cQuery += "			CONVERT(DATETIME,CONVERT(DATETIME,SZ6.Z6_DTLIM) + CONVERT(DATETIME,SZ6.Z6_HRLIMI)) <
											cQuery += "			CONVERT(DATETIME,CONVERT(DATETIME,'" + Dtos(cDt) + "') + CONVERT(DATETIME,'" + cHr + "'))
											
									ElseIf(cCombo2 == "No Prazo")
									
											cQuery += "      AND
											cQuery += "			CONVERT(DATETIME,CONVERT(DATETIME,SZ6.Z6_DTLIM) + CONVERT(DATETIME,SZ6.Z6_HRLIMI)) >=
											cQuery += "			CONVERT(DATETIME,CONVERT(DATETIME,'" + Dtos(cDt) + "') + CONVERT(DATETIME,'" + cHr + "'))    
											
									EndIf

If(cCombo <> "Nenhum")
										
						// FILTRA LOCAL 
						cQuery += " 	AND SZ6.Z6_CTRL	IN ( 
						
															If(cCombo = "PC-Cadastrado")										  
																	cQuery += "('A')												 
															ElseIf(cCombo == "PL-Liberacao")
																	cQuery += "('P') 
															ElseIf(cCombo == "PF-Financeiro")
																	cQuery += "('F')
															ElseIf(cCombo == "PE-Estoque")
																	cQuery += "('T') 											
															ElseIf(cCombo == "NF-Faturamento")
																	cQuery += "('U')											
															/*
															ElseIf(cCombo == "Embarcado")
																	cQuery += "('M')
															ElseIf(cCombo == "Inativo")
																	cQuery += "('I')
															ElseIf(cCombo == "Excluido")
																	cQuery += "('E')
															*/												
															Else
																	cQuery += "('A'), ('P'), ('F'), ('T'), ('U')     
															EndIf    
						//FILTRA PELA EXCECOES
						 //1 = SIM
						 //2 = NAO
															If(ALLTRIM(mv_par15)=='1;')
																	cQuery += "		 ,('E')	
															EndIf
															
															If(ALLTRIM(mv_par16)=='1;')
																	cQuery += "		 ,('M')  
															EndIf
															
															If(ALLTRIM(mv_par17)=='1;')	
																	cQuery += "		 ,('I') 
															EndIf	
						
						cQuery += "		 ) 
						
ElseIf(cCombo == "Nenhum") 

						cQuery += " 	AND SZ6.Z6_CTRL	IN ( 'XXXX'
						
															If(ALLTRIM(mv_par15)=='1;')
																	cQuery += "		 ,('E')																	
															EndIf
															
															If(ALLTRIM(mv_par16)=='1;')
																	cQuery += "		 ,('M') 
															EndIf       
															
															If(ALLTRIM(mv_par17)=='1;')	
																	cQuery += "		 ,('I') 
															EndIf	
						
						
						cQuery += "	)										  
																				

EndIf

cQuery += "	ORDER BY SZ6.Z6_DTCAD, SZ6.Z6_HRCAD, SZ6.Z6_PEDIDO,SZ6.Z6_COD		
 
//Define o alias da query
TcQuery cQuery New Alias "SZ6QRY"

RestArea(aArea) 

return Nil                                             


 

/**********************************************************************************************************************************/
/** Compras                                                                                                                      **/                                                                                                        
/** Tela Justificativa.                             **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                   **/ 
/**********************************************************************************************************************************/
User Function AviEmb(cTxde,cTxhe)
	Local aArea 		:= GetArea()
	Private oTelae 		:= Nil
	Private cGetAvi		:= SPACE(45)
	Private	cSeri		:= ""
	Private	cN			:= ""
	Private cDtAtu		:= STOD("00000000")
	Private cHrAtu		:= ""  
	Private cDtFat		:= STOD("00000000")
	Private cHrFat		:= ""  
	Private cClien		:= ""
	Private cNump		:= ""
   
	//Tela
	DEFINE MSDIALOG oTelae Title "" Pixel Style 128 From 145,000 To 370,400

		//Grupo1
		@ 003, 005 To 90, 198 Title "Aviso de Embarque - Informe a Chave da Nota Fiscal"

		//Caixa de Texto oGetAvi:SetFocus()
		//@ 016, 015 GET oGetJus VAR cGetJus OF oDlg MULTILINE SIZE 171, 034 COLORS 0, 16777215 HSCROLL PIXEL
		oTxde:= tSay():New(016,020,{||'Chave NFe: ' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		@ 015,052 MSGET oGetAvi VAR cGetAvi SIZE 140,4 OF oTelae PIXEL VALID U_ValChNfe(cGetAvi) PICTURE "@!" 

		oTxde:= tSay():New(40,031,{||'Cliente: '+cClien+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,130,20)
		oTxhe:= tSay():New(30,022,{||'Serie/Nota:  '+cSeri+" / "+cN+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)  

		oTxde:= tSay():New(60,010,{||'Data Fatura: '+DTOC(cDtFat)+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		oTxhe:= tSay():New(70,010,{||'Hora Fatura: '+SUBSTR(cHrFat,1,8)+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)

		oTxde:= tSay():New(60,120,{||'Data Embarque: '+DTOC(cDtAtu)+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
		oTxhe:= tSay():New(70,120,{||'Hora Embarque: '+SUBSTR(cHrAtu,1,8)+'' },oTelae,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)

		//Botão para gravar justificativa
		@ 094, 030 Button "Confirmar" Size 040, 015 Pixel Of oTelae Action {||U_GrvEm(cNump),oGetAvi:SetFocus()  } 
		@ 094, 130 Button "Cancelar" Size 040, 015 Pixel Of oTelae Action Close(oTelae) 

	//Inicia a tela
	Activate MsDialog oTelae Centered 
  
  RestArea(aArea) 

Return Nil                      
/**********************************************************************************************************************************/
/** Compras                                                                                                                      **/                                                                                                        
/** Tela Justificativa.                             **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                   **/ 
/**********************************************************************************************************************************/
User Function GrvEm(cNump)

	Local aArea := GetArea()
	
//	U_GREMB(cNump,cN,cSeri,cDtFat,cUsuFat)  

	RecLock("SF2",.F.)
		SF2->F2_XEMBDT	:= Date()
		SF2->F2_XEMBHR	:= Time()
		SF2->F2_XEMBUSR	:= RetCodUsr()
	MsUnLock("SF2")
	
	If ExistBlock("KFATR15")
		U_KFATR15("06",cNump,,SF2->F2_DOC,SF2->F2_SERIE)
	Endif
	
	SC5->( DbSetOrder(1))
	If SC5->( MsSeek(xFilial("SC5")+cNump) )
		RecLock("SC5",.F.)
			SC5->C5_XSITLIB := u_KpFatC01(cNump)
		MsUnLock("SC5")
	Endif

	cSeri 		:=  ""
	cN			:=  ""
	cClien		:=  ""
	cDtAtu		:= 	STOD("00000000")
	cHrAtu		:= 	""  
	cDtFat		:= 	STOD("00000000")
	cHrFat		:= 	""
	cNump		:=  ""
	cGetAvi		:=  SPACE(45)

	RestArea(aArea) 

	MsgInfo("Nota Embarcada!")

Return .T. 

/**********************************************************************************************************************************/
/** Compras                                                                                                                      **/                                                                                                        
/** Tela Justificativa.                             **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                   **/ 
/**********************************************************************************************************************************/
User Function ValChNfe(cChave)
	Local aArea 	:= GetArea()
	Local cChave2	:= ALLTRIM(cChave)
	Local nTam		:= Len(ALLTRIM(cChave))
	Local cSerie	:= SUBSTR(ALLTRIM(cChave2),23,3)
	Local cSre      := ""
	Local cNf		:= SUBSTR(ALLTRIM(cChave2),26,9)
	Local lRet		:= .T.
	Local cQuery	:= ""
		
	If(nTam == 44)      
		
		if !existChave("SF2","F2_CHVNFE",cChave,"F2_FILIAL")
			MsgStop("Nota não localizada.")
			oGetAvi:SetFocus()
			lRet :=  .F.
		Endif
		
		If lRet .and. !Empty(SF2->F2_XEMBDT)
			MsgStop("Nota ja embarcada.")
			oGetAvi:SetFocus()
			lRet :=  .F.
		Endif
		
		If !lRet
			cSeri 		:=  ""
			cN			:=  ""
			cClien		:=  ""
			cDtAtu		:= 	STOD("00000000")
			cHrAtu		:= 	""             
			cDtFat		:= 	STOD("00000000")
			cHrFat		:= 	""
			cNump		:=  ""
			cGetAvi		:= SPACE(45)
			
//			MSGBOX(" Nota Não Encontrada ou Inválida" )
			oGetAvi:SetFocus()
			Return lRet
			
		Endif
		
		cSeri 		:= SF2->F2_SERIE
		cN			:= SF2->F2_DOC 
		cDtAtu		:= Date()
		cHrAtu		:= Time()
		cDtFat		:= SF2->F2_EMISSAO
		cHrFat		:= SF2->F2_HORA
		
		If existChave("SD2","D2_DOC+D2_SERIE",cN+cSeri,"D2_FILIAL")
			cNump		:= SD2->D2_PEDIDO 
		Endif
		
		If SF2->F2_TIPO $ "D/B"
			cClien		:= Posicione("SA2",1,xFilial("SA2") + SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_NOME") 
		Else
			cClien		:= Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME") 
		Endif
		
		cClien := AllTrim(cClien)
		
	ElseIf (nTam == 0)
		lRet := .T.
	Else
		cGetAvi	:= SPACE(45)
		MSGBOX("Chave Inválida")
		oGetAvi:SetFocus()
		lRet := .T.
	EndIf
	
	RestArea(aArea) 

return lRet

/**********************************************************************************************************************************/
/** user function UPDDTV()                                                                                                      **/
/** GRAVA DATA E HORA DO LIMITE DE LIBERACAO.           														**/
/**********************************************************************************************************************************/  

Static Function VCTRL(cNfe,cSe,cCtrl)  

Local aArea	:= GetArea()
Local cQuery  := ""  

cQuery := " SELECT	   
cQuery += "	SZ6.Z6_CTRL	CTRL	 
		
cQuery += " FROM "+RetSqlName("SZ6")+" SZ6 "

cQuery += " WHERE	SZ6.D_E_L_E_T_ =	''
cQuery += "	AND SZ6.Z6_NF = '"+cNfe+"'
cQuery += "	AND SZ6.Z6_SERIE = '"+cSe+"' 
cQuery += "	AND SZ6.Z6_CTRL = '"+cCtrl+"'  
cQuery += "		 AND SZ6.Z6_FILIAL= '"+xFilial("SZ6")+"' " 

//Define o alias da query
TcQuery cQuery New Alias "VCTRL"

RestArea(aArea)

Return  

/**********************************************************************************************************************************/
/** user function Z6XF2()                                                                                                     **/
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/ 

Static Function Z6XF2(cChave)//(cSerie,cNfe)

	Local aArea 	:= GetArea()
	Local cQuery  	:= ""         

/*
	cQuery := " 	SELECT SZ6.Z6_COD CODIGO,
	cQuery += "       SZ6.Z6_PEDIDO PEDIDO,
	cQuery += "       SF2.F2_CLIENTE	CLIENTE,
	cQuery += " 	  SZ6.Z6_CTRL	CTRL,
	cQuery += "       SC5.C5_NOMECLI	NOMECLI,
	cQuery += "       CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD)) VC,
	cQuery += "       SZ6.Z6_DTLIM DTLIM,
	cQuery += "       SZ6.Z6_HRLIMI HRLIM,
	cQuery += "       CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU))VFATU,
	cQuery += "       SZ6.Z6_DTVEMBA DT_VAL_EMB,
	cQuery += "       SZ6.Z6_HRVEMBA HR_VAL_EMB,
	cQuery += "       CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVEMBA) + CONVERT(DATETIME,SZ6.Z6_HRVEMBA))VEMBA,
	cQuery += "       CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))DATAAT
	cQuery += "       ,CONVERT(VARCHAR,CONVERT(DATETIME,GETDATE()),112)DTA
	cQuery += "       ,CONVERT(VARCHAR,(CONVERT(TIME,GETDATE())))HRA
	cQuery += "       ,        SF2.F2_DOC	NFE
	cQuery += "       ,        SF2.F2_SERIE	SERIE 
	cQuery += "       ,        SZ6.Z6_DTFATU	DT_FAT
	cQuery += "       ,        SZ6.Z6_HRFATU	HR_FAT
	cQuery += "       ,        CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU))VFATU 

	cQuery += "		FROM		"+RetSqlName("SZ6")+" SZ6, "
	cQuery += "						"+RetSqlName("ACY")+" ACY, "
	cQuery += "						"+RetSqlName("SC5")+" SC5, "
	cQuery += "     			"+RetSqlName("SF2")+"	SF2 " 
	  

	cQuery += "				WHERE SZ6.D_E_L_E_T_ = ''
	cQuery += "  AND SC5.D_E_L_E_T_ = ''
	cQuery += "  AND ACY.D_E_L_E_T_ = ''
	cQuery += "  AND SZ6.Z6_FILIAL=  '" + xFilial("SZ6") + "' " 
	cQuery += "  AND SZ6.Z6_PEDIDO = SC5.C5_NUM
	cQuery += "  AND SZ6.Z6_TPPED = ACY.ACY_GRPVEN
	cQuery += "  AND SZ6.Z6_FILIAL = SC5.C5_FILIAL
	cQuery += "  AND SF2.F2_FILIAL = SZ6.Z6_FILIAL
	cQuery += "  AND SZ6.Z6_SERIE = SF2.F2_SERIE
	cQuery += "  AND SZ6.Z6_NF	   = SF2.F2_DOC
	cQuery += "  AND SC5.C5_CLIENT	=	SF2.F2_CLIENTE
	cQuery += "  AND SZ6.Z6_SERIE = '"+cSerie+"'
	cQuery += "  AND SZ6.Z6_NF = '"+cNfe+"' 

	cQuery += "  AND SZ6.Z6_CTRL = 'U'
*/

	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "	Z6_COD CODIGO "+ENTER
	cQuery += "	,D2_PEDIDO PEDIDO "+ENTER
	cQuery += "	,D2_CLIENTE CLIENTE "+ENTER
	cQuery += "	,Z6_CTRL CTRL "+ENTER
	cQuery += "	,C5_NOMECLI NOMECLI "+ENTER
	cQuery += "	,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD)) VC "+ENTER
	cQuery += "	,Z6_DTLIM "+ENTER
	cQuery += "	,Z6_HRLIMI "+ENTER
	cQuery += "	,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU))VFATU "+ENTER
	cQuery += "	,Z6_DTVEMBA DT_VAL_EMB "+ENTER
	cQuery += "	,SZ6.Z6_HRVEMBA HR_VAL_EMB "+ENTER
	cQuery += "	,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVEMBA) + CONVERT(DATETIME,SZ6.Z6_HRVEMBA))VEMBA "+ENTER
	cQuery += "	,CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))DATAAT "+ENTER
	cQuery += "	,CONVERT(VARCHAR,CONVERT(DATETIME,GETDATE()),112)DTA "+ENTER
	cQuery += "	,CONVERT(VARCHAR,(CONVERT(TIME,GETDATE())))HRA "+ENTER
	cQuery += "	,D2_DOC NFE "+ENTER
	cQuery += "	,D2_SERIE SERIE "+ENTER
	cQuery += "	,SZ6.Z6_DTFATU	DT_FAT "+ENTER
	cQuery += "	,SZ6.Z6_HRFATU	HR_FAT "+ENTER
	cQuery += "	,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU)) VFATU "+ENTER
	cQuery += "	,F2_EMISSAO "+ENTER
	cQuery += "	,F2_K_USRCO "+ENTER
	cQuery += "	,F2_HORA "+ENTER
	cQuery += "	,C5_XSITLIB "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SD2")+" SD2 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND F2_FILIAL = D2_FILIAL "+ENTER
	cQuery += "		AND F2_DOC = D2_DOC "+ENTER
	cQuery += "		AND F2_SERIE = D2_SERIE "+ENTER
	cQuery += "		AND F2_CHVNFE = '"+cChave+"' "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C5_FILIAL = D2_FILIAL "+ENTER
	cQuery += "		AND C5_NUM = D2_PEDIDO "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SZ6")+" SZ6 ON SZ6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND Z6_FILIAL = D2_FILIAL "+ENTER
	cQuery += "		AND Z6_PEDIDO = D2_PEDIDO "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE SD2.D_E_L_E_T_<>'*' "+ENTER
											   
	//Define o alias da query
	TcQuery cQuery New Alias "Z6XF2"

	RestArea(aArea) 

	/*
	A - CADASTRADO	- BR_VERDE
	P - LIBERADO	- BR_AZUL
	F - FINANCEIRO	- R_AMARELO
	T - ESTOQUE	- AVGARMAZEM
	U - FATURAMENTO	- RPMCABEC
	M - EMBARCADO	- OK
	E - EXCLUIDO	- DISABLE
	I - INATIVO 	- BR_PRETO
	*/

return Nil   
 
/**********************************************************************************************************************************/
/** user function ValCor1()                                                                                                      **/
/** Retorna objeto de acordo com validacao                                **/
/**********************************************************************************************************************************/
user function ValCor1(nCtrlEx)

	//VAriaveis auxiliares
	Local aArea 			:= GetArea()
	
	//SE FOR ENVIADO COMO 0, DEVERA CALCULAR O CAMPO DE INATIVO OU EXCLUIDO

		If(nCtrlEx == 4)
	
			Return oPreto
		
		EndIf
		
	RestArea(aArea)

Return ""

 
/**********************************************************************************************************************************/
/** user function ValCor2()                                                                                                      **/
/** Retorna objeto de acordo com validacao                                **/
/**********************************************************************************************************************************/
user function ValCor2(nDtAtu,nDtFin,nDtVal,nExcl,nDtLib,nCt)

	//VAriaveis auxiliares
	Local aArea 			:= GetArea()
	
	//SE FOR ENVIADO COMO 0, DEVERA CALCULAR O CAMPO DE INATIVO OU EXCLUIDO

If(nDtFin == 0)

						Return oBranco
						RestArea(aArea)		
				
ElseIf(nDtVal > 0)
		
				If (nDtFin>nDtAtu)
				     
				     	If (nExcl=3)
						     Return oPink
						     RestArea(aArea)
							ElseIf (nExcl=2)
						     Return oAmarelo
						     RestArea(aArea)
							Else
								 Return oVerde
						     RestArea(aArea)
							EndIf
				     
				ElseIf((nDtFin<nDtAtu))
						 
				     If (nExcl=3)
						     Return oPink
						     RestArea(aArea)
						 ElseIf (nExcl=2)
						     Return oAmarelo
						     RestArea(aArea)
				     Else
								 Return oVermelho
						     RestArea(aArea)
				     EndIf
						 
		    EndIf
		    
ElseIf (nDtLib == 0)		
		
				If (nDtAtu>nDtFin)
		
						Return oLaranja
						RestArea(aArea)
				
				ElseIf(nDtAtu<nDtFin)
		           
						Return oVerde
						RestArea(aArea)
				
				EndIf
		    
ElseIf (nDtLib>nDtFin)
		
				Return oLaranja
				RestArea(aArea)
				
ElseIf(nDtLib<nDtFin)
		           
				Return oVerde
				RestArea(aArea)
EndIf
		
RestArea(aArea)

Return ""

//----------------------------------------------------------------------------------------------------------------//
// Exportacao de dados para o Excel.
//----------------------------------------------------------------------------------------------------------------//
 
User Function TExcel2()
 
Local aCabec := {}
Local aDados := {}  

aCabec := {		"FILIAL",;
							"CODIGO",;
							"PEDIDO",;
							"GRUPO",;
							"CLIENTE",;
							"LOJA",;
							"DESC_CLICNTE",;
							"DT_CADASTRO",;
							"HR_CADASTRO",;
							"VAL_PEDIDO",;
							"JUST_PEDIDO",;
							"VAL_FINANCEIRO",;
							"JUST_ESTOQUE",;
							"VAL_ESTOQUE",;
							"JUST_ESTOQUE",;
							"VAL_FATURAMENTO",;
							"JUST_FATURAMENTO",;
							"VAL_EMBARQUE",;
							"JUST_EMBARQUE",;
							"NOTA",;
							"SERIE",;
							"VALOR_NOTA",;
							"VALOR_FRETE",;
							"TIPO_FRETE",;
							"TRANSPORT",; 
							"DT_EMB",;
							"HR_EMB",;
							}

    For i := 1 to len(aPedidos)
			
            aadd(aDados,{	aPedidos[i,1],;
            							aPedidos[i,2],;
							            aPedidos[i,3],;
							            aPedidos[i,4],;
							            aPedidos[i,22],;
							            aPedidos[i,23],;
							            aPedidos[i,24],;
							            STOD(aPedidos[i,5]),;
							            aPedidos[i,6],;
							            STOD(aPedidos[i,25]),;
							            aPedidos[i,17],;
							            STOD(aPedidos[i,26]),;
							            aPedidos[i,18],;
							            STOD(aPedidos[i,27]),;
							            aPedidos[i,19],;
							            STOD(aPedidos[i,28]),;
							            aPedidos[i,20],;
							            STOD(aPedidos[i,29]),;
							            aPedidos[i,21],;
							            aPedidos[i,30],;
							            aPedidos[i,31],;
							            aPedidos[i,37],;
							            aPedidos[i,38],;
							            aPedidos[i,39],;
							            aPedidos[i,40],;
							            STOD(aPedidos[i,46]),;
							            aPedidos[i,47],;
							             })
   		
    Next    

 
If !ApOleClient("MSExcel")
 
			MsgAlert("Microsoft Excel não instalado!")
 
			Return
 
EndIf

DlgToExcel({ {"ARRAY", "Exportacao para o Excel", aCabec, aDados }})
 
Return   

/**------------------------------------------------------------------------------------------------------------------------------**/
/** static function ProcSx1()                                                                                                    **/
/** processa a criação das perguntas no SX1                                                                                      **/
/**------------------------------------------------------------------------------------------------------------------------------**/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**------------------------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**------------------------------------------------------------------------------------------------------------------------------**/
Static Function ProcSx1()

  // array com os parametros
  Local aParPerg := {}
  
  
  /* aParPerg[]
       aParPerg[n][01] : nome da pergunta
       aParPerg[n][02] : descrição
       aParPerg[n][03] : tipo
       aParPerg[n][04] : tamanho
       aParPerg[n][05] : decimais
       aParPerg[n][06] : indice de pre selecao de combo
       aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )
       aParPerg[n][08] : rotina de validação do SX1
       aParPerg[n][09] : F3
       aParPerg[n][10] : grupo de perguntas
       aParPerg[n][11] : item 1 do combo
       aParPerg[n][11] : item 2 do combo
       aParPerg[n][11] : item 3 do combo
       aParPerg[n][11] : item 4 do combo
       aParPerg[n][11] : item 5 do combo
       aParPerg[n][12] : array de help
  */
        
  //Indice da pergunta
  Local cIndice := "00"
  
  //Parametro mv_ch
  Local cVarCh := "mv_ch0"
  
  //Parametro mv_par
  Local cVarPar := "mv_par00"
  
  //Indice 0
  Local cIdx0 := "0"
  

	//Cria as perguntas do array 01
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Tipo Cliente"                           ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("Z6_TPPED")[01]                                         ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "ACY"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Tipo do Cliente         "        ,;
                     "." }                                      ; // array de help
                  }                                             ;
      )

	//Cria as perguntas do array 02
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Tipo Cliente"                               ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("Z6_TPPED")[01]                       ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "ACY"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Até Tipo Cliente      "         ,;
                     "." }            ; // array de help
                  }                                             ;
      )
  
  //Cria as perguntas do array 03
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Pedido"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("C5_NUM")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SC5"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Do Pedido"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
      
 //Cria as perguntas do array 04
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Pedido"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("C5_NUM")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SC5"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Até Pedido"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
      
      //Cria as perguntas do array 05
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Cliente"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_COD")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe Cliente"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
      
            //Cria as perguntas do array 06
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Loja"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_LOJA")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe  Loja"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
 
 //Cria as perguntas do array 07
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Cliente"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_COD")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe Cliente"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
      
            //Cria as perguntas do array 08
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Loja"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_LOJA")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe Cliente"           ,;
                     " " }             ; // array de help
                  }                                             ;
      )
      
      //Cria as perguntas do array 09
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Filial"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("C5_FILIAL")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SM0"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"De Filial "           ,;
                     "" }             ; // array de help
                  }                                             ;
      )
      
       //Cria as perguntas do array 10
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Filial"                            ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("C5_FILIAL")[01]                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SM0"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Até Filial "           ,;
                     "" }             ; // array de help
                  }                                             ;
      )
      
             //Cria as perguntas do array 11
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Data Cadastro"                            ,; // descrição
                    "D"                                        ,; // tipo
                    8                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"De data Cadastro "           ,;
                     "" }             ; // array de help
                  }                                             ;
      )
      
             //Cria as perguntas do array 12
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Data Cadastro"                            ,; // descrição
                    "D"                                        ,; // tipo
                    8                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Até Filial "           ,;
                     "" }             ; // array de help
                  }                                             ;
      ) 
      
             //Cria as perguntas do array 13
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Data Vencimento"                            ,; // descrição
                    "D"                                        ,; // tipo
                    8                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"De data Vencimento"           ,;
                     "" }             ; // array de help
                  }                                             ;
      )
      
             //Cria as perguntas do array 14
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Data Vencimento"                            ,; // descrição
                    "D"                                        ,; // tipo
                    8                    ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Até Filial "           ,;
                     "" }             ; // array de help
                  }                                             ;
      )

  //Inicializa as variaveis
  cIndice := "00"
  cIdx0 := "0"
  cVarCh := "mv_ch0"
  cVarPar := "mv_par00"
             
  //Inicializa a barra de progressos                    
  procRegua(len(aParPerg))

  //Loop sobre os parametros a adicionar        
  For nI := 1 to len(aParPerg)
    
    //Incrementa os contadores
    cIndice := soma1(cIndice)
    cIdx0 := soma1(cIdx0)
    cVarCh := "mv_ch" + cIdx0
    cVarPar := "mv_par" + cIndice

    //Incrementa a barra de progressos
    incProc("Criando perguntas " + allTrim(cIndice) + "/" + strZero(len(aParPerg), 2) + "..." )

 
	  //Adiciona o parametro
	  putSX1( aParPerg[nI][01] ,; // nome da pergunta
	          cIndice          ,; // indice
	          aParPerg[nI][02] ,; // descricao portugues
	          aParPerg[nI][02] ,; // descricao espanhol
	          aParPerg[nI][02] ,; // descricao ingles
	          cVarCh           ,; // variavel mv_ch
	          aParPerg[nI][03] ,; // tipo
	          aParPerg[nI][04] ,; // tamanho
	          aParPerg[nI][05] ,; // decimais
	          aParPerg[nI][06] ,; // indice de pre-seleção (combo)
	          aParPerg[nI][07] ,; // tipo do objeto
	          aParPerg[nI][08] ,; // validação
	          aParPerg[nI][09] ,; // F3
	          aParPerg[nI][10] ,; // grupo de perguntas
	          " "              ,; // parametro pyme
	          cVarPar          ,; // variavel mv_par
	          aParPerg[nI][11] ,; // item 1 do combo (portugues)
	          aParPerg[nI][11] ,; // item 1 do combo (espanhol)
	          aParPerg[nI][11] ,; // item 1 do combo (ingles)
	          ""               ,; // conteudo padrao da pergunta
	          aParPerg[nI][12] ,; // item 2 do combo (portugues)
	          aParPerg[nI][12] ,; // item 2 do combo (espanhol)
	          aParPerg[nI][12] ,; // item 2 do combo (ingles)
	          aParPerg[nI][13] ,; // item 3 do combo (portugues)
	          aParPerg[nI][13] ,; // item 3 do combo (espanhol)
	          aParPerg[nI][13] ,; // item 3 do combo (ingles)
	          aParPerg[nI][14] ,; // item 4 do combo (portugues)
	          aParPerg[nI][14] ,; // item 4 do combo (espanhol)
	          aParPerg[nI][14] ,; // item 4 do combo (ingles)
	          aParPerg[nI][15] ,; // item 5 do combo (portugues)
	          aParPerg[nI][15] ,; // item 5 do combo (espanhol)
	          aParPerg[nI][15] ,; // item 5 do combo (ingles)
	          aParPerg[nI][16] ,; // memo de help (portugues)
	          aParPerg[nI][16] ,; // memo de help (espanhol)
	          aParPerg[nI][16] ,; // memo de help (ingles)
	          "" ; // help
	        )
	
  Next nI

Return nil  

/**********************************************************************************************************************************/
/** user function U_KPFATA06()                                                                                                     **/
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/  

Static Function CriaCabec()   //1
    Aadd(aCabecalho, {;
                  "PL",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  1,;					//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			// 
                  
        Aadd(aCabecalho, {;
                  "PC",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
                    
                    //2
    Aadd(aCabecalho, {;
                  "PL",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//                  
                  
                    //3
                    
Aadd(aCabecalho, {;
                  "PF",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//                         
									//4
    Aadd(aCabecalho, {;
                  "PE",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//                  

                  //5
    Aadd(aCabecalho, {;
                  "NF",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//  
                  
                  //6
 Aadd(aCabecalho, {;
                  "EM",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//  
                  
                   //6
 Aadd(aCabecalho, {;
                  "ST",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			// 
                  
                  //7
  Aadd(aCabecalho, {;
                  "Filial",;//X3Titulo()
                  "FILIAL",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  2,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   		//              
                  
                  //8
Aadd(aCabecalho, {;
                  "Codigo",;//X3Titulo()
                  "CODIGO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   
                  
                  //9
Aadd(aCabecalho, {;
                  "Pedido",;//X3Titulo()
                  "PEDIDO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN 
                  
                  //10
Aadd(aCabecalho, {;
                  "Grupo",;//X3Titulo()
                  "GRUPO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  15,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //11 
                  
Aadd(aCabecalho, {;
                  "Cliente",;//X3Titulo()
                  "CLIENTE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  6,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //12  
                  
Aadd(aCabecalho, {;
                  "Loja",;//X3Titulo()
                  "LOJA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  2,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //13
                  
                  
Aadd(aCabecalho, {;
                  "Desc. Cliente",;//X3Titulo()
                  "DESC_CLIENTE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  6,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //14                 
                  
Aadd(aCabecalho, {;
                  "Cadastro",;//X3Titulo()
                  "CADASTRO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //15
                  
Aadd(aCabecalho, {;
                  "HR Cadastro",;//X3Titulo()
                  "HRCADASTRO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
               //16
Aadd(aCabecalho, {;
                  "Val. Pedido",;//X3Titulo()
                  "LIBPEDIDO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN 
                  //17
Aadd(aCabecalho, {;
                  "Lib.Pedido",;//X3Titulo()
                  "LIBPEDIDOU",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                
                //18  
Aadd(aCabecalho, {;
                  "Just. Lib. Pedido",;//X3Titulo()
                  "JUSTIFICATIVA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                  //19
                  
Aadd(aCabecalho, {;
                  "Val. Financeiro",;//X3Titulo()
                  "LIBFATURAMENTO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                   
                 //20 
Aadd(aCabecalho, {;
                  "Lib. Financeiro",;//X3Titulo()
                  "LIBFINANCEIROU",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   
                   
                //21 
Aadd(aCabecalho, {;
                  "Just. Lib. Financeiro",;//X3Titulo()
                  "JUSTIFICATIVA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
							//22
Aadd(aCabecalho, {;
                  "Val. Estoque ",;//X3Titulo()
                  "LIBESTOQUE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  //23
Aadd(aCabecalho, {;
                  "Lib. Estoque",;//X3Titulo()
                  "LIBestoque",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN             
							    //24 
Aadd(aCabecalho, {;
                  "Just. Lib. Estoque",;//X3Titulo()
                  "JUSTIFICATIVA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
               
							//25
Aadd(aCabecalho, {;
                  "Val.Faturamento",;//X3Titulo()
                  "FATURAMENTO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   
                  //26
                  
Aadd(aCabecalho, {;
                  "Us. Fatura",;//X3Titulo()
                  "LIBTURAMENTO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN  
                  
                  //27  
Aadd(aCabecalho, {;
                  "Just. Lib. Faturamento",;//X3Titulo()
                  "JUSTIFICATIVA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  //28
Aadd(aCabecalho, {;
                  "Val.Embarque",;//X3Titulo()
                  "EMBARQUE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  //29
Aadd(aCabecalho, {;
                  "Usr. Embarque",;//X3Titulo()
                  "LIBFATURAMENTO",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN                    
                  
                  //30 
Aadd(aCabecalho, {;
                  "Just. Lib. Embarque",;//X3Titulo()
                  "JUSTIFICATIVA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN 
                  
                                    //31 
Aadd(aCabecalho, {;
                  "Nota",;//X3Titulo()
                  "NOTA",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  
                                    //32 
Aadd(aCabecalho, {;
                  "Serie",;//X3Titulo()
                  "SERIE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
                  

                                    //32 
Aadd(aCabecalho, {;
                  "Valor Nota",;//X3Titulo()
                  "VALORNF",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  2,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "N",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   
                  
                                    //32 
Aadd(aCabecalho, {;
                  "Valor Frete",;//X3Titulo()
                  "VLFRETE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  2,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "N",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN 
                  
                  //32 
Aadd(aCabecalho, {;
                  "Tipo Frete",;//X3Titulo()
                  "TPFRETE",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  1,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN 
                 //32 
Aadd(aCabecalho, {;
                  "Transportadora",;//X3Titulo()
                  "TRANSP",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  20,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "N",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN     
                                              
                  
Aadd(aCabecalho, {;
                  "DT_Embarque",;//X3Titulo()
                  "DTEMB",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN    
                  
                  
Aadd(aCabecalho, {;
                  "HR EMBARQUE",;//X3Titulo()
                  "HREMB",;  //X3_CAMPO
                  "",;		//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN   
               
                  

Return          


/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: existChave														                        	**/
/** DESCRICAO		: valida se o registro existe na tabela                                                  		**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function existChave(_cAlias,cChave,cChaveVlr,cCpoFil)
	// retorno
	Local 	lRet	:= .F.
	// area atual
	Local 	aArea	:= GetArea()
	// query
	Local 	cQuery	:= ""
	// area temporaria
	Local 	cTemp	:= GetNextAlias()
	
	Default cCpoFil	:= Substr(cChave,1,At("_",cChave))+"FILIAL"
	
	// monta a query
	cQuery += "SELECT R_E_C_N_O_ REGNO "+ENTER
	cQuery += "FROM "+RetSqlName(_cAlias)+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND "+cCpoFil+" = '"+xFilial(_cAlias)+"' "+ENTER
	cQuery += "AND "+cChave+" = '"+cChaveVlr+"' "+ENTER
	cQuery += "ORDER BY "+SqlOrder( (_cAlias)->( IndexKey(1) ) )
	
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif 
	
	TcQuery cQuery New Alias (cTemp)
	
	// se retornou algo
	If !(cTemp)->( EOF())
		// posiciona no registro
		(_cAlias)->( DbGoTo( (cTemp)->REGNO ) )
		// se posicionou certo
		If (cTemp)->REGNO == (_cAlias)->( Recno() )
			// atualiza o retorno
			lRet := .T.
		Endif
	Endif 
	
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif 
	
	// restaura a area
	RestArea(aArea)
	// retorna
Return lRet
