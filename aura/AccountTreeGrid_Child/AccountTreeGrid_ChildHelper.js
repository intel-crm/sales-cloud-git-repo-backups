({
    doInIt : function(component){
        var ultimateAccountId = component.get("v.ultimateAccountId");
        // Calling a method to get all the Accounts in a hierarchy for a given Intel Account
        var action = component.get("c.fetchAllAccounts");
        action.setParams({
            "ultimateAccountId": ultimateAccountId
        });  
        var apexResponse = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Response containing all child accounts for a given ultimate account
                apexResponse = response.getReturnValue();
                component.set("v.getAccountsData",response.getReturnValue());
                
                // Columns to be shown in tree grid
                var columns = [
                    {
                        type: 'url',
                        fieldName: 'AccountURL',
                        label: 'Account Name',
                        typeAttributes: {
                            label: { fieldName: 'Name' }
                        }
                    },
                    {label: 'Active/Inactive', fieldName: 'accountActive', type: 'text'},
                ];
                component.set('v.gridColumns', columns);
                var expandedRows = [];
                var accounts = {};
                var hierarchy;
                accounts[hierarchy] = { Id: ultimateAccountId, _children: [] };
                apexResponse.forEach(function(account) {
                    expandedRows.push(account.Id);
                    accounts[account.Id] = { 
                        Name: account.Name ,
                        Id: account.Id,
                        accountActive: (account.RecordType.DeveloperName !== 'Mastered_Account')?(account.Core_MDF_Active_Ind__c?"Active":"Inactive"):"",
                        parentAccount: account.Core_MDF_Parent_Fund_Account__c,
                        parentRecordtype: account.Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName,
                        AccountURL:'/'+account.Id,
                        _children: [] };
                });
                apexResponse.forEach(function(account) {
                    // If Parent Account is Intel then Push Virtual corps into first level
                    if(accounts[account.Id].parentRecordtype === 'Mastered_Account'){
                    	accounts[hierarchy]._children.push(accounts[account.Id]);   
                    }
                    // else Push Account into Account's Parent Fund Account _children
                    else{
                        accounts[account.Core_MDF_Parent_Fund_Account__c]._children.push(accounts[account.Id]);
                    }
                });
                console.log('accountsTreeGrid', accounts);
                component.set("v.gridData", accounts[hierarchy]._children);
                component.set('v.gridExpandedRows', expandedRows);
            }
            else{
                //Handling Server Exception
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // Creating Excel file for Export functionality
    createExcelFile: function(component)
    {
        var accountData = component.get("v.gridData");        
   		var baseURL = component.get("v.salesforceBaseURL");
        var ultimateAccountName = component.get("v.ultimateAcctName");
        var ultimateAccountId = component.get("v.ultimateAcctId");
        
        // Table- Start
        var finalExcelData = "<table border='2px'>";
        
        // Header for the file
        finalExcelData += "<tr>"+"<td>Intel Account</td>"+"<td>Level 1</td>"+"<td>Level 2</td>"+"<td>Level 3</td>"+"<td>Level 4</td>"+"<td>Level 5</td>"+"</tr>";
        finalExcelData += "<tr><td>" + ultimateAccountName.link(baseURL + ultimateAccountId) + "</td><td></td><td></td><td></td><td></td><td></td></tr>";
        
        // Adding data in table in a specific format
        for(var index1=0; index1 < accountData.length; index1++){
            finalExcelData += "<tr><td></td><td>" + accountData[index1].Name.link(baseURL + accountData[index1].Id) +"</td><td></td><td></td><td></td><td></td></tr>";
            var level2Child = accountData[index1]._children;
            
            for(var index2=0; index2< level2Child.length; index2++){
                
                finalExcelData += "<tr><td></td><td></td><td>" +level2Child[index2].Name.link(baseURL + level2Child[index2].Id) +"</td><td></td><td></td><td></td></tr>";
                var level3Child = level2Child[index2]._children;
                
                for(var index3=0; index3< level3Child.length; index3++){
                   
                    finalExcelData += "<tr><td></td><td></td><td></td><td>" + level3Child[index3].Name.link(baseURL + level3Child[index3].Id) + "</td><td></td><td></td></tr>";
                    var level4Child = level3Child[index3]._children;
                    
                    for(var index4=0; index4< level4Child.length; index4++){
                        
                        finalExcelData += "<tr><td></td><td></td><td></td><td></td><td>" + level4Child[index4].Name.link(baseURL + level4Child[index4].Id) + "</td><td></td></tr>";
                        var level5Child = level4Child[index4]._children;
                        
                        for(var index5=0; index5< level5Child.length; index5++){
                            
                            finalExcelData +="<tr><td></td><td></td><td></td><td></td><td></td><td>"+ level5Child[index5].Name.link(baseURL + level5Child[index5].Id) + "</td></tr>";
                        }
                    }                            
                }
            }                      
        }
    	// Table-Ends
        finalExcelData=finalExcelData+"</table>";
             	
        // Final Excel file generation
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:application/vnd.ms-excel,' + encodeURIComponent(finalExcelData);
        hiddenElement.target = '_self';  
        hiddenElement.download = ultimateAccountName + ' Account Hierarchy.xls';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },
    
    /*downloadCSV : function(component){
        var allAccts = component.get("v.gridData");
        var csvName = component.get("v.gridData[0].Name");
        console.log('allAcctsBeforeExcel',allAccts + "==>" + csvName);
        var csv = this.createCSVFile(component, allAccts);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';  
        hiddenElement.download = csvName + ' Account Hierarchy.csv';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },
    getAcctRecordURL : function(component, accountId, accountName){
        var baseURL = component.get("v.salesforceBaseURL");
        console.log("InsidegetAcctRecordURL",baseURL);
        var hyperLink = "\"=HYPERLINK(\"\""+ baseURL + accountId + "\"\",\"\"" + accountName + "\"\")\"";
        return hyperLink;
    },
    createCSVFile : function(component, accountData){
        var csvStringResult, fileHeader, columnDivider, lineDivider;
        fileHeader = ['Intel Account','Level 1','Level 2','Level 3','Level 4','Level 5'];
		columnDivider = ',';
        lineDivider =  '\n';
        csvStringResult = '';
        csvStringResult += fileHeader.join(columnDivider);
        
        // Outermost for loop run once as of now
        for(var index1=0; index1 < accountData.length; index1++){
            csvStringResult += lineDivider + this.getAcctRecordURL(component, accountData[index1].Id, accountData[index1].Name);
            var level2Child = accountData[index1]._children;
            
            for(var index2=0; index2< level2Child.length; index2++){
                //if(level2Child[index2].parentAccount == accountData[index1].Id){
                csvStringResult+= lineDivider;
                csvStringResult += columnDivider;
                csvStringResult += this.getAcctRecordURL(component, level2Child[index2].Id, level2Child[index2].Name);
                var level3Child = level2Child[index2]._children;
                
                for(var index3=0; index3< level3Child.length; index3++){
                    //if(level3Child[index3].parentAccount == level2Child[index2].Id){
                    csvStringResult+= lineDivider;
                    csvStringResult += columnDivider + columnDivider;
                    csvStringResult += this.getAcctRecordURL(component, level3Child[index3].Id, level3Child[index3].Name);
                    var level4Child = level3Child[index3]._children;
                    
                    for(var index4=0; index4< level4Child.length; index4++){
                        //if(level4Child[index4].parentAccount == level3Child[index3].Id){
                        csvStringResult+= lineDivider;
                        csvStringResult += columnDivider + columnDivider + columnDivider;
                        csvStringResult += this.getAcctRecordURL(component, level4Child[index4].Id, level4Child[index4].Name);
                        var level5Child = level4Child[index4]._children;
                        
                        for(var index5=0; index5< level5Child.length; index5++){
                            //if(level5Child[index5].parentAccount == level4Child[index4].Id){
                            csvStringResult+= lineDivider;
                            csvStringResult += columnDivider + columnDivider + columnDivider + columnDivider;
                            csvStringResult += this.getAcctRecordURL(component, level5Child[index5].Id, level5Child[index5].Name);
                            //}
                            var level6Child = level5Child[index5]._children;
                            
                            for(var index6=0; index6< level6Child.length; index6++){
                                csvStringResult+= lineDivider;
                                csvStringResult += columnDivider + columnDivider + columnDivider + columnDivider + columnDivider;
                                csvStringResult += this.getAcctRecordURL(component, level6Child[index6].Id, level6Child[index6].Name);
                            }
                        }
                        //}                                 
                    }                            
                    //}
                }
                //}                
            }                      
        }
        return csvStringResult;
	},*/
})