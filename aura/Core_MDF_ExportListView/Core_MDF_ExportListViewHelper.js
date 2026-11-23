({
    
    loadListViewIds : function(component, event, sObj){
        // call apex method to fetch list view dynamically
        var action = component.get("c.listValues");
        action.setParams({
            "objectInfo" : sObj
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var listViewResult = response.getReturnValue();                
                if(listViewResult.length > 0){                   
                    // set listViewResult attribute with response
                    component.set("v.listViewResult",listViewResult);
                    // set first value as default value and label as list view name                    
                    component.set("v.currentListViewId", listViewResult[0].listViewId);
                    component.set("v.currentListViewName", listViewResult[0].label);   
                    component.set("v.accessErrorMsg", '');
                }
                
            }             
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //in case of error set the error message in the error div.
                        component.set("v.accessErrorMsg", errors[0].message); 
                        component.set("v.isLoading",'false');
                    }
                } 
                
            }
        });
        $A.enqueueAction(action); 
        
    },
    loadColKeys : function(component, event, sObj){
        //get the current list view id and call action to get the columns for the list view.
        var lstViewId = component.get("v.currentListViewId");
        var action = component.get("c.fetchKeys");
        
        action.setParams({
            "filterId" : lstViewId,
            "sObjectName" : sObj
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var respValue = response.getReturnValue();             
                //set the column keys for the selected list view.
                component.set('v.ColKeys', response.getReturnValue());
                component.set("v.accessErrorMsg", '');
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //in case of error set the error message in the error div.
                        component.set("v.accessErrorMsg", errors[0].message); 
                        component.set("v.isLoading",'false');
                    }
                } 
                
            } 
            
        });    
        
        $A.enqueueAction(action); 
    },  
    
    loadRecords : function(component,event,sObj) {
        
        var convertToCsvOrExcel;
        var action = component.get('c.fetchRecords');
        //get the error message that needs to be displayed in case there are no records for the selected list view.
        var errorMsg = $A.get("$Label.c.Core_MDF_Export_ListView_ErrorMessage");
        var maxExportLimitWarningMsg = $A.get("$Label.c.Core_MDF_Max_export_limit_exceeded_msg");
        var maxExportLimit = $A.get("$Label.c.Core_MDF_Max_export_limit");
        //call to load the column keys for the selected list view.
        this.loadColKeys(component, event, sObj);
        action.setParams({
            "filterId" : component.get("v.currentListViewId"),
            "sObjectName" : sObj
            
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var resultcount=data.length;
                if(resultcount>maxExportLimit){
                    component.set("v.maxRecordWarning",maxExportLimitWarningMsg);
                }
                else{
                    component.set("v.maxRecordWarning",'');                
                }
                //set the records for the selected list view.
                component.set("v.fetchedsObjectList",data);
                //call convert to excel/csv after fetching the records.
                convertToCsvOrExcel = this.convertArrayOfObjectsToCSV(component,event,sObj);
                //in case there are no records and csv is null.
                if (convertToCsvOrExcel == null){
                    component.set("v.isLoading",'false');
                    component.set("v.errorMsg",errorMsg);
                    return;
                }
                //download the csv/excel for the records fetched.
                this.download(component,convertToCsvOrExcel,sObj);
                component.set("v.accessErrorMsg", '');
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //in case of error set the error message in the error div.
                        component.set("v.accessErrorMsg", errors[0].message); 
                        component.set("v.isLoading",'false');
                    }
                } 
                
            }             
        });
        $A.enqueueAction(action); 
    },
    
    download: function(component,convertToCsvOrExcel,sObj) {
        //get the export type and the list view name to be set as file name.
        var exportType = component.get("v.exportType");
        var listViewName = component.get("v.currentListViewName");
        //var blob = new Blob(["\ufeff",convertToCsvOrExcel]);
        var a = window.document.createElement("a");
        //a.href = window.URL.createObjectURL(blob,{type:"text/plain"});
        a.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(convertToCsvOrExcel);
        if(exportType=='csv'){           
            a.download = listViewName+".csv";
        }
        else{           
            a.download = listViewName+".xls";
        }
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        component.set("v.isLoading",'false');
    },
    
    convertArrayOfObjectsToCSV : function(component,event,sObj){    

        var userTimeZone = $A.get("$Locale.timezone");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD hh:mm a");
        var listViewName = component.get("v.currentListViewName");
        var csvStringResult, counter, columnDivider, lineDivider;
        var objectRecords = component.get("v.fetchedsObjectList"); 
        //keymap will have the value of columns as map<selectedlistitem:label>
        //ex: {"Title":"Claim Name","Core_MDF_Claim_Ref_Number__c":"Claim ID"}
        var keyMap = component.get("v.ColKeys");  
        
        var keys= [keyMap.length];var p=0;
        //save the label in keys[]
        for (var key in keyMap) {
            keys[p] = keyMap[key].label;
            p++;
            
        }
        var keysunique= [keyMap.length];var p=0;
        //save the api name in keysunique[]
        for (var key in keyMap) {
            keysunique[p] = key;
            p++;
            
        }
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and \t for excel
        // for start next line use '\n' [new line] in lineDivider varaible 
        var exportType = component.get("v.exportType");
        if(exportType=='csv'){           
            columnDivider = ',';
        }
        else{           
            columnDivider = '\t';
        }
        
        
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['Name','Id'];
        
        
        csvStringResult = '';
        csvStringResult = 'Intel Confidential' + lineDivider;
        csvStringResult +=  'Export Date: '+today + lineDivider + lineDivider;
        csvStringResult +=  listViewName+ lineDivider;
        
        csvStringResult += keys.join(columnDivider);
        
        csvStringResult += lineDivider;
        try
        {        
            for(var i=0; i < objectRecords.length; i++){   
                counter = 0;
                for(var sTempkey in keysunique) {                    
                    var skey = keysunique[sTempkey].trim() ; 
                    // add , [comma] after every String value,. [except first] for csv else add \t for excel
                    if(counter > 0){ 
                        csvStringResult += columnDivider; 
                    } 
                    //in case the name contains '.' we need to separate the values
                    var a  = skey.split(".");      //[name]    
                    var b = objectRecords[i];
                    let formattedData = '';
                    //if contains toLable then we need to pop the value inside '() '                   
                    for(var j= 0; j<a.length; j++){
                        if (a[j].includes("toLabel")){
                            a[j]=(a[j]).match(/\((.*)\)/).pop();
                            
                        }else if(keyMap[skey] != undefined && keyMap[skey].type === 'datetime'){// formatting the datetime
                            //We use TimeZone for DateTime as the queried result for DateTime always comes in GMT whereas for Date it comes in User's Timezone
                            var currUserDateTimeValue = (b[a[j]] != undefined) ? new Date(b[a[j]]).toLocaleString("en-US", {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', timeZone: userTimeZone}) : '';
                            b[a[j]] =  currUserDateTimeValue != undefined ? ' ' + currUserDateTimeValue.replaceAll(',', '') : '';
                            //b[a[j]] = userLocaleDate;//.replaceAll(',', '');
                            /*var dateValue = b[a[j]];
                            var date2 = new Date(dateValue);
                            
                            
                            if(!isNaN(date2.getTime())) {
                                //var formatedate = $A.localizationService.formatDate(b[a[j]] ," MM/dd/yyyy hh:mm a");
                                //b[a[j]]= formatedate;
                                
                                var userLocaleDate = new Date(b[a[j]]).toLocaleString("en-US", {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', timeZone: userTimeZone});
                                b[a[j]] = userLocaleDate;//.replaceAll(',', '');
                            }*/
                                  
                        }else if(keyMap[skey] != undefined && keyMap[skey].type === 'date'){// formatting the date
                            //Removing new Date initialization as it was getting intialised with browser's Timezone. 
                            //b[a[j]] = (b[a[j]] != undefined) ? new Date(b[a[j]]).toLocaleString("en-US", {year: 'numeric', month: '2-digit', day: '2-digit'}) : '';
                            b[a[j]] = (b[a[j]] != undefined) ? (b[a[j]]).toLocaleString("en-US", {year: 'numeric', month: '2-digit', day: '2-digit'}) : '';
                        }
                            else if(a[j].includes("Owner")){
                                var str = b[a[j]];
                                var type = typeof str;
                                //var found = str.includes("<img");
                                if(type=="string")
                                {
                                    var result = str.match(/<a(.*?)<\/a>/g);
                                    //In case the owner comes as text and result is null.
                                    if(result != null){
                                        var str1=result[0];                                
                                        var rx = />(.*)<\/a>/g;                                
                                        var m;var result2 = [];
                                        while ((m=rx.exec(str1)) !== null) {
                                            result2.push(m[1]);
                                        } 
                                        
                                        b[a[j]]= result2; 
                                    }
                                }
                                
                            }  
                        
                        
                        
                        //if b is not undefined set it to the next related value.
                        if(b != undefined){
                            formattedData = (formattedData != undefined && formattedData != '') ? formattedData[a[j]] : (b[a[j]] != undefined && b[a[j]] != '') ? b[a[j]] : ''; 
                        }
                        counter++;                        
                    }
                    
                    //check the final value of b and set the string.
                    if(b!=undefined){
                        csvStringResult += '"'+ formattedData+'"';
                    }
                    else{
                        csvStringResult += '"'+''+'"';
                    }
                    
                }                   
                // inner for loop close 
                csvStringResult += lineDivider;
                // outer main for loop close 
            }
        }
        catch(e){          
            component.set("v.accessErrorMsg", e); 
            component.set("v.isLoading",'false');
        }
        // return the CSV formate String
        return csvStringResult;        
    }
    
})