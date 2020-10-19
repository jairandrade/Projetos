#include 'protheus.ch'
#include "Totvs.ch"
#include "Rwmake.ch"
#Include "TopConn.ch"
#include "TC04A020.ch"

user function CN120CTAUT()
    
    // Usado para abrir a medição no contrato selecionado no monitor de reparo/garantia
    if Alltrim(FUNNAME()) = 'TC04A020'
        aContrato := {cCN9_CONTRA, cCN9_REVISA, ""}

        return aContrato
    endif

Return( Nil )
