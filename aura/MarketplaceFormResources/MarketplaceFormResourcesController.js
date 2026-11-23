({

	doInit : function(component, event, helper) {
    // set rows from formData value (input v.value)
    // NOTE: an alternate option is to get the rows from the server
    // in this case the doNotSave option should be set to true
    // ie. helper.getResources(component).then(function(rows) { ... });
    component.set('v.rows', (component.get('v.value') || []).map(function(res) {
      return {
        id: res.Id,
        title: res[component.get('v.titleField')],
        url: res[component.get('v.urlField')],
        type: res[component.get('v.typeField')]
      };
    }));
    component.set('v.rowsSet', true);
    component.set('v.max', 5);
    if (component.get('v.required') && component.get('v.min') < 1) {
      component.set('v.min', 1);
    }
    helper.checkValidity(component);
    helper.updateForm(component);
  },

  handleOpenModal: function(component, event, helper) {
    component.set("v.isOpen", true);
    $A.util.addClass(document.body,'modal-open-no-scroll');
    // add body overrride on css
    document.body.style.overflowY = 'hidden';
  },

  handleModalClose : function(component, event, helper) {
    $A.util.addClass(document.body,'modal-open-no-scroll');
    // add body overrride on css
    document.body.style.overflowY = 'hidden';
  },

  handleRowsChange : function(component, event, helper) {
    var rows = component.get('v.rows');
    if (component.get('v.rowsSet')) {
      var value = rows.map(function(row) {
        var res = { Id: row.id };

        // map fields back to api names
        res[component.get('v.titleField')] = row.title;
        res[component.get('v.urlField')] = row.url;
        res[component.get('v.typeField')] = row.type;

        return res;
      });
      component.set('v.value', value);

      // NOTE: an alternate option is to save the resources to the server here.
      // In this case the doNotSave option should be set to true
      // so the formData does not update
      // helper.saveResources(component).then(function(resources) { ... });

      component.set('v.touched', true);
      helper.checkValidity(component);
      helper.updateForm(component);
    }
  },

})