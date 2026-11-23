({
    doInit: function (component, event, helper) { 
        var actions = [
            { label: 'Export', name: 'exportAll' },
        ];
        console.log('doInit of component called');
        helper.geturl(component);
        
        var columns = [
            {
                type: 'url',
                fieldName: 'AccountURL',
                label: 'Account Name',
                typeAttributes: {
                    label: { fieldName: 'accountName' }
                }
            },
            { type: 'action', typeAttributes: { rowActions: actions } }
        ];
        component.set('v.gridColumns', columns);
        
		console.log('BEFOREHelper CalltoServer');
            helper.callToServer(
                component,
                "c.findHierarchyData",
                function(response) {
                    var expandedRows = [];
                    var apexResponse = response;
                    var roles = {};
                    console.log('*******apexResponse:'+JSON.stringify(apexResponse));
                    var results = apexResponse;
                    roles[undefined] = { Name: "Root", _children: [] };
                    apexResponse.forEach(function(v) {
                        expandedRows.push(v.Id);
                        roles[v.Id] = { 
                            accountName: v.Name ,
                            name: v.Id,
                            /*region:v.Core_Geo__c,
                            subRegion:v.Core_Sub_Geo__c,*/
                            AccountURL:'/'+v.Id,
                            _children: [] };
                    });
                    apexResponse.forEach(function(v) {
                        roles[v.Core_MDF_Parent_Fund_Account__c]._children.push(roles[v.Id]);   
                    });                
                    component.set("v.gridData", roles[undefined]._children);
                    component.set("v.gridOriginalData", roles[undefined]._children);
                    console.log('*******treegrid data:'+JSON.stringify(roles[undefined]._children));
                    
                    component.set('v.gridExpandedRows', expandedRows);
                    component.set("v.getAccountsData",apexResponse);
                }, 
                {});    
     
    },
    
    fetchRecords: function (component, event, helper){
        var searchTextAcctName = component.get("v.accountNameSearchText");
        var allGridData = component.get("v.gridOriginalData");
        
       	var newArray = allGridData.filter(function (el) 
		{ 
  			return el.accountName.toLowerCase().includes(searchTextAcctName.toLowerCase()); 

		});
        console.log('@@@newarray-'+newArray);
		component.set("v.gridData",newArray);
    },
    /*handleClick: function(component, event, helper){
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
         
	},*/
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
                var actlevel1 = accts.filter(item => item.Id === row.name);
                console.log('filteredlevel1accts',actlevel1);
                obj['Level1'] = actlevel1;
                console.log('objlevel1',obj['Level1']);
                
                var level2Ids = [];
                var actlevel2 = accts.filter(item => row.name ===item.Core_MDF_Parent_Fund_Account__c);
                for(var i=0; i<actlevel2.length; i++){
                    level2Ids.push(actlevel2[i].Id);
                }
                console.log('filteredlevel2accts',actlevel2);
                console.log('filteredlevel2acctsIds',level2Ids);
                obj['Level2'] = actlevel2;
                
                var level3Ids = [];
                var actLevel3 = accts.filter(x => level2Ids.includes(x.Core_MDF_Parent_Fund_Account__c));
                for(var i=0; i<actLevel3.length; i++){
                    level3Ids.push(actLevel3[i].Id);
                }
                obj['Level3'] = actLevel3;
                console.log('filteredlevel3accts',actLevel3);
                console.log('filteredlevel3acctsIds',level3Ids);
                
                var level4Ids = [];
                var actLevel4 = accts.filter(x => level3Ids.includes(x.Core_MDF_Parent_Fund_Account__c));
                for(var i=0; i<actLevel4.length; i++){
                    level4Ids.push(actLevel4[i].Id);
                }
                obj['Level4'] = actLevel4;
                console.log('filteredlevel4accts',actLevel4);
                console.log('filteredlevel4acctsIds',level4Ids);
                
                var actLevel5 = accts.filter(x => level4Ids.includes(x.Core_MDF_Parent_Fund_Account__c));                
                obj['Level5'] = actLevel5;
                console.log('filteredlevel5accts',actLevel5);
                
        }
        console.log('ObjectRecords',obj)
        var csv = helper.createExcelFile(component, obj);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';  
        hiddenElement.download = 'ExportData.csv';  
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }
})