/*({
    doInit: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        
        if (pageReference && pageReference.state) {
            var recordId = pageReference.state.recordId || pageReference.state.c__recordId;
            var recordtype = pageReference.state.recordtype || pageReference.state.c__recordtype;
            var recordtypeName = pageReference.state.recordtypeName || pageReference.state.c__recordtypeName;
            var recordtypeDeveloperName = pageReference.state.recordtypeDeveloperName || pageReference.state.c__recordtypeDeveloperName;
            
           	if (recordId) component.set("v.recordId", recordId);
            if (recordtype) component.set("v.selrecordtype", recordtype);
            if (recordtypeName) component.set("v.selrecordtypeName", recordtypeName);
            if (recordtypeDeveloperName) component.set("v.selrecordtypeDeveloperName", recordtypeDeveloperName);
        }
        
        console.log('Wrapper Aura Component initialized with:', {
            recordId: component.get("v.recordId"),
            recordtype: component.get("v.selrecordtype"),
            recordtypeName: component.get("v.selrecordtypeName"),
            recordtypeDeveloperName: component.get("v.selrecordtypeDeveloperName")
        });
    }
})*/
({
    doInit: function (component) {
        console.log('-------hii');
        var pageReference = component.get("v.pageReference");

        if (pageReference && pageReference.state) {
            var state = pageReference.state;

            var recordId =
                state.recordId || state.c__recordId;
            var recordtype =
                state.recordtype || state.c__recordtype;
            var recordtypeName =
                state.recordtypeName || state.c__recordtypeName;
            var recordtypeDeveloperName =
                state.recordtypeDeveloperName || state.c__recordtypeDeveloperName;

            if (recordId) component.set("v.recordId", recordId);
            if (recordtype) component.set("v.selrecordtype", recordtype);
            if (recordtypeName) component.set("v.selrecordtypeName", recordtypeName);
            if (recordtypeDeveloperName)
                component.set("v.selrecordtypeDeveloperName", recordtypeDeveloperName);
        }

        console.log("Wrapper Aura initialized:", {
            recordId: component.get("v.recordId"),
            recordtype: component.get("v.selrecordtype"),
            recordtypeName: component.get("v.selrecordtypeName"),
            recordtypeDeveloperName: component.get("v.selrecordtypeDeveloperName")
        });
    }
});