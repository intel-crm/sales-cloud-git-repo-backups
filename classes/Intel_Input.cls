/*************************************************************************************************************************************************************************
* Class Name  : Intel_Input 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
public virtual class Intel_Input {

      public Boolean doNotSave { get; set; } // for DEVELOPMENT, skips saving
      public String type { get; set; } // REQUIRED (see subclass types below)
      public String apiName { get; set; } { apiName = 'offering'; } // REQUIRED object name, offering by default
      public String fieldName { get; set; } // OPTIONAL field name, ie. 'Tagline__c' (if apiName is complex ie. 'specifications' you might not want a field name)
      public Boolean required { get; set; } // OPTIONAL this field is required (for Front End UI)
      public String errorMessage { get; set; } // OPTIONAL error message text
      public Integer layoutItemSize { get; set; } // OPTIONAL - 1-12 (column flex layout for mobile, desktop) -- 12 is full width
      public Integer layoutItemMediumDeviceSize { get; set; } // OPTIONAL - 1-12 (column flex layout for desktop)
      public Boolean disabled { get; set; } // for DEVELOPMENT, disable
      public String additionalText { get; set; } //added for pre release requirement
}