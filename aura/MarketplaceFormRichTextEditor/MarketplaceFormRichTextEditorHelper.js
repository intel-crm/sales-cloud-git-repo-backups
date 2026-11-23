({
	getLanguageName : function(languageCode) {

		// this map is a list of the available languages and their locale names
		var languageMap = {

		  zh_CN:           "Simplified Chinese",
		  en_US:       "English",
		  ja_JP:       "Japanese", 
		  
		};
		return languageMap[languageCode];
	},
    
    showErrorMessage : function(component, helper) {
        if (!component.get('v.valid')) {
            component.set("v.showInvalid", true);
        }
    },
    
})