({
    init: function(cmp, evt, helper) {
        
        var myPageRef = cmp.get("v.pageReference");
        var id = myPageRef.state.c__recId;
        alert('InNavigation-'+id);
        console.log(amount);
        cmp.set("v.RecordId", id);
        com.set("v.truthy",true);
    }
})