({
    getData : function(cmp) {
        //console.log('My data inside Init', JSON.stringify(cmp.get("v.mydata")));
        
        //var idVal =[]; 
        var idVal= cmp.get("v.claimsData"); //tostring.split(',')
        console.log('Id Values Type', typeof cmp.get("v.claimsData"));
        console.log('Type of Var after parse', typeof idVal);
        var action = cmp.get('c.getClaims');
        //console.log('Params value',cmp.get("v.claimsData"));
       //var idValue = JSON.parse(JSON.stringify(idVal));
        console.log('Id Value after parse', idVal);
        action.setParams({'ids': idVal}); 
        //action.setParams({pfcLst: cmp.get("v.claimsData")}); 
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
                console.log('Inside success', JSON.stringify(response.getReturnValue()));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action); 
    
   }
})