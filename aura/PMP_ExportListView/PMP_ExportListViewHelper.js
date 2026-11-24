({
    
    loadListViewIds : function(component, event){
        // call apex method to fetch list view dynamically
        var action = component.get("c.listValues");
        console.log('act' +action);
        action.setParams({
            "sObjectName" : component.get("v.sObjectName"), 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('resp ' +response);            
            if (state === "SUCCESS") {
                console.log('reVal' +response.getReturnValue());
                var listViewResult = response.getReturnValue();                
               console.log('listViewRes' +listViewResult);
                if(listViewResult.length > 0){ 
                    // component.set("v.sObjectName",'PMP_Partner_Offering__c');
                    // set listViewResult attribute with response
                    component.set("v.listViewResult",listViewResult);
                    // set first value as default value and label as list view name                    
                    component.set("v.currentListViewId", listViewResult[0].listViewId);
                    component.set("v.currentListViewName", listViewResult[0].label);
                    component.find("selectedViewId").set("v.value", listViewResult[0].listViewId);
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
    loadColKeys : function(component, event){
        //get the current list view id and call action to get the columns for the list view.
        var lstViewId = component.get("v.currentListViewId");
        var action = component.get("c.fetchKeys");
        
        action.setParams({
            "filterId" : lstViewId,
            "sObjectName" : component.get("v.sObjectName")
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
    
    loadRecords : function(component,event) {
        
        var convertToCsvOrExcel;
        var action = component.get('c.fetchRecords');
        //get the error message that needs to be displayed in case there are no records for the selected list view.
        var errorMsg = $A.get("$Label.c.PMP_ExportListviewError");
        var maxExportLimitWarningMsg = $A.get("$Label.c.PMP_ExportMaxLimitError");
        var maxExportLimit = $A.get("$Label.c.PMP_ExportMaxLimit");
        //call to load the column keys for the selected list view.
        this.loadColKeys(component, event);
        action.setParams({
            "filterId" : component.get("v.currentListViewId"),
            "sObjectName" : component.get("v.sObjectName")
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
                convertToCsvOrExcel = this.convertArrayOfObjectsToCSV(component,event);               
                //in case there are no records and csv is null.
                if (convertToCsvOrExcel == null){
                    component.set("v.isLoading",'false');
                    component.set("v.errorMsg",errorMsg);
                    return;
                }
                //download the csv/excel for the records fetched.
                
               this.download(component,convertToCsvOrExcel);
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
    
    download: function(component,convertToCsvOrExcel) {
        
        //get the export type and the list view name to be set as file name.
        var exportType = component.get("v.exportType");
        var listViewName = component.get("v.currentListViewName");
        var blob = new Blob(["\ufeff",convertToCsvOrExcel],
            { type: 'application/vnd.ms-excel' }
        );
        var a = window.document.createElement("a");
        a.href = window.URL.createObjectURL(blob);
        if(exportType=='csv'){            
            a.download = listViewName+".csv";
        }
        else{           
            a.download = listViewName+".xlsx";
        }
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        component.set("v.isLoading",'false');
    },
    
    convertArrayOfObjectsToCSV : function(component,event){    
        
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
            keys[p] = keyMap[key];
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
        columnDivider = ',';
        
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
        {     var urlFields = component.get('v.urlFields'); 

         
            for(var i=0; i < objectRecords.length; i++){   
                counter = 0;
                for(var sTempkey in keysunique) {                    
                    var skey = keysunique[sTempkey].trim() ; 
                    // add , [comma] after every String value,. [except first] for csv else add \t for excel
                    if(counter > 0){ 
                        csvStringResult += columnDivider; 
                    } 
                    
                    //in case the name contains '.' we need to separate the values
                    var a  = skey.split(".");          
                    var b = objectRecords[i];
                    
                    //if contains toLable then we need to pop the value inside '() '                   
                    for(var j= 0; j<a.length; j++){
                       
                        if (a[j].includes("toLabel")){
                            a[j]=(a[j]).match(/\((.*)\)/).pop();
                            
                        }
                        // formatting the date
                        else if(a[j].includes("Date")){
                            var dateValue = b[a[j]];
                            var date2 = new Date(dateValue);
                            
                            
                            if(!isNaN(date2.getTime())) {
                                var formatedate = $A.localizationService.formatDate(b[a[j]] ," MM/dd/yyyy hh:mm a");
                                b[a[j]]= formatedate;
                            }
                            
                        }
                        else if(a[j].includes("PMP_View_Offerings__c") || a[j].includes("PMP_View_Partners_Txt__c") ){
                                var newString= "ENG,CHN,JPN";
                                b[a[j]] = null;
                                b[a[j]] = newString;
                               
                            }
                                else if(urlFields.includes(a[j])){
                                 
                                    var hyperlink = b[a[j]];
                                    var subOffName = hyperlink.toString();
                                    
                                    subOffName = subOffName.replace(/(<([^>]+)>)/ig, '');
                                    //console.log('subOffName'+subOffName);
                                    //subOffName = decodeURIComponent(subOffName);
                                    
                                    // subOffName = "<aura:unescapedHtml value='" + subOffName + "'/>";
                                    //Added to sanitize subOffName against XSS attacks
                                   /* subOffName=sanitize(subOffName);
                                    function sanitize(html) {
                                        var parser = new DOMParser();
                                        var doc = parser.parseFromString(html, 'text/html');
                                        // Retrieve the text content of the parsed document
                                        var sanitizedHtml = doc.body.textContent;
                                        return sanitizedHtml;
                                    }*/
                                    subOffName = decodeHtml(subOffName);
                                    function decodeHtml(html) {
                                    var txt = document.createElement("textarea");
                                  //  txt.innerHTML = html;
                                    txt.textContent=html;
                                    return txt.value;
                                }
                                   subOffName = subOffName.split('"').join('""');
                                   subOffName = subOffName.split(',').join(',');
                                  
            
                                    b[a[j]] = subOffName;
                                    
                                    
                                }
                                    else if(a[j].includes("PMP_Account_Address_Txt__c")){
                                        
                                        
                                      
                                        if(b[a[j]] != null){
                                            var  subOffName = b[a[j]].toString();
                                            subOffName = subOffName. replace(/(<([^>]+)>)/ig, '');
                                            //let newString = langHyperlink.split('<br>').join(' ');
                                            b[a[j]] = subOffName; 
                                           
                                        }
                                        else{
                                            b[a[j]] = b[a[j]];
                                        }
                                        
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
                            var val = b[a[j]];
                            b = val; 
                        }
                        counter++;                        
                    }
                    
                    //check the final value of b and set the string.
                    if(b!=undefined){
                        
                         //console.log("b after for end"+b);
                        csvStringResult +='"'+ b +'"';
						//console.log("csvStringResult after for end"+csvStringResult);                        
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
        console.log('csvStringResult'+csvStringResult);
        return csvStringResult;        
    },
     
    
})