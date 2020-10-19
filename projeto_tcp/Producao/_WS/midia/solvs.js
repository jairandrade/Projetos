/*!
 * Plugin javascript especifico da Solvs
 *
 * Plugin original dessenvolvido com funções específicas para tratamento de 
 * dados para workflows         
 *
 * Date: 2013-11-14 
 * 
 * Analista: Lucas José Corrêa Chagas
 * Fábrica de software
 */

/*!
 * Rotina watchBrowse
 * ------------------
 * 
 * Rotina disparada ao final do carregamento do html, onde deve validar se o
 * navegador utilizado pelo usuário é um dos navegadores homologados.
 * 
 * Estes são:
 * IE 9, 10, 11
 * Firefox 25
 * Opera 17
 * Chrome 30.
 * 
 * Retorno esperado: Booleano [ Verdadeiro ou Falso ]
 */
function watchBrowse() {
    var lRet = false;
    var lNoBrowse = false;
    var oBrowse = $.browser;

    var cBrowse = new String('');
    cBrowse += '<h3>Dear supplier, for access to the TCP quote online, please use one of the following browsers:</h3>';
    cBrowse += '<h3>Internet Explorer 9 or newer;</h3>';
    cBrowse += '<h3>Firefox 25 or later;</h3>';
    cBrowse += '<h3>Opera 17 or later;</h3>';
    cBrowse += '<h3>Google Chrome 30.0.1599.101 or higher.</h3>';
    cBrowse += '<hr>';
    cBrowse += '<h3>Estimado fornecedor, para acesso a cotacao online da TCP, por favor utilize um dos seguintes navegadores:</h3>';
    cBrowse += '<h3>Internet Explorer 9 ou mais recente;</h3>';
    cBrowse += '<h3>Firefox 25 ou mais recente;</h3>';
    cBrowse += '<h3>Opera 17 ou mais recente;</h3>';
    cBrowse += '<h3>Google Chrome 30.0.1599.101 ou mais recente.</h3>';

    if ((oBrowse.mozilla !== undefined) && (oBrowse.mozilla)) {
        if (oBrowse.versionNumber < 25) {
            lNoBrowse = true;
        }
    }

    if ((oBrowse.msie !== undefined) && (oBrowse.msie)) {
        if (oBrowse.versionNumber < 9) {
            lNoBrowse = true;
			if(document.documentElement.style.opacity===undefined) {
				cBrowse  = '<br>'
				cBrowse += '<h3>Disable the Internet Explorer compatibility mode.</h3>'
				cBrowse += '<br>'
				cBrowse += '<h3>Desabilite o mode de compatibilidade do Internet Explorer.</h3>';
				cBrowse += '<br>'
			}
        }
    }

    if ((oBrowse.opera !== undefined) && (oBrowse.opera)) {
        if (oBrowse.versionNumber < 17) {
            lNoBrowse = true;
        }
    }

    if ((oBrowse.chrome !== undefined) && (oBrowse.chrome)) {
        if (oBrowse.versionNumber < 25) {
            lNoBrowse = true;
        }
    }
    
    if ((oBrowse.chrome === undefined) && (oBrowse.opera === undefined) && (oBrowse.msie === undefined) && (oBrowse.mozilla === undefined)) {
        lNoBrowse = true;
    }
    
    $("#lblBrowse").text(oBrowse.name.toUpperCase() + ' ');
    $("#lblVersion").text(oBrowse.versionNumber + ' ');
    oBrowse = null;

    if (lNoBrowse) {
        $("#testBrowse").html(cBrowse);
        lRet = false;
    } else {
        lRet = true;
    }

    lNoBrowse = null;

    return lRet;
}

/*!
 * exibeExcessao
 * -------------
 * 
 * Rotina para exibicao de erro de processamento qualquer.
 * 
 * Retorno esperado: objeto singleton
 */
function exibeExcessao( exception, metodo, lAlert ) {    

	var erro = new String("");
	
	if (lAlert) {
	
		erro = 'Erro na rotina: ' + metodo + '.\n';
		erro += exception.name + ": " + exception.message;
		
		alert(erro);
	} else {
		erro = '<h3>Erro na rotina: ' + metodo + '.<h3>';
		erro += '<h4>' + exception.name + ": " + exception.message + '<h4>';
		
		$("#testBrowse").html(erro);
	}

    erro = null;
}

/*!
 * Classe ColOrder
 * ---------------
 * 
 * Classe para auxiliar na ordenação da tabela de produtos
 * 
 * Retorno esperado: objeto singleton
 */
var ColOrder = (
        function() {
            var instantiated;
            var col = new String("");
            var sentido = new String("");
            var campo = new Number(0);

            function init() {
                return {
                    setCol: function(pCol) {
                        col = pCol;
                    },
                    getCol: function() {
                        return col;
                    },
                    setSentido: function(pSentido) {
                        sentido = pSentido;
                    },
                    getSentido: function() {
                        return sentido;
                    },
                    setCampo: function(pCampo) {
                        campo = pCampo;
                    },
                    getCampo: function() {
                        return campo;
                    }
                };
            }

            return {
                getInstance: function() {
                    if (!instantiated) {
                        instantiated = init();
                    }
                    return instantiated;
                }
            };
        }
)();

/*!
 * Classe Global
 * -------------
 * 
 * Classe singleton com dados gerais para exibicao e processamento da cotacao.
 * 
 * Retorno esperado: objeto singleton
 */
var Global = function() {
    var instantiated;
    var id = new String("");
    var empresa = new String("");
    var filial = new String("");
    var url = new String("");
    var url2 = new String("");
    var urlPortal = new String("");
    var numero = new String('');
    var valida = new Date('2013-05-23');
    var proposta = new String('');
    var nome = new String('');
    var codigo = new String('');
    var loja = new String('');
    var email = new String('');
    var nacional = new Boolean(false);
    var estado = new String('');
    var cnpj = new String('');
    var valor = new String("");
    var cep = new String("");

    function init() {
        return {
            getCep: function() {
                return cep;
            },
            setCep: function(pValor) {
                cep = pValor;
            },
            getValor: function() {
                return valor;
            },
            setValor: function(pValor) {
                valor = new String(pValor);
            },
            // getter e setter nome
            setNome: function(pNome) {
                nome = pNome;
            },
            getNome: function() {
                return nome;
            },
            // getter e setter codigo
            setCodigo: function(pCodigo) {
                codigo = pCodigo;
            },
            getCodigo: function() {
                return codigo;
            },
            // getter e setter loja
            setLoja: function(pLoja) {
                loja = pLoja;
            },
            getLoja: function() {
                return loja;
            },
            // getter e setter email
            setEmail: function(pEmail) {
                email = pEmail;
            },
            getEmail: function() {
                return email;
            },
            // setter nacional				
            getNacional: function() {
                return nacional;
            },
            // getter e setter cnpj
            setCnpj: function(pCnpj) {
                cnpj = pCnpj;
            },
            getCnpj: function() {
                return cnpj;
            },
            // getter e setter cnpj
            setEstado: function(pEstado) {
                estado = pEstado;
                nacional = (estado !== 'EX');
            },
            getEstado: function() {
                return estado;
            },
            setNumero: function(pNumero) {
                numero = pNumero;
            },
            getNumero: function() {
                return numero;
            },
            setValida: function(pValida) {
                valida = pValida;
            },
            getValida: function() {
                return valida;
            },
            setProposta: function(pProposta) {
                proposta = pProposta;
            },
            getProposta: function() {
                return proposta;
            },
            setUrl: function(pUrl) {
                url = pUrl;
            },
            getUrl: function() {
                return url;
            },
            setUrl2: function(pUrl) {
                url2 = pUrl;
            },
            getUrl2: function() {
                return url2;
            },
            setUrlPortal: function(pUrl) {
                urlPortal = pUrl;
            },
            getUrlPortal: function() {
                return urlPortal;
            },
            setId: function(pId) {
                id = pId;
            },
            getId: function() {
                return id;
            },
            setEmpresa: function(pEmpresa) {
                empresa = pEmpresa;
            },
            getEmpresa: function() {
                return empresa;
            },
            setFilial: function(pFilial) {
                filial = pFilial;
            },
            getFilial: function() {
                return filial;
            }
        };
    }

    return {
        getInstance: function() {
            if (!instantiated) {
                instantiated = init();
            }
            return instantiated;
        }
    };
}();

/*!
 * Rotina definePrototipos
 * -----------------------
 * 
 * Rotina que define subrotinas para os tipos basicos.
 * 
 * Retorno esperado: objeto singleton
 */
function definePrototipos() {

    Date.prototype.format = function(format) {
        var returnStr = '';
        var replace = Date.replaceChars;
        for (var i = 0; i < format.length; i++) {
            var curChar = format.charAt(i);
            if (i - 1 >= 0 && format.charAt(i - 1) === "\\") {
                returnStr += curChar;
            }
            else if (replace[curChar]) {
                returnStr += replace[curChar].call(this);
            } else if (curChar !== "\\") {
                returnStr += curChar;
            }
        }
        return returnStr;
    };

    String.prototype.equal = function(pString) {
        return this.trim() === pString;
    };

    String.prototype.empty = function() {
        return this.trim() === '';
    };

    String.prototype.toFloat = function() {
        var valor = this.trim();

        while (valor.indexOf('.') >= 0) {
            valor = valor.replace('.', '');
        }
        valor = valor.replace(',', '.');
        return parseFloat(valor);
    };

    String.prototype.isSoLetras = function() {
        var valor = this.trim();

        var regexLetras = /^[a-zA-Z ]$/;

        return regexLetras.test(valor);
    };

    String.prototype.isSoNumeros = function() {
        var valor = this.trim().replace(/\D/g, "");

        var regexLetras = /^[a-zA-Z ]$/;

        return regexLetras.test(valor);
    };


    Number.prototype.empty = function() {
        return this.trim() === 0;
    };

    Number.prototype.toStrCurrency = function() {
        var x = 0;
        var num = this;
        if (num < 0) {
            num = Math.abs(num);
            x = 1;
        }

        if (isNaN(num)) {
            num = "0";
        }

        var cents = Math.floor((num * 100 + 0.5) % 100);
        num = Math.floor((num * 100 + 0.5) / 100).toString();

        if (cents < 10) {
            cents = "0" + cents;
        }

        for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++) {
            num = num.substring(0, num.length - (4 * i + 3)) + '.' + num.substring(num.length - (4 * i + 3));
        }

        var ret = num + ',' + cents;
        if (x === 1) {
            ret = ' - ' + ret;
        }
        num = null;
        x = null;
        return ret;
    };
}

/*!
 * Funcao RequisicaoAjax
 * ---------------------
 * 
 * Rotina para criar um objeto ajax, dependendo do navegador
 * 
 * Retorno esperado: objeto ajax
 */
function RequisicaoAjax() {

    // define array com os tipos de conexaï¿½o
    var XMLHttpFactories = [
        function() {
            return new XMLHttpRequest();
        },
        function() {
            return new ActiveXObject("Msxml2.XMLHTTP");
        },
        function() {
            return new ActiveXObject("Msxml3.XMLHTTP");
        },
        function() {
            return new ActiveXObject("Microsoft.XMLHTTP");
        }
    ];

    var Ajax = null;
    var i = 0;
    while ((i < XMLHttpFactories.length) && (Ajax === null)) {
        try {
            Ajax = XMLHttpFactories[i]();
        } catch (e) {
            Ajax = null;
            continue;
        }
    }
    XMLHttpFactories = null;
    return Ajax;
}

/*!
 * funcao sendRequest
 * ------------------
 * Dt Criacao: 20/05/13
 * Autor: Lucas J. C. Chagas
 * Cria uma requisicao ajax para utilizacao em rotinas do Script
 * 
 * Retorno esperado: nenhum
 */
function sendRequest(cUrl, bCallback, uPostData, lSync, aReqHeader) {
    var req = RequisicaoAjax();

    if (req !== null) {
        var method = (uPostData) ? "POST" : "GET";
        req.open(method, cUrl, lSync);

        req.setRequestHeader('X-PINGOTHER', 'pingpong');
        req.setRequestHeader('Content-Type', 'application/xml; text/xml; charset=utf-8');
        req.setRequestHeader('Access-Control-Allow-Origin', '*');

        // define request a partir do aReqHeader        
        for (var i = 0; i <= aReqHeader.length - 1; i++) {
            var val = aReqHeader[i];
            req.setRequestHeader(val[0], val[1]);
        }

        // define chamada de retorno
        req.onreadystatechange = function() {
            if (req.readyState !== 4) {
                return;
            }

            if (req.status !== 200 && req.status !== 304) {
                //var erro = '<p>HTTP error - "' + req.statusText + '".</p>';
                //erro += '<p>Status - ' + req.status + '.</p>';
				
				var erro = '<br><p>' +req.responseXML.documentElement.getElementsByTagName('faultstring')[0].firstChild.nodeValue+ '</p><br>'
                $("#testBrowse").html(erro);
                return;
            }
            bCallback(req);

            if (req.readyState === 4) {
                return;
            }
        };

        req.send(uPostData);
    } else {
        alert('Objeto Ajax nao pode ser criado corretamente!!!!');
    }
}

/*!
 * funcao SoapFault
 * ----------------
 * Dt Criacao: 21/05/13
 * Autor: Lucas J. C. Chagas
 * Verifica se algum erro foi retornado do webservice
 * 
 * Retorno esperado: string / null
 */
function SoapFault(responseXML) {

    var erro = null;

    if (responseXML !== null) {
	
        if (($.browser.msie !== undefined) && ($.browser.msie) && ($.browser.versionNumber < 10) && ($.browser.versionNumber < 10)) {
            if (responseXML.childNodes[1].childNodes[0].firstChild.nodeName === "SOAP-ENV:Fault") {
                erro = new String(responseXML.childNodes[1].childNodes[0].childNodes[0].childNodes[1].text);
            }
        } else {
            if (responseXML.childNodes[0].childNodes[0].firstChild.nodeName === "SOAP-ENV:Fault") {
                erro = new String(responseXML.childNodes[0].childNodes[0].childNodes[0].childNodes[1].textContent);
            }
        }
    } else {
        erro = new String('ERRO000: Solicitacao nao pode ser processada. | Request can not be processed.');
    }

    return erro;
}

/* indica como usar a formataÃ§Ã£o de datas
 format character 	Description 	Example returned values
 Day
 d 	Day of the month, 2 digits with leading zeros 	01 to 31
 D 	A textual representation of a day, three letters 	Mon through Sun
 j 	Day of the month without leading zeros 	1 to 31
 l 	A full textual representation of the day of the week 	Sunday through Saturday
 N 	ISO-8601 numeric representation of the day of the week (added in PHP 5.1.0) 	1 (for Monday) through 7 (for Sunday)
 S 	English ordinal suffix for the day of the month, 2 characters 	st, nd, rd or th. Works well with j
 w 	Numeric representation of the day of the week 	0 (for Sunday) through 6 (for Saturday)
 z 	The day of the year (starting from 0) 	0 through 365
 Week
 W 	ISO-8601 week number of year, weeks starting on Monday (added in PHP 4.1.0) 	Example: 42 (the 42nd week in the year)
 Month
 F 	A full textual representation of a month, such as January or March 	January through December
 m 	Numeric representation of a month, with leading zeros 	01 through 12
 M 	A short textual representation of a month, three letters 	Jan through Dec
 n 	Numeric representation of a month, without leading zeros 	1 through 12
 t 	Number of days in the given month 	28 through 31
 Year
 L 	Whether itâ€™s a leap year 	1 if it is a leap year, 0 otherwise.
 o 	ISO-8601 year number. This has the same value as Y, except that if the ISO week number (W) belongs to the previous or next year, that year is used instead. (added in PHP 5.1.0) 	Examples: 1999 or 2003
 Y 	A full numeric representation of a year, 4 digits 	Examples: 1999 or 2003
 y 	A two digit representation of a year 	Examples: 99 or 03
 Time
 a 	Lowercase Ante meridiem and Post meridiem 	am or pm
 A 	Uppercase Ante meridiem and Post meridiem 	AM or PM
 B 	Swatch Internet time 	000 through 999
 g 	12-hour format of an hour without leading zeros 	1 through 12
 G 	24-hour format of an hour without leading zeros 	0 through 23
 h 	12-hour format of an hour with leading zeros 	01 through 12
 H 	24-hour format of an hour with leading zeros 	00 through 23
 i 	Minutes with leading zeros 	00 to 59
 s 	Seconds, with leading zeros 	00 through 59
 Timezone
 e (unsuported) 	Timezone identifier (added in PHP 5.1.0) 	Examples: UTC, GMT, Atlantic/Azores
 I 	Whether or not the date is in daylights savings time 	1 if Daylight Savings Time, 0 otherwise.
 O 	Difference to Greenwich time (GMT) in hours 	Example: +0200
 P 	Difference to Greenwich time (GMT) with colon between hours and minutes (added in PHP 5.1.3) 	Example: +02:00
 T 	Timezone setting of this machine 	Examples: EST, MDT â€¦
 Z 	Timezone offset in seconds. The offset for timezones west of UTC is always negative, and for those east of UTC is always positive. 	-43200 through 43200
 Full Date/Time
 c 	ISO 8601 date (added in PHP 5) 	2004-02-12T15:19:21+00:00
 r 	RFC 2822 formatted date 	Example: Thu, 21 Dec 2000 16:01:07 +0200
 U 	Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT) 	See also time()*/

Date.replaceChars = {
    shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    longMonths: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    longDays: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    // Day
    d: function() {
        return (this.getDate() < 10 ? '0' : '') + this.getDate();
    },
    D: function() {
        return Date.replaceChars.shortDays[this.getDay()];
    },
    j: function() {
        return this.getDate();
    },
    l: function() {
        return Date.replaceChars.longDays[this.getDay()];
    },
    N: function() {
        return this.getDay() + 1;
    },
    S: function() {
        return (this.getDate() % 10 === 1 && this.getDate() !== 11 ? 'st' : (this.getDate() % 10 === 2 && this.getDate() !== 12 ? 'nd' : (this.getDate() % 10 === 3 && this.getDate() !== 13 ? 'rd' : 'th')));
    },
    w: function() {
        return this.getDay();
    },
    z: function() {
        var d = new Date(this.getFullYear(), 0, 1);
        return Math.ceil((this - d) / 86400000);
    }, // Fixed now
    // Week
    W: function() {
        var d = new Date(this.getFullYear(), 0, 1);
        return Math.ceil((((this - d) / 86400000) + d.getDay() + 1) / 7);
    }, // Fixed now
    // Month
    F: function() {
        return Date.replaceChars.longMonths[this.getMonth()];
    },
    m: function() {
        return (this.getMonth() < 9 ? '0' : '') + (this.getMonth() + 1);
    },
    M: function() {
        return Date.replaceChars.shortMonths[this.getMonth()];
    },
    n: function() {
        return this.getMonth() + 1;
    },
    t: function() {
        var d = new Date();
        return new Date(d.getFullYear(), d.getMonth(), 0).getDate();
    }, // Fixed now, gets #days of date
    // Year
    L: function() {
        var year = this.getFullYear();
        return (year % 400 === 0 || (year % 100 !== 0 && year % 4 === 0));
    }, // Fixed now
    o: function() {
        var d = new Date(this.valueOf());
        d.setDate(d.getDate() - ((this.getDay() + 6) % 7) + 3);
        return d.getFullYear();
    }, //Fixed now
    Y: function() {
        return this.getFullYear();
    },
    y: function() {
        return ('' + this.getFullYear()).substr(2);
    },
    // Time
    a: function() {
        return this.getHours() < 12 ? 'am' : 'pm';
    },
    A: function() {
        return this.getHours() < 12 ? 'AM' : 'PM';
    },
    B: function() {
        return Math.floor((((this.getUTCHours() + 1) % 24) + this.getUTCMinutes() / 60 + this.getUTCSeconds() / 3600) * 1000 / 24);
    }, // Fixed now
    g: function() {
        return this.getHours() % 12 || 12;
    },
    G: function() {
        return this.getHours();
    },
    h: function() {
        return ((this.getHours() % 12 || 12) < 10 ? '0' : '') + (this.getHours() % 12 || 12);
    },
    H: function() {
        return (this.getHours() < 10 ? '0' : '') + this.getHours();
    },
    i: function() {
        return (this.getMinutes() < 10 ? '0' : '') + this.getMinutes();
    },
    s: function() {
        return (this.getSeconds() < 10 ? '0' : '') + this.getSeconds();
    },
    u: function() {
        var m = this.getMilliseconds();
        return (m < 10 ? '00' : (m < 100 ?
                '0' : '')) + m;
    },
    // Timezone
    e: function() {
        return "Not Yet Supported";
    },
    I: function() {
        var DST = null;
        for (var i = 0; i < 12; ++i) {
            var d = new Date(this.getFullYear(), i, 1);
            var offset = d.getTimezoneOffset();

            if (DST === null)
                DST = offset;
            else if (offset < DST) {
                DST = offset;
                break;
            } else if (offset > DST)
                break;
        }
        return (this.getTimezoneOffset() === DST) | 0;
    },
    O: function() {
        return (-this.getTimezoneOffset() < 0 ? '-' : '+') + (Math.abs(this.getTimezoneOffset() / 60) < 10 ? '0' : '') + (Math.abs(this.getTimezoneOffset() / 60)) + '00';
    },
    P: function() {
        return (-this.getTimezoneOffset() < 0 ? '-' : '+') + (Math.abs(this.getTimezoneOffset() / 60) < 10 ? '0' : '') + (Math.abs(this.getTimezoneOffset() / 60)) + ':00';
    }, // Fixed now
    T: function() {
        var m = this.getMonth();
        this.setMonth(0);
        var result = this.toTimeString().replace(/^.+ \(?([^\)]+)\)?$/, '$1');
        this.setMonth(m);
        return result;
    },
    Z: function() {
        return -this.getTimezoneOffset() * 60;
    },
    // Full Date/Time
    c: function() {
        return this.format("Y-m-d\\TH:i:sP");
    }, // Fixed now
    r: function() {
        return this.toString();
    },
    U: function() {
        return this.getTime() / 1000;
    }
};

/*!
 * classe Produtos   
 * ---------------   
 * Dt Criacao: 22/05/13
 * Autor: Lucas J. C. Chagas
 * Cria classe singleton de produtos                            
 * 
 * Retorno esperado: objeto Singleton Produtos
 */
var Produtos = (
        function() {
            var instantiated;
            var rows = new Array();

            function init() {
                return {
                    // retorna o array inteiro
                    getRows: function() {
                        return rows;
                    },
                    // adiciona id da linha da tabela
                    // na ultima posicao sempre
                    addRow: function(idRow) {
                        rows[rows.length] = idRow;
                    },
                    // recria o array, caso seja necess�rio limpar os dados
                    clearRows: function() {
                        rows = new Array();
                    }
                };
            }

            return {
                getInstance: function() {
                    if (!instantiated) {
                        instantiated = init();
                    }
                    return instantiated;
                }
            };
        }
)();
    
/*!
 * classe ValorAnterior   
 * --------------------   
 * Dt Criacao: 22/05/13
 * Autor: Lucas J. C. Chagas
 * Classe para manter o valor antigo de um campo                
 * 
 * Retorno esperado: objeto Singleton ValorAnterior
 */
var ValorAnterior = (
        function() {
            var instantiated;
            var valor = new String("");

            function init() {
                return {
                    getValor: function() {
                        return valor;
                    },
                    setValor: function(pValor) {
                        valor = new String(pValor);
                    }
                };
            }

            return {
                getInstance: function() {
                    if (!instantiated) {
                        instantiated = init();
                    }
                    return instantiated;
                }
            };
        }
)();