({

    doInit : function(cmp, event, helper) {
      var defaultErrorMessage = 'This field is required.' //Defect Fix
      
      if (!cmp.get('v.errorMessage') && cmp.get('v.required')) cmp.set('v.errorMessage', defaultErrorMessage);
      if (cmp.get("v.required") && !cmp.get("v.value")) {
        cmp.set("v.valid", false);
      } else {
        cmp.set("v.valid", true);
      }
      if (cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && !cmp.get("v.value")) {
          window.localStorage.setItem('hideSaveDesc', true);
      }
        
      if(window.localStorage.getItem('hideSaveDesc')){
         cmp.set('v.touched', false); 
      }else if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && !window.localStorage.getItem('hideSaveDesc')){
         cmp.set('v.touched', true);
      }  
        
      helper.updateForm(cmp);
    },
    
    handleValueChange: function(cmp, event, helper) {
       
      if (cmp.get("v.touched")){		
        // do handleChange if touched, IE doesn't always respond to onkeyup/onkeydown		
        $A.enqueueAction(cmp.get('c.handleChange'));		
      }		
    },

    handleChange : function(cmp, event, helper) {
        
        var language = helper.getLanguageName(cmp.get("v.userSelectedLanguage"));
     	var offeringCreatedLanguage = cmp.get('v.offeringCreatedLanguage')
      var valid = !cmp.get("v.required") || cmp.get("v.value");
      var textValue = '';
        console.log('value entered-->',cmp.get("v.value"));
         // rich text will always have a p		
      if (cmp.get("v.required")){		
        // strip off html tags
        if(cmp.get("v.value"))		
        textValue = cmp.get("v.value").replace(/<[^>]+>/g, '');		
        valid = textValue.length > 0;		
      }
      cmp.set("v.valid", valid);
      cmp.set("v.showInvalid", !valid);
        
         //Added By Shahrukh (ONYX) US357417
        if (cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' ) { // Checking Garbage Characters in Description
            
            var garbageName = $A.get("$Label.c.Core_PMP_Offering_Desc_GarbageSymbols"); 
            var garbageNameArr = [];
            var isgarbageValue = false;
            garbageNameArr = garbageName.split(";");
            for(var index =0; index<garbageNameArr.length;index++){
                if(cmp.get("v.value").includes(garbageNameArr[index])){
                   isgarbageValue = true;
                }
            }
            //Defect Fix : DE47787 - Manasa
            var nameRegexPattern=$A.get("$Label.c.PMP_RegexOfferingNamePattern");//regex pattern stored as a label  
            var namePattern=RegExp(nameRegexPattern,"gi");	
            var validName=namePattern.test(textValue);//checking if the name matches the pattern
            if(!validName){
                isgarbageValue=true;
                
            } 
            if(isgarbageValue){
               cmp.set("v.valid", false);
               cmp.set("v.showInvalid", true);
               cmp.set('v.required', true);
               cmp.set('v.errorMessage',$A.get("$Label.c.PMP_Garbage_Name_Check_Error"));
               window.localStorage.setItem('hideSaveDesc', true); 
            }else if(!isgarbageValue && (cmp.get("v.value")!='' && cmp.get("v.value"))){
                
               cmp.set("v.valid", true);
               cmp.set("v.showInvalid", false);
               cmp.set('v.touched', true);
               window.localStorage.setItem('hideSaveDesc', false); 
            }else if((cmp.get("v.value")=='' || !cmp.get("v.value") || cmp.get("v.value").replace(/\s/g,"")==="")){
              cmp.set("v.valid", false);
              cmp.set("v.showInvalid", true);  
              cmp.set('v.errorMessage','This field is Required');
              window.localStorage.setItem('hideSaveDesc', true);  
            }
        }  
        
        if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && cmp.get('v.apiName')=='offering'){
            
                     
          if(language && language == offeringCreatedLanguage){
			   helper.updateForm(cmp,'both');
			   console.log('tagline--bothhhh');
		   }
		   else if(language && offeringCreatedLanguage){
			   helper.updateForm(cmp,'translation_table');
			   console.log('translationnn');
		   }
		   else{
			   helper.updateForm(cmp);
		   }
    	}
      helper.updateForm(cmp);
    },

    handleTouch : function(cmp, event, helper) {
      cmp.set("v.touched", true);
      helper.updateForm(cmp);
    },
    handleReportValidity : function(component, event, helper) {
      if (!component.get('v.valid')) {
        component.set("v.showInvalid", true);
      }
    },    
   handleBlur : function(cmp,event,helper){
       
        if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && cmp.get('v.apiName')=='offering'){
     
            var descVal = cmp.get("v.value");
            if((descVal != undefined && descVal.length > 131072)){
                cmp.set("v.valid", false);
                cmp.set("v.showInvalid", true);  
                cmp.set('v.errorMessage',$A.get("$Label.c.PMP_DescriptionLengthMessage"));
                window.localStorage.setItem('hideSaveDesc', true); 
               
            }else if(descVal.replace(/\s/g,"")==="<p></p>" || descVal.replace(/\s/g,"")===""){
                  cmp.set("v.valid", false);
                  cmp.set("v.showInvalid", true);
                  cmp.set('v.errorMessage',$A.get("$Label.c.PMP_CTA_Complete_The_Field"));
            }else{
                cmp.set("v.valid", true);
                cmp.set("v.showInvalid", false);
            }
            
        }
    }

  })