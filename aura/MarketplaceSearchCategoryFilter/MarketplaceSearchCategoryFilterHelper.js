({
    // [Hemanta] Unsure whether we need this method as it's currently unused
    recursivelyCloseChildren : function(component) {
        component.set('v.open', false);
        var children = component.find('treenode'), helper = this;
        if (children && children.length) {
            children.forEach(function(cmp) {
                helper.recursivelyCloseChildren(cmp);
            });
        }
    },
    
  /*  sendCategoryAnalyticsData: function(component){
        var currentState = component.get('v.state');
        var analyticsData = component.find('analyticsData');
        if(currentState.selectedCategoryId != null){
            var type = 'filter';
            var element = 'search-panel-filter';
            var detail = currentState.searchResultsCount + '|'+ ((currentState.searchString=='')?'no keyword':currentState.searchString) + '|' + currentState.selectedCategoryId;
            analyticsData.formAnalyticsData(type,detail,element);
        }
        
    }*/
})