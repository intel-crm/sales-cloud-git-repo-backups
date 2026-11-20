({
	render : function(component, helper) {
        const ret = this.superRender();
        // do custom rendering here
        return ret;
    },

    //Added by Ajay for form validation and tab content logic
    rerender : function(component, helper){
        this.superRerender();
        helper.handleTabContentVisibility(component, helper, component.get('v.currentStep'));
    },
})