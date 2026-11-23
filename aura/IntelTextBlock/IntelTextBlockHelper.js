({
	getDisplaySection : function(component) {
		var introSection = component.get('v.introSection') || '';
        var moreSection = component.get('v.moreSection') || '';
        var showMoreSection=component.get('v.showMoreSection');
        var displaySection = introSection;
       if (component.get('v.showMore')) {
            displaySection = moreSection;
          }
        //Added code to expand the overview section for Basic profile
        else if(component.get('v.showMoreSection')==true)
        {
              var displaySection = introSection + moreSection;
              component.set('v.showMoreSectionforEnhanced',false);//to hide show more link
             
        }
        
     return displaySection;
	},
   
})