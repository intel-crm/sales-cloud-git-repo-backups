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
       
		if(objRes.question && objRes.question.PRM_Question_Type_Nm__c == 'Boolean'){
            var returnValue = objRes.response.PRM_Response_Txt__c;
            var booleanValue = cmp.find("checkbox");
            //booleanUpdateValue = (booleanValue === true);
            if(returnValue && returnValue === 'true'){
                console.log('>>is true');
                booleanValue.set("v.value",true);
            }else{
                console.log('>>is false');
                booleanValue.set("v.value",false);
            }            
            console.log('booleanValue--->'+booleanValue);
        }
        if(objRes.question && objRes.question.PRM_Question_Type_Nm__c == 'Multiselect'){
            if(objRes.lstMultiResponse){
                respArr = objRes.lstMultiResponse;
                for(var i=0; i<respArr.length; i++ ){
                    if(respArr[i].PRM_InActive_Ind__c == false){ 
                        if(i==0){
                            multiString =  respArr[i].PRM_Response_Txt__c;
                        }else{
                            multiString = multiString + ';' + respArr[i].PRM_Response_Txt__c;
                        }
                    }
                }
            }
            cmp.set("v.multiResponse",multiString);
            //cmp.set("v.booleanResponse",booleanValue);
            //cmp.set("v.booleanResponse",booleanUpdateValue);
        }
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
        saveResponse.PRM_Account_Id__c = cmp.get("v.recordId");
        console.log('objRes.answers.Id-->'+objRes.answers.Id);
        // getting answer records for the corresponding question..
        if(objRes.answers){
            console.log('get answer record');
            respAns = objRes.answers; 
            //filtering out answers if they match the response for the piclist and boolean type
            if(quesType.includes(objRes.question.PRM_Question_Type_Nm__c)){
                respAns = respAns.filter(function( obj ) {
                    return obj.PRM_Answer_Display_Txt__c === String(objRes.response.PRM_Response_Txt__c);
                });       
            }
        }
        //check if answer was found? and assign it to response
        if(respAns[0])
        saveResponse.PRM_Profile_Answer_Id__c = respAns[0].Id;
        respArr.push(saveResponse);
        cmp.set("v.saveResponse",respArr);
        console.log('respAns[0].Id--->'+respAns[0].Id);
        console.log(saveResponse);
        console.log("respArr-->"+JSON.stringify(respArr));
    },
    multiPicklistChange:function(cmp){
        console.log('Inside multiPicklistChange');
        var objRes= cmp.get("v.res");
        var respArr = [];
        var delArr = [];
        var multiArr = [];
        var respList = cmp.get("v.saveResponse");
        //this is the current selected value
        var newResp = cmp.get("v.multiResponse");
        console.log("Here-->"+JSON.stringify(cmp.get("v.res")));
        console.log("Here-- 1stMultiResponse>"+JSON.stringify(objRes.lstMultiResponse));
        // get the existing responses- and update them
        if(objRes.lstMultiResponse)
            delArr = objRes.lstMultiResponse;
        console.log("delArr-->"+JSON.stringify(objRes.lstMultiResponse));
        console.log("delArr-->"+JSON.stringify(delArr));
        // insert new responses from the user input
        multiArr = newResp.split(';');
        respArr = cmp.get("v.saveResponse");
        //removing existing questions to ensure no duplicate responses are stored in the system
        if(objRes.question.Id){      
            respArr = respArr.filter(function( obj ) {
                return obj.PRM_Profile_Questions_Id__c !== objRes.question.Id;
            });
        }
        for(var i=0;i<multiArr.length;i++){
            var respAns;
            var saveResponse = {}; 
            //var delResponse =[];
            //delResponse = cmp.get("v.deleteResponse");
            saveResponse.PRM_Profile_Questions_Id__c = objRes.question.Id;
            saveResponse.PRM_Response_Txt__c = multiArr[i];
            saveResponse.PRM_InActive_Ind__c = false;
            saveResponse.PRM_Account_Id__c = cmp.get("v.recordId");
            // getting answer records for the corresponding question..
            if(objRes.answers){
                respAns = objRes.answers;
                respAns = respAns.filter(function( obj ) {
                    return obj.PRM_Answer_Display_Txt__c ===  String(multiArr[i]);
                });
            } 
            //check if answer was found? and assign it to response
            if(respAns[0])
                saveResponse.PRM_Profile_Answer_Id__c = respAns[0].Id;
            //check if record already exists
            for( var key in delArr){
                var deleteRes = delArr[key].PRM_Response_Txt__c;
                if(deleteRes == multiArr[i]){
                    saveResponse.Id = delArr[key].Id; 
                }
            } 
            respArr.push(saveResponse);
            //filer out the inactive ones      
            delArr = delArr.filter(function( obj ) {
                return obj.PRM_Response_Txt__c !== multiArr[i];
            });
        }
        console.dir('delArr after filter' + delArr);
        console.log('delArr after filter' + delArr);
        // code to inactivate the ones which are not selected by user
        for(var j=0;j<delArr.length;j++){
            var saveResponse = {};
            saveResponse.PRM_InActive_Ind__c = true;
            saveResponse.Id = delArr[j].Id; 
            saveResponse.PRM_Profile_Questions_Id__c =delArr[j].PRM_Profile_Questions_Id__c;
            respArr.push(saveResponse);
            saveResponse = {};
        }
        console.log("response value-->"+JSON.stringify(respArr));
        cmp.set("v.saveResponse",respArr);       
    },
})