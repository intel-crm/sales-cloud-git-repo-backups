({
	getLanguageCookie: function(intelLanguage){
    var language = intelLanguage + "=";
    console.log('documentCookie-->'+document.cookie);
    var decodedCookie = decodeURIComponent(document.cookie);
    var cookies = decodedCookie.split(';');
    for(var i = 0; i <cookies.length; i++) {
        var c = cookies[i];
        while (c.charAt(0) == ' ') {
        c = c.substring(1);
        }
        if (c.indexOf(language) == 0) {
        return c.substring(language.length, c.length);
        }
    }
    return "";
  }
})