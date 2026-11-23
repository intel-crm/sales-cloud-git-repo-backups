({

  doInit : function(component, event, helper) {
      console.log('valueType',component.get('v.valueType') );
      console.log('apiName',component.get("v.apiName"));
      console.log('fieldName',component.get("v.fieldName"));  
      
    if (component.get('v.valueType') == 'default') {
      helper.setInitialValue(component, helper);
    } else if (component.get('v.valueType') == 'complex') {
      helper.setInitialComplexValue(component, helper);
    }
    
    if(component.get("v.required") && !component.get("v.value")) {
        component.set("v.valid", false);
        console.log('insideIsvalid' + component.get("v.valid"));
    } else {
      component.set("v.valid", true);
    }
      if(component.get('v.label')=='Order Lead Time (Days)'){
         console.log('They See Me'+component.get("v.value")); 
      }  
      
    if (component.get('v.maxLength') && component.find("input")) {
      component.find("input").set('v.maxlength', component.get('v.maxLength')); 
    }
    if (component.get('v.minLength') && component.find("input")) {
      component.find("input").set('v.minLength', component.get('v.minLength'));
    }
    //Added By Shahrukh (ONYX) US357417 
    if(component.get('v.fieldName') == 'PMP_Partner_Offering_Start_Dt__c' && component.get('v.apiName')=='offering'){
       window.localStorage.setItem('fromDate', component.get("v.value"));
    }else if(component.get('v.fieldName') == 'PMP_Partner_Offering_End_Dt__c' && component.get('v.apiName')=='offering'){
       window.localStorage.setItem('toDate', component.get("v.value"));
    }  
    
    if (component.get('v.fieldName') == 'PMP_Partner_Offering_Nm__c' && component.get('v.apiName')=='offering' && !component.get('v.value')) {
        console.log('inside init----#####>');
        window.localStorage.setItem('hideSave', true);
    } 
      
      if(window.localStorage.getItem('hideSave')){
         component.set('v.touched', false); 
      }else{
          component.set('v.touched', true);
      }
     
        helper.updateForm(component);
      
   
  },
   

  handleBlur : function(component, event, helper) {
      console.log('inside handleblur -------> text:'+component.get("v.fieldName"));
    var language = helper.getLanguageName(component.get("v.userSelectedLanguage"));
     var offeringCreatedLanguage = component.get('v.offeringCreatedLanguage')
     console.log('language--->' +language +offeringCreatedLanguage);
    if (component.get('v.subType') == 'email') {
      helper.processInput(component, helper);
    }
      
     //Added By Shahrukh (ONYX) US357417   
    if (component.get('v.fieldName') == 'PMP_Partner_Offering_Nm__c' && component.get('v.apiName')=='offering') {  //Checking if Name contains any garbage character
        var name=component.get("v.value")+'';
        console.log('name--->',name);
        console.log('nameLength--->',name.length);
        var offeringNameEntered = $A.get("e.c:PMP_OfferingNameEvent");
		offeringNameEntered.setParams({
    	offeringName: name}).fire();

        var garbageName = $A.get("$Label.c.Core_PMP_Offering_Name_GarbageSymbols"); //All the garbage characters are stored in label as ; seperated values
        var garbageNameArr = [];
        var isgarbageValue = false;
        
        /*US406710 - START - Added by manasa : Offering Name more than 255 characters it should show an error*/
        var isNameLengthGreaterThan255 = false;
        if(name.length > 255){
            isNameLengthGreaterThan255 = true;
        } 
        console.log('isNameLengthGreaterThan255-->',isNameLengthGreaterThan255);
        /*US406710 - END */
        
        garbageNameArr = garbageName.split(";");
        for(var index =0; index<garbageNameArr.length;index++){ // Looping Through all the garbage values and checking if any of them is present in name
            if(component.get("v.value")!=undefined && component.get("v.value").includes(garbageNameArr[index])){
               isgarbageValue = true;
               break;
            }
        }
        //Defect Fix : DE47787 - Manasa
        var nameRegexPattern=$A.get("$Label.c.PMP_RegexOfferingNamePattern");//regex pattern stored as a label  
        var namePattern=RegExp(nameRegexPattern,"gi");
        var validName=namePattern.test(component.get("v.value"));//checking if the name matches the pattern
        if(!validName && component.get("v.value")){
            isgarbageValue=true;
            window.localStorage.setItem('hideSave', true); 
		}
       //If Offering Name more than 255 characters it should show an error - US406710 - Added by manasa
       //If any garbage character is present then adding error class and disabling next button
        if(isgarbageValue || isNameLengthGreaterThan255){ 
            if(isgarbageValue){
               helper.checkError(component, helper, $A.get("$Label.c.PMP_Garbage_Name_Check_Error")); 
            }else if(isNameLengthGreaterThan255){
                helper.checkError(component, helper, $A.get("$Label.c.PMP_OfferingNameLengthGreaterThan255"));
            }          
           window.localStorage.setItem('hideSave', true); 
        }else if(!(isgarbageValue && isNameLengthGreaterThan255)  && component.get("v.value")){
           helper.checkNoError(component, helper);
           window.localStorage.setItem('hideSave', false);
		   
		   if(language && language == offeringCreatedLanguage){
			   helper.updateForm(component,'both');
			   console.log('bothhhh');
		   }
		   else if(language && language != offeringCreatedLanguage){
			   helper.updateForm(component,'translation_table');
			   console.log('translationnn');
		   }
		   else{
			   helper.updateForm(component);
		   }
				 
        }else if(!component.get("v.value")){
           component.set('v.hasError', false);
           window.localStorage.setItem('hideSave', true); 
           helper.updateForm(component);  
        }
        
    }
     
    if((component.get('v.fieldName') == 'PMP_Partner_Offering_Tag_Line_Txt__c' ||
          component.get('v.fieldName') == 'PMP_Partner_Offering_Nm__c') && component.get('v.apiName')=='offering'){
         
           /*US423682/US517754 - START - Added by Sandhya : Tag Line more than 100 characters it should show an error*/
        	
           if(component.get("v.fieldName")=='PMP_Partner_Offering_Tag_Line_Txt__c'){
               var tagLineVal = component.get("v.value");
               if(tagLineVal.length > 100){
            		
                    helper.checkError(component, helper, $A.get("$Label.c.PMP_TagLine_Length_Check"));
               } else{
                   helper.checkNoError(component, helper);
               }
               
           }
           
        /*US423682/US517754 - END */
           //US434806 if user edits Name/Tagline through language hyperlinks.
           if(language && language == offeringCreatedLanguage){
			   helper.updateForm(component,'both');
			   
		   }
		   else if(language && offeringCreatedLanguage){
			   helper.updateForm(component,'translation_table');
			  
		   }
		   else{
			   helper.updateForm(component);
		   }
      } 
     
    //helper.updateForm(component); 
    
      
  },

	handleChange : function(component, event, helper) {
    if (component.get('v.valueType') == 'complex') {
      helper.setComplexValue(component, helper);
    }
    if (component.get('v.subType') == 'email') {
      helper.processInputWithoutReport(component, helper);
    } else {
      helper.processInput(component, helper);
    }
        
        if (component.get('v.fieldName') == 'PMP_Partner_Offering_Nm__c' && component.get('v.apiName')=='offering') {
            if(!component.get("v.value") || component.get("v.value")===""){
               window.localStorage.setItem('hideSave', true); 
               helper.updateForm(component);   
            }
            
        
        
        var garbageName = $A.get("$Label.c.Core_PMP_Offering_Name_GarbageSymbols"); //All the garbage characters are stored in label as ; seperated values
        var garbageNameArr = [];
        var isgarbageValue = false;
        garbageNameArr = garbageName.split(";");
        for(var index =0; index<garbageNameArr.length;index++){ // Looping Through all the garbage values and checking if any of them is present in name
            if(component.get("v.value")!=undefined && component.get("v.value").includes(garbageNameArr[index])){
               isgarbageValue = true;
               window.localStorage.setItem('hideSave', true); 
               break;
            }
        }
        //Defect Fix : DE47787 - Manasa
        var nameRegexPattern=$A.get("$Label.c.PMP_RegexOfferingNamePattern");//regex pattern stored as a label  
        var namePattern=RegExp(nameRegexPattern,"g");
        var validName=namePattern.test(component.get("v.value"));//checking if the name matches the pattern
            if(!validName && component.get("v.value")){
                isgarbageValue=true;
                window.localStorage.setItem('hideSave', true); 
            }
        } 
        //added by raj for URL validation
        else if(component.get('v.fieldName') == 'Url' && component.get('v.apiName')=='productWebPageData'){
            console.log('inside url validation----->');              
            var isInvalidUrl = false;
            var pattern=$A.get("$Label.c.PMP_RegexURLPattern");//regex pattern stored as a label
            var url=RegExp(pattern,"gi");
            var valid=url.test(component.get("v.value"));//checking if the url matches the pattern
            
            /*START US423682 : Added by Sandhya*/
            var isUrlLengthGreaterThan255 = false;
             var urlValue = component.get("v.value");
            /* END */
            
            if(!valid){
                isInvalidUrl=true;
            }
            if(isInvalidUrl && component.get("v.value")){ //If the URL is invalid then adding error class and disabling next button
                helper.checkError(component, helper, $A.get("$Label.c.PMP_Invalid_Url_Error"));
                
            }else if(!isInvalidUrl && component.get("v.value")){//if the url is valid and value is not null
                /*START US423682 : Added by Sandhya*/
                if(urlValue.length > 255){
                        isUrlLengthGreaterThan255 = true;
                       helper.checkError(component, helper, $A.get("$Label.c.PMP_Url_Length_Check"));
                   } else{
                       helper.checkNoError(component, helper);
                   }
                /* END */
            }else if(!component.get("v.value") && !component.get("v.required")){//if the value is empty and it is not required
                console.log('No value for URL');
                helper.checkNoError(component, helper);
            }
            
        }
        else if(component.get('v.fieldName') == 'Name' && component.get('v.apiName')=='productWebPageData'){
          var isTitleLengthGreaterThan255 = false;
           
               var titleVal = component.get("v.value");
               if(titleVal.length > 80){
            		isTitleLengthGreaterThan255 = true;
                   console.log('isTitleLengthGreaterThan255----'+isTitleLengthGreaterThan255);
                   helper.checkError(component, helper, $A.get('$Label.c.PMP_TitleNameLengthMessage'));
               } 
               else if(!component.get("v.value")){
                   helper.checkError(component, helper);                   
               }else{
                   helper.checkNoError(component, helper);
               }    
      	}else if(component.get('v.fieldName') == 'PMP_Partner_Offering_Start_Dt__c' && component.get('v.apiName')=='offering'){ //Offering From Date Validation
        var fromDate = component.get("v.value");
        fromDate = new Date(fromDate);
        var today = new Date();
        fromDate = fromDate.toISOString().slice(0,10);
        today = today.toISOString().slice(0,10);
        var toDate = window.localStorage.getItem('toDate');
        toDate = new Date(toDate); 
        toDate = toDate.toISOString().slice(0,10);
        
        if(fromDate<today){ //Checking fromdate is not a past date
           window.localStorage.setItem('fromDate', component.get("v.value")); 
           helper.checkError(component, helper, $A.get("$Label.c.PMP_Past_Start_Date_Error")); 
        }else if((fromDate>toDate && fromDate!==today) ||(fromDate>toDate && toDate<today)){ //Checking fromdate is not greater than toDate
           window.localStorage.setItem('fromDate', component.get("v.value")); 
           helper.checkError(component, helper, $A.get("$Label.c.PMP_Start_Date_Greater_Than_End_Date_Error"));  
        }else if(fromDate==toDate){ //Checking if both dates are not equal
           window.localStorage.setItem('fromDate', component.get("v.value")); 
           helper.checkError(component, helper, $A.get("$Label.c.PMP_Start_Date_Equals_End_Date_Error")); 
        }else{
           window.localStorage.setItem('fromDate', component.get("v.value"));  
           helper.checkNoError(component, helper);
        }
    }else if(component.get('v.fieldName') == 'PMP_Partner_Offering_End_Dt__c' && component.get('v.apiName')=='offering'){ //Offering End Date Validation
        var toDate = component.get("v.value");
        toDate = new Date(toDate);
        var today = new Date();
        toDate = toDate.toISOString().slice(0,10);
        today = today.toISOString().slice(0,10);
        var fromDate = window.localStorage.getItem('fromDate');
        fromDate = new Date(fromDate); 
        fromDate = fromDate.toISOString().slice(0,10);
        if(toDate<fromDate){ //Check if toDate is not less than fromDate
           window.localStorage.setItem('toDate', component.get("v.value")); 
           helper.checkError(component, helper, $A.get("$Label.c.PMP_End_Date_Less_Than_Start_Date_Error"));   
        }else if(fromDate==toDate){ //Checking if both dates are not equal
           window.localStorage.setItem('toDate', component.get("v.value")); 
           helper.checkError(component, helper, $A.get("$Label.c.PMP_End_Date_Equals_Start_Date_Error")); 
        }else if(fromDate<today){ //Checking if both dates are not equal
           window.localStorage.setItem('toDate', component.get("v.value"));
           var cmpTarget = component.find('input'); 
      	   $A.util.removeClass(cmpTarget, 'slds-has-error'); 
           component.set('v.hasError', false); 
        }
        else{
           window.localStorage.setItem('toDate', component.get("v.value"));  
           helper.checkNoError(component, helper);
        }
        
    }
        helper.updateForm(component);
	},
    focus : function(component, event, helper) {
    component.find('input').focus();
  },
   
    
    

})