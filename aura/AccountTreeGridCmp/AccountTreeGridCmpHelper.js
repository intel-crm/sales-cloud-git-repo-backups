({
	callToServer : function(component, method, callback, params) {
        console.log('Calling helper callToServer function');
		var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        console.log(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                alert('Problem with connection. Please try again.');
            }
        });
		$A.enqueueAction(action);
    },
    createExcelFile : function(component, objectRecords){
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        keys = ['Level 1','Level 2','Level 3','Level 4','Level 5'];
		columnDivider = ',';
        lineDivider =  '\n';
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        var baseURL = component.get("v.salesforceBaseURL");
        console.log("baseURLLLLLL",baseURL)
        var temp = objectRecords.Level1;
        var temp2 = objectRecords.Level2;
        var temp3 = objectRecords.Level3;
        var temp4 = objectRecords.Level4;
        var temp5 = objectRecords.Level5;
        for(var i=0; i < temp.length; i++){
            console.log('length',temp.length);
            csvStringResult += lineDivider + this.getRequiredURL(baseURL, temp[i].Id, temp[i].Name);
           
            for(var index2=0; index2< temp2.length; index2++){
                if(temp2[index2].Core_MDF_Parent_Fund_Account__c == temp[i].Id){
                    csvStringResult+= lineDivider;
                    csvStringResult += columnDivider;
                    csvStringResult += this.getRequiredURL(baseURL, temp2[index2].Id, temp2[index2].Name);
                    for(var index3=0; index3< temp3.length; index3++){
                        if(temp3[index3].Core_MDF_Parent_Fund_Account__c == temp2[index2].Id){
                            csvStringResult+= lineDivider;
                            csvStringResult += columnDivider + columnDivider;
                            csvStringResult += this.getRequiredURL(baseURL, temp3[index3].Id, temp3[index3].Name);
                            for(var index4=0; index4< temp4.length; index4++){
                                if(temp4[index4].Core_MDF_Parent_Fund_Account__c == temp3[index3].Id){
                                    csvStringResult+= lineDivider;
                                    csvStringResult += columnDivider + columnDivider + columnDivider;
                                    csvStringResult += this.getRequiredURL(baseURL, temp4[index4].Id, temp4[index4].Name);
                                    for(var index5=0; index5< temp5.length; index5++){
                                        if(temp4[index5].Core_MDF_Parent_Fund_Account__c == temp4[index4].Id){
                                            csvStringResult+= lineDivider;
                                            csvStringResult += columnDivider + columnDivider + columnDivider + columnDivider;
                                            csvStringResult += this.getRequiredURL(baseURL, temp5[index5].Id, temp5[index5].Name);
                                        }
                                    }
                                }                                 
                            }                            
                        }
                    }
                }                
            }
                      
        }
        console.log('URLLL:');  
        return csvStringResult;
	},
    geturl : function(cmp){        
        var action = cmp.get("c.fetchit");
        console.log("InsidegetURL");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('geturlstate',state);
            if (state === "SUCCESS") {
                cmp.set("v.salesforceBaseURL",response.getReturnValue());
                console.log("InsidegetURLIf",cmp.get("v.salesforceBaseURL"));
             }
            else{
                console.log("Actionfailed");
            }
        });
        $A.enqueueAction(action);
    },
    getRequiredURL : function(baseURL, accId, accName){
        var hyperLink = "\"=HYPERLINK(\"\""+ baseURL + accId + "\"\",\"\"" + accName + "\"\")\"";
        return hyperLink;
    }
})