({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Tested Permissions',fieldName:'permissionName', type: 'text', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "Left"}},
            {label: '# Permission Sets',fieldName:'countPermissionSets', type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"}},
            {label: '# of Profiles',fieldName:'countProfiles',  type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"}},
            {label: '# of Active User',fieldName:'countActiveUser' , type: 'number', sortable: true, initialWidth: 250, cellAttributes:{ alignment: "center"} },
            {label: 'Status', fieldName:'statusCode',type: 'text',initialWidth: 250, cellAttributes: {  alignment: "right",
                                                                                                      class: { fieldName: 'statusCode' }}},
            {label: 'Action', type: 'button', initialWidth: 250, typeAttributes:
             { label: { fieldName: 'actionLabel'}, title: 'Click to Download', name: 'download_status', iconName: 'utility:download',initialWidth: 250, disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}},		  ]); 
            
            var action = cmp.get("c.getPermissionData");
            action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            cmp.set('v.data',response.getReturnValue().lstDataTableData);
            cmp.set('v.userInfoMap', response.getReturnValue().permissionToUserLstMap);
            helper.sortData(cmp, cmp.get("v.sortedBy"), cmp.get("v.sortedDirection"));
            }
            });
            $A.enqueueAction(action);
            
            },
            
            updateColumnSorting: function (cmp, event, helper) {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            cmp.set("v.sortedBy", fieldName);
            cmp.set("v.sortedDirection", sortDirection);
            helper.sortData(cmp, fieldName, sortDirection);
            },
            handleRowAction: function (cmp, event, helper) {
            var eventAction = event.getParam('action');
            var row = event.getParam('row');
            var data = cmp.get('v.data');
            var index = data.indexOf(row);
            
            if(eventAction.name == 'download_status'){
            var userInfoData = cmp.get('v.userInfoMap'); 
            var userDataToReport = [];
            for(var usr in userInfoData){
                if(usr == row.permissionName){
                    userDataToReport = userInfoData[usr];
                }                    
        	}
        var action = cmp.get("c.getUserInfoData");
        action.setParams({ "permissionList" : userDataToReport,
                          "permissionName" : data[index].permissionAPIName
                         });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataValueToReport = response.getReturnValue();
                var csv = helper.downloadCSV(cmp,dataValueToReport); 
                if (csv == null){return;} 
                var hiddenElement = document.createElement('a');
                hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
                hiddenElement.target = '_self'; // 
                hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
                document.body.appendChild(hiddenElement); // Required for FireFox browser
                hiddenElement.click(); // using click() js function to download csv file*/
            }else{
                console.log(state + 'Error'+ response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
    
}
 })