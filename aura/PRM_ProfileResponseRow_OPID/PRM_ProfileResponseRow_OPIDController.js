({
    doInit: function(cmp,event, helper){
        try{
            helper.initialize(cmp,event,helper);
        }catch(err){
            console.log('Error during opid child component initialization:' +  err);
        }
    },
    
    handleValueChange:function(cmp,event,helper){
        try{
            helper.valueUpdates(cmp,event,helper);
        }catch(err){
            console.log('Error during opid component initialization:' +  err);
        }
       try{
            helper.DateforOptIn(cmp,event,helper);
        }catch(err){
            console.log('Error during child component initialization:' +  err);
        }

    },
    
})