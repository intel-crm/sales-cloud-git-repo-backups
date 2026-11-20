({
    myAction : function(component,event,helper) {
        var action = component.get("c.displayResponse");
        debugger;
        
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        
        action.setCallback(this, function(data) {
            debugger;
            var state= data.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();
                console.log('result'+JSON.stringify(result));
                
                var multiSelectLabel = $A.get("$Label.c.PRM_Multiselect");
                var picklistLabel = $A.get("$Label.c.PRM_Picklist");
                for(var p in result){
                    if(result[p].q.PRM_Question_Type_Nm__c == multiSelectLabel){
                        var listOfPicklist = result[p].selectedResults;
                        var answerList = result[p].listofans;
                    }
                    if(result[p].q.PRM_Question_Type_Nm__c == picklistLabel && result[p].selectedResults != null &&
                       result[p].selectedResults != ''){
                        var totalanswer = result[p].listofans;
                        var picklistList = result[p].selectedResults;
                    }
                }
                
                //multi-select picklist
                var list1 = [];
                var list2 = [];
                if(answerList != null && answerList != ''){
                    for(var a in answerList){
                        var item = {
                            "label": answerList[a].PRM_Answer_Display_Txt__c,
                            "value": answerList[a].PRM_Answer_Display_Txt__c
                        };
                        list1.push(item);
                    }
                }
                if(listOfPicklist != null && listOfPicklist != ''){
                    for(var b in listOfPicklist){
                        list2.push(listOfPicklist[b].PRM_Answer_Display_Txt__c);
                    }
                }
                console.log("list1  "+JSON.stringify(list1));
                console.log("list2  "+JSON.stringify(list2));  
                        				//$A.util.toggleClass(component.find('dualSelect'), 'slds-is-selected');
                component.set("v.options",list1);
                component.set("v.values",list2);
                
                //single-select picklist
                if(totalanswer != null && totalanswer != '' && picklistList != null && picklistList != ''){
                    for(var a in totalanswer){
                        if(totalanswer[a].PRM_Answer_Display_Txt__c == picklistList[0].PRM_Answer_Display_Txt__c){
                            component.set("v.selectpicklist",totalanswer[a].PRM_Answer_Display_Txt__c)
                        }
                    }
                }
                component.set("v.questionAnswerObject",result);
            }
        });
        $A.enqueueAction(action);
    },
    triggerEv : function(component,event,helper) {
        var retriggerAction = component.get("c.retriggerEv");
        
        retriggerAction.setParams({
            recordId: component.get("v.recordId"),
            isFromContact: false
        });
        retriggerAction.setCallback(this, function(data) {
            var message;
            var type;
            var evStatus= data.getReturnValue();
            var state = data.getState();
            var resp = evStatus.response;
            var email = evStatus.email;
            var enterpriseId = evStatus.reqEnterpriseId;
            var responseSearch = $A.get("$Label.c.PRM_AGSRESPONSE");
            var sucessresp = $A.get("$Label.c.PRM_SUCCESSMSG");
            var errMsg = $A.get("$Label.c.PRM_AGSERRMSG");
            var errDescr = $A.get("$Label.c.PRM_AGSERRDESCR");
            console.log('STATE EV --> ' +evStatus);
            console.log('resp --> '+resp);
            console.log('Email --> '+email);
            //console.log('enterpriseId -->'+enterpriseId);
            //resp = JSON.stringify(resp);
            if(component.isValid() && state === "SUCCESS") {
                
                if (resp !=null && resp.search(errDescr) == -1 && resp.search(responseSearch) == -1){
                    message=resp;
                    type='success';
                }
                else{
                    if (resp ==null){
                        message=errMsg;
                        type='error';
                    }else if(resp !=null && resp.search(errDescr) != -1){
                        var end = resp.search("}");
                        var errorStart = resp.search(errDescr);
                        message = resp.slice(errorStart+20, end-1);
                        type='error';
                    }else{
                        
                        if (typeof email != 'undefined' && typeof email !=null && typeof email != ' '){
                            message=sucessresp+' '+email;
                            type='success';
                        }else{
                            message=errMsg;
                            type='error';
                        }
                    }
                    
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    type: type,
                    mode: 'sticky'
                });
                toastEvent.fire();
                
            }
        });
        
        $A.enqueueAction(retriggerAction);
        
    }
})