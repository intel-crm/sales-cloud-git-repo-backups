({
    initialize : function(cmp,event,helper) {
        console.log('constructor-->');
        var objRes= cmp.get("v.res");
        var isDisable = objRes.isNotAccess;
        cmp.set("v.isDisable",isDisable);
        var respArr = [];
        var multiString = '';
        var booleanUpdateValue;
        
        console.dir(objRes);
        // var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        if(objRes.question && objRes.question.PRM_Question_Type_Nm__c == 'Boolean'){
            // && objRes.question.PRM_Question_Display_Txt__c !='Points Opt-in' && objRes.question.PRM_Question_Display_Txt__c !='Points Not eligible'
            var returnValue = objRes.response.PRM_Response_Txt__c;
            var booleanValue = cmp.find("checkbox");
            
            if(returnValue && returnValue === 'true'){
                console.log('>>is true');
                booleanValue.set("v.value",true);
            }else if(returnValue != 'true' && returnValue != 'false' && returnValue != 'null'){
                console.log('>>date'+JSON.stringify(returnValue)); 
            }else {
                console.log('>>is false');
                booleanValue.set("v.value",false);
            }            
            console.log('booleanValue--->'+booleanValue);
            
        }
        
      /*  // Added as part of US_2469 
        var reasonTextValue = cmp.find("reasontext").get("v.value");
        if(reasonTextValue === "undefined") {       
            cmp.find("reasontext").set("v.value",'');       
        }     */   
    },
    
    valueUpdates:function(cmp){
        var quesType = ["Picklist","Boolean"];
        var respArr = [];
        var objRes;
        var saveResponse;
        var respAns;
        objRes= cmp.get("v.res");
        saveResponse = cmp.get("v.objResponse"); 
        respArr = cmp.get("v.saveResponse");
        //removing existing questions to ensure no duplicate responses are stored in the system
        if(objRes.question.Id){
            respArr = respArr.filter(function( obj ) {
                return obj.PRM_Profile_Questions_Id__c !== objRes.question.Id;
            });
        }
        if(objRes.response){
            saveResponse.Id = objRes.response.Id;
        }
        saveResponse.PRM_Profile_Questions_Id__c = objRes.question.Id;
        saveResponse.PRM_Response_Txt__c = String(objRes.response.PRM_Response_Txt__c);
        // Added as part of US_2469 
        if(objRes.response.PRM_Reason_Text__c === undefined){
            saveResponse.PRM_Reason_Text__c = '';
        }else{  
            saveResponse.PRM_Reason_Text__c = String(objRes.response.PRM_Reason_Text__c);            
        }
        saveResponse.PRM_ResponseDate__c = String(objRes.response.PRM_ResponseDate__c);
        saveResponse.PRM_Account_Id__c = cmp.get("v.recordId");
        console.log('objRes.answers.Id-->'+objRes.answers.Id);
        // getting answer records for the corresponding question..
        if(objRes.answers){
            console.log('get answer record',objRes.answers);
            console.log('get question record',objRes.response);
            console.log('get question record',objRes.question);
            respAns = objRes.answers; 
            //filtering out answers if they match the response for the piclist and boolean type
            if(quesType.includes(objRes.question.PRM_Question_Type_Nm__c)){
                console.log('respAns1',respAns);
                respAns = respAns.filter(function( obj ) {
                    return obj.PRM_Answer_Display_Txt__c === String(objRes.response.PRM_Response_Txt__c);
                    
                });       
                console.log('respAns2',respAns);
            }
        }
        console.log('respAns3',respAns[0]);
        //check if answer was found? and assign it to response
        if(respAns[0])
            saveResponse.PRM_Profile_Answer_Id__c = respAns[0].Id;
        respArr.push(saveResponse);
        cmp.set("v.saveResponse",respArr);
       // console.log('respAns[0].Id--->'+respAns[0].Id);
        console.log(saveResponse);
        console.log("respArr-->"+JSON.stringify(respArr));
    },
    
    DateforOptIn : function(cmp) {
        objRes= cmp.get("v.res");
        var quesType = ["Boolean"];
        var respArr = [];
        var objRes;
        var saveResponse;
        var respAns;
        // console.log('Objresponse11'+JSON.stringify(objRes));
        
        // console.log('display text-'+JSON.stringify(objRes.question.PRM_Question_Cd__c)); 
        console.log('Line 100'+checkboxVar);   
        console.log('objRes',objRes);
        
        if((objRes.question.PRM_Question_Cd__c == 'PRM_Opt_In' || objRes.question.PRM_Question_Cd__c == 'PRM_Point_Not_Eligible') && objRes.response.PRM_Response_Txt__c == true)
        {
            var today = new Date();
            var mydate =today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
            // console.log('final date'+JSON.stringify(objRes.response.PRM_Response_Txt__c));
            cmp.set('v.res.response.PRM_Response_Txt__c',mydate);
            console.log('v.res.response.PRM_Response_Txt__c',v.res.response.PRM_Response_Txt__c);
            console.log('mydate',mydate);
        }
        
        var expdate = cmp.find("expdate").get("v.value");
        //console.log('expdate-->' +expdate);
    },
    
})