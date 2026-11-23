@isTest
public class CN_PMD_Test {
    
static testMethod void validategetCalculatedValue () 
{
Integer a=CN_PMD.getCalculatedValue();
System.assertEquals(10, a);
}
}