({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc'; 
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", data);
    }, 
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    downloadCSV: function(cmp, objectRecords) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider =  '\n';
        keys = ['Id','FullName','Active','PermissionTypeName','Type','EmployeeTypeCode','LastLoginDate','FrozenStatus'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }  
                if(objectRecords[i]){
                    if(objectRecords[i][skey]){
                        csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                    }else{
                         csvStringResult += '"'+' '+'"';
                    }
                   
                }else{
                    csvStringResult += '"'+' '+'"';
                }
                
                counter++;
                
            } 
            csvStringResult += lineDivider;
        } 
        return csvStringResult;    
        
    },
    getUserInfoData : function(component){
       		var action = component.get("c.getUserInfoData");
            action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            console.log(respnse.response.getReturnValue());
            }
                });
$A.enqueueAction(action);

                
    },
})