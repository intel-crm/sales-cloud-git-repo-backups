({    
    doInit : function(component,event,helper){
        var url = window.location.href;
        url = url.replace('page/home','n/PRM_Admin_Registration');
        component.set('v.url',url);
    },
})