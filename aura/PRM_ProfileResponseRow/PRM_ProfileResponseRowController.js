({
    doInit: function(cmp,event, helper){
        try{
            helper.initialize(cmp,event,helper);
        }catch(err){
            console.log('Error during child component initialization:' +  err);
        }
    },
    
    handleValueChange:function(cmp,event,helper){
        try{
            helper.valueUpdates(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }
    },
    
    handleMultiChange : function(cmp,event,helper){ 
        try{
            helper.multiPicklistChange(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }   
    },
})