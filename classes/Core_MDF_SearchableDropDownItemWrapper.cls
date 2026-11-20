/**************************************************************************************************************************  
Method Name:        Core_MDF_SearchableDropDownItemWrapper
Description:        This Wrapper class is used to wrap Id and Name
Added By:   Sandesh Hase - 24/05/2022        
Modified By:        Date:       Changes: 
****************************************************************************************************************************/

public class Core_MDF_SearchableDropDownItemWrapper { 

        @AuraEnabled public Id Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        
        
        public Core_MDF_SearchableDropDownItemWrapper(Id sObjectId, String sObjectLabel)
        {
            this.Id = sObjectId;
            this.Name = sObjectLabel;
        }
    
}