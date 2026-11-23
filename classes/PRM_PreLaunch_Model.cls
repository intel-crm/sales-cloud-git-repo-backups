global class PRM_PreLaunch_Model {
    
   global  class WithoutSubComponent
    {
        public String type;
        public String faIcon;
        public String imageUrl;
        public String title;
        public String body;
        public List<Step> steps;
    }
    
    public class LinkData
    {
        public String label;
        public String externalUrl;
        public String communityPage;
        public String objectPage;
        public String recordId;
    }
    
    public class Step
    {
        public String stepId;
        public String component;
        public String title;
        public String description;
        public String completedTitle;
        public String completedDescription;
        public boolean completed;
        public String modalTitle;
        public LinkData linkData;
    }
}