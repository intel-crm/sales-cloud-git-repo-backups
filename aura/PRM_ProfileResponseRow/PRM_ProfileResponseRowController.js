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
       try{
           helper.DateforOptIn(cmp,event,helper);
           console.log('in update');
        }catch(err){
            console.log('Error during child component initialization:' +  err);
        }
    
        
 
      
    },
     
    
 /* handleValueChangelst:function(cmp,event,helper){
        try{
            helper.valueUpdates1(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }
    },*/
    
    handleMultiChange : function(cmp,event,helper){ 
        try{
            helper.multiPicklistChange(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }   
    },
    
   /* handleOnload: function(cmp,event,helper){ 
        try{
            helper.checkReasonTest(cmp,event,helper);
            console.log('in update');
        }catch(err){
            console.log('Error during child component initialization:' +  err);
        }
    },*/
  
  
})