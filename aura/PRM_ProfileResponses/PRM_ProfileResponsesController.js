({
    doInit: function(cmp,event,helper) {
        try{
            helper.initialize(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }
        try{
            helper.A(cmp,event,helper);
        }catch(err){
            console.log('Error during component initialization:' +  err);
        }
    },
    saveResp:function(cmp,event,helper){
         try{
            helper.showSpinner(cmp,event,helper);
            helper.save(cmp,event,helper);
           // setTimeout(function(){window.location.reload();},200);
            //helper.updateButton(cmp,event,helper);
          //  helper.showToast(cmp,event,helper); 
        }catch(err){
            console.log('Error during save response:' +  err);
        }
    },
    clearResponse:function(cmp,event,helper){
         try{
            helper.showSpinner(cmp,event,helper); 
            helper.clear(cmp,event,helper);
            //helper.updateButton(cmp,event,helper);
        }catch(err){
            console.log('Error during clear response:' +  err);
        }
    },
})