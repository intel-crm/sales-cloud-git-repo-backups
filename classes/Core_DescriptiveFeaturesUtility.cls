public class Core_DescriptiveFeaturesUtility {

    
    @AuraEnabled
    public static DescriptiveFeatureslist getDescriptiveFeatureData (){
        DescriptiveFeatureslist descFeaturesList = new DescriptiveFeatureslist ();
        List<DescriptiveFeatures> descriptiveFeaturesData = null;
        List<Core_Feature_Set__c> featureSet = [Select id,Core_Header_Name__c, Core_Feature_BU__c, Core_Feature_Type__c, Core_Feature_Value__c, Core_Display_Order__c, Core_Active__c from Core_Feature_Set__c where Core_Header_Name__c = 'Agilex' and Core_Feature_BU__c = 'CCG' and Core_Active__c = true order by Core_Feature_Type__c ];
        Integer seq = 0;
        
        for( Core_Feature_Set__c fst : featureSet){
            descriptiveFeaturesData.add(new DescriptiveFeatures(fst.Id, seq, fst.Core_Header_Name__c , fst.Core_Feature_BU__c, fst.Core_Feature_Type__c, fst.Core_Feature_Value__c,  fst.Core_Active__c ));
            seq+=1;
            
        }
        
        if(!descriptiveFeaturesData.isEmpty()){
            descFeaturesList.descriptiveFeatures.addAll(descriptiveFeaturesData);
        }
        
        return descFeaturesList;
    }
    
    public class  DescriptiveFeatureslist{
         @AuraEnabled
        public List<DescriptiveFeatures> descriptiveFeatures = new List<DescriptiveFeatures>();
    } 
    
   public class DescriptiveFeatures{
        
        @AuraEnabled
        public String intelPlatform { get; set; } 
       
        @AuraEnabled
        public String platformBU { get; set; } 
       
        @AuraEnabled
        public String featureType { get; set; } 
       
        @AuraEnabled
        public String featureValue { get; set; } 
       
        @AuraEnabled
        public Boolean isActive { get; set; } 
       
        @AuraEnabled
        public Id Id { get; set; } 
        
        @AuraEnabled
        public Integer Sequence { get; set; } 
       
       public DescriptiveFeatures(){ }
       
       public DescriptiveFeatures(Id Id, Integer Sequence,String intelPlatform,String platformBU,String featureType,String featureValue, Boolean isActive){
           
           this.intelPlatform = intelPlatform;
           this.platformBU = platformBU ;
           this.featureType = featureType;
           this.featureValue = featureValue;
           this.isActive = isActive;
           this.Id = Id;
           this.sequence = sequence ;
       }
        
        
    }
}