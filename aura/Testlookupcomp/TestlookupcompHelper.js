({
    doInit: function(component,event,helper){
        var userList = ($A.get("$Label.c.testlabelVD")).split(";");
        
        component.set('v.userIdList', userList);
        var userIds = "@quote;" + userList.join("@quote;,@quote;") + "@quote;";
        component.set('v.vdUserList', userIds);
        
        var searchCriteria = 'Id IN (' + userIds + ')';
        component.set('v.ownerSearchCriteria', searchCriteria);
    },
})