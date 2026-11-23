public class FetchQuoteStatus 
{
     public class OrderOutput {
    @InvocableVariable(required=true)
    public String QuoteStatus;
  }

  public class OrderInput {
    @InvocableVariable(required=true)
    public String QuoteNumber;
  }

  @InvocableMethod(label='Get Quote Status')
  public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs) {
    Set<String> orderNumbers = new Set<String>(); 

 
    for (OrderInput orderInput : orderInputs) {
      orderNumbers.add(orderInput.QuoteNumber);
    }

    
    List<SBQQ__Quote__c> orders = 
      [SELECT id, SBQQ__Status__c FROM SBQQ__Quote__c where Name in :orderNumbers];
      
    
    Map<String, String> mapNameStatus = new Map<String, String>(); 
    if (orders.size() > 0) {
        for (SBQQ__Quote__c order : orders) {
          mapNameStatus.put(order.id, order.SBQQ__Status__c);
        }
    }
    
    
    List<OrderOutput> orderOutputs = new List<OrderOutput>();
    for (OrderInput orderInput : orderInputs) {
      OrderOutput orderOutput = new OrderOutput();
      
      
      if (mapNameStatus.containsKey(orderInput.QuoteNumber)) {
          
          orderOutput.QuoteStatus = mapNameStatus.get(orderInput.QuoteNumber);
      } else {
          
          orderOutput.QuoteStatus = 'Quote not found';
      }
      orderOutputs.add(orderOutput);
    }

    return orderOutputs;    
  }
    
 
}