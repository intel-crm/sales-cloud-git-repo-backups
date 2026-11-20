({    
    doInit : function(component,event,helper){
        var url = window.location.href;
        var ipaRefresh = $A.get("$Label.c.PRM_IPARefresh");
        if(ipaRefresh){
            url = url.replace('page/home','n/Admin_Registration_Upgraded');
        }else{
            url = url.replace('page/home','n/PRM_Admin_Registration');
        }
        component.set('v.url',url);
    },
})