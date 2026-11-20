({
	render: function(component, helper) {
    var ret = this.superRender();
    component.find('input').getElement().setAttribute('autocomplete','off');
    return ret;
  },
  rerender: function(component, helper) {
    var ret = this.superRerender();
    component.find('input').getElement().setAttribute('autocomplete','off');
    return ret;
  }
})