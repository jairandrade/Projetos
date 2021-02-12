#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

//==================================================================================================//
//	Programa: SCHDPACK 	|	Autor: Luis Paulo									|	Data: 01/06/2018//
//==================================================================================================//
//	Descrição: Funcao para executar o pack na tabela ZPV			  								//
//																									//
//==================================================================================================//
User Function SCHDPACK()
	
Prepare Environment Empresa "04" Filial "01"
U_ZPVPACKA() 

Return()


User Function ZPVPACKA()
Conout("")
Conout("Executando Pack na Tabela ZPV: " + Dtoc(Date()) + " - " + Time())

DbSelectArea('ZPV')
//ZPV->(__DBPack())

Conout("")
Conout("Pack na Tabela ZPV Finalizado com Sucesso!!! " + Dtoc(Date()) + " - " + Time())
Conout("")
Return()