({
	init : function(component, event, helper) {
		var myPageRef = cmp.get("v.pageReference");
        var licneserecordid = myPageRef.state.c__licneserecordid;
        cmp.set("v.licneserecordid", licneserecordid);
        var activatecodeonload = myPageRef.state.c__activatecodeonload;
        cmp.set("v.activatecodeonload", activatecodeonload);
        var webdisplayFlag = myPageRef.state.c__webdisplayFlag;
        cmp.set("v.webdisplayFlag", webdisplayFlag);c
        alert('licneserecordid>>'+licneserecordid+'activatecodeonload>>'+activatecodeonload
             +'webdisplayFlag>>'+webdisplayFlag);
        
	}
})