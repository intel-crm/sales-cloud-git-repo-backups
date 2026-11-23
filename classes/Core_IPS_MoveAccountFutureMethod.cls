global class Core_IPS_MoveAccountFutureMethod {

  @future 
  public static void updateCase(String caseListJson) {
    System.debug('Method called with: ' + caseListJson);
    List<Case> caseLst = (List<Case>) JSON.deserialize(caseListJson, List<Case>.class);
    //Database.update(caseLst);
    upsert caseLst;
  }
}