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
    
    checkGarbageValue : function(cmp, helper) {
        var garbageName = $A.get("$Label.c.Core_PMP_Offering_Desc_GarbageSymbols"); 
            var garbageNameArr = [];
            var isgarbageValue = false;
            garbageNameArr = garbageName.split(";");
            for(var index =0; index<garbageNameArr.length;index++){
                if(cmp.get("v.value").includes(garbageNameArr[index])){
                   isgarbageValue = true;
                }
            }
        
        var valid = !cmp.get("v.required") || cmp.get("v.value");
             var textValue = '';
         // rich text will always have a p		
            if (cmp.get("v.required")){		
                // strip off html tags
                if(cmp.get("v.value"))		
                    textValue = cmp.get("v.value").replace(/<[^>]+>/g, '');		
                valid = textValue.trim().length > 0;		
            }
            
            if(isgarbageValue){
               cmp.set("v.valid", false);
               cmp.set("v.showInvalid", true);
               cmp.set('v.required', true);
               cmp.set('v.errorMessage',$A.get("$Label.c.PMP_Garbage_Name_Check_Error"));
               window.localStorage.setItem('hideSaveDesc', true); 
            }else if(!isgarbageValue && valid && (cmp.get("v.value")!='' && cmp.get("v.value"))){
                
               cmp.set("v.valid", true);
               cmp.set("v.showInvalid", false);
               cmp.set('v.touched', true);
               window.localStorage.setItem('hideSaveDesc', false); 
            }else if((!valid || cmp.get("v.value")=='' || !cmp.get("v.value") || cmp.get("v.value").replace(/\s/g,"")==="")){
              cmp.set("v.valid", false);
              cmp.set("v.showInvalid", true);  
              cmp.set('v.errorMessage',$A.get("$Label.c.PMP_FieldRequired"));
              window.localStorage.setItem('hideSaveDesc', true);  
            }
    },
    
})