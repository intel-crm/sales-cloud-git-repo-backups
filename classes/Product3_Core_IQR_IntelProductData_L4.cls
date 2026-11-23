//Batch Class by Ayan to process L4 records
public class Product3_Core_IQR_IntelProductData_L4 implements Database.Batchable<Object>, Database.AllowsCallouts,Database.Stateful{
	
    public List<Object> L4ListNew = new List<Object>();
    
    public Product3_Core_IQR_IntelProductData_L4(List<Object> L4List){
        L4ListNew = L4List;
        
    }
    public Iterable<Object> start(database.batchablecontext BC)
    {
  
        return L4ListNew;
        
    }
    public void execute(Database.BatchableContext bc, List<Object> scope)
    { 
      
        
    }

    public void finish(Database.BatchableContext bc)
    { 
        
    }
    
     class ProductL4Details{
        public List<ProductDetails> productDetialsList = new List<ProductDetails>();
    }
    
    class ProductDetails{
        
        public String hierarchy_l1Id = null;
        public String hierarchy_l1Name = null;
        public String hierarchy_l2Id = null;
        public String hierarchy_l2Name = null;
        public String hierarchy_l3Id = null;
        public String hierarchy_l3Name = null;
        public String product_l4Id = null;
        public String product_l4Name = null;
        public String attribute_codeNameText_rawValue = null;
        public String attribute_codeNameText_value = null;
        public String attribute_processorNumber_value = null;
        public String attribute_driveCapacity_value = null;
        // Added By Abhigna
        public String attribute_MaxTDP_rawValue= null;
        public String attribute_MaxTDP_value = null;
        public String attribute_CoreCount_rawValue= null;
        public String attribute_CoreCount_value= null;
        public String attribute_VerticalSegment_rawValue= null;
        public String attribute_VerticalSegment_value = null;
        public String orderinginfo_materialStatusCode_value = null;
        public String orderinginfo_mmid = null;
        public String orderinginfo_division_withoutbracket = null;
        public String orderinginfo_division_withbracket = null;
        public String orderinginfo_group_withoutbracket = null;
        public String orderinginfo_group_withbracket = null;
        public String orderinginfo_empid = null;
        public String orderinginfo_opcode = null;
        public String orderinginfo_customindicator = null;
        public String epmid_l4id_l3id_l2id_l1id = null;
        public String orderinginfo_orderingCode = null;
        public String orderinginfo_familyName = null;
        public String orderinginfo_name = null;
        public String orderinginfo_customCustomerCode = null;
        //Added By Ankit
        public String product_Description = null;
        //Added By Abhigna
        public date product_onMarketDate = null;
        public boolean attribute_VProTechnology_rawValue = null;
        public boolean attribute_VProTechnology_value = null;
    }
}