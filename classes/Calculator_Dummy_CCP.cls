public class Calculator_Dummy_CCP {
    public static Integer add(Integer a, Integer b) {
        if (a == null || b == null) {
            return null;
        }
        return a + b;
    }
    public static Integer multiply(Integer a, Integer b) {
        return (a == null || b == null) ? null : a * b;
    }
    //SFDX Dummy component testing for CCP
}