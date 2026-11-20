/*************************************************************************************************************************************************************************
* Class Name  : Intel_Radio 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
/*public class Intel_Radiobutton extends Intel_Input {
      { type = 'radiobutton'; }
      public String label { get; set; }
      public Boolean recursive { get; set; }
      //public List<CheckboxOption> options { get; set; } { options = new List<CheckboxOption>(); }
    } */
    
 public class Intel_Radio extends Intel_Input {
     public static Boolean isWorking() {
        return true;
    }
    //   { type = 'radio'; }
    //   public String label { get; set; }
    //   public List<Intel_RadioOption> options { get; set; } { options = new List<Intel_RadioOption>(); }
    //   public String valueType {get; set;}
    //   public boolean isChildRequired {get;set;} // psg category mandatory analysis : should not go to devint
    //  public boolean isInlineRadio {get; set;}// psg radio Inline analysis
    }