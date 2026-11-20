({
    doInit: function(component, event, helper)  {
        //This helper function is used to check session type and redirects user to external url
        helper.getCurrentSessionType(component);
    }
});