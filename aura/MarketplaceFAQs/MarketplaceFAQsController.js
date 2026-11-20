({
  doInit: function(component, event, helper) {
     
     helper.helperMethod(component, event, helper);
    
  },
  handlePageEvent: function(component, event, helper) {
    if (event.getParam("type") == "scrollToFAQ") {
      var payload = event.getParam("payload");

      var rect = component.getElement().getBoundingClientRect();
      var scrollTop = window.pageYOffset || document.documentElement.scrollTop;

      // Open accordion
      var accordion = component.find("accordion");
      accordion.forEach(function(elem) {
        if (elem.get("v.id") == payload.questionId) {
          elem.set("v.open", true);
        }
      });
      window.scrollTo(0, rect.top + scrollTop);
    }
  }
});