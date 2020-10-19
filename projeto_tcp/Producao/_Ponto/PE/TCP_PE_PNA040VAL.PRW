#Include 'Protheus.ch'

/*/{Protheus.doc} PNA040VAL
Ponto de Entrada criado para validar a linha digitada na atualização de marcações.
@type function
@author luizf
@since 17/08/2016
http://tdn.totvs.com.br/pages/releaseview.action?pageId=43549382
PARAMIXB[ 1 ] = Array com as novas informações digitadas
PARAMIXB[ 2 ] = Array com as novas informações já gravadas anteriormente
PARAMIXB[ 3 ] = Array com calendário
PARAMIXB[ 4 ] = Numérico com a linha posicionada
Estrutura
PARAMIXB[ 1 ][ nX ][ 1 ] = Data da Marcação
PARAMIXB[ 1 ][ nX ][ 3 ][ 1 ] = Horário da Marcação
PARAMIXB[ 1 ][ nX ][ 3 ][ 2 ] = Recno
PARAMIXB[ 1 ][ nX ][ 3 ][ 3 ] = Giro
PARAMIXB[ 1 ][ nX ][ 3 ][ 4 ] = Função
PARAMIXB[ 1 ][ nX ][ 3 ][ 5 ] = Centro de Custo
PARAMIXB[ 1 ][ nX ][ 3 ][ 6 ] = Flag de Apontamento
PARAMIXB[ 1 ][ nX ][ 3 ][ 7 ] = Flag de Marcação
PARAMIXB[ 1 ][ nX ][ 3 ]8 = Data de Marcação
PARAMIXB[ 1 ][ nX ][ 3 ][ 9 ] = Relógio
PARAMIXB[ 1 ][ nX ][ 3 ][ 10 ] = Tipo de Marcação
PARAMIXB[ 1 ][ nX ][ 3 ][ 11 ] = Período de Apontamento
PARAMIXB[ 1 ][ nX ][ 3 ][ 13 ] = Número do REp
PARAMIXB[ 1 ][ nX ][ 3 ][ 14 ] = Tipo de Marcação no REP
PARAMIXB[ 1 ][ nX ][ 3 ][ 15 ] = Tipo de Registro
PARAMIXB[ 1 ][ nX ][ 3 ][ 16 ] = Motivo Modificação do Registro
PARAMIXB[ 1 ][ nX ][ 3 ][ 17 ] = Se marcacoes originais foram recarregadas
PARAMIXB[ 2 ] – Idem ao anterior porém com a linha anteriormente gravada
PARAMIXB [ 3 ][ nX ][ 1 ] - Data
PARAMIXB [ 3 ][ nX ][ 2 ]- Ordem
PARAMIXB [ 3 ][ nX ][ 3 ]- Hora
PARAMIXB [ 3 ][ nX ][ 4 ]- Tipo Marc
PARAMIXB [ 3 ][ nX ][ 5 ]- No Marc.
PARAMIXB [ 3 ][ nX ][ 6 ]- Tipo Dia
PARAMIXB [ 3 ][ nX ][ 7 ]- No Horas
PARAMIXB [ 3 ][ nX ][ 8 ]- Sequência de Turno
PARAMIXB [ 3 ][ nX ][ 9 ]- Horas de Intervalo
PARAMIXB [ 3 ][ nX ][ 10 ]- Exceção (E-Excecao,#E-nao eh excecao)
PARAMIXB [ 3 ][ nX ][ 11 ]- Motivo da Exceção
PARAMIXB [ 3 ][ nX ][ 12 ]- Tipo de Hora Extra Normal
PARAMIXB [ 3 ][ nX ][ 13 ]- Tipo de Hora Extra Noturna
PARAMIXB [ 3 ][ nX ][ 14 ]- Turno de Trabalho
PARAMIXB [ 3 ][ nX ][ 15 ]- Centro de Custo
PARAMIXB [ 3 ][ nX ][ 16 ]- Pagamento de Nona Hora
PARAMIXB [ 3 ][ nX ][ 17 ]- Limite de Marcação Inicial/Final 
PARAMIXB [ 3 ][ nX ][ 18 ]- Código da Refeição
PARAMIXB [ 3 ][ nX ][ 19 ]- Dia e Feriado
PARAMIXB [ 3 ][ nX ][ 20 ]- Tipo de Hora Extra Normal Feriado 
PARAMIXB [ 3 ][ nX ][ 21 ]- Tipo de Hora Extra Noturna Feriado 
PARAMIXB [ 3 ][ nX ][ 22 ]- Descrição do Feriado
PARAMIXB [ 3 ][ nX ][ 23 ]- Regra de Apontamento
PARAMIXB [ 3 ][ nX ][ 24 ]- Funcionário está Afastado
PARAMIXB [ 3 ][ nX ][ 25 ] - Tipo do Afastamento do Funcionário
PARAMIXB [ 3 ][ nX ][ 26 ] - Data Inicial do Afastamento do Funcionário
PARAMIXB [ 3 ][ nX ][ 27 ] - Data Final do Afastamento do Funcionário
PARAMIXB[ 4 ] – Número da linha posicionada
/*/
User Function PNA040VAL()

LOCAL nLinha := PARAMIXB[04]//Linha 
LOCAL aNovo  := PARAMIXB[01][nLinha]//Array com as novas informações digitadas
LOCAL aAnt   := PARAMIXB[02][nLinha]//Array com as novas informações já gravadas anteriormente
LOCAL lRet   := .T.
LOCAL aArea  := GetArea()
Local nFor
DBSelectArea("ZAB")
DBSetOrder(01)//ZAB_FILIAL+ZAB_USER
If ZAB->(MSSeek(xFilial("ZAB")+__cUserID))//Dispensa o processamento quando o usuario nao faz parte da regra.
	Return lRet
	RestArea(aArea)
EndIf


//Se a houve alteração de data valida se o período foi bloqueado para alteração do usuário.
If aNovo[01] <> aAnt[01] 
	If !u_APONV01(aNovo[01]) 
	   Return .F.
	EndIf	
EndIf

//Percorre por todas as batidas, para analisar se houve mudança e abre inconsistência quando periodo bloqueado para o usuario.
For nFor:= 3 To 10
 If aNovo[nFor][01] <> aAnt[nFor][01] .And. !u_APONV01(aAnt[01])
   Return .F.
 EndIf	
Next

Return lRet 

