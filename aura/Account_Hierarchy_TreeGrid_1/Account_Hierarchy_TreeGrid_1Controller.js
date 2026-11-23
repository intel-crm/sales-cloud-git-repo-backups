({
    doInit: function (component, event, helper) { 
        console.log('doInit of component called');
        var columns = [
            {
                type: 'url',
                fieldName: 'AccountURL',
                label: 'Parent Name',
                typeAttributes: {
                    label: { fieldName: 'accountName' }
                }
            },
            /*{
                type: 'text',
                fieldName: 'region',
                label: 'Region'
            },
            {
                type: 'Text',
                fieldName: 'subRegion',
                label: 'Sub Region'
            } */
        ];
        component.set('v.gridColumns', columns);
        

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
                            region:v.Core_Geo__c,
                            subRegion:v.Core_Sub_Geo__c,
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
    }
})