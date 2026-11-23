({
  doInit: function(component, event, helper) {
    helper.setCommunityDisplay(component); 
    helper.helperMethod(component, event, helper);   
    component.set('v.headingLabel',$A.get("$Label.c.PMP_MP_FAQ_Heading"));
  },
 

  afterRender  : function(cmp, helper){
		this.superAfterRender();
        var urlString = window.location.href;
        setTimeout(function(){
        
    },0); 
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
  },

});