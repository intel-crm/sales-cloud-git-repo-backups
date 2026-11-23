({
    setUserLangLocale: function(component, event, helper) {
        
        //userLangLocale="fr";
        var userLangLocale = $A.get("$Locale.langLocale");
        
		var analyticsUserLangLocale = 'us-en';
        console.log('userLangLocale = '+ userLangLocale);
        
        switch (userLangLocale)
        {
            case "ja":
                userLangLocale = "ja_JP";
                analyticsUserLangLocale = "jp-ja";
                break;
            case "fr":
                userLangLocale = "fr_FR";
                analyticsUserLangLocale = "fr-fr";
                break;
            case "de":
                userLangLocale = "de_DE";
                analyticsUserLangLocale = "de-de";
                break;
            case "ko":
                userLangLocale = "ko_KR";
                analyticsUserLangLocale = "kr-ko";
                break;
            case "es":
                userLangLocale = "es_ES";
                analyticsUserLangLocale = "es-es";
                break;
            case "it":
                userLangLocale = "it_IT";
                analyticsUserLangLocale = "it-it";
                break;
            case "ru":
                userLangLocale = "ru_RU";
                analyticsUserLangLocale = "ru-ru";
                break;
        }      

        window.INTELNAV = window.INTELNAV || {};
        INTELNAV.renderSettings={version:"2.0 - 03/12/2017 08:00:00",textDirection:"ltr",culture:userLangLocale,OutputId:"default"};

        //************ Do not allow authenticated users to switch to another language
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if(!($A.util.isEmpty(userId) || $A.util.isUndefined(userId))){
            INTELNAV.dashboard = "";
        }
        
        //*******************Load WAP Framework*************************
        
        analyticsUserLangLocale = 'en_US';
        console.log('Inside IntelHeaderHelper.js userLangLocale > analyticsUserLangLocale = '+ analyticsUserLangLocale);
        try{
        	//loadAnalyticsScript(analyticsUserLangLocale);  // Used for calling the function in the head script
        	//console.log('1. intelHeaderHelper.js > wap_tms = '+ wap_tms);    
            //code before the pause
            /*setTimeout(function(){
                //console.log('2. intelHeaderHelper.js > wap_tms = '+ wap_tms);
                //window.wap_tms = wap_tms;
                //console.log('intelHeaderHelper > window.wap_tms = '+ window.wap_tms);
            }, 2000);*/
        }catch(e){
        	console.log(e);  
        }

    },
    
})