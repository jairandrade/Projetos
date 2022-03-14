#include 'totvs.ch'

/*/{Protheus.doc} User Function CTGFEROM
    Relatório Romaneio de Carga GFER050
    @type  Function
    @author Willian Kaneta
    @since 31/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CTGFEROM()
    Local oReport //objeto que contem o relatorio
	Local aArea := GetArea()
	
	Private cCDMTR, cNMMTR, cCDMTR2, cNMMTR2, cEMISDC, cNMEMIS, cCDREM, cNMREM, cCDDEST2, cNMREM2, cNRCDREM, cNMCDREM, cUFCDREM, cNRCDDES, cNMCDDES, cUFCDDES, cDESUNI,cDSTRP
	Private nTotTrans := 0, nTotVol := 0, nTotPeso  := 0, nTotPesoC := 0
	Private nGW1Trans := 0, nGW1Vol := 0, nGW1Peso  := 0, nGW1PesoC := 0
	Private cGWNTab
	Private cGWTTrp, cGWTTpVc, cGWTOpVp

	If TRepInUse() // teste padrão
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
		oReport:ParamReadOnly()
	EndIf

	If Select(cGWNTab) > 0
		(cGWNTab)->(dbCloseArea())
	EndIf

	RestArea( aArea )

Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ReportDef
Relatorio de Documentos de Carga
Generico.

@sample
ReportDef()

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportDef()
	Local oReport, oSection1, oSection2, oSection3, oSection4, oSection5
	Local aOrdem    := {}
	Local aSituacao := RetSX3Box(Posicione('SX3',2,'GWN_SIT','X3CBox()'),,,1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("GFER050","Listagem de Romaneios de Carga","GFER050", {|oReport| ReportPrint(oReport)},"Emite a listagem dos Romaneios de Carga conforme os parâmetros informados.")  //"Romaneios de Carga"###"Emite a listagem dos Romaneios de Carga conforme os parâmetros informados."
	oReport:SetLandscape()     // define se o relatorio saira deitado
	oReport:HideParamPage()    // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	Pergunte("GFER050",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da secao utilizada pelo relatorio                               ³
	//³                                                                        ³
	//³TRSection():New                                                         ³
	//³ExpO1 : Objeto TReport que a secao pertence                             ³
	//³ExpC2 : Descricao da seçao                                              ³
	//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
	//³        sera considerada como principal para a seção.                   ³
	//³ExpA4 : Array com as Ordens do relatório                                ³
	//³ExpL5 : Carrega campos do SX3 como celulas                              ³
	//³        Default : False                                                 ³
	//³ExpL6 : Carrega ordens do Sindex                                        ³
	//³        Default : False                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Aadd( aOrdem, "Código" ) // "Sequência" //"Codigo"

	oSection1 := TRSection():New(oReport,"Romaneios de Carga",{"(cGWNTab)","GU7","GUU"},aOrdem)  //"Romaneios de Carga"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"GWN_FILIAL","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_FILIAL               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_NRROM" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_NRROM                }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_CDTRP" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_CDTRP                }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"cDSTRP"    ,""         ,"Nome Transportador"  ,"@!"   ,50 ,/*lPixel*/, {||  cDSTRP                             }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_CDTPOP","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_CDTPOP               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_PRIOR" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_PRIOR                }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_SIT"   ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| aSituacao[Val((cGWNTab)->GWN_SIT),3]}/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_DTIMPL","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| StoD((cGWNTab)->GWN_DTIMPL)         }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_HRIMPL","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_HRIMPL               }/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,"GWN_HRSAI" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_HRSAI                }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_DTSAI" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| StoD((cGWNTab)->GWN_DTSAI)          }/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,"cCDMTR"    ,""          ,"Motorista."  		,"@!"       ,5          ,/*lPixel*/, {||cCDMTR                               }/*{|| code-block de impressao }*/) //"Motorista."
	TRCell():New(oSection1,"cNMMTR"    ,""          ,"Nome Motorista"  	,"@!"       ,50         ,/*lPixel*/, {||cNMMTR                               }/*{|| code-block de impressao }*/) //"Nome Motorista"
	TRCell():New(oSection1,"cCDMTR2"   ,""          ,"Motorista 02"  	,"@!"       ,5          ,/*lPixel*/, {||cCDMTR2                              }/*{|| code-block de impressao }*/) //"Motorista 02"
	TRCell():New(oSection1,"cNMMTR2"   ,""          ,"Nome Motorista 02","@!"       ,50         ,/*lPixel*/, {||cNMMTR2                              }/*{|| code-block de impressao }*/) //"Nome Motorista 02"

	TRCell():New(oSection1,"GWN_PLACAD","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_PLACAD               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_PLACAT","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_PLACAT               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_PLACAM","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_PLACAM               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_LACRE" ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_LACRE                }/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,"GWN_CDTPVC","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_CDTPVC               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_CDCLFR","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_CDCLFR               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_DSCLFR","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_DSCLFR               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_NRCIDD","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_NRCIDD               }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GU7_NMCID" ,"GU7"      ,/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/)
	TRCell():New(oSection1,"GWN_CEPD " ,"(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_CEPD                 }/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"GWN_DISTAN","(cGWNTab)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cGWNTab)->GWN_DISTAN               }/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,"nTotTrans" ,""   ,"Tot Valor" 	,"@E 99,999,999.99"  ,13        ,/*lPixel*/, {|| nTotTrans                           }/*{|| code-block de impressao }*/) //"Tot Valor"
	TRCell():New(oSection1,"nTotVol"   ,""   ,"Vol Tot" 	,"@E 99,999.999.99"  ,11        ,/*lPixel*/, {|| nTotVol                             }/*{|| code-block de impressao }*/) //"Vol Tot"
	TRCell():New(oSection1,"nTotPeso"  ,""   ,"Peso Tot" 	,"@E 99,999.99999"   ,11        ,/*lPixel*/, {|| nTotPeso                            }/*{|| code-block de impressao }*/) //"Peso Tot"
	TRCell():New(oSection1,"nTotPesoC" ,""   ,"Peso Cub Tot","@E 9,999,999.9999" ,13        ,/*lPixel*/, {|| nTotPesoC                           }/*{|| code-block de impressao }*/) //"Peso Cub Tot"

	TRPosition():New(oSection1,"GU7",1,{|| xFilial("GU7") + (cGWNTab)->GWN_NRCIDD})

	/***************************************************************************/

	oSection2 := TRSection():New(oSection1,"Documentos de Carga",{"GW1"},aOrdem) //  //"Documentos de Carga"
	oSection2:SetTotalInLine(.F.)
	oSection2:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção
	//cEMISDC, cNMEMIS, cCDREM, cNMREM, cCDDEST2, cNMREM2

	TRCell():New(oSection2,"GW1_SERDC" ,"GW1",/*cTitle*/  ,/*Picture*/         ,5 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"GW1_NRDC"  ,"GW1",/*cTitle*/  ,/*Picture*/         ,12,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"cEMISDC"   ,""   ,"Emissor"   ,/*Picture*/         ,14,/*lPixel*/,  {|| cEMISDC                 }  ) //"Emissor"
	TRCell():New(oSection2,"cNMEMIS"   ,""   ,"Nome "     ,/*Picture*/         ,15,/*lPixel*/,  {|| cNMEMIS                 }  ) //"Nome "
	TRCell():New(oSection2,"GW1_CDTPDC","GW1","Tp Docto"  ,/*Picture*/         ,15,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tp Docto"

	TRCell():New(oSection2,"cCDREM"    ,""   ,"Remetente" ,/*Picture*/         ,16,/*lPixel*/,  {|| cCDREM                  }  ) //"Remetente"
	TRCell():New(oSection2,"cNMCDREM"  ,""   ,"Cidade"    ,/*Picture*/         ,15,/*lPixel*/,  {|| cNMCDREM                }  ) //"Cidade"
	TRCell():New(oSection2,"cUFCDREM"  ,""   ,"UF"	      ,/*Picture*/         ,2 ,/*lPixel*/,  {|| cUFCDREM                }  ) //UF

	TRCell():New(oSection2,"cCDDEST2"  ,""   ,"Destinatário",/*Picture*/         ,16,/*lPixel*/,  {|| cCDDEST2                }  ) //"Destinatário"
	TRCell():New(oSection2,"cNMCDDES"  ,""   ,"Cidade"    ,/*Picture*/         ,15,/*lPixel*/,  {|| cNMCDDES                }  ) //"Cidade"
	TRCell():New(oSection2,"cUFCDDES"  ,""   ,"UF"        ,/*Picture*/         ,2 ,/*lPixel*/,  {|| cUFCDDES                }  ) //"UF"

	TRCell():New(oSection2,"nGW1Trans" ,""   ,"Tot Valor" ,"@E 99,999,999.99"  ,10,/*lPixel*/,  {|| nGW1Trans               }  ) //"Tot Valor"
	TRCell():New(oSection2,"nGW1Vol"   ,""   ,"Vol Tot"   ,"@E 99,999.999.99"  ,10,/*lPixel*/,  {|| nGW1Vol                 }  ) //"Vol Tot"
	TRCell():New(oSection2,"nGW1Peso"  ,""   ,"Peso Tot"  ,"@E 99,999.99"      ,10,/*lPixel*/,  {|| nGW1Peso                }  ) //"Peso Tot"
	TRCell():New(oSection2,"nGW1PesoC" ,""   ,"Peso Cub Tot","@E 9,999,999.99"   ,10,/*lPixel*/,  {|| nGW1PesoC               }  ) //"Peso Cub Tot"

	//TRPosition():New(oSection2,"GU3",1,{|| xFilial("GU3") + GW1->GW1_EMISDC})
	//TRPosition():New(oSection2,"GV5",1,{|| xFilial("GV5") + GW1->GW1_CDTPDC})

	/*************************************************************************/

	oSection3 := TRSection():New(oSection2,"Itens dos Documentos",{"GW8"},aOrdem) // //"Itens dos Documentos"
	oSection3:SetTotalInLine(.F.)
	oSection3:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção

	TRCell():New(oSection3,"GW8_ITEM"   ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_DSITEM" ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_CDCLFR" ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_QTDE"   ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_VOLUME" ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_PESOR"  ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_PESOC"  ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"GW8_VALOR"  ,"GW8",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


	/**************************************************************************/


	oSection4 := TRSection():New(oSection2,"Unitizadores",{"GWB"},aOrdem) //  //"Unitizadores"
	oSection4:SetTotalInLine(.F.)
	oSection4:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção

	TRCell():New(oSection4,"GWB_CDUNIT ","GWB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection4,"cDESUNI"    ,""   ,"Descrição Unit.","@!",50,/*lPixel*/, {||cDESUNI} ) //"Descrição Unit."
	TRCell():New(oSection4,"GWB_QTDE"   ,"GWB",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


	/*************************************************************************************************************************************/

	oSection5 := TRSection():New(oSection2,"Trechos do Itinerário",{"GWU","GU3","GU7"},aOrdem) //  //"Trechos do Itinerário"
	oSection5:SetTotalInLine(.F.)
	oSection5:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção

	TRCell():New(oSection5,"GWU_SEQ"   ,"GWU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GWU_CDTRP" ,"GWU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GU3_NMEMIT","GU3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection5,"GU7_NRCID" ,"GU7",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GU7_NMCID" ,"GU7",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GU7_CDUF"  ,"GU7",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection5,"GWU_DTPENT","GWU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GWU_DTENT" ,"GWU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection5,"GWU_PAGAR" ,"GWU",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRPosition():New(oSection5,"GU3",1,{|| xFilial("GU3") + GWU->GWU_CDTRP})

	/*************************************************************************************************************************************/

	oSection6 := TRSection():New(oSection1,"Pedágio do Romaneio",{"GWT","GU3"},aOrdem) //  //"Adiantamento de Pedágio"
	oSection6:SetTotalInLine(.F.)
	oSection6:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção

	TRCell():New(oSection6,"GWT_SEQ"   	,"GWT",/*cTitle*/,/*Picture*/,3  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_CDTRP"  ,"GWT",/*cTitle*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"cGWTTrp"  	,"", "Nome Transportador" /*cTitle*/,/*Picture*/,30 /*Tamanho*/,/*lPixel*/, {||cGWTTrp} /*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_TPTRP"  ,"GWT",/*cTitle*/,/*Picture*/,7  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_CDTPVC" ,"GWT",/*cTitle*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"cGWTTpVc" 	,"", "Descrição Tip. Veic." /*cTitle*/,/*Picture*/,30 /*Tamanho*/,/*lPixel*/, {||cGWTTpVc} /*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_ADTPDG" ,"GWT",/*cTitle*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_VPVAL"  ,"GWT",/*cTitle*/,/*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_VPNUM"  ,"GWT",/*cTitle*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_VPCDOP" ,"GWT",/*cTitle*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"cGWTOpVp" 	,"", "Nome Oper. Val. Ped." /*cTitle*/,/*Picture*/,30 /*Tamanho*/,/*lPixel*/, {||cGWTOpVp} /*{|| code-block de impressao }*/)
	TRCell():New(oSection6,"GWT_VALEP"  ,"GWT",/*cTitle*/,/*Picture*/,10  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)
/*************************************************************************************************************************************/


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ReportPrint
Relatorio de Romaneio
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local oSection3 := oReport:Section(1):Section(1):Section(1)
	Local oSection4 := oReport:Section(1):Section(1):Section(2)
	Local oSection5 := oReport:Section(1):Section(1):Section(3)
	Local oSection6	:= oReport:Section(1):Section(2)
	Local nRegs     := 0
	Local cQuery
	Local cTabSum

	CarregaDados()

	(cGWNTab)->( dbGoTop() )

	//Calcula a quantidade de registros para utilizar na regra de progressão
	( cGWNTab )->( dbEval( { || nRegs ++ },,{ || ( cGWNTab )->( !Eof() ) } ) )

	oReport:SetMeter( nRegs )

	dbSelectArea(cGWNTab)
	(cGWNTab)->( dbGoTop() )
	While !oReport:Cancel() .And. !(cGWNTab)->( Eof() )
		oSection1:Init()

		oReport:IncMeter()

		dbSelectArea("GUU")
		GUU->(dbSetOrder(1))
		GUU->(dbSeek(xFilial("GUU") + (cGWNTab)->GWN_CDMTR))
		cCDMTR  := GUU->GUU_CDMTR
		cNMMTR  := GUU->GUU_NMMTR

		GUU->(dbSeek(xFilial("GUU") + (cGWNTab)->GWN_CDMTR2))
		cCDMTR2  := GUU->GUU_CDMTR
		cNMMTR2  := GUU->GUU_NMMTR

		nTotTrans := 0
		nTotVol   := 0
		nTotPeso  := 0
		nTotPesoC := 0

		cQuery := ""
		cQuery += " SELECT SUM(ISNULL(GW8.GW8_VALOR,0))  AS GW8_VALOR, "
		cQuery += "        SUM(ISNULL(GW8.GW8_VOLUME,0)) AS GW8_VOLUME,  "
		cQuery += "        SUM(ISNULL(GW8.GW8_PESOR,0))  AS GW8_PESOR, "
		cQuery += "        SUM(ISNULL(GW8.GW8_PESOC,0)) AS GW8_PESOC "
		cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
		cQuery += " LEFT JOIN " + RetSQLName("GW8") + " GW8 ON (GW8.GW8_FILIAL = GW1.GW1_FILIAL AND "
		cQuery += "                          GW8.GW8_CDTPDC = GW1.GW1_CDTPDC AND "
		cQuery += "                          GW8.GW8_EMISDC = GW1.GW1_EMISDC AND "
		cQuery += "                          GW8.GW8_SERDC  = GW1.GW1_SERDC  AND "
		cQuery += "                          GW8.GW8_NRDC   = GW1.GW1_NRDC   AND "
		cQuery += "                          GW8.D_E_L_E_T_ <> '*') "
		cQuery += " WHERE GW1.GW1_FILIAL = '" + (cGWNTab)->GWN_FILIAL + "'"
		cQuery += " AND   GW1.GW1_NRROM  = '" + (cGWNTab)->GWN_NRROM + "'"
		cQuery += " AND   GW1.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY GW8.GW8_VALOR, GW8.GW8_VOLUME,  GW8.GW8_PESOR, GW8.GW8_PESOC "

		cTabSum := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cTabSum, .F., .T.)
		dbSelectArea((cTabSum))

		nTotTrans := (cTabSum)->GW8_VALOR
		nTotVol   := (cTabSum)->GW8_VOLUME
		nTotPeso  := (cTabSum)->GW8_PESOR
		nTotPesoC := (cTabSum)->GW8_PESOC

		If Select(cTabSum) > 0
			(cTabSum)->(dbCloseArea())
		EndIf

		cDSTRP := (cGWNTab)->GU3_NMEMITTRP

		oSection1:PrintLine()

		//Secção 2
		dbSelectArea("GW1")
		GW1->( dbSetOrder(9) )
		GW1->( dbSeek((cGWNTab)->GWN_FILIAL + (cGWNTab)->GWN_NRROM) )
		While !GW1->( Eof() ) .And. (cGWNTab)->GWN_FILIAL + (cGWNTab)->GWN_NRROM = GW1->GW1_FILIAL + GW1->GW1_NRROM

			oSection2:Init()

			dbSelectArea("GU3")
			GU3->(dbSetOrder(1))
			GU3->(dbSeek(xFilial("GU3") + GW1->GW1_EMISDC))
			cEMISDC := GW1->GW1_EMISDC
			cNMEMIS := GU3->GU3_NMEMIT

			GU3->(dbSeek(xFilial("GU3") + GW1->GW1_CDREM))

			GU7->(dbSetOrder(1))
			GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))

			cCDREM   := GW1->GW1_CDREM
			cNMREM   := GU3->GU3_NMEMIT
			cNRCDREM := GU7->GU7_NRCID
			cNMCDREM := GU7->GU7_NMCID
			cUFCDREM := GU7->GU7_CDUF

			GU3->(dbSeek(xFilial("GU3") + GW1->GW1_CDDEST))
			GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))

			cCDDEST2 := GW1->GW1_CDDEST
			cNMREM2  := GU3->GU3_NMEMIT
			cNRCDDES := GU7->GU7_NRCID
			cNMCDDES := GU7->GU7_NMCID
			cUFCDDES := GU7->GU7_CDUF

			dbSelectArea("GW8")
			GW8->(dbSetOrder(1))
			GW8->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))

			nGW1Trans := 0
			nGW1Vol   := 0
			nGW1Peso  := 0
			nGW1PesoC := 0

			While !GW8->( Eof() ) .And. (GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC ) == GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC

				nGW1Trans := nGW1Trans + GW8->GW8_VALOR
				nGW1Vol   := nGW1Vol   + GW8->GW8_VOLUME
				nGW1Peso  := nGW1Peso  + GW8->GW8_PESOR
				nGW1PesoC := nGW1PesoC + GW8->GW8_PESOC

				GW8->( dbSkip() )
			EndDo

			oSection2:PrintLine()

			//Secção 3
			oSection3:Init()

			GW8->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))

			While !GW8->(EOF()) .And. (GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC ) == GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC
				oSection3:PrintLine()
				GW8->( dbSkip() )
			EndDo

			oSection3:Finish()

			//Secção 4
			oSection4:Init()

			dbSelectArea("GWB")
			GWB->(dbSetOrder(1))
			GWB->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRDC))
			While !GWB->( Eof() ) .And. (GWB->GWB_FILIAL + GWB->GWB_NRDC ) == (GW1->GW1_FILIAL + GW1->GW1_NRDC)

				cDESUNI := Posicione("GUG",1,XFILIAL("GUG")+GWB->GWB_CDUNIT,"GUG_DSUNIT")
				oSection4:PrintLine()
				GWB->( dbSkip() )

			EndDo

			oSection4:Finish()

			//Secção 5
			oSection5:Init()
			GWU->(dbSetOrder(1))
			GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
			While !GWU->(EOF()) .And. (GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC ) == (GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)

				GU3->(dbSeek(xFilial("GU3") + GWU->GWU_CDTRP))
				GU7->(dbSeek(xFilial("GU7") + GU3->GU3_NRCID))

				oSection5:PrintLine()

				GWU->( dbSkip() )

			EndDo
			
			oSection5:Finish()

			oSection2:Finish()

			GW1->( dbSkip() )
		EndDo

		If GFXCP12117("GWT_NRROM")	
			// Secção 6
			oSection6:Init()
				
			GWT->(dbSetOrder(1))
			GWT->(dbSeek((cGWNTab)->GWN_FILIAL + (cGWNTab)->GWN_NRROM))
			While !GWT->( Eof() ) .And. (cGWNTab)->GWN_FILIAL + (cGWNTab)->GWN_NRROM = GWT->GWT_FILIAL + GWT->GWT_NRROM
				
				cGWTTrp  := AllTrim(Posicione("GU3",1,xFilial("GU3")+GWT->GWT_CDTRP,"GU3_NMEMIT"))
				cGWTTpVc := AllTrim(Posicione("GV3",1,xFilial("GV3")+GWT->GWT_CDTPVC,"GV3_DSTPVC"))
				cGWTOpVp := AllTrim(Posicione("GU3",1,xFilial("GU3")+GWT->GWT_VPCDOP,"GU3_NMEMIT"))
				
				oSection6:PrintLine()
			
				GWT->(dbSkip())
			EndDo
			
			oSection6:Finish()

		EndIf
		oSection1:Finish()

		(cGWNTab)->( dbSkip() )
	EndDo

Return

/*/{Protheus.doc} CarregaDados
Carrega Dados
@type function
@version 1.0
@author Willian Kaneta
@since 02/11/2020
@return Nil
/*/
Static Function CarregaDados()
	Local cQuery := ""

	cQuery += " SELECT GWN_FILIAL, GWN.GWN_NRROM,  GWN.GWN_CDTPOP, GWN.GWN_CDCLFR, GWN.GWN_CDTRP,  GWN.GWN_CDMTR,  GWN.GWN_CDMTR2, "
	cQuery += "        GWN.GWN_CDTPVC, GWN.GWN_PLACAD, GWN.GWN_PLACAT, GWN.GWN_PLACAM, GWN.GWN_SIT,    GWN.GWN_DTIMPL, GWN.GWN_HRIMPL, "
	cQuery += "        GWN.GWN_CALC,   GWN.GWN_PRIOR,  GWN.GWN_DTSAI,  GWN.GWN_HRSAI,  GWN.GWN_DISTAN, GWN.GWN_NRCIDD, GWN.GWN_CEPD,   "
	cQuery += "        GU3TRP.GU3_NMEMIT GU3_NMEMITTRP, GUB.GUB_DSCLFR GWN_DSCLFR"
	cQuery += " , GWN.GWN_LACRE "	
	cQuery += " FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " LEFT JOIN " + RetSQLName("GUB") + " GUB ON (GWN.GWN_CDCLFR = GUB.GUB_CDCLFR AND GUB.D_E_L_E_T_ <> '*') "
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3TRP ON (GWN.GWN_CDTRP = GU3TRP.GU3_CDEMIT AND GU3TRP.D_E_L_E_T_ <> '*') "
	cQuery += " WHERE  GWN.D_E_L_E_T_ <> '*'"

	//cQuery += IIF(MV_PAR05==4," AND GWN.GWN_SIT  >= '0' " ," AND GWN.GWN_SIT  =  '" + cValToChar(MV_PAR05)+ "'")
	//if MV_PAR06 != 3
	//	cQuery += IIF(MV_PAR06==1," AND  GWN.GWN_CALC  = '1' " ," AND  GWN.GWN_CALC <> '1' " )
	//EndIf

	cQuery += " AND  GWN.GWN_FILIAL >= '010101'"
	cQuery += " AND  GWN.GWN_NRROM  >= '" + cRmIni + "'"
	cQuery += " AND  GWN.GWN_NRROM  <= '" + cRmFim + "'"

	cQuery += " ORDER BY GWN_FILIAL, GWN_NRROM "

	cGWNTab := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cGWNTab, .F., .T.)
	dbSelectArea((cGWNTab))
	(cGWNTab)->( dbGoTop() )
Return
