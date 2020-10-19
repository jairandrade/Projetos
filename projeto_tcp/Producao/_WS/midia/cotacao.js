/*!
 * Rotina ordena
 * -------------    
 * 
 * Ordena dados da tabela de produtos no html
 * Data: 01/11/13
 * Analista: Lucas Chagas                        
 * 
 * Retorno esperado: nenhum
 */
function ordena(clIdx) {

    var idx = new Number(0);

    switch (clIdx) {
        case 'img1':
            idx = 0;
            break;

        case 'img2':
            idx = 1;
            break;

        case 'img3':
            idx = 2;
            break;

        case 'img4':
            idx = 3;
            break;

        case 'img5':
            idx = 4;
            break;

        case 'img6':
            idx = 5;
            break;

        case 'img7':
            idx = 6;
            break;
    }

    if (ColOrder.getInstance().getCampo() === idx) {
        if (ColOrder.getInstance().getSentido().equal('0')) {
            ColOrder.getInstance().setSentido('1');
            ColOrder.getInstance().setCol(clIdx);
        } else {
            ColOrder.getInstance().setSentido('0');
            ColOrder.getInstance().setCol(clIdx);
        }
        ordenaItem();
    } else {
        ColOrder.getInstance().setCampo(-1);
        ColOrder.getInstance().setSentido('0');
        ColOrder.getInstance().setCol(clIdx);
        ordenaItem();
        ColOrder.getInstance().setCampo(idx);
    }
}

/*!
 * Rotina ordenaItem()
 * -------------------    
 * 
 * Disparada pela oderna, a rotina redefine a tabela para ordenas os dados
 * Data: 01/11/13
 * Analista: Lucas Chagas                        
 * 
 * Retorno esperado: nenhum
 */
function ordenaItem() {

    var objItens = document.getElementById('itens');
    var aIdx = [];
    for (var i = 0; i < objItens.rows.length; i++) {
        switch (ColOrder.getInstance().getCol()) {
            case "img1":
                aIdx.push([objItens.rows[i].cells[0].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img2":
                aIdx.push([objItens.rows[i].cells[1].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img3":
                aIdx.push([objItens.rows[i].cells[2].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img4":
                aIdx.push([objItens.rows[i].cells[3].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img5":
                aIdx.push([objItens.rows[i].cells[4].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img6":
                aIdx.push([objItens.rows[i].cells[5].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;

            case "img7":
                aIdx.push([objItens.rows[i].cells[6].childNodes[0].data, objItens.rows[i].rowIndex]);
                break;
        }
    }

    if (ColOrder.getInstance().getCampo() === -1) {
        aIdx = aIdx.sort();
    } else {
        if (ColOrder.getInstance().getSentido().equal('0')) {
            aIdx = aIdx.sort();
        } else {
            aIdx = aIdx.reverse();
        }
    }

    if (!ColOrder.getInstance().getSentido().equal("")) {
        var newrows = [];
        for (var i = 0; i < aIdx.length; i++) {
            newrows[newrows.length] = objItens.rows[aIdx[i][1] - 1];
        }

        while (objItens.rows.length > 0) {
            objItens.deleteRow(0);
        }

        for (var i = 0; i < newrows.length; i++) {
            var nRow = objItens.insertRow(objItens.rows.length);

            while (newrows[i].cells.length > 0) {
                nRow.appendChild(newrows[i].cells[0]);
            }
        }
        delete newrows;
    }
}

/*!
 * Rotina defineLang
 * -----------------
 * 
 * Rotina disparada após validar o browse utilizado, tem por objetivo definir
 * quisitos de linguagem de exibição.                                
 * 
 * Retorno esperado: nenhum
 */
function defineLang() {
    //Global.getInstance().setEstado('PR');

    var isPtBr = Global.getInstance().getNacional();

    $("#titulo").html((isPtBr) ? 'Cota&ccedil;&atilde;o de Pre&ccedil;os' : 'Quotation Prices');
    $("#lblDetalhes").html((isPtBr) ? 'Detalhes da Cota&ccedil;&atilde;o' : 'Quotation Details');
    $("#dadosCabecCot").html((isPtBr) ? 'N&uacute;mero da Cota&ccedil;&atilde;o' : 'Quotation Number');
    $("#dadosCabecPro").html((isPtBr) ? 'Proposta' : 'Proposal');
    $("#dadosCabecVal").html((isPtBr) ? 'Data de Validade' : 'Expiration Date');


    document.getElementById('dCot').innerHTML = (isPtBr) ? 'Dados da Cota&ccedil;&atilde;o' : 'Quote Data';
    document.getElementById('dados01H1').innerHTML = (isPtBr) ? 'N&uacute;mero da Cota&ccedil;&atilde;o' : 'Quotation Number';
    document.getElementById('dados01H2').innerHTML = (isPtBr) ? 'Proposta' : 'Proposal';
    document.getElementById('dados01H3').innerHTML = (isPtBr) ? 'Data de Validade' : 'Expiration Date';

    document.getElementById('dForn').innerHTML = (isPtBr) ? 'Seus Dados' : 'Your Data';
    document.getElementById('dados02H1').innerHTML = (isPtBr) ? 'C&oacute;digo' : 'Code';
    document.getElementById('dados02H2').innerHTML = (isPtBr) ? 'Loja' : 'Shop';
    document.getElementById('dados02H3').innerHTML = (isPtBr) ? 'Nome' : 'Name';
    document.getElementById('dados02H4').innerHTML = (isPtBr) ? 'CNPJ' : 'CNPJ (Brazil Only)';
    document.getElementById('dados02H5').innerHTML = 'E-mail';
    document.getElementById('dados02H6').innerHTML = (isPtBr) ? 'Estado' : 'State';

    document.getElementById('dTcp').innerHTML = (isPtBr) ? 'Dados do TCP' : 'TCP Data';
    document.getElementById('dados03H1').innerHTML = (isPtBr) ? 'Nome' : 'Name';
    document.getElementById('dados03H2').innerHTML = (isPtBr) ? 'Nome Comercial' : 'Commercial Name';
    document.getElementById('dados03H3').innerHTML = (isPtBr) ? 'CNPJ' : 'CNPJ (Brazil Only)';
    document.getElementById('dados03H4').innerHTML = (isPtBr) ? 'Endere&ccedil;o' : 'Adress';
    document.getElementById('dados03H5').innerHTML = (isPtBr) ? 'Cidade' : 'City';
    document.getElementById('dados03H6').innerHTML = (isPtBr) ? 'Estado' : 'State';
    document.getElementById('dados03H7').innerHTML = (isPtBr) ? 'Telefone' : 'Telephone';
    document.getElementById('dados03H8').innerHTML = (isPtBr) ? 'CEP' : 'CEP';
    document.getElementById('dados03H9').innerHTML = (isPtBr) ? 'Inscri&ccedil;&atilde;o Estadual' : 'State Registration (Brazil Only)';

    document.getElementById('lblNumOrc').innerHTML = (isPtBr) ? 'Numero do Or&ccedil;amento' : 'Number Budget';
    document.getElementById('lblTipoFrete').innerHTML = (isPtBr) ? 'Tipo do Frete' : 'Type of Shipping';

    var oSelFrete = document.getElementById('tipoFrete');

    var tipo = document.createElement("option");
    tipo.text = "CIF";
    tipo.value = "C";
    tipo.selected = "selected";
    oSelFrete.options.add(tipo);

    var tipo = document.createElement("option");
    tipo.text = "FOB";
    tipo.value = "F";
    oSelFrete.options.add(tipo);

/*    var tipo = document.createElement("option");
    tipo.text = (isPtBr) ? 'Por Conta de Terceiros' : 'On behalf of third parties';
    tipo.value = "T";
    oSelFrete.options.add(tipo);

    var tipo = document.createElement("option");
    tipo.text = (isPtBr) ? 'Sem Frete' : 'No Shipping';
    tipo.value = "S";
    oSelFrete.options.add(tipo);
    document.getElementById('vlFrete').disabled = true;
*/
    oSelFrete.onchange = function() {
        var oVlFrete = document.getElementById('vlFrete');
        var selectedIndex = this.selectedIndex;
        oVlFrete.value = '0,00';
        if (selectedIndex === 0) {
            oVlFrete.disabled = false;
        } else {
            switch (this.options[selectedIndex].value) {
                case 'C':
                    oVlFrete.disabled = true;
                    break;

                case 'S':
                    oVlFrete.disabled = true;
                    break;

                case 'F':
                    oVlFrete.disabled = false;
                    break;

                case 'T':
                    oVlFrete.disabled = false;
                    break;
            }
            ;
        }

        selectedIndex = null;
        oVlFrete = null;
    };

    tipo = null;
    oSelFrete = null;

    document.getElementById('lblTpPgto').innerHTML = (isPtBr) ? 'Tipo do Pagamento' : 'Type of Payment';
    document.getElementById('lblVlrFrete').innerHTML = (isPtBr) ? 'Valor do Frete' : 'Value Shipping';

    document.getElementById('lblProd1').innerHTML = 'Item';
    document.getElementById('lblProd2').innerHTML = (isPtBr) ? 'Produto' : 'Product';
    document.getElementById('lblProd3').innerHTML = (isPtBr) ? 'Quantidade' : 'Quantity';
    document.getElementById('lblProd4').innerHTML = (isPtBr) ? 'Valor Unit&aacute;rio' : 'Unit Value';
    document.getElementById('lblProd5').innerHTML = (isPtBr) ? 'Prazo de Entrega (Dias)' : 'Delivery Time (Days)';
    document.getElementById('lblProd6').innerHTML = (isPtBr) ? 'Aliquota ICMS' : 'Aliquot ICMS';
    document.getElementById('lblProd7').innerHTML = (isPtBr) ? 'Aliquota IPI' : 'Aliquot IPI';
    document.getElementById('lblProd8').innerHTML = (isPtBr) ? 'Observa&ccedil;&atilde;o' : 'Observation';
	document.getElementById('lblProd9').innerHTML = (isPtBr) ? 'N&atilde;o Tenho?' : 'Not Have?';
}

/*!
 * Rotina validaId
 * ---------------
 * 
 * Rotina disparada após validar o browse utilizado, tem por objetivo definir
 * quisitos de linguagem de exibição.                                
 * 
 * Retorno esperado: nenhum
 */
function validaId(cId, cUrl, cUrl2, cUrlPortal, cEmpW, cFilW) {

    $("#testBrowse").html('<p>Loading data... please wait...</p>');
    try {
        definePrototipos();
        Global.getInstance().setId(cId);
        Global.getInstance().setEmpresa(cEmpW);
        Global.getInstance().setFilial(cFilW);

        Global.getInstance().setUrl(cUrl);
        Global.getInstance().setUrl2(cUrl2);
        Global.getInstance().setUrlPortal(cUrlPortal);

        var action = new String("SOAPAction");
        var newUrl = new String(Global.getInstance().getUrl() + "GETCOM001");

        var aRequest = [[action, newUrl]];
        var cSoapRequest = new String('');
        cSoapRequest += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loc="' + Global.getInstance().getUrl2() + '">';
        cSoapRequest += '   <soapenv:Header/>';
        cSoapRequest += '   <soapenv:Body>';
        cSoapRequest += '       <loc:GETCOM001>';
        cSoapRequest += '           <loc:EMP>';
        cSoapRequest += '           	<loc:EMPRESA>' + Global.getInstance().getEmpresa() + '</loc:EMPRESA>';
        cSoapRequest += '           	<loc:FILIAL>' + Global.getInstance().getFilial() + '</loc:FILIAL>';
        cSoapRequest += '           	<loc:CHAVE>' + Global.getInstance().getId() + '</loc:CHAVE>';
        cSoapRequest += '           </loc:EMP>';
        cSoapRequest += '       </loc:GETCOM001>';
        cSoapRequest += '   </soapenv:Body>';
        cSoapRequest += '</soapenv:Envelope>';

        $("#testBrowse").html($("#testBrowse").html() + '<p>Requesting data...</p>');

        sendRequest(Global.getInstance().getUrlPortal(), retValidaId, cSoapRequest, false, aRequest);
    } catch (e) {
		exibeExcessao(e, 'validaId', false);
    }
}

/*!
 * retValidaId()      
 * -------------          
 * 
 * Retorna se a chave foi validada ou nao, caso nao seja levanta um soapfault,
 * señ traz os dados para exibição em tela
 * Analista: Lucas Chagas                        
 * 
 * Retorno esperado: nenhum
 */
function retValidaId(resp) {

	if(typeof String.prototype.trim !== 'function') {
	  String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g, ''); 
	  }
	}

    $("#testBrowse").html($("#testBrowse").html() + '<p>Validanting returned data...</p>');
    try {
        // verifica se a rotina retornou um SoapFault do protheus, se for
        // levanta o erro com um alert na tela para o browse    
        var erro = SoapFault(resp.responseXML);
        if (erro === null) {
            // neste ponto a rotina jï¿½ retornou os dados da empresa.
            var xml = null;

            if (($.browser.msie !== undefined) && ($.browser.msie) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10)) {
                xml = resp.responseXML.childNodes[1].childNodes[0].childNodes[0].childNodes[0];
            } else {
                xml = resp.responseXML.childNodes[0].childNodes[0].childNodes[0].childNodes[0];
            }

            var oCotacaoXml = xml.childNodes[0];
            var oEmpresaXml = xml.childNodes[1];
            var oFornecedorXml = xml.childNodes[2];
            var oProdutosXml = xml.childNodes[3];
            var oPagConXml = xml.childNodes[4];

            // popula objeto de cotacao definido no comeco do arquivo
            var aData = oCotacaoXml.childNodes[0].childNodes[0].nodeValue.split('-');

            Global.getInstance().setValida(new Date(parseInt(aData[0]), parseInt(aData[1]) - 1, parseInt(aData[2])));
            Global.getInstance().setNumero(oCotacaoXml.childNodes[1].childNodes[0].nodeValue);
            Global.getInstance().setProposta(oCotacaoXml.childNodes[2].childNodes[0].nodeValue);

            $("#cot1").html(Global.getInstance().getNumero());
            $("#cot2").html(Global.getInstance().getProposta());
            $("#cot3").html(Global.getInstance().getValida().format('d/m/Y'));

            // popula objeto de fornecedor definido no comeco do arquivo
            Global.getInstance().setCnpj(oFornecedorXml.childNodes[0].childNodes[0].nodeValue);
            Global.getInstance().setCodigo(oFornecedorXml.childNodes[1].childNodes[0].nodeValue);
            Global.getInstance().setEmail(oFornecedorXml.childNodes[2].childNodes[0].nodeValue);
            Global.getInstance().setEstado(oFornecedorXml.childNodes[3].childNodes[0].nodeValue);
            Global.getInstance().setLoja(oFornecedorXml.childNodes[4].childNodes[0].nodeValue);
            Global.getInstance().setNome(oFornecedorXml.childNodes[5].childNodes[0].nodeValue);

            $("#forn1").html(Global.getInstance().getCodigo());
            $("#forn2").html(Global.getInstance().getLoja());
            $("#forn3").html(Global.getInstance().getNome());
            $("#forn4").html(Global.getInstance().getCnpj());
            $("#forn5").html(Global.getInstance().getEmail());
            $("#forn6").html(Global.getInstance().getEstado());

            $("#tcp1").html((oEmpresaXml.childNodes[6].childNodes.length > 0) ? oEmpresaXml.childNodes[6].childNodes[0].nodeValue : new String(""));
            $("#tcp2").html((oEmpresaXml.childNodes[7].childNodes.length > 0) ? oEmpresaXml.childNodes[7].childNodes[0].nodeValue : new String(""));
            $("#tcp3").html((oEmpresaXml.childNodes[1].childNodes.length > 0) ? oEmpresaXml.childNodes[1].childNodes[0].nodeValue : new String(""));
            $("#tcp4").html((oEmpresaXml.childNodes[3].childNodes.length > 0) ? oEmpresaXml.childNodes[3].childNodes[0].nodeValue : new String(""));
            $("#tcp5").html((oEmpresaXml.childNodes[2].childNodes.length > 0) ? oEmpresaXml.childNodes[2].childNodes[0].nodeValue : new String(""));
            $("#tcp6").html((oEmpresaXml.childNodes[4].childNodes.length > 0) ? oEmpresaXml.childNodes[4].childNodes[0].nodeValue : new String(""));
            $("#tcp7").html((oEmpresaXml.childNodes[8].childNodes.length > 0) ? oEmpresaXml.childNodes[8].childNodes[0].nodeValue : new String(""));
            $("#tcp8").html((oEmpresaXml.childNodes[0].childNodes.length > 0) ? oEmpresaXml.childNodes[0].childNodes[0].nodeValue : new String(""));
            $("#tcp9").html((oEmpresaXml.childNodes[5].childNodes.length > 0) ? oEmpresaXml.childNodes[5].childNodes[0].nodeValue : new String(""));

            var oTabela = document.getElementById('itens');
            Produtos.getInstance().clearRows();
            for (var i = 0; i < oProdutosXml.childNodes.length; i++) {
                var item = oProdutosXml.childNodes[i];
                Produtos.getInstance().addRow([item.childNodes[2].childNodes[0].nodeValue, item.childNodes[6].childNodes[0].nodeValue]); // para poder procurar a linha da tabela posteriormente

                var oLinha = oTabela.insertRow(oTabela.rows.length);
                oLinha.id = item.childNodes[2].childNodes[0].nodeValue;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[2].childNodes[0].nodeValue; // item

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[6].childNodes[0].nodeValue; // produto
                oCelula.innerHTML += ' - '; // descriÃ§Ã£o
                oCelula.innerHTML += item.childNodes[0].childNodes[0].nodeValue; // descriÃ§Ã£o
                oCelula.colSpan = 2;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[7].childNodes[0].nodeValue; // quantidade
                oCelula.className = 'numeroRN';

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[5].childNodes[0].nodeValue; // valor unitario
                oCelula.className = 'numeroR';
                oCelula.size = 16;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[4].childNodes[0].nodeValue; // prazo
                oCelula.className = 'numeroI';
                oCelula.size = 5;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[3].childNodes[0].nodeValue; // icms
                oCelula.className = 'numeroR';
                oCelula.size = 5;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = item.childNodes[1].childNodes[0].nodeValue; // ipi
                oCelula.className = 'numeroR';
                oCelula.size = 5;

                var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.innerHTML = (item.childNodes[8].childNodes.length > 0) ? item.childNodes[8].childNodes[0].nodeValue : new String(""); // observacao
                oCelula.className = 'obs';
                oCelula.size = 200;
				
				var oCelula = oLinha.insertCell(oLinha.cells.length);
                oCelula.size = 5;
				
				// cria o input para o ultima célula dinamicamente
				var newInput = document.createElement('input');
				newInput.id = 'chk_' + item.childNodes[2].childNodes[0].nodeValue;
				newInput.type = 'checkbox';
				oCelula.appendChild(newInput);				
            }

            var oSelPgto = document.getElementById('tipoPgto');
            for (var i = 0; i < oPagConXml.childNodes.length; i++) {
                var item = oPagConXml.childNodes[i];

                var tipo = document.createElement("option");
                tipo.text = item.childNodes[1].childNodes[0].nodeValue;
                tipo.value = item.childNodes[0].childNodes[0].nodeValue;
                if(item.childNodes[0].childNodes[0].nodeValue==="007")
					tipo.selected = "selected"
				oSelPgto.options.add(tipo);

                item = null;
                tipo = null;
            }
            oSelPgto = null;

            oCotacaoXml = null;
            oEmpresaXml = null;
            oFornecedorXml = null;
            oProdutosXml = null;
            oPagConXml = null;
            xml = null;

			logIP();
			
            ordena('img1');
            eventosTela();
            $("#vlFrete").maskMoney({decimal: ",", thousands: "."});
            $("#testBrowse").html('');
            document.getElementById('corpo').style.display = 'block';

                defineLang();

        } else {
            $("#testBrowse").html(erro);
        }
    } catch (e) {
        exibeExcessao(e, 'retValidaId', false);
    }
}

/*!
 * Rotina logIP
 * ---------------
 * Rotina disparada para gravar o log de acesso ao Workflow.         
 */
function logIP() {
	$.getJSON("http://jsonip.appspot.com?callback=?",retLogIP);
}

/*!
 * Rotina retLogIp
 * ---------------
 * Retorno da chamada do LogIp. A rotina deve consumir o método GETCOM004 para realizar o log de acesso do WF.
 */
function retLogIP( resp ) {

    try {
        if (resp != null) {
        	var oBrowse = $.browser;
			var action = new String("SOAPAction");
			var newUrl = new String(Global.getInstance().getUrl() + "GETCOM004");

			var aRequest = [[action, newUrl]];
			var cSoapRequest = new String('');
			cSoapRequest += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loc="' + Global.getInstance().getUrl2() + '">';
			cSoapRequest += '   <soapenv:Header/>';
			cSoapRequest += '   <soapenv:Body>';
			cSoapRequest += '       <loc:GETCOM004>';
			cSoapRequest += '           <loc:LOGWS>';
			cSoapRequest += '           	<loc:IP>' + resp.ip + '</loc:IP>';
			cSoapRequest += '           	<loc:ENDERECO>' + resp.address + '</loc:ENDERECO>';
			cSoapRequest += '           	<loc:EMPRESA>' + Global.getInstance().getEmpresa() + '</loc:EMPRESA>';
			cSoapRequest += '           	<loc:FILIAL>' + Global.getInstance().getFilial() + '</loc:FILIAL>';
			cSoapRequest += '           	<loc:ID>' + Global.getInstance().getId() + '</loc:ID>';
			cSoapRequest += '           	<loc:BROWSE>' + oBrowse.name.toUpperCase() + '</loc:BROWSE>';
			cSoapRequest += '           	<loc:VERSAO>' + oBrowse.versionNumber + '</loc:VERSAO>';
			cSoapRequest += '           </loc:LOGWS>';
			cSoapRequest += '       </loc:GETCOM004>';
			cSoapRequest += '   </soapenv:Body>';
			cSoapRequest += '</soapenv:Envelope>';
			
			sendRequest(Global.getInstance().getUrlPortal(), null, cSoapRequest, false, aRequest);
			oBrowse = null;
		}
    } catch (e) {
        exibeExcessao(e, 'retLogIP', true);
    }
}

/*!
 * Rotina eventosTela
 * ------------------
 * 
 * Define a ação a ser tomada de acordo com a classe do objeto   
 * Retorno esperado: nenhum
 */
function eventosTela() {
    var oItens = document.getElementById('itens').rows;
    for (var i = 0; i < oItens.length; i++) {
        var oItem = oItens[i];
        for (var j = 0; j < oItem.cells.length; j++) {
            var oCelula = oItem.cells[j];

            if ((!oCelula.className.empty()) && (!oCelula.className.equal('numeroRN'))) {
                defineOnClick(oCelula);
                defineOnKeyUp(oCelula);
            }
            oCelula = null;
        }
        oItem = null;
    }
    oItens = null;
}

/*!
 * Rotina defineOnKeyUp
 * --------------------
 * Analista: Lucas J. C. Chagas
 * Define evento onKeyUp do input de tela
 * Retorno esperado: nenhum
 */
function defineOnKeyUp(oCelula) {
    oCelula.onkeyup = function(oEvento) {
        if (oEvento.keyCode === 13) {
            var oParent = oEvento.target.parentNode;
            var valor = oEvento.target.value;
            var rowIdx = oParent.parentNode.rowIndex - 1;
            var classe = oParent.className.trim();
            oParent.removeChild(oEvento.target);
            oParent.innerHTML = valor.trim();
            defineOnClick(oParent);
            defineOnKeyUp(oParent);
            valor = null;
            oParent = null;
            ValorAnterior.getInstance().setValor('');
            classe = null;
            rowIdx = null;
        }

        if (oEvento.keyCode === 27) {
            var oParent = oEvento.target.parentNode;
            var valor = ValorAnterior.getInstance().getValor();
            oParent.removeChild(oEvento.target);
            oParent.innerHTML = valor;
            defineOnClick(oParent);
            defineOnKeyUp(oParent);
            valor = null;
            oParent = null;
        }
    };
}

/*!
 * Rotina defineOnClick
 * --------------------
 * Analista: Lucas J. C. Chagas
 * Define evento onClick do input temporario
 * Retorno esperado: nenhum
 */
function defineOnClick(oCelula) {
    oCelula.onclick = function(oEvento) {
        var oTarget = oEvento.target;
        oTarget.onclick = null;

        var valor = new String("");
        if (oTarget.childNodes.length > 0) {
            valor = oTarget.childNodes[0].data;
        }
        var newInput = document.createElement('input');
        newInput.value = valor;
        ValorAnterior.getInstance().setValor(valor);
        newInput.style.width = "97%";
        newInput.id = 'input_temp';
        newInput.maxLength = oTarget.size;

        if (!oTarget.className.empty()) {
            switch (oTarget.className) {
                case 'numeroR':
                    newInput.className = 'numerosR';
                    break;

                case 'numeroI':
                    newInput.className = 'numerosI';
                    break;

                default:
                    newInput.className = 'obs';
            }
        }

        newInput.onblur = function() {
            var oParent = this.parentNode;
            var rowIdx = oParent.rowIndex;
            var valor = this.value;
            oParent.removeChild(this);
            oParent.innerHTML = valor;

            defineOnClick(oParent);
            defineOnKeyUp(oParent);

            valor = null;
            oParent = null;
            ValorAnterior.getInstance().setValor('');

            rowIdx = null;
        };

        if (oTarget.childNodes.length > 0) {
            oTarget.removeChild(oTarget.childNodes[0]);
        }
        oTarget.appendChild(newInput);
        newInput.focus();

        // define as mascaras para os campos
        switch (newInput.className) {
            case 'numerosR':
                $("#input_temp").maskMoney({decimal: ",", thousands: "."});
                break;

            case 'numerosI':
                $("#input_temp").mask("99999",{placeholder:" "});
                break;

            case 'obs':
                newInput.onkeypress = function(e) {
                    e = e || window.event;
                    var k = e.which || e.charCode || e.keyCode;
                    if (k === undefined) {
                        return false; //needed to handle an IE "special" event
                    }

                    // tratamento para maxlength
                    if (this.value.length === this.maxLength) {
                        return false;
                    }
                };
        }

        newInput = null;
        valor = null;
        oTarget = null;
    };
}

/*!
 * Rotina sendData
 * ---------------
 * Analista: Lucas J. C. Chagas
 * Data: 03/11/13
 * Envia dados para o webservice. 
 * Retorno esperado: nenhum
 */
function sendData() {

    var erro = new String("");
    var isPtBr = Global.getInstance().getNacional();
    var tipoF = new String("");

    var obj = document.getElementById('numOrc');
    if (obj.value.empty()) {
        if (isPtBr) {
            erro += "O número do orçamento deve ser informado!\n";
        } else {
            erro += "The number of the budget was not informed!\n";
        }
    }
    obj = null;

    var obj = document.getElementById('tipoPgto');
    if (obj.selectedIndex === -1) {
        if (isPtBr) {
            erro += "O tipo de pagamento deve ser informado!\n";
        } else {
            erro += "The type of payment was not informed!\n";
        }
    } else {
        if (obj.options[obj.selectedIndex].value.empty()) {
            if (isPtBr) {
                erro += "O tipo de pagamento deve ser informado!\n";
            } else {
                erro += "The type of payment was not informed!\n";
            }
        }
    }
    obj = null;

    var obj = document.getElementById('tipoFrete');
    if (obj.selectedIndex === -1) {
        if (isPtBr) {
            erro += "O tipo de frete deve ser informado!\n";
        } else {
            erro += "The type of freight was not informed!\n";
        }
    } else {
        if (obj.options[obj.selectedIndex].value.empty()) {
            if (isPtBr) {
                erro += "O tipo de frete deve ser informado!\n";
            } else {
                erro += "The type of freight was not informed!\n";
            }
        } else {
            tipoF = obj.options[obj.selectedIndex].value;
        }
    }
    obj = null;

    var obj = document.getElementById('vlFrete');
    if (obj.value.empty()) {
        obj.value = '0,00';
    }
    valF = obj.value;
    obj = null;

    var oItens = document.getElementById('itens').rows;
    for (var i = 0; i < oItens.length; i++) {
        var oItem = oItens[i];

        if (!document.getElementById('chk_' + oItem.cells[0].textContent).checked) { // valida se o item será enviado ou não        
	        var obj = oItem.cells[3];
	        if ((obj.childNodes[0].data.empty()) || (obj.childNodes[0].data.toFloat() === 0)) {
	            if (isPtBr) {
	                erro += 'Valor do item ' + oItem.cells[0].childNodes[0].data + ' deve ser informado!\n';
	            } else {
	                erro += 'Value item ' + oItem.cells[0].childNodes[0].data + ' was not informed!\n';
	            }
	        }
	        obj = null;
        }

        oItem = null;
    }
    oItens = null;

    if (!erro.empty()) {
        alert(erro);
    } else {
        //confirma(Global.getInstance().getNumero(), tipoF, valF );
        confirma();
    }

    isPtBr = null;
}

/*!
 * Rotina declinar
 * ---------------
 * Analista: Lucas J. C. Chagas
 * Data: 12/06/2014
 * Oculta/exibe a div de recusa do workflow.
 * Retorno esperado: nenhum
 */
function declinar( bDeclinar ) {

	if ( bDeclinar ) {
		document.getElementById('declinar').style.display = "inline";
		document.getElementById('conteudo').style.display = "none";
		document.getElementById('memoD').value = "";
	} else {
		document.getElementById('declinar').style.display = "none";
		document.getElementById('conteudo').style.display = "block";
	}
}

/*!
 * Rotina sendDataD
 * ----------------
 * Analista: Lucas J. C. Chagas
 * Data: 12/06/2014
 * Rotina para declinar o retorno de informações da cotação. 
 * Retorno esperado: nenhum
 */
function sendDataD() {

	try {
        var action = new String("SOAPAction");
        var newUrl = new String(Global.getInstance().getUrl() + "GETCOM003");
		
        var aRequest = [[action, newUrl]];
        var cSoapRequest = new String('');
        cSoapRequest += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loc="' + Global.getInstance().getUrl2() + '">';
        cSoapRequest += '   <soapenv:Header/>';
        cSoapRequest += '   <soapenv:Body>';
        cSoapRequest += '       <loc:GETCOM003>';
        cSoapRequest += '           <loc:DECLINA>';
        cSoapRequest += '           	<loc:EMPRESA>' + Global.getInstance().getEmpresa() + '</loc:EMPRESA>';
        cSoapRequest += '           	<loc:FILIAL>' + Global.getInstance().getFilial() + '</loc:FILIAL>';
        cSoapRequest += '           	<loc:ID>' + Global.getInstance().getId() + '</loc:ID>';
		cSoapRequest += '           	<loc:MOTIVO>' + document.getElementById('memoD').value + '</loc:MOTIVO>';
		cSoapRequest += '           	<loc:PROPOSTA>' + Global.getInstance().getProposta() + '</loc:PROPOSTA>';
        cSoapRequest += '           </loc:DECLINA>';
        cSoapRequest += '       </loc:GETCOM003>';
        cSoapRequest += '   </soapenv:Body>';
        cSoapRequest += '</soapenv:Envelope>';

        $("#testBrowse").html($("#testBrowse").html() + '<p>Requesting data...</p>');

        sendRequest(Global.getInstance().getUrlPortal(), retDeclina, cSoapRequest, false, aRequest);
    } catch (e) {
        exibeExcessao(e, 'sendDataD', true);
    }
}

/*!
 * Rotina retDeclina
 * -----------------
 * Analista: Lucas J. C. Chagas
 * Data: 17/06/2014
 * Retorno da rotina sendDataD 
 * Retorno esperado: nenhum
 */
function retDeclina(resp) {
    // verifica se a rotina retornou um SoapFault do protheus, se for
    // levanta o erro com um alert na tela para o browse    
    var erro = SoapFault(resp.responseXML);
    if (erro === null) {

        var confirma = new String("");
        if (($.browser.msie !== undefined) && ($.browser.msie) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10)) {
            confirma = new String(resp.responseXML.text);
        } else {
            confirma = new String(resp.responseXML.childNodes[0].childNodes[0].childNodes[0].childNodes[0].textContent);
        }
        
        alert(confirma);
        document.getElementById('declinar').style.display = "none";
		document.getElementById('conteudo').style.display = "none";
    } else {
    	alert(erro);
    }
}


/*!
 * Rotina confirma
 * ---------------
 * Analista: Lucas J. C. Chagas
 * Data: 22/05/13
 * Confirma os dados da tela para o protheus 
 * Retorno esperado: nenhum
 */
function confirma() {
    $("#testBrowse").html('');
    var dataAtual = new Date();
    var valorFrete = 0.00;
    var vlInteiro = 0;
    var vlDecimal = 0.00;

    var valFrete = document.getElementById('vlFrete').value;
    var tipoFrete = document.getElementById('tipoFrete').value;

    if (valFrete.trim() !== '') {
		if (document.getElementById('itens').rows.length > 1) {
			valorFrete = valFrete.toFloat();
			if (valorFrete !== 0.00) {
				valorFrete = valorFrete / Produtos.getInstance().getRows().length;
				vlInteiro = Math.floor(valorFrete);
				vlDecimal = valorFrete - vlInteiro;
				vlDecimal = Math.round(vlDecimal * Produtos.getInstance().getRows().length);
			}
		} else {
			vlInteiro = valFrete.toFloat() / Produtos.getInstance().getRows().length;
		}
    }

    // verificando a data
    if (dataAtual > Global.getInstance().getValida()) {
        if (Global.getInstance().getNacional()) {
            var msg = "Cotacao digitada apos o prazo maximo definido para digitacao. A cotacao sera aceita, porem, esse atraso sera considerado na sua avaliacao de fornecedor e na avaliacao da cotacao.";
        } else {
            var msg = "Quote typed after the deadline set for typing. The price will be accepted, however, this delay will be considered in its supplier evaluation and assessment of the quotation.";
        }

        alert(msg);
        msg = null;
    }

    var cSoap = new String('');

    cSoap += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loc="' + Global.getInstance().getUrl2() + '">';
    cSoap += '<soapenv:Header/>';
    cSoap += '<soapenv:Body>';
    cSoap += '	<loc:GETCOM002>';
    cSoap += '		<loc:COTENTRADA>';
    cSoap += '			<loc:ID>' + Global.getInstance().getId() + '</loc:ID>';
    cSoap += '                  <loc:EMPRESA>' + Global.getInstance().getEmpresa() + '</loc:EMPRESA>';
    cSoap += '                  <loc:FILIAL>' + Global.getInstance().getFilial() + '</loc:FILIAL>';
    cSoap += '			<loc:ITENS>';

    var rows = Produtos.getInstance().getRows();
    var tbl = document.getElementById('itens');
    for (i = 0; i < tbl.rows.length; i++) {
    	
    	var linha = tbl.rows[i];
    	var item = linha.cells[0].textContent;
		var produto = null;
		var j = 0;
		
		while ((j < rows.length) && (produto === null)) {
			if (rows[j][0].trim() === item) {
				produto = rows[j][1].trim();
			}
			j++
		}		
		
		var oCheck = document.getElementById('chk_' + item);
		
		var c8Decli = oCheck.checked ? 'SIM' : 'NAO';
		var ipi = oCheck.checked ? '0.00' : linha.cells[6].textContent;
		var icm = oCheck.checked ? '0.00' : linha.cells[5].textContent;
		var prazo = oCheck.checked ? '0' : linha.cells[4].textContent;
		var preco = oCheck.checked ? '0.00' : linha.cells[3].textContent;
		var quant = oCheck.checked ? '0.00' : linha.cells[2].textContent;		
		
        cSoap += '				<loc:PROCODSTRUCT>';
        cSoap += '					<loc:C8ALIIPI>' + ipi + '</loc:C8ALIIPI>';
        cSoap += '					<loc:C8ITEM>' + linha.cells[0].textContent + '</loc:C8ITEM>';
        cSoap += '					<loc:C8PICM>' + icm + '</loc:C8PICM>';
        cSoap += '					<loc:C8PRAZO>' + prazo + '</loc:C8PRAZO>';
        cSoap += '					<loc:C8PRECO>' + preco + '</loc:C8PRECO>';
		cSoap += '					<loc:C8PRODUTO>' + produto + '</loc:C8PRODUTO>';
        cSoap += '					<loc:C8QUANT>' + quant + '</loc:C8QUANT>';
        cSoap += '					<loc:C8XOBSWEB>' + linha.cells[7].textContent + '</loc:C8XOBSWEB>';
        cSoap += '					<loc:C8FRETE>' + ((i === (tbl.rows.length - 1)) ? (vlInteiro + vlDecimal).toStrCurrency() : vlInteiro.toStrCurrency()) + '</loc:C8FRETE>';
        cSoap += '					<loc:C8DECLI>' + c8Decli + '</loc:C8DECLI>';
        cSoap += '				</loc:PROCODSTRUCT>';
    	
        c8Decli = null;      
		ipi = null;      
		icm = null;      
		prazo = null;      
		preco = null;      
		quant = null;      
        
        oCheck = null;        
    	linha = null;
    	item = null;
    }

    cSoap += '			</loc:ITENS>';
    cSoap += '			<loc:NUMORC>' + $("#numOrc")[0].value + '</loc:NUMORC>';
    cSoap += '			<loc:PROPOSTA>' + Global.getInstance().getProposta() + '</loc:PROPOSTA>';
    cSoap += '			<loc:TIPOFRETE>' + tipoFrete + '</loc:TIPOFRETE>';
    cSoap += '			<loc:VALFRETE>' + valorFrete.toStrCurrency() + '</loc:VALFRETE>';
    cSoap += '			<loc:TIPOPGTO>' + document.getElementById('tipoPgto').options[document.getElementById('tipoPgto').selectedIndex].value + '</loc:TIPOPGTO>';
    cSoap += '		</loc:COTENTRADA>';
    cSoap += '	</loc:GETCOM002>';
    cSoap += '</soapenv:Body>';
    cSoap += '</soapenv:Envelope>';

    var action = new String("SOAPAction");
    var newUrl = new String(Global.getInstance().getUrl() + "GETCOM002");

    var aRequest = [[action, newUrl]];
    sendRequest(Global.getInstance().getUrlPortal(), retConfirma, cSoap, false, aRequest);
}

/*!
 * Rotina retConfirma
 * ------------------
 * Analista: Lucas J. C. Chagas
 * Data: 24/05/13
 * Retorno da confirmacao de dados do fornecedor ao protheus 
 * Retorno esperado: nenhum
 */
function retConfirma(resp) {
    // verifica se a rotina retornou um SoapFault do protheus, se for
    // levanta o erro com um alert na tela para o browse    
    var erro = SoapFault(resp.responseXML);
    if (erro === null) {

        var confirma = new String("");
        if (($.browser.msie !== undefined) && ($.browser.msie) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10)) {
            confirma = new String(resp.responseXML.text);
        } else {
            confirma = new String(resp.responseXML.childNodes[0].childNodes[0].childNodes[0].childNodes[0].textContent);
        }

        document.getElementById('corpo').style.display = 'none';
        $("#testBrowse").html('<h1>' + confirma + '</h1>');
    } else {
        $("#testBrowse").html(erro);
    }
    window.setTimeout(window.location.href = "http://www.tcp.com.br",5000);
}