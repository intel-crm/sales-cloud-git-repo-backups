({
	formAnalyticsData : function(component, event, helper) {
		var analyticsLibrary = component.find("analyticsLibrary");
        
        var params = event.getParam("arguments");
        params = JSON.parse(JSON.stringify(params));
        
        var messageData = {   
		'analyticsType' : params[0],
		'details'		: params[1],
		'element'		: params[2],
        'href'   		: params[3],
        'pageType'  	: params[4]   
		};
        
        analyticsLibrary.makeAnalyticsCall(messageData);
	},
    
    /**
   	* Forms selectedFilter section in quick search analytics payload.
   	* @param {Object} component  The Lightning component.
  	* @param {Object} event  The event associated with the call.
  	* @param {Object} helper  The component's Helper object.
    */
    formQuickSearchDetail: function(component, event, helper){
        
        var params = event.getParam("arguments");
        params = JSON.parse(JSON.stringify(params));
        var searchFilters = params[0];
        var selectedFilters = params[1];
        var type = params[2];
        var separator = '';
        if(type == 'click'){
           separator = '|'; 
        }else{
            separator = ',';
        }
        
        var catSelected = [];
        
        for(let filter in selectedFilters){
            for(var i=0; i<searchFilters.length; i++){                
                if(filter == searchFilters[i].value)
                    catSelected[i] = selectedFilters[filter][0];        
            }
            
        }
        var detail = '';
        for(let i = 0; i<4 ; i++){
            if(catSelected[i]!=null){
                if(i!=3){
                    detail+= catSelected[i] + separator;
                }else{
                    detail+=catSelected[i];
                }
            }else{
                if(i!=3){
                    detail+= 'NA' + separator;
                }else{
                    detail+='NA';
                }
                
            }
        } 
        
        return detail;
    }
})