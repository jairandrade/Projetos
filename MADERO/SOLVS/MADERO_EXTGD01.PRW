
#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} EXTGD01
(Extrator GoodData relatório de ordens de Produção)
@type function
@author fenon
@since 02/08/2018
@version 1.0
/*/
User Function EXTGD01()
Local cAliasGD, cTabela := ""
              
	//Prepare Enviroonment Empresa "01" Filial "01GDIN0004" Modulo "EST"   
	//RPCSetType( 3 ) // Não consome licença de uso
	
	// Gera dados para gravação na tabela auxiliar
	EXTGD01A()
	
	// Transfere tabela para o banco do GoodData
	cAliasGD := "Z51"
	cTabela  := "Z51010"	
	
	//EXTGD01B(cAliasGD, cTabela)
	conout( "Fim da extracao da tabela " + cTabela  + Chr(13) + Chr(10))

		
	//RESET ENVIRONMENT
	
Return


/*/{Protheus.doc} EXTGD01A
(Compilar informações para a tabela auxiliar)
@type function
@author fenon
@since 02/08/2018
@version 1.0
/*/
Static Function EXTGD01A()
Local dDtFech 	:= GETMV("MV_ULMES")
Local dDatLeOP	:= GETMV("MV_XDTOP")
	
	If Alltrim(dtos(dDatLeOP)) == ""
		conout( "O parâmetro MV_XDTOP não existe ou não foi preenchido!" + Chr(13) + Chr(10))
		//alert(dtos(dDatLeOP))
		Return
	Endif
	
	cSql := " SELECT * FROM " + RetSqlName('SC2') + " SC2 "
	cSql += " WHERE C2_FILIAL = '" + xFilial('SC2') + "' AND C2_DATRF <> '' AND C2_DATRF >= '" + dtos(dDatLeOP) +"' AND SC2.D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	
	TcQuery cSql NEW ALIAS "QRY"
	QRY->(DbGotop())                         
	Do While QRY->(!Eof())
	
		cNumOP := QRY->(C2_NUM + C2_ITEM + C2_SEQUEN)		
		
		cSql := " SELECT D3_COD, SUM(D3_QUANT) D3_QUANT, SUM(D3_CUSTO1) D3_CUSTO1 
		cSql += " FROM " + RetSqlName('SD3') + " SD3 " 
		cSql += " WHERE D3_FILIAL = '" + xFilial('SD3') + "' AND D3_OP = '" + cNumOP + "' AND SD3.D_E_L_E_T_ = ' ' GROUP BY D3_COD "	
		cSql := ChangeQuery(cSql)
	
		TcQuery cSql NEW ALIAS "QRY_D3"
		QRY_D3->(DbGotop())            
		
		Do While QRY_D3->(!Eof())
			DbSelectArea("Z51")
			If QRY->C2_PRODUTO = QRY_D3->D3_COD
				DbSetOrder(2) // PARODUTO ACABADO
			Else
				DbSetOrder(1) // MATERIA PRIMA
			Endif
			
			If SUBSTR(QRY_D3->D3_COD,1,3) == "MOD"
				EXTGD01M(SUBSTR(QRY_D3->D3_COD,3,15), cNumOP) // Abre os dados da mão de obra
				QRY_D3->(dbSkip())
				Loop
			Endif
			
			If Z51->(DbSeek(xFilial("Z51") + PADR(cNumOP,14," ") + QRY_D3->D3_COD))
				RecLock("Z51",.F.)
			Else
				RecLock("Z51",.T.)
				Z51->Z51_NUMOP := cNumOP
			Endif
			
			SB1->(dbSetOrder(1))
			SB1->(dbSeek( xFilial("SB1") + QRY_D3->D3_COD ))
			
			SD4->(dbSetOrder(1))
			SD4->(dbSeek( xFilial("SD4") + QRY_D3->D3_COD + cNumOP))
					
			Z51->Z51_CODMP	:= iif(QRY->C2_PRODUTO = QRY_D3->D3_COD, "", QRY_D3->D3_COD) 
			Z51->Z51_DSMP	:= iif(QRY->C2_PRODUTO = QRY_D3->D3_COD, "", SB1->B1_DESC)
			Z51->Z51_CODPA	:= iif(QRY->C2_PRODUTO = QRY_D3->D3_COD, QRY_D3->D3_COD, "")
			Z51->Z51_DSPA	:= iif(QRY->C2_PRODUTO = QRY_D3->D3_COD, SB1->B1_DESC, "")
			Z51->Z51_QTDPLA	:= iif(QRY->C2_PRODUTO = QRY_D3->D3_COD, QRY->C2_QUANT, SD4->D4_QUANT)			
			Z51->Z51_QTDREA	:= QRY_D3->D3_QUANT
			Z51->Z51_CUSUNI	:= QRY_D3->D3_CUSTO1 / QRY_D3->D3_QUANT
			Z51->Z51_CUSPL	:= Z51->Z51_QTDPLA * Z51->Z51_CUSUNI
			Z51->Z51_CUSREA	:= QRY_D3->D3_CUSTO1
			Z51->Z51_DTCONC	:= stod(QRY->C2_DATRF)
			
			Z51->( MsUnLock())
			
			QRY_D3->(dbSkip())
		EndDo
	            
		QRY_D3->(DbCloseArea())
				
		
		QRY->(dbSkip())
	EndDo	            
	QRY->(DbCloseArea())

	PutMv ("MV_XDTOP", dDtFech)

Return


/*/{Protheus.doc} EXTGD01M
(Abre os dados de mão de obra na contabilidade)
@type function
@author Fernando Nonato
@since 13/08/2018
@version 1.0
/*/
Static Function EXTGD01M(cCCusto, cNumOP)
	// Seleciona o valor total de todas contas contábeis
	cSql := " SELECT CT2_DEBITO, SUM(CT2_VALOR) CT2_VALOR "
	cSql += " FROM " + RetSqlName('CT2') + " CT2 " 
	cSql += " WHERE CT2_FILIAL = '" + xFilial('CT2') + "' AND CT2_CCD = '" + alltrim(cCCusto) + "' AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY CT2_DEBITO "
	cSql := ChangeQuery(cSql)
	
	TcQuery cSql NEW ALIAS "QRY_CT2"
	QRY_CT2->(DbGotop())            
		
	Do While QRY_CT2->(!Eof())
		DbSelectArea("Z51")
		DbSetOrder(1) // MATERIA PRIMA
				
		If Z51->(DbSeek(xFilial("Z51") + PADR(cNumOP,14," ") + QRY_CT2->CT2_DEBITO))
			RecLock("Z51",.F.)
		Else
			RecLock("Z51",.T.)
			Z51->Z51_NUMOP := cNumOP
		Endif
		
		CT1->(dbSetOrder(1))
		CT1->(dbSeek( xFilial("CT1") + QRY_CT2->CT2_DEBITO ))
		
		SD4->(dbSetOrder(1))
		SD4->(dbSeek( xFilial("SD4") + QRY_D3->D3_CODIGO + cNumOP))
		
		Z51->Z51_FILIAL	:= xFilial("Z51")
		Z51->Z51_CODMP	:= QRY_D3->D3_CODIGO 
		Z51->Z51_DSMP	:= CT1_DESC01
		Z51->Z51_QTDPLA	:= SD4->D4_QUANT
		Z51->Z51_QTDREA	:= QRY_D3->D3_QUANT
		Z51->Z51_CUSUNI	:= QRY_CT2->CT2_VALOR / QRY_D3->D3_QUANT 
		Z51->Z51_CUSPL	:= Z51->Z51_QTDPLA * Z51->Z51_CUSUNI
		Z51->Z51_CUSREA	:= QRY_CT2->CT2_VALOR
		Z51->Z51_DTCONC	:= stod(QRY->C2_DATRF)
				
		Z51->( MsUnLock())
		Z51->(dbSkip())
		QRY_CT2->(dbSkip())
	EndDo
            
	QRY_CT2->(DbCloseArea())
	
Return

/*/{Protheus.doc} EXTGD01B
(Gerar dados o banco de dados do GoodData)
@type function
@author Fernando Nonato
@since 02/08/2018
@version 1.0
@param cAliasGD, character, (Descrição do parâmetro)
@param cTabela, character, (Descrição do parâmetro)
/*/
Static Function EXTGD01B(cAliasGD, cTabela)
Local nHndERP 	:= AdvConnection()
Local cDbGData 	:= GETMV("GD_BANCO") //"MSSQL/C0B83F_915_GOODDATA"	//Comunicação com TSS
Local cSrvGData := GETMV("GD_SERVER")// "DBAASLSN001002P.dbaas.intera.local:37000"		//IP do servidor a ser acessado  
Local nHndGData	:= -1
Local cSql 		:= ""
Local aSQL		:= {}  
Local i         :=0  
 
	
	conout( Chr(13) + Chr(10)+ "Iniciando Extracao - Tabela: " + cTabela   + Chr(13) + Chr(10))
	
	DbSelectArea(cAliasGD)
	DbSetORder(1)
	DbGotop()
	
	// Gera clausula de insert
	aStruct	:=	(cAliasGD)->(DBStruct())
 
	cValue 	:= ""
	While !(cAliasGD)->(EOF())
		
		// Monta clausula insert
		cSql 	:= "INSERT INTO " + cTabela + " ( "
		cValue 	:= ""
		For i := 1 to len(aStruct)

			cCampo := aStruct[i][1]										
			cSql += cCampo + ", "
			
			Do Case
			Case aStruct[i][2] = "N"
				cValue += alltrim(str( &(cAliasGD + '->' + aStruct[i][1]))) + ", "
			Case aStruct[i][2] = "D"
				cValue += "'" + dtos(&(cAliasGD + '->' + aStruct[i][1])) + "', "							
			Case aStruct[i][2] = "M"				
				cValue += "Cast('" + &(cAliasGD + '->' + aStruct[i][1]) + "' As varbinary(max)) , "
			Case aStruct[i][2] = "L"
				cValue += "'" + iif(&(cAliasGD + '->' + aStruct[i][1]),"T","F") + "', "
			Otherwise
				cValue += "'" + &(cAliasGD + '->' + aStruct[i][1]) + "', "
			EndCase											
		Next i
		cSql += " R_E_C_N_O_ ) VALUES ( "
		cSql += cValue		
		cSql += str((cAliasGD)->(RECNO())) + " ) "
		
		AADD(aSQL,cSql)
		
		(cAliasGD)->(dbSkip())
	Enddo	

 	// Cria uma conexão com um outro banco, outro DBAcces
	nHndGData := TcLink( cDbGData, cSrvGData, 7891 )
	
	If nHndGData < 0
    	UserException( "Falha ao conectar com " + cDbGData + " em " + cSrvGData )
  	Endif
	
	If TcCanOpen(cTabela)  
  		lOk := TcDelFile(cTabela)  
  		If lOk    
  			conout("Tabela " + cTabela + " apagada."  + Chr(13) + Chr(10))  			  			 
  		Else    
  			conout("Falha ao apagar " + cTabela + " : " +  TcSqlError())  
  		Endif
  	Else  
  		conout("Tabela " + cTabela + " nao encontrada."  + Chr(13) + Chr(10))
  	Endif
  	
  	// Cria Tabela para inserir dados.
  	DBCreate( cTabela, aStruct, 'TOPCONN' )
  	conout("Tabela " + cTabela + " criado na base GD."  + Chr(13) + Chr(10))
  			
	For i := 1 to len(aSQL)
			
		// Executa inert
  		nStatus := TCSqlExec(aSQL[i])
	   
		if (nStatus < 0)
			conout("************************************************************************"  + Chr(13) + Chr(10))
			conout("TCSQLError() " + TCSQLError()  + Chr(13) + Chr(10))			
			conout(aSQL[i]  + Chr(13) + Chr(10))
			conout("************************************************************************"  + Chr(13) + Chr(10))
		endif
	 Next i  
	 
	 
  	// Fecha a conexão com o Oracle
  	TcUnlink( nHndGData )
  	conout( "Banco GoodData desconectado"  + Chr(13) + Chr(10))
	       	  
Return

