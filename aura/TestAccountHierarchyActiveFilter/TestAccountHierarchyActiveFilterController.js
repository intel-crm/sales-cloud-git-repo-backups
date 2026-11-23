({
    
    doInit: function (component, event, helper) { 
        var actions = [
            { label: 'Export', name: 'exportAll' },
        ];
        console.log('doInit of component called');
        helper.geturl(component);
        //console.log("salesforceBaseURL",component.get("salesforceBaseURL"));
        var columns = [
            {
                type: 'url',
                fieldName: 'AccountURL',
                label: 'Account Name',
                typeAttributes: {
                    label: { fieldName: 'accountName' }
                }
            },
            {
                type: 'text',
                fieldName: 'region',
                label: 'Region'
            },
            {
                type: 'Text',
                fieldName: 'subRegion',
                label: 'Sub Region'
            },
             {
                type: 'Text',
                fieldName: 'accountactiveflag',
                label: 'Co-Marketing Active?',
            },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ];
        component.set('v.gridColumns', columns);
        

            helper.callToServer(
                component,
                "c.createAccountWrapperData",
                function(response) {
                    
                    var expandedRows = [];
                    var apexResponse = response;
                    var roles = {};
                    console.log('*******apexResponse:'+JSON.stringify(apexResponse));
                    var results = apexResponse;
                    roles[undefined] = { Name: "Root", _children: [] };
                    apexResponse.forEach(function(v) {
                        console.log('@@@V-'+v);
                        expandedRows.push(v.Id);
                        roles[v.Id] = { 
                            accountName: v.Name ,
                            name: v.Id,
                            region:v.Core_Geo__c,
                            subRegion:v.Core_Sub_Geo__c,
                            AccountURL:'/'+v.Id,
                            accountactiveflag:v.Core_MDF_CoMarketingActive__c,
                            _children: [] };
                    });
                    apexResponse.forEach(function(v) {
                        roles[v.Core_MDF_Parent_Fund_Account__c]._children.push(roles[v.Id]);   
                    });                
                    component.set("v.gridData", roles[undefined]._children);
                    component.set("v.gridOriginalData", roles[undefined]._children);
                    console.log('*******treegrid data:'+JSON.stringify(roles[undefined]._children));
                    console.log('*******roles data:'+JSON.stringify(roles));
                    
                    component.set('v.gridExpandedRows', expandedRows);
                    component.set("v.getAccountsData",apexResponse);
                },   
                {});    
     
    },
    
    
    
    fetchRecords: function (component, event, helper){
        var searchTextAcctName = component.find("searchAcctName").get("v.value");
        var AcctActiveInd = component.find("SearchAcctStatus").get("v.value");
        var allGridData = component.get("v.gridOriginalData");
        
        
       	var newArray = allGridData.filter(function (el) 
		{ 
            
            console.log("@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
            console.log('@@@el object-'+el)
            console.log('@el values'+el.accountName,el._children.accountactiveflag);
           	if((searchTextAcctName != null && searchTextAcctName != '') && (AcctActiveInd == 'true' || AcctActiveInd== 'false')){
                if(AcctActiveInd== 'true'){
                    console.log("1---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
                    return el.accountName.toLowerCase().includes(searchTextAcctName.toLowerCase()) && el.accountactiveflag == true;
                }
                else if(AcctActiveInd== 'false'){
                    console.log("2---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
                   	return el.accountName.toLowerCase().includes(searchTextAcctName.toLowerCase()) && el.accountactiveflag == false; 
            	}

            }
			else if(searchTextAcctName == null || searchTextAcctName == ''){
                if((AcctActiveInd=='true')){
                   console.log("3---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
                   return el.accountactiveflag == true;
                }
                else if(AcctActiveInd=='false'){
                    console.log("4---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
                    return el.accountactiveflag == false;
                }
                else{
                      console.log("5---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);  
                    	return el;
                    }
                    
            }
            else{
                    console.log("final---@@@Searchtext-"+searchTextAcctName,AcctActiveInd);
                    return el.accountName.toLowerCase().includes(searchTextAcctName.toLowerCase());   
                } 
		}); 
		component.set("v.gridData",newArray);
    },
    handleClick: function(component, event, helper){
        var accts = component.get("v.getAccountsData");
        var intelAccts = '{"Level1":[],"Level2":[],"Level3":[],"Level4":[],"Level5":[]}';
        var obj = JSON.parse(intelAccts);
        console.log("acts",accts);
        for(var i=0; i<accts.length; i++) {
            if(accts[i].RecordType.DeveloperName == "Mastered_Account"){
                obj['Level1'].push(accts[i]);
            }
            else if(accts[i].RecordType.DeveloperName == "Core_MDF_Co_Marketing" && 
                    accts[i].Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName == "Mastered_Account"){
                obj['Level2'].push(accts[i]);
            }
        }
        for(var i=0; i<accts.length; i++) {
            var temp2 = obj.Level2;
            console.log('Levelll3',temp2);
            var bool = temp2.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
            if(bool){
                obj['Level3'].push(accts[i]);
            }
        }
        for(var i=0; i<accts.length; i++) {
            var temp3 = obj.Level3;
            console.log('Levelll3',temp3);
            var bool = temp3.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
            if(bool){
                obj['Level4'].push(accts[i]);
            }
        }
        for(var i=0; i<accts.length; i++) {
            var temp4 = obj.Level4;
            console.log('Levelll4',temp4);
            var bool = temp4.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
            if(bool){
                obj['Level5'].push(accts[i]);
            }
        }
        console.log('IntelAccts',obj);
        var csv = helper.createExcelFile(component, obj);
        var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self';  
          hiddenElement.download = 'ExportData.csv';  
          document.body.appendChild(hiddenElement);
          hiddenElement.click(); 
         
	},
    onRowSelect: function(component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        var accts = component.get("v.getAccountsData");
        var intelAccts = '{"Level1":[],"Level2":[],"Level3":[],"Level4":[],"Level5":[]}';
        var obj = JSON.parse(intelAccts);
        switch (action.name) {
            case 'exportAll':
            	console.log('rowId',row.name);
                console.log("accts",accts);
                for(var i=0; i<accts.length; i++) {
                    console.log('parentfundacct',accts[i]);
                    if(accts[i].Id == row.name){
                        obj['Level1'].push(accts[i]);
                        console.log("Insidelevel1");
                    }
                    else if(accts[i].Core_MDF_Parent_Fund_Account__c !== undefined && accts[i].Core_MDF_Parent_Fund_Account__c == row.name){
                        console.log("Insidelevel2");
                        obj['Level2'].push(accts[i]);
                    }
                }
                for(var i=0; i<accts.length; i++) {
                    var temp2 = obj.Level2;
                    console.log('Levelll3',temp2);
                    var bool = temp2.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
                    if(bool){
                    	obj['Level3'].push(accts[i]);
                    }
                 }
                for(var i=0; i<accts.length; i++) {
                    var temp3 = obj.Level3;
                    console.log('Levelll3',temp3);
                    var bool = temp3.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
                    if(bool){
                    	obj['Level4'].push(accts[i]);
                    }
                 }
                for(var i=0; i<accts.length; i++) {
                    var temp4 = obj.Level4;
                    console.log('Levelll4',temp4);
                    var bool = temp4.filter(x => x.Id === accts[i].Core_MDF_Parent_Fund_Account__c ? true: false);
                    if(bool){
                    	obj['Level5'].push(accts[i]);
                    }
                 }
             }
        
        console.log('objlog',obj);
        var csv = helper.createExcelFile(component, obj);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';  
        hiddenElement.download = 'ExportData.csv';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }
})