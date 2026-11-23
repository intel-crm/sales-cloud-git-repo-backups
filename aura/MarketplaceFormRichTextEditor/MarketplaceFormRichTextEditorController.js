/**
 * @description       : 
 * @author            : Balaji M
 * @group             : 
 * @last modified on  : 09-03-2020
 * @last modified by  : Balaji M
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   09-03-2020   Balaji M   Initial Version
**/
({

    doInit : function(cmp, event, helper) {
      var defaultErrorMessage = $A.get("$Label.c.PMP_FieldRequired"); //Defect Fix
      
      if (!cmp.get('v.errorMessage') && cmp.get('v.required')) cmp.set('v.errorMessage', defaultErrorMessage);
      if (cmp.get("v.required") && !cmp.get("v.value")) {
        cmp.set("v.valid", false);
      } else {
        cmp.set("v.valid", true);
        // Adding the change to let the description field allow paragraphs
      //  var textValue = cmp.get("v.value").replace(/<[^>]+>/g, '');
      var textValue = cmp.get("v.value");
cmp.set('v.value', textValue); 
      }
      // IPA2.0 + US TWC4497-1631
      // if (cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && !cmp.get("v.value")) {
      //     window.localStorage.setItem('hideSaveDesc', true);
      // }else if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && cmp.get("v.value")){
      //     window.localStorage.setItem('hideSaveDesc', false);
      // }
        
      if(window.localStorage.getItem('hideSaveDesc')){
         cmp.set('v.touched', false); 
      }
      // IPA2.0 + US TWC4497-1631
      // else if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && !window.localStorage.getItem('hideSaveDesc')){
      //    cmp.set('v.touched', true);
      // }  
        
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
      //   IPA2.0 + US TWC4497-1631
     	// var offeringCreatedLanguage = cmp.get('v.offeringCreatedLanguage')
      var valid = !cmp.get("v.required") || cmp.get("v.value");
      var textValue = '';
         // rich text will always have a p		
      if (cmp.get("v.required")){		
        // strip off html tags
        if(cmp.get("v.value"))		
        textValue = cmp.get("v.value").replace(/<[^>]+>/g, '');
        valid = textValue.length > 0;		
      }
      cmp.set("v.valid", valid);
      cmp.set("v.showInvalid", !valid);
        
       //As Part of US954587:Limit Error message in storefront Description
       if(cmp.get('v.fromStorefront')){
       		var descriptionVal = cmp.get("v.value");
            if(descriptionVal != undefined && descriptionVal.length > 131072){
           		cmp.set("v.valid", false);
            	cmp.set("v.showInvalid", true);  
            	cmp.set('v.errorMessage',$A.get("$Label.c.PMP_Maximum_Limit_Exceeded_Msg"));
       		}
            else if(descriptionVal != undefined && descriptionVal.length <= 131072){
           		cmp.set("v.valid", true);
            	cmp.set("v.showInvalid", false);  
       		}
       }
       //US954587:END
       
        
         //Added By Shahrukh (ONYX) US357417
        //  IPA2.0 + US TWC4497-1631
      //   if (cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c') { // Checking Garbage Characters in Description
            
      //       helper.checkGarbageValue(cmp,helper);
      //   }  
        
      //   if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && cmp.get('v.apiName')=='offering'){
           
      //       //As Part of US954587:Limit Error message in Offering Description
      //       var descVal = cmp.get("v.value");
      //       if((descVal != undefined && descVal.length > 131072)){
      //           cmp.set("v.valid", false);
      //           cmp.set("v.showInvalid", true);  
      //           cmp.set('v.errorMessage',$A.get("$Label.c.PMP_DescriptionLengthMessage"));
      //           window.localStorage.setItem('hideSaveDesc', true); 
      //       } //US954587:END
        
                     
      //     if(language && language == offeringCreatedLanguage){
			//    helper.updateForm(cmp,'both');
		  //  }
		  //  else if(language && offeringCreatedLanguage){
			//    helper.updateForm(cmp,'translation_table');
		  //  }
		  //  else{
			//    helper.updateForm(cmp);
		  //  }
    	// }
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
    // IPA2.0 + US TWC4497-1631
       
        // if(cmp.get('v.fieldName') == 'PMP_Partner_Offering_Dsc__c' && cmp.get('v.apiName')=='offering'){
      		
            
        //     var descVal = cmp.get("v.value");
        //     if((descVal != undefined && descVal.length > 131072)){
        //         cmp.set("v.valid", false);
        //         cmp.set("v.showInvalid", true);  
        //         cmp.set('v.errorMessage',$A.get("$Label.c.PMP_DescriptionLengthMessage"));
        //         window.localStorage.setItem('hideSaveDesc', true); 
               
        //     }else if(descVal.replace(/\s/g,"")==="<p></p>" || descVal.replace(/\s/g,"")===""){
        //           cmp.set("v.valid", false);
        //           cmp.set("v.showInvalid", true);
        //           cmp.set('v.errorMessage',$A.get("$Label.c.PMP_CTA_Complete_The_Field"));
        //     }else{
        //         cmp.set("v.valid", true);
        //         cmp.set("v.showInvalid", false);
        //     }
            
            
            
        //      var valid = !cmp.get("v.required") || cmp.get("v.value");
        //      var textValue = '';
        //  // rich text will always have a p		
        //     if (cmp.get("v.required")){		
        //         // strip off html tags
        //         if(cmp.get("v.value"))		
        //             textValue = cmp.get("v.value").replace(/<[^>]+>/g, '');		
        //         valid = textValue.length > 0;
                
        //     }
            
        //     if(cmp.get("v.valid")){
        //     	helper.checkGarbageValue(cmp,helper);
        //     }
        // }
       //	var textInput = cmp.get("v.value").replace(/<[^>]+>/g, '');
       //	cmp.set('v.value',textInput);
        // check for existing checks and also the plain text now.
         var plain = (cmp.get("v.value") || '').replace(/<[^>]+>/g, '');
         cmp.set("v.showInvalid", cmp.get("v.required") && plain.length === 0);
    }

  })