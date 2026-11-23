public class Quest_Dummy_Calculator {
    public static Integer add(Integer a, Integer b) {
    //Testing
        return a + b;
    }
    
    public static Integer multiply(Integer a, Integer b) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return a * b;
    }
}