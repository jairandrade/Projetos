//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} Est015
Função que cria um exemplo de FWMsExcel MVE - Movimentações de Estoque.
@author Contim
@alesince 03/08/2018
@version 1.0
    u_Est015()
/*/
 
User Function Est015()
	
    Local aArea        := GetArea()
    Local cQuery        := ""
    Local cQuer2        := ""
    Local oFWMsExcel
    Local oExcel
    Local aRetorno  := {}						//Array de retorno da CalcEst()
    Local nEsti_un := 0
	Local nVifim := 0
	Local nVi_cm1  := 0
	Local nEstf_un := 0
	Local nVffim := 0
	Local nVf_cm1  := 0
	Local sDateFim := ""
    Local sMesFim  := ""
    Local sDateFim1 := ""
    Local sDiaFim  := ""
	Local cAnob := 0
	Local nAnoI := 0
    Local cArquivo    := "MVE_" + Alltrim(DTOS(Date()) + "_"  + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + SUBSTR(TIME(),7,2)) + '.xml'//GetTempPath()+'MVE1.xml'
    Local cPath     := "C:\TEMP\"
	Local lContinua	:= .T.
    Local cEmpBkp	:= cEmpAnt
    Local cFilBkp	:= cFilAnt

	Private cPerg    := "MVEMAD"
	Private lPergunta	:= .T.
	
	If lPergunta
		lContinua := Pergunte(cPerg,.T.)
	Else
		Pergunte(cPerg,.F.)
		lContinua := .T.
	Endif
	
	
	//CriaPerg() 
	//Pergunte(cPerg,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros			 	   			³
	//³ mv_par01	// Da Filial? 										³
	//³ mv_par02	// Ate a Filial?  									³
	//³ mv_par03	// Da Data ?                   				  	    ³
	//³ mv_par04	// Ate a Data ?                   				  	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If lContinua
 
    //Pegando os dados
    cQuery := " SELECT "                       + STR_PULA
    cQuery += "     filial,                   "+ STR_PULA  
    //cQuery += "     emissao,                  "+ STR_PULA
    cQuery += "     conta,                    "+ STR_PULA
    cQuery += "     ctarec,                   "+ STR_PULA
    cQuery += "     ctacust,                  "+ STR_PULA
    cQuery += "     ctadesp,                  "+ STR_PULA
    cQuery += "     produto,                  "+ STR_PULA
    cQuery += "     descricao,                "+ STR_PULA
    cQuery += "     grupo,                    "+ STR_PULA
    cQuery += "     estoque,                  "+ STR_PULA
    cQuery += "     custo_medio,              "+ STR_PULA
    cQuery += "     SUM(quant_compras) qt_comp,            "+ STR_PULA
    cQuery += "     SUM(total_compras) tl_comp,            "+ STR_PULA
    cQuery += "     SUM(bonif_compras) bf_comp,            "+ STR_PULA
    cQuery += "     SUM(bonif_total) bf_total,              "+ STR_PULA
    cQuery += "     SUM(transf_compras) tf_comp,           "+ STR_PULA
    cQuery += "     SUM(transf_total) tf_total,             "+ STR_PULA
    cQuery += "     SUM(total_entradas_un) t_ent_un,        "+ STR_PULA
    cQuery += "     SUM(total_entradas_r) t_ent_r,         "+ STR_PULA
    cQuery += "     SUM(cons_vendas_un) c_vd_un,           "+ STR_PULA
    cQuery += "     SUM(cons_vendas_r) c_vd_r,            "+ STR_PULA
    cQuery += "     SUM(evento_prime_durski_un) ep_dk_un,   "+ STR_PULA
    cQuery += "     SUM(evento_prime_durski_r) ep_dk_r,    "+ STR_PULA 
    cQuery += "     SUM(total_conso_vendas_un) tcsv_un,    "+ STR_PULA
    cQuery += "     SUM(total_conso_vendas_r) tcsv_r,     "+ STR_PULA
    cQuery += "     SUM(ret_marqueting_ind_un) Rm_ind_un,    "+ STR_PULA
    cQuery += "     SUM(ret_marqueting_ind_r) Rm_ind_r,     "+ STR_PULA
    cQuery += "     SUM(perda_qual_ind_un) pq_ind_un,        "+ STR_PULA
    cQuery += "     SUM(perda_qual_ind_r) pq_ind_r,         "+ STR_PULA
    cQuery += "     SUM(ret_troca_desist_un) tc_des_un,      "+ STR_PULA
    cQuery += "     SUM(ret_troca_desist_r) tc_des_r,       "+ STR_PULA
    cQuery += "     SUM(ret_merc_danif_un) me_danif_un,        "+ STR_PULA
    cQuery += "     SUM(ret_merc_danif_r) me_danif_r,         "+ STR_PULA
    cQuery += "     SUM(ret_sob_pre_prep_un) s_pprep_un,      "+ STR_PULA
    cQuery += "     SUM(ret_sob_pre_prep_r) s_pprep_r,       "+ STR_PULA
    cQuery += "     SUM(ret_falha_salao_un) fa_salao_un,       "+ STR_PULA
    cQuery += "     SUM(ret_falha_salao_r) fa_salao_r,        "+ STR_PULA
    cQuery += "     SUM(falha_cozinha_bar_un) fa_c_bar_un,     "+ STR_PULA
    cQuery += "     SUM(ret_desp_validade_un) dp_val_un,     "+ STR_PULA
    cQuery += "     SUM(falha_cozinha_bar_r) fa_c_bar_r,      "+ STR_PULA
    cQuery += "     SUM(ret_desp_validade_r) dp_val_r,      "+ STR_PULA
    cQuery += "     SUM(ret_desp_descong_un) ddesc_un,      "+ STR_PULA
    cQuery += "     SUM(ret_desp_descong_r) ddesc_r,       "+ STR_PULA
    cQuery += "     SUM(total_desp_un) t_desp_un,            "+ STR_PULA
    cQuery += "     SUM(total_desp_r) t_desp_r,             "+ STR_PULA
    cQuery += "     SUM(aj_conso_vendas_un) aj_c_v_un,       "+ STR_PULA
    cQuery += "     SUM(aj_conso_vendas_r) aj_c_v_r,        "+ STR_PULA
    cQuery += "     SUM(AJ_INVENTARIO_UN) AJ_INV_UN,         "+ STR_PULA
    cQuery += "     SUM(AJ_INVENTARIO_R) AJ_INV_R,          "+ STR_PULA
    cQuery += "     SUM(tot_desp_ajustes_un) t_dp_aj_un,      "+ STR_PULA
    cQuery += "     SUM(tot_desp_ajustes_r) t_dp_aj_r,       "+ STR_PULA
    cQuery += "     SUM(ret_testes_un) r_test_un,            "+ STR_PULA
    cQuery += "     SUM(ret_testes_r) r_test_r,             "+ STR_PULA
    cQuery += "     SUM(ret_prime_durski_un) r_pd_un,      "+ STR_PULA
    cQuery += "     SUM(ret_prime_durski_r) r_pd_r,       "+ STR_PULA
    cQuery += "     SUM(retirada_secos_un) r_secos_un,        "+ STR_PULA
    cQuery += "     SUM(retirada_secos_r) r_secos_r,         "+ STR_PULA
    cQuery += "     SUM(tot_cons_aj_secos_un) tcaj_sec_un,     "+ STR_PULA
    cQuery += "     SUM(tot_cons_aj_secos_r) tcaj_sec_r,      "+ STR_PULA
    cQuery += "     SUM(ret_limpeza_un) r_limp_un,           "+ STR_PULA
    cQuery += "     SUM(ret_limpeza_r) r_limp_r,            "+ STR_PULA
    cQuery += "     SUM(desp_limpeza_un) d_limp_un,          "+ STR_PULA
    cQuery += "     SUM(desp_limpeza_r) d_limp_r,           "+ STR_PULA
    cQuery += "     SUM(tot_cons_desp_limpeza_un) tcdl_un, "+ STR_PULA
    cQuery += "     SUM(tot_cons_desp_limpeza_r) tcdl_r,  "+ STR_PULA
    cQuery += "     SUM(ret_enxoval_un) r_enxo_un,           "+ STR_PULA
    cQuery += "     SUM(ret_enxoval_r) r_enxo_r,            "+ STR_PULA  
    cQuery += "     SUM(tot_ret_aj_enxoval_un) traje_un,    "+ STR_PULA
    cQuery += "     SUM(tot_ret_aj_enxoval_r) traje_r,     "+ STR_PULA
    cQuery += "     SUM(ret_uso_consumo_un) r_uso_c_un,       "+ STR_PULA
    cQuery += "     SUM(ret_uso_consumo_r) r_uso_c_r,        "+ STR_PULA
    cQuery += "     SUM(desp_uso_consumo_un) ds_cons_un,      "+ STR_PULA
    cQuery += "     SUM(desp_uso_consumo_r) ds_cons_r,       "+ STR_PULA
    cQuery += "     SUM(tot_cons_desp_uso_cons_un) tcds_c_un,"+ STR_PULA
    cQuery += "     SUM(tot_cons_desp_uso_cons_r) tcds_c_u_r, "+ STR_PULA
    cQuery += "     SUM(cons_al_func_un) c_al_fc_un,          "+ STR_PULA
    cQuery += "     SUM(cons_al_func_r) c_al_fc_r,           "+ STR_PULA
    cQuery += "     SUM(sobra_al_func_un) sal_fc_un,         "+ STR_PULA
    cQuery += "     SUM(sobra_al_func_r) sal_fc_r,          "+ STR_PULA
    cQuery += "     SUM(desperdicio_al_func_un) dal_fc_un,   "+ STR_PULA
    cQuery += "     SUM(desperdicio_al_func_r) dal_fc_r,    "+ STR_PULA
    cQuery += "     SUM(total_consumo_func_un) tc_fc_un,    "+ STR_PULA
    cQuery += "     SUM(total_consumo_func_r) tc_fc_r,     "+ STR_PULA
    cQuery += "     SUM(retirada_uniformes_un) r_unif_un,    "+ STR_PULA
    cQuery += "     SUM(retirada_uniformes_r) r_unif_r,     "+ STR_PULA
    cQuery += "     SUM(total_ajustes_unif_un) taj_unif_un,    "+ STR_PULA
    cQuery += "     SUM(total_ajustes_unif_r) taj_unif_r,     "+ STR_PULA
    cQuery += "     SUM(saida_venda_un) s_venda_un,           "+ STR_PULA
    cQuery += "     SUM(saida_venda_r) s_venda_r,            "+ STR_PULA
    cQuery += "     SUM(saida_transf_un) s_tf_un,          "+ STR_PULA
    cQuery += "     nome_filial,               "+ STR_PULA
    cQuery += "     SUM(saida_transf_r) s_tf_r,           "+ STR_PULA
    cQuery += "     SUM(SAIDA_DEVOLUCAO_UN) S_DEV_UN,     "+ STR_PULA
    cQuery += "     SUM(SAIDA_DEVOLUCAO_R) S_DEV_R,      "+ STR_PULA
    cQuery += "     SUM(total_saidas_un) t_sai_un,          "+ STR_PULA
    cQuery += "     SUM(total_saidas_r) t_sai_r,           "+ STR_PULA
    cQuery += "     SUM(estoque_final_un) EST_F_UN,         "+ STR_PULA
    cQuery += "     SUM(valor_unito_final_r) v_u_fi_r,      "+ STR_PULA
    cQuery += "     SUM(estoque_final_r) e_final_r          "+ STR_PULA
    cQuery += " FROM                          "+ STR_PULA
    cQuery += "     vw_movestoque  WVE        "+ STR_PULA 
    cQuery += " left join  (select B9_FILIAL AS D3_FILIAL, MAX(B9_DATA) AS EMISSAO  from SB9020 where D_E_L_E_T_ = ' ' GROUP BY B9_FILIAL) sb9m  "+ STR_PULA
    cQuery += "   on sb9m.D3_FILIAL = FILIAL  "+ STR_PULA
    cQuery += "     where filial between '"+MV_PAR01+"' AND '"+MV_PAR02+"' and WVE.emissao  between nvl(sb9m.EMISSAO, '"+DTOS(MV_PAR03)+"')  AND '"+DTOS(MV_PAR04)+"'  "+ STR_PULA
    if !empty(MV_PAR05)
    	cQuery += " AND Grupo between  '"+MV_PAR05+"' AND  '"+MV_PAR06+"' "+ STR_PULA
    Endif
	cQuery += " GROUP BY     filial, conta, ctarec, ctacust, ctadesp, produto, descricao, grupo, estoque, custo_medio, nome_filial             "+ STR_PULA
    


    TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
		//oFWMsExcel:AddColumn("Movimento Estoque","Dados","Emissao"				  ,1,1)     
		//Aba 02 - Produtos
		oFWMsExcel:AddworkSheet("Movimento Estoque")
        //Criando a Tabela
        oFWMsExcel:AddTable("Movimento Estoque","Dados")
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Cod Filial"                 ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Descrição Filial"			  ,1,1)
        //oFWMsExcel:AddColumn("Movimento Estoque","Dados","Conta Contábil Estoque" ,1,1)
        //oFWMsExcel:AddColumn("Movimento Estoque","Dados","Conta Contábil Receita" ,1,1)
        //oFWMsExcel:AddColumn("Movimento Estoque","Dados","Conta Contábil Custo"   ,1,1)
        //oFWMsExcel:AddColumn("Movimento Estoque","Dados","Conta Contábil Despesa" ,1,1)
        /*
        LimpStr(QRYPRO->conta),; //4
        LimpStr(QRYPRO->ctarec),;//5
        LimpStr(QRYPRO->ctacust),;//6
        LimpStr(QRYPRO->ctadesp),;//7
                                                                    
        */
        
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Cod Produto"            ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Descrição Produto"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Grupo"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Descrição Grupo de Produtos" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Posição Inicial (UN)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Preço médio Inicial (R$)" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Posição Inicial (R$)" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Compra (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Compra (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Bonificação (UN)" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Bonificação (R$)" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Transferencia (UN)",1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Entrada Transferencia (R$)" ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Entradas (UN)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Entradas R$"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Consolidação Vendas (UN) " ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Consolidação Vendas (R$) " ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Evento Prime/Durski (UN)" ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Evento Prime/Durski (R$)" ,1,1) 
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consolidaçõo de Vendas (UN)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consolidação de Vendas (R$)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Marketing (Indústria) (UN)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Marketing (Indústria) (R$)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Qualidade (Indústria) (UN)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Qualidade (Indústria) (R$)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada troca/desist (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada troca/desist (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Mercadoria Danificada (UN)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Mercadoria Danificada (R$)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Sobra pre-preparo (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Sobra pre-preparo (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Falha Salão (UN)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Falha Salão (R$)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Falha Cozinha/Bar (UN)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Falha Cozinha/Bar (R$)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Desperdicio por Validade (UN)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Desperdicio por Validade (R$)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Desperdicio por Descongelamento (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Desperdicio por Descongelamento (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Desperdícios (UN)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Desperdícios (R$)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Ajuste p/ Consolidação Vendas (UN)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Ajuste p/ Consolidação Vendas (R$)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Ajustes de Inventário (UN)"       ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Ajustes de Inventário (R$)"       ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Desperdícios+Ajustes (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Desperdícios+Ajustes (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Testes (UN)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Testes (R$)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Prime/Durski (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Prime/Durski (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Secos (UN)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Secos (R$)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Ajustes Secos (UN)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Ajustes Secos (R$)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Limpeza (UN)"         ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Limpeza (R$)"         ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdicio Limpeza (UN)"        ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdicio Limpeza (R$)"        ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Desperdícios+Ajustes Limpeza (UN)",1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Desperdícios+Ajustes Limpeza (R$)",1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Enxoval (UN)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Enxoval (R$)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Retirada+Ajustes Enxoval (UN)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Retirada+Ajustes Enxoval (R$)"  ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Uso e Consumo (UN)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Uso e Consumo (R$)"      ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdício Uso e Consumo (UN)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdício Uso e Consumo (R$)"     ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Desperdícios+Ajustes Uso e Consumo (UN)",1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Desperdícios+Ajustes Uso e Consumo (R$)",1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Consumo Alimentação Funcionários (UN)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Consumo Alimentação Funcionários (R$)"          ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Sobra Alimentação Funcionários (UN)"         ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Sobra Alimentação Funcionários (R$)"         ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdício Alimentação Funcionarios (UN)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Desperdício Alimentação Funcionarios (R$)"   ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Sobras+Desperdícios+Ajustes Alimentação Funcionários (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Consumo+Sobras+Desperdícios+Ajustes Alimentação Funcionários (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Uniformes (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Retirada Uniformes (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Retirada+Ajustes Uniformes (UN)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Retirada+Ajustes Uniformes (R$)"    ,1,1)
        oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Venda (UN)"           ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Venda (R$)"           ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Transferência (UN)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Transferência (R$)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Devolução (UN)"       ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Saída - Devolução (R$)"       ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Saidas (UN)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Total Saidas (R$)"          ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Estoque Final (UN)"         ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Valor Unitário Final (R$)"     ,1,1)
		oFWMsExcel:AddColumn("Movimento Estoque","Dados","Estoque Final (R$)"         ,1,1)
		
		//dtoc(stod(QRYPRO->emissao)),;  //3
            														
		//Criando as Linhas... Enquanto não for fim da query
        While !(QRYPRO->(EoF()))
        	cQuer2 := " SELECT  B2_QATU est_f_un, B2_CM1 v_u_fi_r, B2_VATU1 e_final_r, B2_LOCAL cLocal FROM SB2020 WHERE B2_COD = '"+ QRYPRO->produto +"' AND B2_FILIAL = '"+ QRYPRO->filial +"' and D_E_L_E_T_ <> '*' "+ STR_PULA 
    		TCQuery cQuer2 New Alias "QRYSLD"
			cDesGrp := Posicione('SBM', 1, xfilial('SBM') + QRYPRO->Grupo, 'BM_DESC')    

        	

    		nEsti_un := 0
			nVifim   := 0
			nVi_cm1  := 0
    		nEstf_un := 0
			nVffim   := 0
			nVf_cm1  := 0

    	    if MV_PAR01 == MV_PAR02
    	    	cFilAnt := MV_PAR01 
    	    else
    	    	cFilAnt := QRYPRO->filial
    	    Endif

			
			aRetorno := CalcEst(QRYPRO->produto,cLocal,MV_PAR03)
			nEsti_un := TRANSFORM(aRetorno[1], "@E 9999999.9999")
			nVi_cm1  := TRANSFORM(aRetorno[2]/aRetorno[1], "@E 999,999,999,999.99")
			nVifim := TRANSFORM(aRetorno[2], "@E 999,999,999,999.99")
			
			sDateFim := DTOS(MV_PAR04)
			
			cAnob := val(substr(sDateFim, 1, 4))/4  
			nAnoI := INT(cAnob)
			if cAnob == nAnoI
			  if substr(sDateFim,7,2) == "29"  
			  	sDateFim := StoD(substr(sDateFim, 1, 4)+StrZero(val(substr(sDateFim, 5, 2))+1,2)+"01")
			  Else
                sDateFim := StoD(substr(sDateFim, 1, 4)+StrZero(val(substr(sDateFim, 5, 2)+1),2)+"01")
				//sDateFim := StoD(substr(sDateFim, 1, 6)+StrZero(val(substr(sDateFim, 7, 2))+1,2))	
			  EndIf
			Else
				if substr(sDateFim,7,2) == "31" .and. substr(sDateFim,5,2) $ ("01|03|05|07|08|10|12") 
			  		sDateFim1:= substr(sDateFim, 1, 4)
                    sMesFim  := StrZero(val(substr(sDateFim, 5, 2))+1,2)
                    sDiaFim  := "01"
				Elseif  substr(sDateFim,7,2) == "30" 
					sDateFim1 := substr(sDateFim, 1, 4)
                    sMesFim  := StrZero(val(substr(sDateFim, 5, 2))+1,2)
                    sDiaFim  := "01"
                Else
                    sDateFim1 := substr(sDateFim, 1, 4)
                    sMesFim   := substr(sDateFim, 5, 2)
                    sDiaFim   := StrZero(val(substr(sDateFim, 7, 2))+1,2)
				EndIf
			Endif 			
			sDateFim := StoD(sDateFim1+sMesFim+sDiaFim)		
			aRetorno := CalcEst(QRYPRO->produto,cLocal,sDateFim)
			nEstf_un := TRANSFORM(aRetorno[1], "@E 9999999.9999")
			nVf_cm1  := TRANSFORM(aRetorno[2]/aRetorno[1], "@E 999,999,999,999.99")
			nVffim   := TRANSFORM(aRetorno[2], "@E 999,999,999,999.99") 
    
            cEmpAnt := cEmpBkp
	        cFilAnt := cFilBkp
	        SM0->( dbSeek( cEmpAnt + cFilAnt ) )

            oFWMsExcel:AddRow("Movimento Estoque","Dados",{QRYPRO->filial,;//1
            														AllTrim(QRYPRO->nome_filial),;//2
            														QRYPRO->produto,;//8
                                                                    QRYPRO->descricao,;//9
                                                                    QRYPRO->Grupo,;
                                                                    LimpStr(cDesGrp),;//10
                                                                    nEsti_un,;//11
                                                                    nVi_cm1,;//12F
                                                                    nVifim,;
                                                                    QRYPRO->qt_comp,;//13 quant_compras
                                                                    QRYPRO->tl_comp,;//14 total_compras
                                                                    QRYPRO->bf_comp,;//15 bonif_compras
                                                                    QRYPRO->bf_total,;//16 bonif_total
                                                                    QRYPRO->tf_comp,;//17 transf_compras
                                                                    QRYPRO->tf_total,;//18 transf_total
                                                                    QRYPRO->t_ent_un,;//19 total_entradas_un
                                                                    QRYPRO->t_ent_r,;//20 total_entradas_r
                                                                    NumNeg(QRYPRO->c_vd_un),;//21 cons_vendas_un
                                                                    NumNeg(QRYPRO->c_vd_r),;//22 cons_vendas_r
                                                                    NumNeg(QRYPRO->ep_dk_un),;//23 evento_prime_durski_un
                                                                    NumNeg(QRYPRO->ep_dk_r),; //24 evento_prime_durski_r
                                                                    NumNeg(QRYPRO->tcsv_un),;//25 total_conso_vendas_un
                                                                    NumNeg(QRYPRO->tcsv_r),;//26 total_conso_vendas_r
                                                                    NumNeg(QRYPRO->Rm_ind_un),;//27 ret_marqueting_ind_UN
                                                                    NumNeg(QRYPRO->Rm_ind_r),;//28 ret_marqueting_R
                                                                    NumNeg(QRYPRO->pq_ind_un),;//29 perda_qual_ind_un
                                                                    NumNeg(QRYPRO->pq_ind_r),;//30 perda_qual_ind_r
                                                                    NumNeg(QRYPRO->tc_des_un),;//31 ret_troca_desist_un
                                                                    NumNeg(QRYPRO->tc_des_r),;//32 ret_troca_desist_r
                                                                    NumNeg(QRYPRO->me_danif_un),;//33 ret_merc_danif_un
                                                                    NumNeg(QRYPRO->me_danif_r),;//34 ret_merc_danif_r
                                                                    NumNeg(QRYPRO->s_pprep_un),;//35 ret_sob_pre_prep_un
                                                                    NumNeg(QRYPRO->s_pprep_r),;//36 ret_sob_pre_prep_r
                                                                    NumNeg(QRYPRO->fa_salao_un),;//37 ret_falha_salao_un
                                                                    NumNeg(QRYPRO->fa_salao_r),;//38 ret_falha_salao_r
                                                                    NumNeg(QRYPRO->fa_c_bar_un),;//39
                                                                    NumNeg(QRYPRO->fa_c_bar_r),;//41
                                                                    NumNeg(QRYPRO->dp_val_un),;//40
                                                                    NumNeg(QRYPRO->dp_val_r),;//42
                                                                    NumNeg(QRYPRO->ddesc_un),;//43 ret_desp_descong_un
                                                                    NumNeg(QRYPRO->ddesc_r),;//44 ret_desp_descong_r
                                                                    NumNeg(QRYPRO->t_desp_un),;//45 total_desp_un
                                                                    NumNeg(QRYPRO->t_desp_r),;//46 total_desp_r
                                                                    QRYPRO->aj_c_v_un,;//47 aj_conso_vendas_un
                                                                    QRYPRO->aj_c_v_r,;//48 aj_conso_vendas_r
                                                                    QRYPRO->AJ_INV_UN,;//49 AJ_INVENTARIO_UN
                                                                    QRYPRO->AJ_INV_R,;//50 AJ_INVENTARIO_R
                                                                    QRYPRO->t_dp_aj_un,;//51 tot_desp_ajustes_un
                                                                    QRYPRO->t_dp_aj_r,;//52 tot_desp_ajustes_r
                                                                    NumNeg(QRYPRO->r_test_un),;//53 QRYPRO->ret_testes_un
                                                                    NumNeg(QRYPRO->r_test_r),;//54 QRYPRO->ret_testes_r
                                                                    NumNeg(QRYPRO->r_pd_un),;//55 QRYPRO->ret_prime_durski_un
                                                                    NumNeg(QRYPRO->r_pd_r),;//56 QRYPRO->ret_prime_durski_r
                                                                    NumNeg(QRYPRO->r_secos_un),;//57 QRYPRO->retirada_secos_un
                                                                    NumNeg(QRYPRO->r_secos_r),;//58 QRYPRO->retirada_secos_r
                                                                    QRYPRO->tcaj_sec_un,;//59 tot_cons_aj_secos_un
                                                                    QRYPRO->tcaj_sec_r,;//60 tot_cons_aj_secos_r
                                                                    NumNeg(QRYPRO->r_limp_un),;//61 ret_limpeza_un
                                                                    NumNeg(QRYPRO->r_limp_r),;//62 ret_limpeza_r
                                                                    NumNeg(QRYPRO->d_limp_un),;//63 desp_limpeza_un
                                                                    NumNeg(QRYPRO->d_limp_r),;//64 desp_limpeza_r
                                                                    QRYPRO->tcdl_un,;//65 tot_cons_desp_limpeza_un
                                                                    QRYPRO->tcdl_r,;//66 tot_cons_desp_limpeza_r
                                                                    NumNeg(QRYPRO->r_enxo_un),;//67 ret_enxoval_un
                                                                    NumNeg(QRYPRO->r_enxo_r),;  //68 ret_enxoval_r
                                                                    NumNeg(QRYPRO->traje_un),;//69 tot_ret_aj_enxoval_un
                                                                    NumNeg(QRYPRO->traje_r),;//70 tot_ret_aj_enxoval_r
                                                                    NumNeg(QRYPRO->r_uso_c_un),;//71 ret_uso_consumo_un
                                                                    NumNeg(QRYPRO->r_uso_c_r),;//72 ret_uso_consumo_r
                                                                    NumNeg(QRYPRO->ds_cons_un),;//73 desp_uso_consumo_un
                                                                    NumNeg(QRYPRO->ds_cons_r),;//74 desp_uso_consumo_r
                                                                    QRYPRO->tcds_c_un,;//75 tot_cons_desp_uso_cons_un
                                                                    QRYPRO->tcds_c_u_r,;//76 tot_cons_desp_uso_cons_r
                                                                    NumNeg(QRYPRO->c_al_fc_un),;//77 cons_al_func_un
                                                                    NumNeg(QRYPRO->c_al_fc_r),;//78 cons_al_func_r
                                                                    NumNeg(QRYPRO->sal_fc_un),;//79 sobra_al_func_un
                                                                    NumNeg(QRYPRO->sal_fc_r),;//80 sobra_al_func_r
                                                                    NumNeg(QRYPRO->dal_fc_un),;//81 desperdicio_al_func_un
                                                                    NumNeg(QRYPRO->dal_fc_r),;//82 desperdicio_al_func_r
                                                                    QRYPRO->tc_fc_un,;//83 total_consumo_func_un
                                                                    QRYPRO->tc_fc_r,;//84 total_consumo_func_r
                                                                    NumNeg(QRYPRO->r_unif_un),;//85 retirada_uniformes_un
                                                                    NumNeg(QRYPRO->r_unif_r),;//86 retirada_uniformes_r
                                                                    QRYPRO->taj_unif_un,;//87 total_ajustes_unif_un
                                                                    QRYPRO->taj_unif_r,;//88 total_ajustes_unif_r
                                                                    NumNeg(QRYPRO->s_venda_un),;//89 saida_venda_un
                                                                    NumNeg(QRYPRO->s_venda_r),;//90 saida_venda_r
                                                                    NumNeg(QRYPRO->s_tf_un),;//91 saida_transf_un
                                                                    NumNeg(QRYPRO->s_tf_r),;//92 saida_transf_r
                                                                    NumNeg(QRYPRO->S_DEV_UN),;//93 SAIDA_DEVOLUCAO_UN
                                                                    NumNeg(QRYPRO->S_DEV_R),;//94 SAIDA_DEVOLUCAO_R
                                                                    NumNeg(QRYPRO->t_sai_un),;//95 total_saidas_un
                                                                    NumNeg(QRYPRO->t_sai_r),;//96 total_saidas_r
                                                                    nEstf_un,;
                                                                    nVf_cm1,;
                                                                    nVffim})
                                                                    
            QRYSLD->(DbCloseArea())
            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo

                                                                    //QRYSLD->est_f_un,;//97 estoque_final_un
                                                                    //QRYSLD->v_u_fi_r,;//98 valor_unito_final_r
                                                                    //QRYSLD->e_final_r}) //99 estoque_final_r

    //If !Empty(oExcel:aWorkSheet)
     
	    //Ativando o arquivo e gerando o xml
	    oFWMsExcel:Activate()
	    oFWMsExcel:GetXMLFile(GetTempPath() + cArquivo)
	    
	         
	    //Abrindo o excel e abrindo o arquivo xml
	    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	    oExcel:WorkBooks:Open(GetTempPath() + cArquivo)     //Abre uma planilha
	    oExcel:SetVisible(.T.)                 //Visualiza a planilha
	    oExcel:Destroy() 
	  //EndIf                       //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Endif
Return

/*
STATIC Function CriaPerg()

Local aPerg

//+-----------------------------------------+
//| Parametros do programa                  |
//| "Da Filial?       "		 "MV_PAR01"     |
//| "Ate a Filial?    "		 "MV_PAR02"     |
//| "Da Data ?        "		 "MV_PAR03"     |
//| "Ate a Data ?     "		 "MV_PAR04"     |
//+-----------------------------------------+


aPerg := {}

AADD(aPerg,{cPerg,"01",STR0072,STR0072,STR0072,"MV_CH1","C",06	,0	,0	,"G","NaoVazio()"		,"mv_par01",""				,""		,""		,""					,""	,""        		,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,"SA1"		,""})		//"Cliente       ?"
AADD(aPerg,{cPerg,"02",STR0073,STR0073,STR0073,"MV_CH2","C",02	,0	,0	,"G","NaoVazio"		,"mv_par02",""				,""		,""		,""				,""	,""        		,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""		,""})		//"Loja          ?"
AADD(aPerg,{cPerg,"03",STR0074,STR0074,STR0074,"MV_CH3","C",10	,0	,0	,"G",""		,"mv_par03",""				,""		,""		,""					,""	,""        		,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""	,""})		//"Envelope de   ?"
AADD(aPerg,{cPerg,"04",STR0075,STR0075,STR0075,"MV_CH4","C",10	,0	,0	,"G","(mv_par04>=mv_par03)"		,"mv_par04",""				,""		,""		,""					,""	,""        		,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""	,""	,""		,""		,""	,""		,""}) 		//"Envelope ate  ?"


Return(Nil)
*/

STATIC Function LimpStr(cSTR)
Local cRetSTR := cSTR

If Alltrim(cRetSTR) = ''
  cRetSTR := '0'
Endif

Return(cRetSTR)


STATIC Function NumNeg(nValor)
Local nValNeg := nValor*-1

Return(nValNeg)